---
layout: single
title: Data Pump Best Practics
date: 2023-12-11 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - datapump
   - migration
excerpt : Data Pump 도구 사용시 고려사항에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

**참고사항** <br>본문은 2021년 8월에 작성된 오라클 백서[Oracle Data Pump Best Practices v2.0](https://www.oracle.com/a/ocom/docs/oracle-data-pump-best-practices.pdf){: target="_blank"}를 참고하여 정리하였습니다.
{: .notice} 

## 개요

오라클은 Data Pump 도구를 통해서 데이터 마이그레이션할때 자주 사용합니다.
DB 버전 및 OS 영향으로부터 영향받지 않는 논리적인 마이그레이션 방법이기 때문입니다.
보통 데이터 마이그레이션을 할때는 3가지 절차로 진행됩니다.

1. 원천소스DB에서 expdp명령어로 데이터를 추출(export)합니다. 
2. Export받은 dump file을 타켓DB로 복사합니다. 
3. 타켓DB에서 impdp명령어를 통해서 데이터을 적재(Import) 합니다.

이러한 과정에서 Data Pump작업에 문제 없이 원활하게 진행할수 있는 팁들을 정리하였습니다. 

## SYS as SYSDBA로 EXPORT를 실행하지 마라
SYSDBA는 내부적으로 사용되며 특별한 기능들을 제공하고 있습니다. 일반적으로 생성된 유저와 동일하게 동작하지 않습니다. 그러므로 Export할때 SYSDBA로 수행할 필요가 없습니다. 
(대신 오라클 기술지원의 요청이나 Transportable Tablespace를 수행할때는 사용될수 있습니다.)

## PARAMETER FILE을 사용해라

Parameter File은 parfile 매개변수를 사용할수 있습니다. parameter file을 만들면 오타를 줄이고 CLI에서 아주 긴 data pump 명령어를 실행시 화면에 잘못표기 되는 오류를 방지하는데 도움이 됩니다. 
(그리고 따옴표를 사용할때 더 도움이 됩니다.)

```bash
-- expdp를 위한 parameter file 생성
-- EXCLUDE, LOGTIME, METRIC, FLASHBACK_TIME 매개변수들을 본문에서 자세히 설명될 예정입니다. 
$> cat exp_hr.par
DIRECTORY=my_data_pump_dir
DUMPFILE=dumpfile.dmp
LOGFILE=logfile.log
SCHEMAS=HR
EXCLUDE=STATISTICS
LOGTIME=ALL
METRICS=YES
FLASHBACK_TIME=SYSTIMESTAMP
-- parameter file를 이용하여 expdp수행
$> expdp admin@pdb1 parfile=exp_hr.par
```

## 데이터 일관성(Consistent)를 유지하면서 Export하는 방법?

기본적으로 단일 테이블내에서는 일관성(consistency)를 유지하면서 export할수 있습니다. 예로 1000개의 파티션을 가지고 있는 테이블을 export하게 되면 모두 동일한 SCN으로 export됩니다. 그러나 여러개의 테이블을 export할때는 서로 다른 SCN번로호 Export됩니다. 모두 동일한 시점으로 데이터를 Export 받고 싶다면  FLASHBACK_SCN=scn, FLASHBACK_TIME=timestamp를 사용할수 있습니다. 

가장편한 방법은 FLASHBACK_TIME=SYSTIMESTAMP 로 설정하는 방법입니다. 

**- SCN기반으로 Export수행할경우**

특정 SCN시점으로 데이터를 Export합니다.
```bash
-- SCN번호를 확인합니다.
-- select dbms_flashback.get_system_change_number from dual;
SQL> select CURRENT_SCN from v$database;
CURRENT_SCN
-----------
   47122278

```
```bash
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_scn1.dmp FLASHBACK_SCN=47122278
```

**- TIME기반으로 Export수행할경우**

시간을 지정하면 가장 가까운 SCN번호를 찾아서 Export합니다. 
```bash
--따옴표가 들어가는 인자를 사용할때 parameter file을 사용하면 오류를 방지할수 있습니다.
$> cat exp_scn2.par
FLASHBACK_TIME="TO_TIMESTAMP('2023-12-17 11:09:25','YYYY-MM-DD HH24:MI:SS')"

$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_scn2.dmp parfile=exp_scn2.par
```

**- 현재시점으로 Export수행할경우**

현재시점으로 export수행할때 SYSTIMESTAMP현재기준으로 설정하면 됩니다. 11.2부터 지원했던 CONSISTENT=y도 사용이 가능합니다. (내부적으로 FLASHBACK_TIME=SYSTIMESTAMP으로 변환됩니다.)

```bash
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_scn3.dmp FLASHBACK_TIME=SYSTIMESTAMP
```

> FLASHBACK_SCN과 FLASHBACK_TIME는 데이터 consistency를 위하여 변경된 이전 데이터인 UNDO로 부터 데이터를 가져오게 됩니다. 만약 UNDO retention이 충분하지 않다면 snapshot segment too old에러가 발생되면서 Data Pump작업이 실패할수 있습니다. 

## EXPORT와 IMPORT 할때 통계정보는 제외해라

Export할때 통계정보를 같이 export하지 않는것이 좋습니다. 왜냐하면 통계정보를 별도로 이관하거나 새로 통계정보수집하는 작업보다 성능이 느리기 때문입니다. export할때 EXCLUDE=STATISTIC 매개변수를 사용하면 통계정보를 제외시킬수 있습니다. (Transportable Tablepsace작업시에는  EXCLUDE=TABLE_STATISTICS,INDEX_STATISTICS 설정합니다.)

```bash
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_exclude_static.dmp  EXCLUDE=STATISTICS
```

**- stage테이블을 이용한 통계정보 이관 방법**

특정 유저의 데이터를 이관할때 해당 유저의 통계정보를 stage테이블에 저장하여 다른 DB로 이관할수 있습니다.

```sql
-- staging 테이블 생성
SQL> EXEC DBMS_STATS.CREATE_STAT_TABLE(OWNNAME=>'ADMIN',STATTAB=>'STATS_TAB'); 
-- HR유저의 통계정보 백업
SQL> EXEC DBMS_STATS.EXPORT_SCHEMA_STATS (OWNNAME=>'HR',STATTAB=>'STATS_TAB',STATID=>'HR_BACKUP',STATOWN=>'ADMIN');

SQL> select statid, count(*) from admin.STATS_TAB group by statid;
STATID       COUNT(*)
---------- ----------
HR_BACKUP          17
```

```bash
-- staging테이블을 Export 수행
$> expdp admin@pdb1 DIRECTORY=my_data_pump_dir DUMPFILE=stats_tab.dmp TABLES=ADMIN.STATS_TAB
. . exported "ADMIN"."STATS_TAB"                         19.74 KB      17 rows
-- staging테이블을 Import 수행
$> impdp admin@pdb2 DIRECTORY=my_data_pump_dir DUMPFILE=stats_tab.dmp log=implog.log
. . imported "ADMIN"."STATS_TAB"                         19.74 KB      17 rows
```

```sql
-- 통계정보 복구
SQL> EXEC DBMS_STATS.IMPORT_SCHEMA_STATS (OWNNAME=>'HR',STATTAB=>'STATS_TAB',STATID=>'HR_BACKUP',STATOWN=>'ADMIN');
```

## EXPORT와 IMPORT 과정을 분석하기 위한 파리미터 설정은?

export작업의 로그에 timestamp을 표시하려면 LOGTIME=ALL을 설정할수 있습니다. LOGTIME은 12.2부터 추가되었으며 export 및 import의 성능 측정하는데 도움이 됩니다.

그리고 data pump log file에는 작업에 대한 objects의 개수나 소요시간을 기록되는데 METRICS=YES를 설정하면 PARALLEL 작업시 각 work프로세스별로 상세히 로그에 저장됩니다.

**- export 작업에 대한 로그**

LOGTIME=ALL은 로그의 맨앞에 타임스탬프정보(17-DEC-23 12:50:06.518)가 추가되어 표시됩니다.
METRICS=YES는 Worker프로세스(W-1,W-2)의 처리시간간과 object개수를 표시합니다.(Completed 1 USER objects in 0 seconds)

```bash
$>  expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_%u.dmp  LOGTIME=ALL METRICS=YES PARALLEL=2
Connected to: Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
17-DEC-23 12:50:06.518: Starting "ADMIN"."SYS_EXPORT_SCHEMA_01":  admin/********@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr_%u.dmp LOGTIME=ALL METRICS=YES PARALLEL=2
17-DEC-23 12:50:06.761: W-1 Startup took 0 seconds
17-DEC-23 12:50:07.834: W-2 Startup took 0 seconds
17-DEC-23 12:50:07.857: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
17-DEC-23 12:50:07.963: W-1 Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
17-DEC-23 12:50:07.987: W-1      Completed 19 INDEX_STATISTICS objects in 0 seconds
17-DEC-23 12:50:08.171: W-1 Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
17-DEC-23 12:50:08.176: W-1      Completed 7 TABLE_STATISTICS objects in 0 seconds
17-DEC-23 12:50:08.337: W-1 Processing object type SCHEMA_EXPORT/USER
17-DEC-23 12:50:08.341: W-1      Completed 1 USER objects in 0 seconds
17-DEC-23 12:50:08.389: W-1 Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
17-DEC-23 12:50:08.394: W-1      Completed 9 SYSTEM_GRANT objects in 0 seconds
17-DEC-23 12:50:08.493: W-1 Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
17-DEC-23 12:50:08.497: W-1      Completed 1 DEFAULT_ROLE objects in 0 seconds
17-DEC-23 12:50:08.588: W-1 Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
17-DEC-23 12:50:08.592: W-1      Completed 1 TABLESPACE_QUOTA objects in 0 seconds
17-DEC-23 12:50:08.689: W-1 Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
17-DEC-23 12:50:08.693: W-1      Completed 1 PROCACT_SCHEMA objects in 0 seconds
17-DEC-23 12:50:09.574: W-1 Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
17-DEC-23 12:50:09.579: W-1      Completed 3 SEQUENCE objects in 0 seconds
17-DEC-23 12:50:11.412: W-2 Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
17-DEC-23 12:50:11.479: W-2      Completed 1 MARKER objects in 3 seconds
17-DEC-23 12:50:11.993: W-2 Processing object type SCHEMA_EXPORT/TABLE/COMMENT
17-DEC-23 12:50:12.005: W-2      Completed 42 COMMENT objects in 1 seconds
17-DEC-23 12:50:12.990: W-2 Processing object type SCHEMA_EXPORT/PROCEDURE/PROCEDURE
17-DEC-23 12:50:12.994: W-2      Completed 2 PROCEDURE objects in 0 seconds
17-DEC-23 12:50:13.367: W-2 Processing object type SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE
17-DEC-23 12:50:13.372: W-2      Completed 2 ALTER_PROCEDURE objects in 0 seconds
17-DEC-23 12:50:15.019: W-2 Processing object type SCHEMA_EXPORT/VIEW/VIEW
17-DEC-23 12:50:15.023: W-2      Completed 1 VIEW objects in 2 seconds
17-DEC-23 12:50:16.142: W-2 Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
17-DEC-23 12:50:16.177: W-2      Completed 17 INDEX objects in 1 seconds
17-DEC-23 12:50:16.326: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
17-DEC-23 12:50:16.332: W-2      Completed 9 CONSTRAINT objects in 0 seconds
17-DEC-23 12:50:17.445: W-2 Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
17-DEC-23 12:50:17.451: W-2      Completed 10 REF_CONSTRAINT objects in 0 seconds
17-DEC-23 12:50:17.588: W-2 Processing object type SCHEMA_EXPORT/TABLE/TRIGGER
17-DEC-23 12:50:17.592: W-2      Completed 2 TRIGGER objects in 0 seconds
17-DEC-23 12:50:19.508: W-1 Processing object type SCHEMA_EXPORT/TABLE/TABLE
17-DEC-23 12:50:20.183: W-2 . . exported "HR"."COUNTRIES"                            6.398 KB      25 rows in 0 seconds using external_table
17-DEC-23 12:50:20.260: W-2 . . exported "HR"."DEPARTMENTS"                          7.125 KB      27 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.288: W-2 . . exported "HR"."EMPLOYEES"                            17.07 KB     107 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.305: W-2 . . exported "HR"."JOBS"                                 7.109 KB      19 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.323: W-2 . . exported "HR"."JOB_HISTORY"                          7.195 KB      10 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.342: W-2 . . exported "HR"."LOCATIONS"                            8.437 KB      23 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.360: W-2 . . exported "HR"."REGIONS"                              5.546 KB       5 rows in 0 seconds using direct_path
17-DEC-23 12:50:20.529: W-1      Completed 7 TABLE objects in 9 seconds
17-DEC-23 12:50:20.849: W-2      Completed 7 SCHEMA_EXPORT/TABLE/TABLE_DATA objects in 0 seconds
17-DEC-23 12:50:21.299: W-2 Master table "ADMIN"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
17-DEC-23 12:50:21.337: ******************************************************************************
17-DEC-23 12:50:21.337: Dump file set for ADMIN.SYS_EXPORT_SCHEMA_01 is:
17-DEC-23 12:50:21.338:   /oradata/datapump/hr_01.dmp
17-DEC-23 12:50:21.339:   /oradata/datapump/hr_02.dmp
17-DEC-23 12:50:21.362: Job "ADMIN"."SYS_EXPORT_SCHEMA_01" successfully completed at Sun Dec 17 12:50:21 2023 elapsed 0 00:00:17
```

## 성능 개선 방법(병렬처리, 통계정보수집)

**- PARALLELISM를 사용**

병렬처리를 하면 적은 시간으로 더 많은 작업을 수행할수 있습니다. Data Pump Job은 최소 두개의 백그라운드 프로세스(Control Process, Worker process, 2 Sessions)로 구성됩니다. PARALLEL 파라미터를 사용하면 export와 Import작업시에 더 많은 백그라운드 프로세스와 세션이 생성됩니다. 

Parallel=n 파라미터는 Export 와 Import Job에서 수행되는 작업의 최대 프로세스개수를 지정합니다. 일반적으로 n값은 CPU 코어의 2배로 설정하지만 필요에 의해 크게 혹은 작제 조정할수 있습니다.
12.2부터 대부분의 메타데이터와 객체들을 paralell로 import됩니다. 여러개의 인덱스를 parallel하게 생성하지만 일부 메타데이터 객체들은 dependency에 따라서 serial하게 처리도리수 있습니다.

11.2.0.4 혹은 12.1.0.2환경에서는 여러개의 인덱스를 parallel처리하게 생성하고 싶을 경우 bug 22273229패치를 적용하면 됩니다.

> Data Pumps의 Parallel은 두종류가 있습니다. 하나의 Worker프로세스는 파티션과 테이블에 사용(inter-table parallelism)되고 큰파티션이나 파티션되지 않은 테이블들은 PX프로세스(intra-table parallelism)가 사용됩니다.

```bash
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=par_hr_%u.dmp PARALLEL=4
JOB_NAME=par4_job 
```

**- 여러개의 DUMPFILE생성을 위해서 WILDCARDS를 지정**

병렬처리를 하면 dumpfile이름을 지정할때 %U or %L을 사용해야합니다. 이것을 사용하면 동시에 여러개의 logfiles로 병렬 쓰기가 가능합니다. 또한 더 작아진 dumpfile은 관리하거나 복사할때 유리합니다.

```bash
-- %U는 1~99파일을 만들수 있고, %L은 1부터 99이상의 파일을 만들수 있습니다.
-- %L : 2-digit, %은 3-digit to 10-digit

$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=par_hr_%L.dmp PARALLEL=4
```

하나의 파일에 병렬 쓰기가 되면 성능이 개선되지 않습니다. 하나의 worker프로세스가 해당파일에 대한 exclusive lock을 가지고 있기 때문에 다른 worker 프로세스가 blocking되기 때문입니다.

**- DATA PUMP 작업 전후로 정확한 통계정보를 수집**

export 및 import하기전에 정확한 통계정보를 가지고 있는것이 성능에 도움이 됩니다. 통계정보 수집은 dictionary 통계정보, object 통계정보 두개로 구분되는데, Dictionary 통계정보는 export에 수행되는 많은 단계(data pump filter나 정렬, medata object 수집등)에서 사용됩니다. Object 통계정보는 병렬처리하거나 정렬하기 위해 테이블과 인덱스 사이즈를 계산할때 사용됩니다. 

메타데이터를 export하면서 테이블 사이즈를계산하여 큰것에서 작은것 순서대로 순위를 매깁니다. 테이블 크기는 통계정보를 사용하여 계산합니다. dbms_stats패키지의  gather_table_stats, gather_schema_stats, gather_database_stats 프로시저를 이용해서 통계정보를 수집합니다.

```sql
BEGIN
  DBMS_STATS.GATHER_SCHEMA_STATS('SYS');
  DBMS_STATS.GATHER_SCHEMA_STATS('SYSTEM');
END;
/
```
> 운영시스템에서 통계정보를 수집할때 시간이 소요되고 레소스를 많이 사용할수 있습니다. 통계정보 수집이후에는 Cursor invalidation되어 hard parsing이 발생될가능성이 높고, 새로운 통계정보는 새로운 Plan을 만들어낼수 있으니 주의하여 통계정보를 수집하기 바랍니다.

**추가내용**

Data Pump Export작업수행시 각 테이블로 사이즈를 계산할때 기본적으로 테이블의 통계정보를 사용합니다. 통계정보가 부정확한 상태일경우는 Block개수로 사이즈 계산하도록 변경할수 있습니다. 
(대신 export하려는 대상이 압축된 테이블이면 더 부정확한 크기로 계산할수 있으나 주의가 필요합니다.)
```bash
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=estimate_stat.dmp ESTIMATE=BLOCKS 
Starting "ADMIN"."SYS_EXPORT_SCHEMA_01":  admin/********@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=estimate_stat.dmp ESTIMATE=BLOCKS
Processing object type SCHEMA_EXPORT/TABLE/TABLE_DATA
.  estimated "HR"."COUNTRIES"                            4.683 KB   <-- 먼저 사이즈계산을 먼저합니다.
.  estimated "HR"."DEPARTMENTS"                          4.683 KB
.  estimated "HR"."EMPLOYEES"                            4.683 KB
.  estimated "HR"."JOBS"                                 4.683 KB
.  estimated "HR"."JOB_HISTORY"                          4.683 KB
.  estimated "HR"."LOCATIONS"                            4.683 KB
.  estimated "HR"."REGIONS"                              4.683 KB
Processing object type SCHEMA_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type SCHEMA_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type SCHEMA_EXPORT/STATISTICS/MARKER
Processing object type SCHEMA_EXPORT/USER
Processing object type SCHEMA_EXPORT/SYSTEM_GRANT
Processing object type SCHEMA_EXPORT/DEFAULT_ROLE
Processing object type SCHEMA_EXPORT/TABLESPACE_QUOTA
Processing object type SCHEMA_EXPORT/PRE_SCHEMA/PROCACT_SCHEMA
Processing object type SCHEMA_EXPORT/SEQUENCE/SEQUENCE
Processing object type SCHEMA_EXPORT/TABLE/TABLE
Processing object type SCHEMA_EXPORT/TABLE/COMMENT
Processing object type SCHEMA_EXPORT/PROCEDURE/PROCEDURE
Processing object type SCHEMA_EXPORT/PROCEDURE/ALTER_PROCEDURE
Processing object type SCHEMA_EXPORT/VIEW/VIEW
Processing object type SCHEMA_EXPORT/TABLE/INDEX/INDEX
Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/CONSTRAINT
Processing object type SCHEMA_EXPORT/TABLE/CONSTRAINT/REF_CONSTRAINT
Processing object type SCHEMA_EXPORT/TABLE/TRIGGER
. . exported "HR"."COUNTRIES"                            6.398 KB      25 rows
. . exported "HR"."DEPARTMENTS"                          7.125 KB      27 rows
. . exported "HR"."EMPLOYEES"                            17.07 KB     107 rows
. . exported "HR"."JOBS"                                 7.109 KB      19 rows
. . exported "HR"."JOB_HISTORY"                          7.195 KB      10 rows
. . exported "HR"."LOCATIONS"                            8.437 KB      23 rows
. . exported "HR"."REGIONS"                              5.546 KB       5 rows
Master table "ADMIN"."SYS_EXPORT_SCHEMA_01" successfully loaded/unloaded
******************************************************************************
Dump file set for ADMIN.SYS_EXPORT_SCHEMA_01 is:
  /oradata/datapump/estimate_stat.dmp
Job "ADMIN"."SYS_EXPORT_SCHEMA_01" successfully completed at Sun Dec 17 12:53:46 2023 elapsed 0 00:00:25
```


## 적절한 리소스를 할당해라

STREAMS_POOL_SIZE 파라미터는 64MB ~ 256MB 정도는 할당되어 있어야합니다. Data Pump는 Advanced Queuing(AW)기능을 사용하여 프로세스간에 통신을 합니다. SGA_TARGET 파라미터가 설정되어 있으면 STREAMS_POOL_SIZE 파라미터는 데이터베이스 사용량에 적합한 최소값으로 설정되어 있어야합니다.

**- 19c부터 Multitenant환경의 경우 PDB별로 Data Pump Job의 개수를 관리**

Multitenant환경의 PDB에서 사용가능한 Data Pump Job의 최대 갯수와 최대 병렬도를 설정할수 있습니다. 

- MAX_DATAPUMP_JOBS_PER_PDB : Job의 갯수를 의미하고 SESSIONS 파라미터의 50%로 자동할당되며 PDB레벨에서 동적으로 변경가능합니다.
- MAX_DATAPUMP_PARALLEL_PER_JOB : 개별 JOB의 병렬도를 의미하고 SESSIONS 파리미터의 25% 로 자동할당되며 PDB레벨에서 동적으로 변경가능합니다. 

> 너무 많은 JOB이나 Parallel이 설정되면 "ORA-00018: maximum number of sessions exceeded" or "ORA-00020: maximum number of processes (%s) exceeded" 에러가 발생됩니다.

## 다양한 OS 및 스토리지을 위해 NETWORK LINK를 사용해라

타켓 DB로부터 Database link을 통해서 impdp 작업을 할수 있습니다. Dump file생성되지 않아 마이그레이션 작업중에 temporary storage가 필요없게 됩니다. 12.2부터는 dblink를 사용해도 Direct Path Load를 지원합니다. impdp할때 ACCESS_METHOD=DIRECT_PATH 설정이 필요합니다. 

```bash
$> impdp admin@pdb2 SCHEMAS=HR DIRECTORY=my_data_pump_dir NETWORK_LINK=source_database_link ACCESS_METHOD=DIRECT_PATH
```

## SECUREFILE LOB을 사용해라

Secruefile Lob을 사용하는것을 권고합니다. BasicFile Lob에 비해서 성능 및 기능적인 이점이 더많기 때문입니다.

- LOB컬럼에 대한 병렬 I/O지원
- 압축 및 암호화 지원 

impdp사용할때 LOB_STORAGE=SECUREFILE를 사용하면 Securefiles Lob으로 변환해서 import됩니다. 테이블과 함께 Securefile Lob 영역이 자동생성됩니다.

```bash
$> impdp admin@pdb2 TABLES=hr.EMPLOYEES DIRECTORY=my_data_pump_dir DUMPFILE=hr.dmp TRANSFORM=LOB_STORAGE:SECUREFILE
```

## 데이터베이스 버전이 다를경우 COMPATIBILITY를 설정해라

데이터베이스의 Compatibility 레벨은 Data Pump의 Export와 Import작업에 영향을 줍니다. 소스 데이터베이스의 Compatibility는 dumpfile의 Compatibility를 결정합니다. 21c이전에서는 epxort와 import할때 소스와 타켓 데이터베이스의 verion을 매칭해서 수행했어야 했지만 21c부터는 어떠한 데이터베이스 버전도 Data Pump를 지원하게 되었습니다. 네트워크 모드를 이용하여 import할때 타켓데이터베이스의 Major버전이 동일하거나 달라도 수행이 가능합니다. 

impdp명령어는 오래된 버전의 data pump파일을 항상 읽을수 있습니다.
- 타켓 데이터베이스가 소스데이터베이스 버전보다 낮으면 expdp사용시 타켓데이터베이스 버전으로 VERSION파라미터로 지정할수 있습니다. 
- 18c부터는 COMPATIBLE을 18.0.0, 19.0.0으로 설정해야합니다. 
- Data Pump와 Original Export*Import 도구와 상호운용성이 없습니다. 그러므로 impdp가 Orignal dumpfile을 읽을수 있고, imp가 data pump의 dumpfile을 읽을수 없습니다.

> Data Pump의 호환성을 아래 MOS노트에서 확인할수 있습니다.
> Export/Import DataPump Parameter VERSION -Compatibility of Data Pump Between Different Oracle Versions (Doc ID 553337.1)

## 스토리지 공간 절감 및 성능향상을 위하여 COMPRESSION을 사용해라

Export하는 과정에서 메타데이터와 데이터에 대한 압축(Compression)은 dumpfile사이즈를 줄이기도 하고 네트워크 모드에서 import할때 Stream사이즈도 줄입니다. 특이 네트워크 모드에서는 성능이 개선될수 있습니다. 하지만 추가적인 DPU 리소스가 요구됩니다.

압축(Compression)은 메타데이터, 데이터 둘다 적용하거나 둘중 하나면 할수도 있습니다. 기본값은 COMPRESSION=METDATA_ONLY입니다.

대부분의 CASE에서는 COMPRESSION=ALL COMPRESSION_ALGORITHM=MEDIUM을 하는것이 효과적입니다. 그러나 COMPRESSION_ALGORITHM=BASIC은 데이터는 압축 되지만 성능적인 이점은 크지 않습니다. 

```bash
-- ACO라이센스가 없을경우 (기본값)
$> expdp admin@pdb1 SCHEMAS=HR DIRECTORY=my_data_pump_dir DUMPFILE=hr.dmp COMPRESSION=METADATA_ONLY

-- ACO라이센스가 있을경우 
$> expdp admin@pdb1 SCHEMAS=HR  DIRECTORY=my_data_pump_dir DUMPFILE=hr_comp.dmp COMPRESSION=ALL COMPRESSION_ALGORITHM=MEDIUM

-- 약 1/3로 dump file사이즈가 감소되었습니다.
$> ls -al 
-rw-r-----.  1 oracle oinstall 712704 Dec 17 13:07 hr.dmp
-rw-r-----.  1 oracle oinstall 221184 Dec 17 13:08 hr_comp.dmp

```
> Data Pump에서 Data 압축은 Advnaced Compression Option이 필요합니다. COMPRESSION=MEDATA_ONLY 설정을 하거나 압축된 datapump을 import할때는 라이센스가 요구되지 않습니다.

## DATA PUMP JOB을 실행하기 전에 데이터베이스를 점검해라.

**- AQ_TM_PROCESSES 파라미터 확인**

AQ_TM_PROCESSES 를 0으로 설정하면 안됩니다. 0으로 설정될경우 Advanced Queue(AQ) 작업이 느려지므로 결과적으로 AQ를 사용하는 data pump job도 느려질수 있습니다. 0이상의 값으로 설정되어 있어야합니다. (19c기준 AQ_TM_PROCESSES의 default 값은 1입니다.)

```sql
SQL> show parameter AQ_TM_PROCESSES
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
aq_tm_processes                      integer     1
```

**- _OPTIMIZER_GATHER_STATS_ON_LOAD 파리미터 확인**

12c부터 CTAS(Create Table as Select)나 insert /*+ append */ 사용하는 direct path insert와 같은 데이터 로딩작업시에 자동으로 통계정보를 수집하는 기능이 추가되었습니다. _OPTIMIZER_GATHER_STATS_ON_LOAD의 Default값이 true이므로 import작업시에 성능이 느려질수 있으므로  false설정 후 import작업 이후에 수동으로 통계정보를 수집하는것이 더 좋습니다.

```sql
SQL> alter system set "_OPTIMIZER_GATHER_STATS_ON_LOAD"=false;
```

**- RAC환경에서 _lm_share_lock_opt 파라미터 확인**

12.2의 RAC환경부터 library cache에서 SHARE lock(S-Lock)이 가능하게 되었습니다. impdp 작업시 parallel을 1부터 크게 설정할 경우 'Library Cache Lock' (Cycle)' 이벤트가 발생되며 성능이 느려질수 있습니다. impprot작업시이 _lm_share_lock_opt=false설정하거나, metadata import에는 paralel=1로 설정하는것이 좋습니다.

```sql
-- 먼저 medata import작업
$> impdp admin@pdb2 DIRECTORY=my_data_pump_dir DUMPFILE=hr_%u.dmp content=metadata_only parallel=1

-- 데이터만 import 작업
$> impdp admin@pdb2 DIRECTORY=my_data_pump_dir DUMPFILE=hr_%u.dmp content=DATA_ONLY parallel=8
```

관련이슈 : 'Library Cache Lock' (Cycle) Seen During DataPump Import in 12.2
RAC Environment (Doc ID 2407491.1)

## (추가) DDL구문을 미리확인해서 메타데이터의 오류를 최소화해라

소스데이터베이스와 타켓데이터베이스가 동일한 구성일경우 DDL생성작업이 에러가 최소화될수 있으나, 
data pump작업은 논리적인 마이그레이션 작업이므로 대부분의 환경은 타켓 데이터베이스이 변경될수 있습니다. 
메타데이터 import작업이전에 SQL로 추출하여 문장을 검증하는것이 좋습니다.

```bash
-- impdp작업시 SQL 파일을 추출 (데이터로딩은 되지 않음)
-- 테이블스페이스를 변경함.
$> impdp admin@pdb2 DIRECTORY=my_data_pump_dir DUMPFILE=hr.dmp SQLFILE=expfull.sql REMAP_TABLESPACE=USERS:TS_SOE_01
```

```sql
-- SQL 구문확인 (테이블스페이스가 USERS에서 TS_SOE_01로 변경됨을 확인)
$> cat expfull.sql 
CREATE TABLE "HR"."LOCATIONS"
   (    "LOCATION_ID" NUMBER(4,0),
        "STREET_ADDRESS" VARCHAR2(40 BYTE),
        "POSTAL_CODE" VARCHAR2(12 BYTE),
        "CITY" VARCHAR2(30 BYTE) CONSTRAINT "LOC_CITY_NN" NOT NULL ENABLE,
        "STATE_PROVINCE" VARCHAR2(25 BYTE),
        "COUNTRY_ID" CHAR(2 BYTE)
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TS_SOE_01" ;  <-- 테이블스페이스가 변경된것을 확인할수 있습니다.
```

## 오라클 클라우드로 데이터마이그레이션시 고려사항

**- SCHEMA 레벨에서 EXPORT작업을 수행**

스키마 단위 마이그레이션 단위일 경우 schemas=schema_name 을 설정합니다.

```bash 
$> EXPDP admin@pdb1 DIRECTORY=DP_DIR SCHEMAS=SCOTT LOGFILE=EXPORT_SCOTT.LOG PARALLEL=8 ...
```

**- AUTONOMOUS 데이터베이스로 마이그레이션하기 위해서 NETWORK LINK를 사용**

Autonomous DB에서 직접 DBlink을 이용해서 import수행합니다. dump files 생성이 필요없습니다.

- ACCESS METHOD 사용
  - ACCESS_METHOD 매개변수는 unload할때만 부분적으로 사용할수 있었지만, 12.2부터 ACCESS_METHOD=DIRECT_PATH와 NETWORK_LINK=<dblink>를 사용하면 LONG,LONG RAW 데이터타입도 가능합니다. 
- CHECKSUM으로 DATAFILE 정합성확인
  - 데이터마이그레이션하다보면 dump file을 이동해야되는경우가 발생됩니다. 특히 클라우드로 마이그레이션할때는 object storage에 dump file을 올려놓고 import작업을 수행합니다. 21c부터 dump file의 정합성을 검증할수 있도록 chechsum 변수가 추가되었습니다.  
- NON-PARTITIONED TABLE로 IMPORT수행 
  - 소스의 테이블이 파티션되어 있는데 autonomous 에서 파티션을 사용하지 않고 싶을경우 DATA_OPTIONS=GROUP_PARTITION_TABLE_DATA 을 추가합니다.
- AL32UTF8 케릭터셋 사용
  - superset 케릭터셋인 A32UTF8을 사용을 권고합니다.

## 마무리

데이터 이관작업시에 Data Pump도구를 많이 사용합니다. 누구에게나 소중한 경험이 있겠지만, 조금이나마 원활한 작업이 될수 있도록 참조하시기 바랍니다.

## 관련문서

- Documents
  - [Oracle Data Pump ](https://docs.oracle.com/en/database/oracle/oracle-database/19/sutil/oracle-data-pump.html){: target="_blank"}
  - [Oracle Data Pump Best Practices v2.0](https://www.oracle.com/a/ocom/docs/oracle-data-pump-best-practices.pdf){: target="_blank"}