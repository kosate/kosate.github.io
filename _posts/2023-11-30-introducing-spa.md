---
layout: single
title: SQL Performance Analyzer 수행방법
date: 2023-11-30 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - sql tuning set
   - sql performance analyzer
   - real application testing
excerpt : SQL Performance Analyzer 수행방법에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

오라클데이터베이스에서는 시스템(환경)변경에 따른 SQL영향도를 분석하는 도구을 제공합니다. SPA 기능에 대해서 알아보도록 하겠습니다.

## SPA(SQL Performance Analyzer) 이란?

SQL Performance Analyzer(SPA) 기능은 SQL 쿼리의 성능을 분석하고 최적화하는 도구입니다. SPA를 사용하면 데이터베이스에서 실행되는 SQL 문장의 성능을 평가하고 변경 전후의 성능 차이를 비교할 수 있습니다. 

SPA를 사용하려면 Oracle Enterprise Manager 또는 SQL*Plus(DBMS_SQLPA 패키지사용)와 같은 도구를 통해 데이터베이스에서 성능 분석을 실행하고 결과를 확인할 수 있습니다. SQL Performance Analyzer는 SQL 튜닝을 통해 데이터베이스 성능을 향상시키는 데 중요한 역할을 합니다.

※ SPA기능을 사용하기 위해서는 Real Application Testing 기능이 활성화되어 있어야하며, 라이센스가 필요합니다.

## 사전준비 작업

1. SPA수행을 위한 SQL 정보 캡쳐
   - SPA를 수행기전에 SQL정보를 캡쳐해야합니다. STS 생성하는 방법은 아래 문서를 참고하세요.
     - AWR혹은 Cursor정보로 부터 SQL정보를 캡쳐하여 STS(SQL Tuning Set)으로 생성할수 있습니다.
     - 참고 문서 : [STS 생성하는 방법](/blog/oracle/how-to-create-sqlset/){: target="_blank"}
2. RAT 옵션 필요
   - SPA수행을 위해서는 RAT기능이 binary에서 활성화되어 있어야합니다. (Real Application Testing 라이센스가 필요합니다.)
3. 테스트 환경 구성(업그레이드 업그레이드 및 서버가 변경될경우)
   - 캡쳐된 SQL정보를 수행하기 위한 테스트 DB환경이 필요합니다.
   - DB 백업본으로 테스트환경을 구성합니다. (RMAN을 사용하여, DataPump로 데이터 이관을 합니다)
   - 최대한 운영환경과 일치하도록 구성해야하고, 켭쳐한 SQL정보를 가져옵니다.

```sql
--RAT 옵션 활성화 여부 확인
SQL> select value from v$option where parameter = 'Real Application Testing';
VALUE
----------------------------------------------------------------
FALSE
SQL> shutdown immediate
-- RAT 옵션 활성화
$> chopt enable rat
SQL> startup
```

## SPA 수행 방법

SPA는 크게 3단계로 구분할수있습니다. 
1. Pre-Change SQL Trial 작업
2. Post-Change SQL Trial 작업
3. Compare Performance 작업

SPA는 2개의 SQL Trial간에 비교하여 성능변화를 확인할수 있습니다.
- Pre-Change SQL Trial #1 : 환경변경전의 SQL 수행결과
- Post-Change SQL Trial #2 : 환경변경후의 SQL 수행결과

SQL Trial을 생성하는 방법(SQL 성능 측정 방법)
- Test Execute : SPA를 이용하여 SQL 구문을 실행합니다. 테스트환경에서 수행하거나, Remote DB에서 수행가능합니다. (execution_type => 'TEST EXECUTE')
- Explain Plan : SPA를 이용하여 SQL Plan정보만 생성합니다. 테스트환경에서 수행하거나, Remote DB에서 수행가능합니다. SQL Plan정보는 explain plan구문을 이용한 실행계획이 아니라 바인드변수를 참조한 실제 실행계획을 의미합니다. (execution_type => 'EXPLAIN PLAN')
- Convert SQL Tuning Set : SQL Tuning Set에 저장된 Plan정보와 실행정보를 변환합니다. API를 통해서만 지원합니다.(execution_type => 'CONVERT SQLSET')

SPA은 Remote DB에서 Test Execute, Explain Plan 작업이 가능하므로 remote DB간, Local DB vs Remote DB간에 다양한 환경에서 테스트가 가능합니다. SQL 워크로드에 따라서 시간과 리소스가 많이 필요할수 있습니다. 따라서 긴급으로 확인할때는 Explain Plan을 고려해볼수 있습니다. 

SPA는 SQL을 실행할때 최소 2번을 실행합니다. 첫번째 실행은 buffer cache를 준비하는데 사용되고, 두번째이후의 실행정보를 이용하여 성능 정보를 저장합니다. 

- SPA 수행시 고려사항
  - DDL을 지원하지 않습니다.
  - 기본적으로 DML중 Query부분이 실행됩니다. EXECUTE_FULLDML매개변수를 사용할 경우 모든 DML수행이 가능합니다.
  - Parallel DML을 지원하지 않습니다. 그러므로 Parallel힌트를 제거하지 않으면 실행되지 않습니다.

Compare performance 단계(execution_type => ‘COMPARE PERFORMANCE’)에서는 두개의 SQL Trial을 비교하는 작업을 수행합니다. 이때 비교의 기준이 필요합니다. 
실행시간, IO량, CPU 시간등을 기준으로 비교할수 있으며, 추가적인 상세 비교기준은 아래 SQL을 통해서 확인할수 있습니다.
```sql
SQL> SELECT metric_name FROM v$sqlpa_metric;
METRIC_NAME
----------------------------------------------------------------
PARSE_TIME
ELAPSED_TIME
CPU_TIME
USER_IO_TIME
BUFFER_GETS
DISK_READS
DIRECT_WRITES
OPTIMIZER_COST
IO_INTERCONNECT_BYTES

9 rows selected.
SQL> 
```
비교가 완료되면 변경전과 변경후의 SQL 성능정보를 비교한 Report데이터를 생성합니다. 결과 데이터는 HTML, Exte, Active Report로 볼수 있습니다. 

## 작업예제

AWR로 부터 만들어진 STS를 이용해서 SPA 작업을 수행하는 예제입니다.
STS는 운영환경에서 생성이 되었고, 테스트환경으로 옮겨졌다는 전제로 시작합니다. 
- 참고 문서 : [STS 생성하는 방법](/blog/oracle/how-to-create-sqlset/){: target="_blank"}

테스트환경에서는 Pre-SQL trial은 실제 SQL구문을 실행하지 않고  STS정보를 사용하였습니다. 
post-SQL trial은 테스트환경에서 SQL를 모두 실행하도록 작성하였습니다. 
마지막에 buffer gets관점에서 성능 비교하고나서 Report을 확인하는 작업을 수행합니다.

### SPA 작업 수행

```sql
SQL> declare
  t_name varchar2(100);
  execute_name1 varchar2(100) := 'EXEC_SPA_SQL#1';
  execute_name2 varchar2(100) := 'EXEC_SPA_SQL#2';
begin 
 t_name:= DBMS_SQLPA.CREATE_ANALYSIS_TASK(
      task_name => 'my_spa_task',
      sqlset_name => 'STS_CaptureAWR',
      sqlset_owner => 'admin'); 

  DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
     task_name => t_name, 
     execution_name => execute_name1, 
     execution_type => 'CONVERT SQLSET', 
     execution_desc => 'Convert STS'); 

  DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
     task_name => t_name, 
     execution_name => execute_name2, 
     execution_type => 'TEST EXECUTE', 
     execution_desc => 'Test Workload in 23c'); 
     
   DBMS_SQLPA.EXECUTE_ANALYSIS_TASK( 
     task_name => t_name, 
     execution_name => 'Compare BUFFER_GETS', 
     execution_type => 'COMPARE PERFORMANCE', 
     execution_params => 
       DBMS_ADVISOR.ARGLIST( 
               'comparison_metric', 
               'buffer_gets', 
               'execution_name1',execute_name1, 
               'execution_name2',execute_name2), 
     execution_desc => 'Compare BUFFER_GETS'
     ); 
end;
/

PL/SQL procedure successfully completed.
```

### SPA 결과확인
```sql
SET PAGESIZE 0
SET LINESIZE 1000
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET TRIMSPOOL ON
SET TRIM ON
set echo off
set feedback off

SQL> SELECT DBMS_SQLPA.report_analysis_task('my_spa_task','TEXT','ALL','ALL') FROM   dual;
General Information
---------------------------------------------------------------------------------------------

 Task Information:                              Workload Information:
 ---------------------------------------------  ---------------------------------------------
  Task Name    : my_spa_task                     SQL Tuning Set Name        : STS_CaptureAWR
  Task Owner   : ADMIN                           SQL Tuning Set Owner       : ADMIN
  Description  :                                 Total SQL Statement Count  : 29

Execution Information:
---------------------------------------------------------------------------------------------
  Execution Name             : Compare BUFFER_GETS    Started             : 12/01/2023 08:05:34
  Execution Type             : COMPARE PERFORMANCE    Last Updated        : 12/01/2023 08:05:34
  Description                : Compare BUFFER_GETS    Global Time Limit   : UNLIMITED
  Scope                      : COMPREHENSIVE          Per-SQL Time Limit  : UNUSED
  Status                     : COMPLETED              Number of Errors    : 0
  Number of Unsupported SQL  : 12

Analysis Information:
---------------------------------------------------------------------------------------------
 Before Change Execution:                       After Change Execution:
 ---------------------------------------------  ---------------------------------------------
  Execution Name      : EXEC_SPA_SQL#1           Execution Name      : EXEC_SPA_SQL#2
  Execution Type      : CONVERT SQLSET           Execution Type      : TEST EXECUTE
  Scope               : COMPREHENSIVE            Scope               : COMPREHENSIVE
  Status              : COMPLETED                Status              : COMPLETED
  Started             : 12/01/2023 08:05:22      Started             : 12/01/2023 08:05:22
  Last Updated        : 12/01/2023 08:05:22      Last Updated        : 12/01/2023 08:05:34
  Global Time Limit   : UNLIMITED                Global Time Limit   : UNLIMITED
  Per-SQL Time Limit  : UNUSED                   Per-SQL Time Limit  : UNUSED
                                                 Number of Errors    : 0

 ---------------------------------------------
 Comparison Metric: BUFFER_GETS
 ------------------
 Workload Impact Threshold: 1%
 --------------------------
 SQL Impact Threshold: 1%
 ----------------------

Report Summary
---------------------------------------------------------------------------------------------

Projected Workload Change Impact:
-------------------------------------------
 Overall Impact      :  27.42%
 Improvement Impact  :  27.42%
 Regression Impact   :  0%

SQL Statement Count
-------------------------------------------
 SQL Category  SQL Count  Plan Change Count
 Overall              29                  1
 Improved              1                  1
 Unchanged            16                  0
 Unsupported          12                  0

Top 17 SQL Sorted by Absolute Value of Change Impact on the Workload
---------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
|           |               | Impact on | Execution | Metric              | Metric | Impact  | Plan   |
| object_id | sql_id        | Workload  | Frequency | Before              | After  | on SQL  | Change |
-------------------------------------------------------------------------------------------------------
|        53 | c13sma6rkr27c |    27.42% |   3554546 |    34.7612522105495 |      2 |  94.25% | y      |  <-- Plan이 변경됨
|        44 | 7r7636982atn9 |      .66% |    282416 |    12.8517222820237 |      3 |  76.66% | n      |
|        43 | 5mddt5kt45rg3 |      .46% |    296659 |    9.59189170057204 |      3 |  68.72% | n      |
|        45 | 7ws837zynp1zv |      -.1% |    296459 |    4.51186167395829 |      6 | -32.98% | n      |
|        57 | f9u2k84v884y7 |      .09% |     37036 |    12.9958958850848 |      3 |  76.92% | n      |
|        34 | 0y1prvxqc2ra9 |      .08% |   4416286 |    10.0812030742574 |     10 |    .81% | n      |
|        47 | 8z3542ffmp562 |     -.07% |    997006 |    5.71326351095179 |      6 |  -5.02% | n      |
|        58 | g81cbrq5yamf5 |     -.04% |    333554 |    4.52613969552156 |      5 | -10.47% | n      |
|        37 | 1b3utaf6tfhfy |      .01% |     20544 |    5.33834696261682 |      3 |   43.8% | n      |
|        40 | 4bu758jg7fhq2 |     -.01% |         8 |           29552.125 |  33254 | -12.53% | n      |
|        55 | cy9vc0gbhmvy4 |     -.01% |         6 |               29778 |  34275 |  -15.1% | n      |
|        42 | 5kgcmp83y55ga |        0% |        10 |               21425 |  23357 |  -9.02% | n      |
|        38 | 1z0tu8pg3bh1u |        0% |         3 |               72610 |  78470 |  -8.07% | n      |
|        46 | 8vw69z0b7h9br |        0% |        10 |             18632.9 |  19851 |  -6.54% | n      |
|        35 | 140xxcvs92yp3 |        0% |         2 |               29518 |  33988 | -15.14% | n      |
|        41 | 5ckxyqfvu60pj |        0% |    889618 |    4.00247072338914 |      4 |    .06% | n      |
|        49 | a7q96p26uzq9a |        0% |    119563 | .000200730995374823 |      0 |    100% | n      |
-------------------------------------------------------------------------------------------------------
Note: time statistics are displayed in microseconds
---------------------------------------------------------------------------------------------
```

SPA report에는 SQL별로 SQL Plan정보 및 성능 정보에 대한 정보가 있습니다.
전후를 비교하여 SQL 변경을 확인할수 있습니다. 

```sql
---------------------------------------------------------------------------------------------

Report Details
---------------------------------------------------------------------------------------------

SQL Details:
-----------------------------
 Object ID            : 53
 Schema Name          : SOE
 Container Name       : Unknown (con_dbid: 909607496)
 SQL ID               : c13sma6rkr27c
 Execution Frequency  : 3554546
 SQL Text             : SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME,
                      PRODUCT_DESCRIPTION, CATEGORY_ID, WEIGHT_CLASS,
                      WARRANTY_PERIOD, SUPPLIER_ID, PRODUCT_STATUS, LIST_PRICE,
                      MIN_PRICE, CATALOG_URL, QUANTITY_ON_HAND FROM PRODUCTS,
                      INVENTORIES WHERE PRODUCTS.CATEGORY_ID = :B3 AND
                      INVENTORIES.PRODUCT_ID = PRODUCTS.PRODUCT_ID AND
                      INVENTORIES.WAREHOUSE_ID = :B2 AND ROWNUM < :B1

Bind Variables:
-----------------------------
 1  -  (NUMBER):  197
 2  -  (NUMBER):  184
 3  -  (NUMBER):  15

Execution Statistics:
-----------------------------
------------------------------------------------------------------
|                       | Impact on | Value   | Value   | Impact |
| Stat Name             | Workload  | Before  | After   | on SQL |
------------------------------------------------------------------
| elapsed_time          |    10.29% | .000077 | .000009 | 88.29% |
| parse_time            |           |         | .000947 |        |
| cpu_time              |    12.37% | .000073 | .000009 | 87.65% |
| user_io_time          |           |         |       0 |        |
| buffer_gets           |    27.42% |      34 |       2 | 94.25% |
| cost                  |        0% |       6 |       6 |     0% |
| reads                 |        0% |       0 |       0 |   100% |
| writes                |        0% |       0 |       0 |     0% |
| io_interconnect_bytes |           |         |       0 |        |
| rows                  |           |       4 |       0 |        |
------------------------------------------------------------------
Note: time statistics are displayed in seconds

Notes:
-----------------------------

After Change:
 1. The statement was first executed to warm the buffer cache.
 2. Statistics shown were averaged over next 9 executions.


Findings (4):
-----------------------------
 1. The performance of this SQL has improved.
 2. The structure of the SQL execution plan has changed.
 3. This SQL statement returned zero rows.
 4. The number of returned rows in execution 'EXEC_SPA_SQL#1' is different than
    in execution 'EXEC_SPA_SQL#2'.


Execution Plan Before Change:
-----------------------------
 Plan Hash Value  : 2393254267

-------------------------------------------------------------------------------------------------------------
| Id | Operation                                    | Name                 | Rows | Bytes | Cost | Time     |
-------------------------------------------------------------------------------------------------------------
|  0 | SELECT STATEMENT                             |                      |      |       |    6 |          |
|  1 |   COUNT STOPKEY                              |                      |      |       |      |          |
|  2 |    HASH JOIN                                 |                      |    1 |   405 |    6 | 00:00:01 |
|  3 |     NESTED LOOPS                             |                      |    1 |   405 |    6 | 00:00:01 |
|  4 |      STATISTICS COLLECTOR                    |                      |      |       |      |          |
|  5 |       HASH JOIN OUTER                        |                      |    1 |   391 |    4 | 00:00:01 |
|  6 |        NESTED LOOPS OUTER                    |                      |    1 |   391 |    4 | 00:00:01 |
|  7 |         STATISTICS COLLECTOR                 |                      |      |       |      |          |
|  8 |          TABLE ACCESS BY INDEX ROWID BATCHED | PRODUCT_INFORMATION  |    1 |   178 |    2 | 00:00:01 |
|  9 |           INDEX RANGE SCAN                   | PROD_CATEGORY_IX     |    1 |       |    1 | 00:00:01 |
| 10 |         TABLE ACCESS BY INDEX ROWID BATCHED  | PRODUCT_DESCRIPTIONS |    1 |   213 |    2 | 00:00:01 |
| 11 |          INDEX RANGE SCAN                    | PRD_DESC_PK          |    1 |       |    1 | 00:00:01 |
| 12 |        TABLE ACCESS FULL                     | PRODUCT_DESCRIPTIONS |    1 |   213 |    2 | 00:00:01 |
| 13 |      TABLE ACCESS BY INDEX ROWID             | INVENTORIES          |    1 |    14 |    2 | 00:00:01 |
| 14 |       INDEX UNIQUE SCAN                      | INVENTORY_PK         |    1 |       |    1 | 00:00:01 |
| 15 |     TABLE ACCESS BY INDEX ROWID BATCHED      | INVENTORIES          |    1 |    14 |    2 | 00:00:01 |
| 16 |      INDEX RANGE SCAN                        | INV_WAREHOUSE_IX     |    1 |       |    1 | 00:00:01 |
-------------------------------------------------------------------------------------------------------------

Notes
-----
- This is an adaptive plan


Execution Plan After Change:
-----------------------------
 Plan Id          : 215
 Plan Hash Value  : 124060720

-----------------------------------------------------------------------------------------------------------
| Id  | Operation                                 | Name                 | Rows | Bytes | Cost | Time     |
-----------------------------------------------------------------------------------------------------------
|   0 | SELECT STATEMENT                          |                      |    1 |   405 |    6 | 00:00:01 |
| * 1 |   COUNT STOPKEY                           |                      |      |       |      |          |
|   2 |    NESTED LOOPS                           |                      |    1 |   405 |    6 | 00:00:01 |
|   3 |     NESTED LOOPS                          |                      |    1 |   405 |    6 | 00:00:01 |
|   4 |      NESTED LOOPS OUTER                   |                      |    1 |   391 |    4 | 00:00:01 |
|   5 |       TABLE ACCESS BY INDEX ROWID BATCHED | PRODUCT_INFORMATION  |    1 |   178 |    2 | 00:00:01 |
| * 6 |        INDEX RANGE SCAN                   | PROD_CATEGORY_IX     |    1 |       |    1 | 00:00:01 |
|   7 |       TABLE ACCESS BY INDEX ROWID BATCHED | PRODUCT_DESCRIPTIONS |    1 |   213 |    2 | 00:00:01 |
| * 8 |        INDEX RANGE SCAN                   | PRD_DESC_PK          |    1 |       |    1 | 00:00:01 |
| * 9 |      INDEX UNIQUE SCAN                    | INVENTORY_PK         |    1 |       |    1 | 00:00:01 |
|  10 |     TABLE ACCESS BY INDEX ROWID           | INVENTORIES          |    1 |    14 |    2 | 00:00:01 |
-----------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
------------------------------------------
* 1 - filter(ROWNUM<:B1)
* 6 - access("I"."CATEGORY_ID"=:B3)
* 8 - access("D"."PRODUCT_ID"(+)="I"."PRODUCT_ID")
* 9 - access("INVENTORIES"."PRODUCT_ID"="I"."PRODUCT_ID" AND "INVENTORIES"."WAREHOUSE_ID"=:B2)
...
```

환경변경사항으로 Adaptive plan기능을 비활성화(optimizer_adaptive_plans=false)하는 작업을 수행했습니다. 결과 SQL_ID(c13sma6rkr27c)만 SQL Plan이 변경이 되었습니다. 


SPA 작업에 대한 결과를 확인할수 있습니다. 
```sql
SQL> SELECT owner, task_name, status FROM dba_advisor_tasks WHERE upper(advisor_name)='SQL PERFORMANCE ANALYZER'; 
OWNER      TASK_NAME            STATUS
---------- -------------------- -----------
ADMIN      my_spa_task          COMPLETED

SQL> select task_name, execution_name,EXECUTION_TYPE,EXECUTION_START START_DT, EXECUTION_END END_DT, status 
from dba_advisor_executions where TASK_NAME = 'my_spa_task';
TASK_NAME            EXECUTION_NAME       EXECUTION_TYPE       START_DT            END_DT              STATUS
-------------------- -------------------- -------------------- ------------------- ------------------- -----------
my_spa_task          Compare BUFFER_GETS  COMPARE PERFORMANCE  2023-12-01 08:05:34 2023-12-01 08:05:34 COMPLETED
my_spa_task          EXEC_SPA_SQL#1       CONVERT SQLSET       2023-12-01 08:05:22 2023-12-01 08:05:22 COMPLETED
my_spa_task          EXEC_SPA_SQL#2       TEST EXECUTE         2023-12-01 08:05:22 2023-12-01 08:05:34 COMPLETED
```

## 후속작업(튜닝 및 실행계획 고정)

성능이 저하된 SQL이 발견이 되면 튜닝작업을 수행해서 성능을 개선시키거나, 이전의 실행계획으로 고정하면 성능을 유지할수 있습니다. 

SQL 검증이후 방법
1. 먼저 Regression SQL목록을 STS로 생성
   ```sql
   -- STS 생성
   SQL> exec SYS.dbms_sqlset.CREATE_SQLSET(sqlset_name=>'STS_regressed_sql');
   -- Compare Performance를 수행한 Task를 이용하여 Regressed SQL정보를 가져옴.
   -- level_filter조건이 다양하게 있음. (IMPROVED, REGRESSED(default), CHANGED, UNCHANGED, CHANGED_PLANS, UNCHANGED_PLANS, ERRORS, MISSING_SQL, NEW_SQL)
   SQL> DECLARE
     cur sys_refcursor;
   BEGIN
     OPEN cur FOR
     SELECT VALUE (P) 
     FROM table(DBMS_SQLTUNE.SELECT_SQLPA_TASK(TASK_NAME=>'my_spa_task', EXECUTION_NAME=>'Compare BUFFER_GETS',LEVEL_FILTER=> 'REGRESSED')) p;
      dbms_sqlset.load_sqlset('STS_regressed_sql', cur);
      CLOSE cur;
    END;
    /
    -- SQL 개수확인
    SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'STS_regressed_sql';
   ```
2. Regression SQL들을 SQL Plan baselines으로 실행계획으로 고정(SPM을 사용하고 있다면)
   ```sql
    DECLARE
    my_plans PLS_INTEGER;
    BEGIN
    my_plans := DBMS_SPM.LOAD_PLANS_FROM_SQLSET(
        sqlset_name => 'STS_regressed_sql',
        fixed        => 'YES',
        enabled      => 'YES');
    END;
    /
    ```
3. SQL Tuning Advisor를 통해서 성능 개선수행
   ```sql
   -- STS로부터 STA를 수행 (혹은 SPA결과를 직접 STA와 연동시킬수 있습니다.)
   DECLARE
     sts_name varchar2(100) := 'STS_regressed_sql';
     sts_owner varchar2(100):= 'ADMIN';
     tune_task_name varchar2(100):= 'TUNE_TASK1';
     tname varchar2(100);
     exec_name varchar2(100);
   BEGIN
     tname := DBMS_SQLTUNE.CREATE_TUNING_TASK(sqlset_name  => sts_name, 
                                           sqlset_owner => sts_owner, 
                                           task_name    => tune_task_name);
     DBMS_SQLTUNE.SET_TUNING_TASK_PARAMETER(tname, 
                                              'APPLY_CAPTURED_COMPILENV', 
                                              'FALSE');
     exec_name := DBMS_SQLTUNE.EXECUTE_TUNING_TASK(tname);
   END;
   /

   SQL> set lines 1000
   SQL> set long 999999
   -- STA 리포트를 확인(SQL Profile이 만들어지면 적용합니다.)
   SQL> select dbms_sqltune.report_tuning_task ('TUNE_TASK1') from dual;
   ```
 

## 마무리

SPA 사용방법에 대해서 알아보았습니다. 튜닝대상을 선정하여 STS를 만들어 놓고, 환경 변경을 기점으로 두번의 실행으로 성능에 대한 변경에 대해서 곧바로 확인할수 있습니다. 
SPA수행할때는 수행되는 DB서버에서 시간이 소요되고 부하가 발생됩니다. 운영서버에서 테스트환경에 원격으로 실행시키도록 작업을 만들수도 있고, SQL Plan만 가지고 성능을 유추해볼수도 있습니다. 

변경에 대한 영향을 DB안에서 테스트해볼수 있다는것이 큰 이점이 있는것 같습니다. 변경관리에 영향도후에 후속작업으로 튜닝으로 연결된다면 더 안정되게 시스템을 운영할수 있을것입니다.

## 참고문서

- Documents
  - [SQL Performance Analyzer](https://docs.oracle.com/en/database/oracle/oracle-database/19/ratug/introduction-to-sql-performance-analyzer.html){: target="_blank"}
  - [DBMS_SQLPA Packages](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQLPA.html){: target="_blank"}
  - [DBMS_SQLTUNE.SELECT_SQLPA_TASK Function](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQLTUNE.html#GUID-510255F3-7850-4FDB-A3EB-4B3E65323274){: target="_blank"}

- Blogs
  - [SPA관련 스크립트(spa_*.sql,spa_report_*.sql)](https://mikedietrichde.com/scripts/){: target="_blank"}