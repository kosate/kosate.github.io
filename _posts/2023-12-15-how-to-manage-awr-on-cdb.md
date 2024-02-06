---
layout: single
title: CDB환경에서 AWR관리 방법
date: 2023-12-15 15:00
categories: 
  - Oracle
books:
 - multitenant
author: 
tags: 
   - Oracle
   - Automatic Workload Repository
   - multitenant
   - 19c
excerpt : Multitenant환경에서 AWR 관리하는 방법에 대해서 정리하였습니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스는 데이터베이스의 성능 정보를 관리하는 AWR(Automatic Workload Repository)기능을 제공합니다. 데이터베이스 성능 분석을 위한 중요한 데이터로 AWR로부터 리포트를 생성하여 TOP SQL, Workload정보를 분석하는데요, 

CDB환경에서 AWR데이터를 어떻게 관리할수 있는지 알아보겠습니다.

## PDB에서 AWR관리 및 리포트 생성
 
AWR 데이터는 SYSAUX 테이블스페이스에 저장되어 있습니다. AWR데이터는 보관주기정책에 따라서 자동 관리되고 있습니다. Multitenant환경에서는 CDB레벨에서는 전체 PDB정보의 성능정보를 관리하고, 개별 PDB레벨에서도 AWR 성능정보를 별도로 관리할수 있습니다.

**Multitenant(CDB) 환경에서의 AWR관리 방법**

19c에서의 기본설정은 CDB레벨에서만 AWR데이터를 관리하도록 되어 있습니다. PDB레벨에서 AWR데이터를 관리하고 싶은경우 DB파라미터 변경이 필요합니다. 

- awr_pdb_autoflush_enabled : PDB에서 AWR Snapshot을 활성화할지 설정 (기본값 : false)
- awr_snapshot_time_offset : PDB간의 AWR offet을 설정(기본값 : 0)

awr_pdb_autoflush_enabled 파라미터를 true되어 있으면 개별 PDB별로 AWR를 관리하게 됩니다.
각 PDB에서 관리되는 AWR 정보들은 AWR_PDB_*로 시작하는 뷰를 사용합니다. 

```sql
-- CDB접속
SQL> show parameter awr
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
awr_pdb_autoflush_enabled            boolean     FALSE
awr_pdb_max_parallel_slaves          integer     10
awr_snapshot_time_offset             integer     0

-- CDB레벨에서 파라미터 변경하면 PDB까지 자동으로 설정됨
-- awr_pdb_autoflush_enabled는 PDB레벨에서 AWR Snapshot을 관리할수 있는 의미입니다.
SQL> alter system set awr_pdb_autoflush_enabled=true;
-- awr_snapshot_time_offset는 1000000을 설정하면 여러개의 PDB가 동시에 Snapshot을 수행할때 부하가 많이 발생되지 않도록 PDB간에 offet을 두고 자동 스케줄링합니다.
SQL> alter system set awr_snapshot_time_offset=1000000;
SQL> show parameter awr
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
awr_pdb_autoflush_enabled            boolean     TRUE
awr_pdb_max_parallel_slaves          integer     10
awr_snapshot_time_offset             integer     1000000
```

PDB에 접속하면 DBA_HIST뷰와 AWR_PDB뷰를 제공하고 있습니다. DBA_HIST는 CDB와 PDB정보가 조회되고 AWR_PDB뷰에서는 PDB정보만 조회가 됩니다. 

**AWR보관주기 관리**

PDB레벨에서 AWR Snapshot주기가 매우 길게 설정되어 있습니다. 거의 수행하지 않도록 interval간격이 4만일로 기본 설정되어 있습니다.
설정절차는 기존 Non-CDB와 동일합니다. PDB에 들어가서 보관주기를 설정하면 됩니다

```sql
SQL> alter session set container=pdb1;
SQL> SELECT min(snap_id) begin_id, max(snap_id) end_id FROM awr_pdb_snapshot;
  BEGIN_ID     END_ID
---------- ----------
        93         95
-- PDB AWR정보만 확인
SQL> SELECT DBID,SNAP_INTERVAL, RETENTION FROM  AWR_PDB_WR_CONTROL;
      DBID SNAP_INTERVAL                  RETENTION
---------- ------------------------------ ------------------------------
 909607496 +40150 00:01:00.0              +00008 00:00:00.0    <-- 그러나 SNAP_INTERVAL시간이 매우 김

-- 30일보관 20분 주기
SQL> EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS(RETENTION=>60*24*30,INTERVAL=>20);

-- PDB AWR정보만 확인
SQL> SELECT DBID,SNAP_INTERVAL, RETENTION FROM  AWR_PDB_WR_CONTROL;
      DBID SNAP_INTERVAL                  RETENTION
---------- ------------------------------ ------------------------------
 909607496 +00000 00:20:00.0              +00030 00:00:00.0

-- CDB와 PDB AWR정보를 확인
-- CDB레벨에서는 1시간 간격으로 Snanpshot을 생성하고, PDB레벨에서는 20분간격으로 Snapshot을 생성합니다. 
SQL> SELECT DBID,SNAP_INTERVAL, RETENTION FROM  dba_hist_WR_CONTROL;
      DBID SNAP_INTERVAL                  RETENTION
---------- ------------------------------ ------------------------------
1108973582 +00000 01:00:00.0              +00008 00:00:00.0
 909607496 +00000 00:20:00.0              +00030 00:00:00.0

```

**AWR Report생성**

PDB레벨에서 AWR Report를 생성할때는 CDB레벨의 데이터와 PDB레벨 데이터를 선택할수 있습니다. 

```sql
SQL> alter session set container=pdb1;
-- AWR데이터는 2가지가 존재합니다, CDB레벨의 1시간간격의 Snapshot, PDB레벨의 20분간격의 Snpshot데이터입니다. 
SQL> SELECT dbid, min(snap_id) begin_id, max(snap_id) end_id FROM dba_hist_snapshot group by dbid;
      DBID   BEGIN_ID     END_ID
---------- ---------- ----------
1108973582        219        252  <-- CDB AWR정보
 909607496         93         95  <-- PDB AWR정보

-- AWR Report를 생성할때 어느 데이터를 참조할지를 선택하게 됩니다.
SQL> @?/rdbms/admin/awrrpt

Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
AWR reports can be generated in the following formats.  Please enter the
name of the format at the prompt.  Default value is 'html'.

'html'          HTML format (default)
'text'          Text format
'active-html'   Includes Performance Hub active report

Enter value for report_type: txt
old   1: select 'Type Specified: ',lower(nvl('&&report_type','html')) report_type from dual
new   1: select 'Type Specified: ',lower(nvl('txt','html')) report_type from dual

Type Specified:  txt

Specify the location of AWR Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AWR_ROOT - Use AWR data from root (default)   <-- CDB레벨의 데이터 참조
AWR_PDB - Use AWR data from PDB               <-- PDB레벨의 데이터 참조
Enter value for awr_location: AWR_PDB   <-- 선택하여 Report를 생성합니다. 
```

## AWR 데이터 이관 절차

AWR 데이터 이관 절차는 기존 Non-CDB환경과 동일합니다. awrextr.sql로 AWR 데이터를 Export한후에 awrload.sql을 통해 타켓 DB에 AWR 데이터를 로딩하면됩니다. 

### AWR데이터 EXPORT예시(PDB1)

AWR 데이터 Export 작업을 수행합니다. 먼저 사이즈 확인후에 Snapshot id(범위)를 지정하여 Export 작업을 수행할수 있습니다.

```sql
-- AWR 데이터 확인
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO

SQL> alter session set container=pdb1;
-- AWR공간확인
-- 혹은 awrinof로 조회가능 - SQL> @?/rdbms/admin/awrinfo.sql
SQL> select OCCUPANT_NAME, OCCUPANT_DESC, SCHEMA_NAME, SPACE_USAGE_KBYTES from  v$sysaux_occupants where occupant_name = 'SM/AWR';
OCCUPANT_N OCCUPANT_DESC                                           SCHEMA_NAM SPACE_USAGE_KBYTES
---------- ------------------------------------------------------- ---------- ------------------
SM/AWR     Server Manageability - Automatic Workload Repository    SYS                     52096

-- Directory 생성
SQL> create directory awr_dump as '/oradata/awr_dump';

-- AWR 데이터 Export수행
SQL> @?/rdbms/admin/awrextr.sql
~~~~~~~~~~~~~
AWR EXTRACT
~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~  This script will extract the AWR data for a range of snapshots  ~
~  into a dump file.  The script will prompt users for the         ~
~  following information:                                          ~
~     (1) database id                                              ~
~     (2) snapshot range to extract                                ~
~     (3) name of directory object                                 ~
~     (4) name of dump file                                        ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enter value for dbid: 909607496  <-- 입력
Enter value for num_days: 1  <-- 입력
Enter value for begin_snap: 93  <-- 입력  
Enter value for end_snap: 94  <-- 입력
Enter value for directory_name: AWR_DUMP  <-- 입력 
Enter value for file_name: awrdat_93_94  <-- 입력
..

Using the dump file prefix: awrdat_93_94
|
| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
|  The AWR extract dump file will be located
|  in the following directory/file:
|   /oradata/awr_dump
|   awrdat_93_94.dmp
| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
|
|  *** AWR Extract Started ...
..

End of AWR Extract
-- Export 파일 확인 (13MB)
SQL> !ls -al /oradata/awr_dump
total 13360
drwxr-xr-x.  2 oracle oinstall     4096 Dec 18 08:23 .
drwxr-xr-x. 13 oracle oinstall     4096 Dec 18 03:13 ..
-rw-r-----.  1 oracle oinstall 13635584 Dec 18 08:24 awrdat_93_94.dmp
-rw-r--r--.  1 oracle oinstall    29709 Dec 18 08:24 awrdat_93_94.log
SQL>
```


### AWR데이터 IMPORT예시 #1(PDB3)

신규 생성된 PDB3에 AWR 데이터를 로딩하는 작업을 수행하겠습니다. 
- PDB1 -> PDB3(신규)

```sql
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
-- 신규 PDB 생성
SQL> create pluggable database pdb3 admin user admin identified by "<패스워드>";
SQL> alter pluggable database pdb3 open;
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
         9 PDB3                           READ WRITE NO

SQL> alter session set container=pdb3;
SQL> create directory awr_dump as '/oradata/awr_dump';
-- AWR 데이터 Load작업수행 
SQL> @?/rdbms/admin/awrload.sql
~~~~~~~~~~
AWR LOAD
~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~  This script will load the AWR data from a dump file. The   ~
~  script will prompt users for the following information:    ~
~     (1) name of directory object                            ~
~     (2) name of dump file                                   ~
~     (3) staging schema name to load AWR data into           ~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enter value for directory_name: AWR_DUMP  <-- 입력
Enter value for file_name: awrdat_93_94   <-- 입력
Enter value for schema_name: STAGE_USER <-- 대문자로 작성필요
Enter value for default_tablespace: USERS  <-- 입력
Enter value for temporary_tablespace: TEMP  <-- 입력

... Creating STAGE_USER user

|
| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
|  Loading the AWR data from the following
|  directory/file:
|   /oradata/awr_dump
|   awrdat_93_94.dmp
| ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
|
|  *** AWR Load Started ...
|
|  This operation will take a few moments. The
|  progress of the AWR load operation can be
|  monitored in the following directory/file:
|   /oradata/awr_dump
|   awrdat_93_94.log
|
... Dropping STAGE_USER user

End of AWR Load
```

### AWR 데이터 IMPORT예시 #2(PDB4)

PDB1으로 부터 복제한 PDB4에 AWR 데이터를 로딩하는 작업을 수행하겠습니다. 

- PDB1 -> PDB4(PDB1의 복제본)

PDB1의 AWR정보가 PDB4에 존재하므로 AWR데이터로딩할때 에러가 발생됩니다. 에러 발생될때 조치 방법도 같이 알아보겠습니다. 

```sql
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
         9 PDB3                           READ WRITE NO

-- PDB1을 복제하여 PDB4를 생성
SQL> create pluggable database pdb4 from pdb1
SQL> alter pluggable database pdb4 open;
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
         9 PDB3                           READ WRITE NO
        10 PDB4                           READ WRITE NO

SQL> alter session set container=pdb4;
-- 이미 생성되어 있을경우 skip
SQL> create directory awr_dump as '/oradata/awr_dump';

-- AWR 데이터를 Load수행 (에러발생)
SQL> @?/rdbms/admin/awrload.sql

Enter value for directory_name: AWR_DUMP  <-- 입력
Enter value for file_name: awrdat_93_94  <-- 입력
Enter value for schema_name: STAGE_USER <-- 대문자로 작성필요
Enter value for default_tablespace: USERS  <-- 입력
Enter value for temporary_tablespace: TEMP  <-- 입력

-- 데이터 중복되면 ORA-20103 에러 발생
*
ERROR at line 1:
ORA-20103: Data has conflict, please use a new dbid to import or drop the local data first.
ORA-06512: at "SYS.DBMS_SWRF_INTERNAL", line 3017
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 2500
ORA-06512: at line 4

-- 동일한 DBID가 있으면 ORA-20303 에러 발생

ERROR at line 1:
ORA-20105: Unable to move AWR data to SYS
ORA-06512: at "SYS.DBMS_SWRF_INTERNAL", line 5085
ORA-20303: Can not import snapshots because flushing is enabled
ORA-06512: at "SYS.DBMS_SWRF_INTERNAL", line 4493
ORA-06512: at "SYS.DBMS_WORKLOAD_REPOSITORY", line 2503
ORA-06512: at line 4 

-- PDB1를 복제하여 만든 PDB4는 동일한 DBID로 데이터가 있을수 있으므로 에러가 발생됩니다. 
-- awrload.sql의 인자로 임의 DBID(10)를 넣으면 됩니다.
SQL> @?/rdbms/admin/awrload.sql 10

... Creating STAGE_USER user
... Dropping STAGE_USER user
End of AWR Load
```

### AWR Report 생성

새로 로딩된 AWR데이터로부터 Report를 생성하기 위해서는 awrrpti.sql을 사용합니다. 
(awrrpt는 해당 PDB의 DBID를 자동 사용합니다)

```sql
-- DBID를 인자로 받을수 있도록 awrrpti를 사용합니다.
SQL> @?/rdbms/admin/awrrpti

Specify the Report Type
~~~~~~~~~~~~~~~~~~~~~~~
AWR reports can be generated in the following formats.  Please enter the
name of the format at the prompt. Default value is 'html'.

   'html'          HTML format (default)
   'text'          Text format
   'active-html'   Includes Performance Hub active report

Enter value for report_type: text  <-- 입력

Type Specified: html

Specify the location of AWR Data
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
AWR_ROOT - Use AWR data from root (default)
AWR_PDB - Use AWR data from PDB
Enter value for awr_location: AWR_PDB <-- 입력
 
 
Instances in this Workload Repository schema
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  DB Id      Inst Num   DB Name      Instance     Host
------------ ---------- ---------    ----------   ------
  10             1      CDB1         CDB1         db-upgrade <-- Import한 AWR데이터 
  909607496      1      CDB1         CDB1         db-upgrade

Enter value for dbid: 10  <-- 입력
Enter value for inst_num: 1 <-- 입력
Enter value for num_days: 1 <-- 입력
Enter value for begin_snap: 93 <-- 입력
Enter value for end_snap: 94 <-- 입력
Enter value for report_name: awrrpt_1_93_94  <-- 입력
(생략)
Report written to awrrpt_1_93_94.txt
```

## 마무리

Multitenant환경에서는 AWR데이터를 CDB레벨에서 PDB레벨에서 각각 관리할수 있습니다. 

CDB레벨에서 AWR데이터를 관리하면 한번에 모든 PDB정보를 관리할수 있습니다. 반면 PDB레벨에서 AWR데이터를 관리하면 PDB이동시에 AWR데이터도 같이 이동되므로 성능의 추적이 가능합니다.  

CDB레벨에서는 장기간보관하고 PDB레벨에서는 단기보관으로 보관주기를 구분하면서 관리할수도 있습니다. 

AWR데이터를 사용하는 방법은 기존 DBA_HIST뷰대신 AWR_PDB뷰로 앞에 prefix만 변경하면 동일한 기능을 쉽게 사용할수 있습니다. 

## 참조문서

- MOS note
  - How to Export and Import the AWR Repository From One Database to Another (Doc ID 785730.1)