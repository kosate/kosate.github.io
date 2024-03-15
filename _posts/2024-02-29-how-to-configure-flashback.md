---
layout: single
title: CDB환경에서 Flashback Database설정 방법
date: 2024-02-29 21:00
categories: 
  - Oracle
author: 
books:
 - multitenant
tags: 
   - Oracle
   - flashback database
   - multitenant
   - 19c
excerpt : Multitenant환경에서 Flashback Database 설정하는 절차에 대해서 정리하였습니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 테스트 환경 

|서버환경|서버종류|OS종류|OS버전|DB타입|DB버전|기타|
|-|-|-|-|-|-|-|
|OCI|VM(x86)|Oracle Linux|8.7|Oracle|19.3||

## 개요

Multitenant환경에서도 기존 환경(Non-CDB)과 동일하게 Flashback Database기능을 사용할수 있습니다. 
CDB레벨, PDB레벨에서 Flashback Database수행하는 절차에 대해서 알아보겠습니다. 

## Flashback Database 고려사항

Flashback Database를 설정하기 위해서는 CDB레벨에서 Archive Mode가 설정되어 있어야하고, Flashback log가 저장되는 Fast recovery area가 설정되어 있어야합니다. 

1. Archive Mode 설정(archived log 생성하도록 설정)
2. Fast Recovery Area 설정(flashback log 위치를 설정)
3. Flashback logging설정(CDB에서 설정)

### 1. Archive Mode 설정
Archive Mode 설정이 되어 있는지 확인합니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- archive mode확인 
archive log list
```

Archive Mode 확인 로그입니다. `Database log Mode`가 Archive Mode로 설정되어 있습니다. 
```sql
SQL> archive log list
Database log mode              Archive Mode
Automatic archival             Enabled
Archive destination            USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence     1
Next log sequence to archive   9
Current log sequence           9
```

만약 Archive Mode가 아닐경우 아래와 같이 Archive Mode로 변경작업합니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
-- DB중지
shutdown immediate;
-- DB를 mount모드로 실행
startup mount;
-- Archived log 저장위치 지정
alter system set log_archive_dest_1='location=USE_DB_RECOVERY_FILE_DEST';
-- Archive Mode 설정
alter database archivelog;
-- Archive Mode 설정 확인
archive log list
-- DB를 open수행
alter database open;
```

### 2. FRA(Fast Recovery Area) 설정

Flashback Database를 설정하면 Flashback log가 생성이 됩니다. 
데이터가 변경될때 변경된 Block의 before Copy본을 Flashback log로 저장합니다.  
flashback Database를 수행하면 Flashback log를 이용하여 변경된 Block을 rewind하고 archived log로 시점까지 복구하게 됩니다.

Flashback log가 저장되는 스토리지에 대한 필요용량을 계산할수 있습니다.

- FRA 설정시 고려사항
  - Flashback Log 저장 공간 : 1일 redo발생량(예 : 3.5G) * db_flashback_retention_target (예 : 10일) = 총 35G필요
  - 변경되는 block갯수가 더 영향을 받음.
  - db_recovery_file_dest_size 산정 : 현재 설정된 FRA영역에서 위에서 계산한 Flashback Log 저장 공간을 추가합니다.

- FRA 연관 파라미터
  - db_flashback_retention_target : FRA 보관기간(단위 : 분) (default = 1440 min = 1 Day )
  - db_recovery_file_dest :  FRA 저장 위치
  - db_recovery_file_dest_size : FRA 저장 크기
  
※ FRA에는 Flashback log뿐만아니라 online redolog, archived log, rman 백업정보가 포함되므로 전체 크기를 잘 계산해서 조정해야합니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="30 sec" %}
```sql
-- 1일 보관으로 설정
alter session set db_flashback_retention_target=1440;
-- FRA 공간 지정
alter session set db_recovery_file_dest=/oradata/fast_recovery_area;
-- FRA 공간의 크기 지정
alter session set db_recovery_file_dest_size=60G;
```

### 3. FlashBack logging 설정

Flashback log가 생성되도록 CDB레벨에서 Flashback Database설정을 합니다.
(CDB에서 Flashback Database를 설정해야 PDB에서 Flashback 수행이 가능합니다. )
Flashback Database는 데이터베이스가 open상태에서 수행가능합니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- Flashback 설정(one)
alter database flashback on;
-- Flashback 설정여부 확인
select flashback_on from v$database;
```

수행결과입니다. Flashback 설정한 SCN번호와 자동으로 Flashback log buffer를 할당합니다. 

```sql
SQL> alter database flashback on;
Database altered.

-- alert.log
2024-03-13 00:55:16.180000 +00:00
alter database flashback on
Starting background process RVWR
RVWR started with pid=89, OS id=13314
Allocating 25658464 bytes in shared pool for flashback generation buffer.
Allocated 25658464 bytes in shared pool for flashback generation buffer
Flashback Database Enabled at SCN 49181007
Completed: alter database flashback on

SQL> select flashback_on from v$database;
FLASHBACK_ON
------------------
YES
```

**FlashBack log 모니터링**

FlashBack log의 사용량을 모니터링할수 있습니다. 기본적으로 retention정책에 따라 자동으로 재사용되지만, 업무가 변경될경우 Flashback log가 증가될수 있습니다. 

V$FLASHBACK_DATABASE_LOG과 V$FLASHBACK_DATABASE_STAT를 참고하여 현재 적절하게 용량이 할당되어 있는지 확인하고, 용량이 여유가 있을경우 FRA보관주기(DB_FLASHBACK_RETENTION_TARGET)을 늘리거나, 용량이 부족할경우 스토리지 공간을 확보후에 db_recovery_file_dest_size를 증가시킵니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
-- Flashback log의 가장 오래된 TIME과 SCN번호를 확인 
select oldest_flashback_scn, oldest_flashback_time  from  v$flashback_database_log;
-- Flashback log의 통계정보에 저장됨, Flashback 크기추이를 확인가능
select flashback_data, db_Data, redo_data, estimated_flashback_size from v$flashback_database_stat;
```

수행결과입니다.

```sql
SQL> select oldest_flashback_scn, oldest_flashback_time  from  v$flashback_database_log;
OLDEST_FLASHBACK_SCN OLDEST_FLASHBACK_TI
-------------------- -------------------
            48197666 2024-01-01 08:03:51
SQL> select flashback_data, db_Data, redo_data, estimated_flashback_size from v$flashback_database_stat;
FLASHBACK_DATA    DB_DATA  REDO_DATA ESTIMATED_FLASHBACK_SIZE
-------------- ---------- ---------- ------------------------
      86769664   72695808   74130944                        0
```

**Flashback logfile 관리**

Flashback log는 Flashback logfile로 생성이 됩니다. Flashback logfile은 기본 online redo log 사이즈를 기반으로 생성됩니다. 

online redo log의 평균 사이즈가 200M일경우 Flashaback logfile도 200M로 생성됩니다. 
관련된 파라미터는 _flashback_size_based_on_redo 입니다. 기본값은 true로 되어 있기 때문에 redo기반으로 flashback logfile사이즈를 생성합니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- online redo log 평균크기 확인
select avg(bytes) from v$log;
-- flashback logfile 크기 확인
select name, log#, thread#,  bytes from V$flashback_database_logfile;
```

수행결과입니다.
```sql
SQL> select avg(bytes) from v$log;
AVG(BYTES)
----------
 209715200

SQL> select name, log#, thread#,  bytes from V$flashback_database_logfile;
NAME                                                                    LOG#    THREAD#      BYTES
----------------------------------------------------------------- ---------- ---------- ----------
/oradata/fast_recovery_area/CDB1/flashback/o1_mf_ls4wh6n4_.flb             1          1  209715200
/oradata/fast_recovery_area/CDB1/flashback/o1_mf_ls4wh7n9_.flb             2          1  209715200
....
/oradata/fast_recovery_area/CDB1/flashback/o1_mf_lyxs2g4f_.flb            10          1  209715200
/oradata/fast_recovery_area/CDB1/flashback/o1_mf_lz1xyy3f_.flb            11          1  209715200
```

Flashback logfile사이즈가 작아서 I/O가 많이 발생되거나, reclaim작업이 자주발생될경우, Flashback logfile 사이즈를 메뉴얼로 관리할수 있습니다.
Flashback logfile사이즈를 최소 값을 수정하면 신규로 생성되는 Flashback logfile사이즈부터 반영됩니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
--Flashback logfile 최소 사이즈 변경
alter system set "_db_flashback_log_min_size"=524288000;
```

Flashback logfile파일 만드는 작업도 오버헤드가 있을수 있으므로 미리 Flashback logfile를 지정된 사이즈만큼 만들어 놓을수 있습니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- Flashback log 최소 할당 사이즈 변경  
alter system set "_db_flashback_log_min_total_space"=10G;
```

**Flashback Log buffer관리**

Flashback log에 변경된 block을 저장하는 역할을 담당하는 백그라운드 프로세스가 RVWR(Recovery Writer Process)입니다. DML수행되어 데이터가 발생될때 SGA영역에 있는 Flasback log buffer에 변경전 Block을 저장하고, 변경전/후 row정보를 Redo log buffer에 저장합니다. 

Flasbhack log buffer에 있는 데이터는 RVWR프로세스가 Flashback logfile에 Write하고, Log buffer에 있는 데이터는 LGWR(log Writer)가 online redo logfile에 write합니다. 

Flashback Database설정을 하면 Flashback 처리하는 로직이 추가 수행되어 부하가 추가적으로 발생할수 밖에 없겠습니다.

관련 Wait 이벤트는 아래와 같습니다. 

- Flashback 관련 Wait 이벤트 
  - flashback log file sync :  RVWR가 Flashback logfile에 write할때 발생되는 이벤트
  - flashback buf free by RVWR : RVWR가 flashback buffer를 cleanup 할때 발생되는 이벤트

flashback log file sync이벤트가가 자주 확인될경우 Flashback log영역의 Disk성능을 확인합니다.
flashback buf free by RVWR이벤트의 경우 Flahsback log buffer사이즈가 작아서 너무 자주 flush가 되어 발생되는지 확인하거나 Flashback log영역의 Disk성능도 확인합니다.

Flashback log buffer사이즈 확인하는 방법입니다. SGA의 Shared pool에 위치해있습니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- CDB의 Shared pool사이즈 확인
select sum(bytes) From v$sgastat where pool = 'shared pool' and con_id = 1;
-- flashback log fuffer사이즈 확인
SELECT pool, name,  bytes FROM v$sgastat WHERE name in ( 'flashback generation buff','log_buffer');
```

수행결과입니다. 

현재 Flashback log buffer 크기는 redo log buffer에 비해 약 45%해당되는 크기로 데이터 변경이 많을경우 flashback log buffer부족으로 병목 현상가능성이 있습니다. 

```sql
SQL> select sum(bytes) From v$sgastat where pool = 'shared pool' and con_id = 1;
SUM(BYTES)
----------
 495762736
SQL> SELECT pool, name,  bytes FROM v$sgastat WHERE name in ( 'flashback generation buff','log_buffer');
POOL           NAME                                                                   BYTES
-------------- ----------------------------------------------------------------- ----------
               log_buffer                                                          54423552
shared pool    flashback generation buff                                           25658464 
```

Flashback log buffer가 부족하면 아래와 같이 히든파라미터로 buffer 크기를 변경할수 있습니다.
flashback log buffer의 최대크기는 SGA에서 연속된 메모리공간인 granule이상을 사용할수 없습니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
select ksppinm, ksppstvl from x$ksppi x, x$ksppcv y where x.indx = y.indx and x.ksppinm in ('_ksmg_granule_size' );
-- DB재기동이 필요합니다. 
alter system set "_flashback_generation_buffer_size"=67108864 scope=spfile;
shutdown immediate;
startup
SELECT pool, name,  bytes FROM v$sgastat WHERE name in ( 'flashback generation buff','log_buffer');
```

수행결과입니다.

```sql
SQL> select ksppinm, ksppstvl from x$ksppi x, x$ksppcv y where x.indx = y.indx and x.ksppinm in ('_ksmg_granule_size');
KSPPINM              KSPPSTVL
-------------------- ----------
_ksmg_granule_size   67108864

SQL> alter system set "_flashback_generation_buffer_size"=67108864 scope=spfile;
System altered.
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
SQL> startup
ORACLE instance started.
Total System Global Area 2.1475E+10 bytes
Fixed Size                 12685056 bytes
Variable Size            1677721600 bytes
Database Buffers         1.9730E+10 bytes
Redo Buffers               54423552 bytes
Database mounted.
Database opened.
SQL> SELECT pool, name,  bytes FROM v$sgastat WHERE name in ( 'flashback generation buff','log_buffer');
SQL>
POOL           NAME                            BYTES
-------------- -------------------------- ----------
               log_buffer                   54423552
shared pool    flashback generation buff    63749952
```

## Flashback 수행

CDB에서 Flashback Database설정을 하면 CDB레벨 혹은 PDB레벨에서 Flasbhack 작업이 가능합니다. 

Flashback수행을 위한 몇가지 고려사항들입니다. 

- Current Control File에서 수행
  - restore나 재생성하면 모든 Flashback log정보가 discard됨.

- PDB에서의 고려사항
  - COMPATIBLE 파라미터가 12.2.0.0이상에서 PDB레벨에서 Flashback database 설정가능
  - PDB에서 Flashback Database작업을 수행하려면 해당 PDB는 close상태여야함. (다른 PDB는 관계없음)
  - CDB에서 PDB작업을 수행

Flashback 수행을 위해서는 TIME 혹은 SCN기반으로 할수 있지만, Restore Point를 이용하여 수행할수 있습니다. 

Flashback Database수행하는 절차는 아래와 같습니다. 

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
FLASHBACK DATABASE TO SCN <scn>; 
FLASHBACK DATABASE TO TIMESTAMP <timestamp>;
FLASHBACK DATABASE TO RESTORE POINT “before_update” ;
```

Restore Point을 두가지로 구분할수 있습니다. 

|구분|Normal restore Point|Guaranteed restore point|
|--|--|--|
|보장여부|데이터베이스가 해당 시점으로 flashback될수 있다는것을 보장하지 않음|데이터베이스가 해당 시점으로 flashback될수 있다는것을 보장합니다. |
|FRA공간부족시|Flashback log가 재사용되거나 삭제될수 있습니다.|Flashback log가 삭제되는것을 허용하지 않습니다.|
|Controlfile| Control file에서 aging out될수 있습니다| Control file에서 aging out되지 않습니다|
|시나리오|테이블에 대한 PITR 작업시 혹은 특정 시점으로 Flashback database수행합니다.|반복적인 테스트를 하거나, Snapshot Standby 테스트할때 사용됩니다.|


**아래 예제에서는 Guaranteed restore point(GRP)를 이용하여 수행하였습니다.**


### 1. CDB레벨에서 Flasback 수행

CDB에서 Flasbhack을 통해서 rewind을 할경우 CDB위에 기동되고 있는 모든 PDB가 같이 rewind됩니다. 주위가 필요합니다.

**CDB레벨에서 resotre point를 설정합니다.**

`BEFORE_UPDATE` 라는 GRP를 생성하였습니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
-- GRP 설정
create restore point BEFORE_UPDATE guarantee flashback database;
-- GRP설정 여붛 확인
select name, scn, guarantee_flashback_database, pdb_restore_point, con_id  from v$restore_point;
```

수행결과입니다.

```sql
$> create restore point BEFORE_UPDATE guarantee flashback database;
Restore point created.

-- alert.log
2024-03-13 02:42:02.647000 +00:00
Created guaranteed restore point BEFORE_UPDATE

SQL> select name, scn, guarantee_flashback_database, pdb_restore_point, con_id  from v$restore_point;
NAME                        SCN GUA PDB     CON_ID
-------------------- ---------- --- --- ----------
BEFORE_UPDATE          49195188 YES NO           0
```

**Flashback 수행을 통해서 DB전체를 rewind하겠습니다.**

생성되어 있는 `BEFORE_UPDATE` restore point를 이용하여 flashback 수행합니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
conn / as sysdba
shutdown immediate;
startup mount;
select name, scn, guarantee_flashback_database, pdb_restore_point, con_id  from v$restore_point;
flashback database to restore point BEFORE_UPDATE;
alter database open resetlogs;
select to_char(resetlogs_change# - 2) from v$database;
select current_scn From v$database;
```

수행결과입니다. SCN 49195188까지 복구가 되었습니다. 

```sql
SQL> flashback database to restore point BEFORE_UPDATE;
Flashback complete.

-- alert.log 
2024-03-13 02:47:49.480000 +00:00
flashback database to restore point BEFORE_UPDATE
Flashback Restore Start
Flashback Restore Complete
Flashback Media Recovery Start
 Started logmerger process
max_pdb is 10
Parallel Media Recovery started with 8 slaves
Recovery of Online Redo Log: Thread 1 Group 3 Seq 13 Reading mem 0
  Mem# 0: /oradata/CDB1/onlinelog/o1_mf_3_l4nw6jwr_.log
  Mem# 1: /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_3_l4nw6k6l_.log
Incomplete Recovery applied until change 49195189 time 03/13/2024 02:42:02
Flashback Media Recovery Complete
Completed: flashback database to restore point BEFORE_UPDATE

SQL> alter database open resetlogs;
Database altered.

-- alert.log
2024-03-13 02:48:20.400000 +00:00
alter database open resetlogs
RESETLOGS after incomplete recovery UNTIL CHANGE 49195189 time 03/13/2024 02:42:02
...
Clearing online log 1 of thread 1 sequence number 11
Clearing online log 2 of thread 1 sequence number 12

SQL> SELECT TO_CHAR(RESETLOGS_CHANGE# - 2) FROM V$DATABASE;
TO_CHAR(RESETLOGS_CHANGE#-2)
----------------------------------------
49195188
SQL> select current_scn From v$database;
CURRENT_SCN
-----------
   49197024
SQL>
```

### 2. PDB레벨에서 Flasback 수행

**PDB레벨에서 restore point를 설정합니다.**

PDB레벨에서 restore point를 설정합니다. CDB레벨에서 restore point설정하는 방법과 동일합니다.

{% include codeHeader.html runas="PDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
alter session set container=pdb1;
create restore point PDB1_GRP_BEFORE_UPGRADE guarantee flashback database;
select name, scn, guarantee_flashback_database, pdb_restore_point, con_id  from v$restore_point;
```

수행결과입니다.

```sql 
SQL> alter session set container=pdb1;
SQL> create restore point PDB1_GRP_BEFORE_UPGRADE  guarantee flashback database;

--alert.log
2024-03-13 03:05:02.898000 +00:00
Created guaranteed restore point PDB1_GRP_BEFORE_UPGRADE

SQL> select name, scn, guarantee_flashback_database, pdb_restore_point, con_id  from v$restore_point;
NAME                                  SCN GUA PDB     CON_ID
------------------------------ ---------- --- --- ----------
BEFORE_UPDATE                    49195188 YES NO           0
PDB1_GRP_BEFORE_UPGRADE          49200036 YES YES          3
```


**Flashback 수행을 통해서 PDB를 rewind하겠습니다.**

Flasbhack 수행하는 방법으로 두가지가 있습니다.
1. PDB레벨에 생성한 Restore Point(PDB1_GRP_BEFORE_UPGRADE)를 이용하여 Flashback수행합니다.
2. CDB레벨에 생성된 Restore Point(BEFORE_UPDATE)을 이용하여 Flashback 수행합니다.

**PDB의 Restore point를 이용**

우선 PDB에 생성되어 있는 `PDB1_GRP_BEFORE_UPGRADE` restore point를 이용하여 flashback 수행합니다.
Flashback 수행은 CDB에서 수행합니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
conn / as sysdba
alter pluggable database pdb1 close immediate;
flashback pluggable database pdb1 to restore point PDB1_GRP_BEFORE_UPGRADE;
alter pluggable database pdb1 open resetlogs;
alter session set container=pdb1;
select to_char(resetlogs_change# - 2) from v$database;
select current_scn From v$database;
```

수행결과입니다. 

```sql
SQL> flashback pluggable database pdb1 to restore point PDB1_GRP_BEFORE_UPGRADE;
Flashback complete.

-- alert.log
2024-03-13 03:11:54.998000 +00:00
flashback pluggable database pdb1 to restore point PDB1_GRP_BEFORE_UPGRADE
Flashback Restore Start
Restore Flashback Pluggable Database PDB1 (3) until change 49197143
Flashback Restore Complete
Flashback Media Recovery Start
Serial Media Recovery started
max_pdb is 10
Recovery of Online Redo Log: Thread 1 Group 1 Seq 1 Reading mem 0
  Mem# 0: /oradata/CDB1/onlinelog/o1_mf_1_l4nw6jvq_.log
  Mem# 1: /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_1_l4nw6k5b_.log
Incomplete Recovery applied until change 49200037 time 03/13/2024 03:05:02
Flashback Media Recovery Complete
Flashback Pluggable Database PDB1 (3) recovered until change 49200037
Completed: flashback pluggable database pdb1 to restore point PDB1_GRP_BEFORE_UPGRADE

SQL> alter pluggable database pdb1 open resetlogs;
Pluggable database altered.

-- alert.log
2024-03-13 03:12:55.245000 +00:00
alter pluggable database pdb1 open resetlogs
Online datafile 26
Online datafile 12
...
Completed: alter pluggable database pdb1 open resetlogs
2024-03-13 03:12:57.582000 +00:00
Buffer Cache Full DB Caching mode changing from FULL CACHING ENABLED to FULL CACHING DISABLED
Full DB Caching disabled: DEFAULT_CACHE_SIZE should be at least 1941 MBs bigger than current size.

SQL> select to_char(resetlogs_change# - 2) from v$database;
TO_CHAR(RESETLOGS_CHANGE#-2)
----------------------------------------
49200036
SQL> select current_scn From v$database;
CURRENT_SCN
-----------
   49201283
SQL>
```

**CDB의 Restore point를 이용**

CDB에 생성되어 있는 `BEFORE_UPDATE` restore point를 이용하여 flashback 수행합니다.
Flashback 수행은 CDB에서 수행합니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="60 sec" %}
```sql
conn / as sysdba
alter pluggable database pdb1 close immediate;
flashback pluggable database pdb1 to restore point BEFORE_UPDATE;
alter pluggable database pdb1 open resetlogs;
alter session set container=pdb1;
select current_scn From v$database;
```

수행결과는 PDB레벨 수행결과과 비슷합니다. 복구시점의 SCN은 restore point와 동일합니다.


**Flashback 수행 여부 확인**

Flashback 수행시 데이터 변경량에 따라서 다소 시간이 소요될수 있습니다. 진행사항에 대해서 모니터링하여 수행 완료시간을 예측해볼수 있습니다.

{% include codeHeader.html runas="CDB" copyable="true" codetype="sql" elapsedtime="5 sec" %}
```sql
SELECT sofar, totalwork, units FROM v$session_longops WHERE opname = 'Flashback Database';
```

오라클 메뉴얼 상으로는 작업시간에 대해서 언급이 되어 있습니다. 
 - 400 GB의 대량의 배치 작업일경우 - 5분이내 처리
 - 8G의 OLTP 작업일 경우 - 2분 이내 처리

- 참고문서 : [Oracle Flashback Performance Observations](https://docs.oracle.com/en/database/oracle/oracle-database/19/haovw/oracle-flashback-best-practices.html#GUID-D489DBA7-609B-4D81-AD59-097086A52B59){:target="_blank"}


## 마무리 

Multitenant환경에서 flashback 설정 및 사용방법에 대해서 알아보았습니다. 
CDB레벨에서 전체 Flashback 설정을 관리하고 PDB레벨에서는 개별 PDB별로 flashback를 수행할수 있습니다. 

Guaranteed Restore Point를 사용할경우 flashback log가 삭제되지 않으므로 스토리지에 대한 용량 관리가 필요합니다.  특별한 경우가 아니면 Guaranteed Restore Point사용할 필요 없겠습니다. 

Flashback은 주로 DataGuard로 구성된 Standby DB에서 설정합니다. Snapshot Standby와 같은 기능을 사용하기 위해서입니다. 혹은 Primary DB에서 데이터가 잘못되었을경우 Standby DB에서 복구하여 사용할수 있습니다. 

## 참고문서

- My Oracle Support문서
  - How To Calculate the Size of the Generated Flashback Logs (Doc ID 761126.1)
  - Flashback Database Best Practices & Performance (Doc ID 565535.1)

- Documents
  - <https://docs.oracle.com/en/database/oracle/oracle-database/19/rcmrf/FLASHBACK-DATABASE.html>{: target="_blank"}
  - <https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/using-flasback-database-restore-points.html>{: target="_blank"}