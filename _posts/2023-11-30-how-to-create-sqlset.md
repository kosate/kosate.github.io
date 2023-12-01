---
layout: single
title: SQL Tuning Set 생성방법
date: 2023-11-30 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - sql tuning set
   - sts
excerpt : SQL Tuning Set 생성 절차를 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스는 SQL튜닝을 위하여 SQL튜닝 세트(SQL Tuning Set)를 만들수 있습니다.
만들어진 STS를 이용하여 다양한 Advisor기능과 연동이 가능합니다. 

본문에서는 STS 생성하는 방법과 이동하는 방법에 대해서 알아보겠습니다.

## STS(SQL Tuning Set) 이란?

STS는 다양한 Tuning Tool에 사용되는 데이터베이스 객체입니다.
STS는 SQL Tuning Advisor, SQL Access Advisor, SQL Performance Analyzer등에 사용됩니다.
- STS에 포함된 정보
  - SQL 문장들의 모음
  - SQL 실행환경 정보(스키마, Application Module/Action, 바인드변수, Cursor생성을 위한 환경정보(옵티마이저변수, Plan정보))
  - SQL 실행결과 (실행시간, CPU, Buffer Gets, Disk Reads, Rows Processed, 실행횟수, Cost등)

STS는 데이터베이스간에 이동이 가능하여, 운영에서 문제가 되었던 SQL구문을 테스트환경에서 재현할때 사용할수 있습니다. 업그레이드시에 SQL성능테스트할때도 SPA(SQL Performance Analyzer)와 같이 사용됩니다.

## (테스트) 업무 발생
SQL Tuning Set를 만들기 위하여 임의 업무를 수행하였습니다.
업무수행은 Swingbench 도구을 통해서 Order Entry Schema에 OLTP업무를 발생시켰습니다(약 5분간수행)  

참조 : [Swingbench 소개(2.7) 및 설치 방법 ](/blog/oracle/introduce-swingbench/){: target="_blank"}

수행내용(5분간 부하 발생)
```bash
[oracle@instance-20230922-1608 bin]$ ./charbench -c ../configs/SOE_Server_Side_V2_test1.xml -v tpm,tps,users,resp,vresp

Swingbench
Author  :        Dominic Giles
Version :        2.7.0.1313

Results will be written to results.xml
Hit Return to Terminate Run...

Time     TPM      TPS     Users       Response NCR   UCD   BP    OP    PO    BO    SQ    WQ    WA
01:27:56 0        0       [0/10]      0        0     0     0     0     0     0     0     0     0
01:27:57 0        0       [0/10]      0        0     0     0     0     0     0     0     0     0
..
01:28:16 9997     314     [10/10]     14       22    0     109   176   6     1     0     0     0
01:28:17 10292    295     [10/10]     14       22    0     24    53    2     119   0     0     0
..
01:32:55 37546    648     [10/10]     11       2     4     26    50    10    10    0     0     0
01:32:56 37333    469     [10/10]     11       9     1     24    52    13    3     0     0     0
01:32:57 37143    480     [10/10]     11       10    6     5     26    16    7     0     0     0
Saved results to results00001.xml
01:32:58 36651    199     [0/10]      11       8     9     34    25    5     7     0     0     0
Completed Run.
[oracle@instance-20230922-1608 bin]$
```

## STS 생성 절차

STS는 AWR과 Cursor정보를 이용(캡쳐)하여 생성할수 있습니다.
AWR로 부터 STS를 생성할때는 AWR의 Snapshot ID를 지정하여 수행하고, Cursor로부터 캡쳐할때는 특정 시간동안 반복적으로 조회하여 STS에 저장합니다. 

STS은 SYSAUX테이블스페이스의 SQL_MANAGEMENT_BASE영역에 저장됩니다. (SQL개수별로 평균 10K~20K정도의 공간이 필요한것 같습니다. SQL 구문이 길어질수록 더 많은 공간이 필요합니다.(SQL Plan길이, SQL구문길이에 따라 차이발생))
```sql
SQL> SELECT  occupant_name, space_usage_kbytes FROM v$sysaux_occupants WHERE occupant_name ='SQL_MANAGEMENT_BASE';

OCCUPANT_NAME                                                    SPACE_USAGE_KBYTES
---------------------------------------------------------------- ------------------
SQL_MANAGEMENT_BASE                                                            6528

SQL>
```
- STS생성을 위한 소스(dbms_sqltune.load_sqlset)
  - AWR(Automatic Workload Repository) 
    - dbms_sqlset.select_workload_repository : AWR는 High-load SQL(Top X개)만 저장됨
  - Shared SQL Area
    - dbms_sqlset.select_cursor_cache : Shared SQL Area로 부터 수집(SQL_ID, Plan_hash_value별로 하나의 row가 생성됨)
    - dbms_sqlset.capture_cursor_cache_sqlset : 지정된 시간동안 반복적으로 polling방식으로데이터를 수집하는 방법(업무가 수행시점에 모든 워크로드 수집가능)
  - SQL Trace
    - dbms_sqlset.select_sql_trace : 10046 trace를 읽어서 STS로 변환합니다.
  - 다른 STS
    - dbms_sqlset.select_sqlset : 다른 STS를 참고할수 있습니다.

※ SQL Tuning Set관련 기능은 DBMS_SQLSET 패키지와 DBMS_SQLTUNE패키지 모두 지원합니다.

### AWR로 부터 STS 생성

AWR으로 부터 STS 생성합니다.튜닝목적에 맞게 범위나 필터링 조건을 추가하여 생성할수 있습니다.

```sql
-- STS 생성
SQL> exec SYS.dbms_sqlset.CREATE_SQLSET( sqlset_name=>'STS_CaptureAWR', description=>'Statements from AWR Before-Change');
-- STS삭제시
-- exec SYS.dbms_sqlset.DROP_SQLSET( sqlset_name=>'STS_CaptureAWR' );

-- STS생성전에 마지막 로드 정보를 AWR에 저장
SQL> exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

-- AWR의 처음과 마지막 id를 확인  (업무 수행시점은 146~147임)
SQL> SELECT min(snap_id) begin_id, max(snap_id) end_id FROM dba_hist_snapshot;
  BEGIN_ID     END_ID
---------- ----------
         1        147

-- AWR 정보를 STS에 저장
-- 실행시간(elapsed_time) 기준 상위 5000개(result_limit)의 SQL을 저장
SQL> DECLARE
  cur sys_refcursor;
  begin_id   number := 146;
  end_id     number := 147;
  BEGIN
	open cur for
	  select value(p) from table(dbms_sqlset.select_workload_repository(
		   begin_snap       => begin_id,
		   end_snap         => end_id,
		   basic_filter     => 'parsing_schema_name not in (''DBSNMP'',''SYS'',''ORACLE_OCM'')',
		   ranking_measure1 => 'elapsed_time',
		   result_limit     => 5000)) p;
	  dbms_sqlset.load_sqlset('STS_CaptureAWR', cur);
	close cur;
END;
/ 

-- SQL문장 갯수 확인
SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'STS_CaptureAWR';
STATEMENT_COUNT
---------------
             32

-- SQL문장별 성능 정보 확인 
SQL> SELECT SQL_ID, SQL_TEXT, ELAPSED_TIME, BUFFER_GETS, DISK_READS, EXECUTIONS FROM dba_sqlset_statements where SQLSET_NAME = 'STS_CaptureAWR';
SQL_ID        SQL_TEXT                                                                         ELAPSED_TIME BUFFER_GETS DISK_READS EXECUTIONS
------------- -------------------------------------------------------------------------------- ------------ ----------- ---------- ----------
0w2qpuc6u2zsp BEGIN :1 := orderentry.neworder(:2 ,:3 ,:4 ); END;                                 1235113144    31995640     297447      58908
c13sma6rkr27c SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG    516104046    24594726         84     704900
147a57cxq3w5y BEGIN :1 := orderentry.browseproducts(:2 ,:3 ,:4 ); END;                            481841817     8891051         20      73566
0y1prvxqc2ra9 SELECT PRODUCTS.PRODUCT_ID, PRODUCT_NAME, PRODUCT_DESCRIPTION, CATEGORY_ID, WEIG    265393178     8885304          8     880186
f7rxuxzt64k87 INSERT INTO ORDER_ITEMS ( ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTI    136406267     2844587     112679     179866
3fw75k1snsddx INSERT INTO ORDERS ( ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS     87701342     1069483      27228      58905
01jzc2mg6cg92 BEGIN :1 := orderentry.newcustomer(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ,:8 ,:9 ,:10 ); END;       60452443      987597      39860      22089
apgb2g9q2zjh1 BEGIN :1 := orderentry.browseandupdateorders(:2 ,:3 ,:4 ); END;                      39730834      179256      33025       7362
5mddt5kt45rg3 UPDATE ORDERS SET ORDER_MODE = 'online', ORDER_STATUS = FLOOR(DBMS_RANDOM.VALUE(     28005071      562574       1500      58908
8z3542ffmp562 SELECT QUANTITY_ON_HAND FROM PRODUCT_INFORMATION P, INVENTORIES I WHERE I.PRODUC     27909428     1135760          3     198634
5ckxyqfvu60pj SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY     24039009      706895      45253     176632
7r7636982atn9 UPDATE INVENTORIES SET QUANTITY_ON_HAND = QUANTITY_ON_HAND - :B1 WHERE PRODUCT_I     21220849      723616         27      56243
7t0959msvyt5g SELECT ORDER_ID, ORDER_DATE, ORDER_MODE, CUSTOMER_ID, ORDER_STATUS, ORDER_TOTAL,     19838375       33809      11941       7362
gh2g2tynpcpv1 INSERT INTO CUSTOMERS ( CUSTOMER_ID , CUST_FIRST_NAME , CUST_LAST_NAME , NLS_LAN     18175092      411321      23681      22092
g81cbrq5yamf5 SELECT ADDRESS_ID, CUSTOMER_ID, DATE_CREATED, HOUSE_NO_OR_NAME, STREET_NAME, TOW     16066112      299528      66271      66243
a9gvfh5hx9u98 BEGIN :1 := orderentry.processorders(:2 ,:3 ,:4 ); END;                              14847146      213239      21376       7345
7ws837zynp1zv SELECT CARD_ID, CUSTOMER_ID, CARD_TYPE, CARD_NUMBER, EXPIRY_DATE, IS_VALID, SECU     12316369      265504      56585      58897
cmndgkbkcz5s9 BEGIN :1 := orderentry.updateCustomerDetails(:2 ,:3 ,:4 ,:5 ,:6 ,:7 ,:8 ); END;      11606673      103107      15205      14833
9t3n2wpr7my63 INSERT INTO ADDRESSES ( ADDRESS_ID, CUSTOMER_ID, DATE_CREATED, HOUSE_NO_OR_NAME,      8205275      261454       9983      24608
budtrjayjnvw3 INSERT INTO CARD_DETAILS ( CARD_ID, CUSTOMER_ID, CARD_TYPE, CARD_NUMBER, EXPIRY_      7875636      162556       7459      22092
1qf3b7a46jm3u SELECT ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY,DISPATCH_DATE, R      6903302       13871       5558       3382
gzhkw1qu6fwxm INSERT INTO LOGON (LOGON_ID,CUSTOMER_ID, LOGON_DATE) VALUES (LOGON_SEQ.NEXTVAL,       6440402       77196         99      29383
7hk2m2702ua0g WITH NEED_TO_PROCESS AS (SELECT ORDER_ID, CUSTOMER_ID FROM ORDERS WHERE ORDER_ST      5403001      117538      18577       7345
f9u2k84v884y7 UPDATE /*+ index(orders, order_pk) */ ORDERS SET ORDER_STATUS = FLOOR(DBMS_RANDO      5246989       95682       2799       7345
8zz6y2yzdqjp0 SELECT CUSTOMER_ID, CUST_FIRST_NAME, CUST_LAST_NAME, NLS_LANGUAGE, NLS_TERRITORY      3538888       60174      13903      14832
491wcfyfd6wc1 BEGIN DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT; END;                                  1554202       57583       2799          1
1b3utaf6tfhfy UPDATE ORDER_ITEMS SET QUANTITY = QUANTITY + 1 WHERE ORDER_ITEMS.ORDER_ID = :B2       1107833       18026       2303       3373
4z3ktqk9zq1j9 SELECT CUSTOMER_SEQ.NEXTVAL FROM DUAL                                                  870428           0          0      22088
c749bc43qqfz3 SELECT SYSDATE FROM DUAL                                                               836084           0          0      29380
a7q96p26uzq9a SELECT ADDRESS_SEQ.NEXTVAL FROM DUAL                                                   626708           0          0      24609
4065gwcf6n8ck select 1 from user_tables where table_name =  'ORDERENTRY_METADATA'                     69186         540         25          1
awuwhfhgh5qz5 select sys_context('userenv','con_name') from dual                                       2867           0          0         21
```

부하 발생시점을 확인해서 AWR 데이터로 부터 STS 생성작업을 했습니다. 
AWR 모든 데이터를 STS로 생성할수 있지면 필터링해서 일부 데이터만 선별해서 저장할수도 있습니다. 

### Cursor로 부터 STS생성

Shared Cursor로 부터 STS 생성합니다. 

```sql
-- STS 생성
SQL> exec SYS.dbms_sqlset.CREATE_SQLSET(sqlset_name=>'STS_CaptureCursorCache', description=>'Statements from Before-Change' );
-- STS삭제시
-- exec SYS.dbms_sqlset.DROP_SQLSET( sqlset_name=>'STS_CaptureCursorCache' );

-- Shared Cursor로부터 STS저장
-- 현재 Cursor정보를 저장합니다.
SQL> DECLARE
  cur sys_refcursor; 
  BEGIN
	open cur for
	  select value(p) from table(DBMS_SQLSET.SELECT_CURSOR_CACHE(
            basic_filter => 'parsing_schema_name not in (''DBSNMP'',''SYS'',''ORACLE_OCM'')')) p;
	  dbms_sqlset.load_sqlset('STS_CaptureCursorCache', cur);
	close cur;
END;
/ 

-- SQL문장 갯수 확인
SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'STS_CaptureCursorCache';
STATEMENT_COUNT
---------------
             65

-- Shared Cursor로부터 STS에 저장
-- Cursor로부터 캡쳐할때는 polling방식으로 수집합니다.
-- 총 30초동안(time_limit) 5초에(repeat_interval) 한번씩 캡쳐합니다
-- capture mode에는 MODE_REPLACE_OLD_STATS(execute가 커지면 통계정보를 replace)와 MODE_ACCUMULATE_STATS(변경되면 통계정보를 add함) 두가지 모드 제공

SQL> begin
 DBMS_SQLTUNE.CAPTURE_CURSOR_CACHE_SQLSET(
        sqlset_name => 'STS_CaptureCursorCache',
        time_limit => 30,
        repeat_interval => 5,
        capture_option => 'MERGE',
        capture_mode => DBMS_SQLTUNE.MODE_ACCUMULATE_STATS,
        basic_filter  => 'parsing_schema_name not in (''DBSNMP'',''SYS'',''ORACLE_OCM'')',
		    sqlset_owner => NULL,
        recursive_sql => 'HAS_RECURSIVE_SQL');
end;
/
PL/SQL procedure successfully completed.
Elapsed: 00:00:30.41

-- SQL문장 갯수 확인 (1개밖에 증가되지 않음. 해당시간에 업무가 수행되지 않아서 수집된 SQL이 적습니다.)
SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'STS_CaptureCursorCache';
STATEMENT_COUNT
---------------
             66
```

## STS Export & Import 방법

STS를 다른 DB로 이동시킬수 있습니다. 
STS를 위하여 Stage 테이블을 생성후에 STS를 저장후 expdp & impdp를 통해서 이동합니다.

### STS Packing 및 Export 절차 

Stage 테이블을 생성후, STS를 packing 후 Export합니다.
```sql
-- Stage 테이블을 생성합니다(dba_sqlset관련 테이블의 join된 형태로 반정규화된 테이블로 생성됩니다.)
SQL> exec dbms_sqlset.CREATE_STGTAB_SQLSET (table_name  => 'TAB_STAGE1',schema_name => 'ADMIN');

-- STS_CaptureAWR STS를 Stage 테이블에 저장합니다.
SQL> begin 
dbms_sqlset.PACK_STGTAB_SQLSET(
    sqlset_name =>'STS_CaptureAWR',
    sqlset_owner=>'ADMIN',
	staging_schema_owner  =>'ADMIN',
    staging_table_name  =>'TAB_STAGE1');
	
end;
/

-- STS_CaptureCursorCache STS를 Stage 테이블에 저장합니다.
SQL> begin 
dbms_sqlset.PACK_STGTAB_SQLSET(
    sqlset_name =>'STS_CaptureCursorCache',
    sqlset_owner=>'ADMIN',
	staging_schema_owner  =>'ADMIN',
    staging_table_name  =>'TAB_STAGE1');
end;
/

-- Expdp를 위하여 디렉토리를 확인합니다.
SQL> select DIRECTORY_PATH From dba_directories where directory_name = 'DATA_PUMP_DIR';

DIRECTORY_PATH
-------------------------------------------------------------------------------------
/opt/oracle/admin/FREE/dpdump/05EF01A1AC931F01E063A300000AB337

-- Export 작업 수행(dbms_datapump 패키지를 통해서 수행했습니다. expdp 도구를 사용해도 동일합니다.)
-- expdp <user_id>/<password>@<tns> TABLES=admin.TAB_STAGE DIRECTORY=DATA_PUMP_DIR DUMPFILE=sts_staging_export.dmp logfile=sts_staging_export_LOG.log
SQL> declare
  l_dp_handle number;
  staging_schema_owner  varchar2(100) := 'ADMIN';
  staging_table_name varchar2(100) := 'TAB_STAGE1';
  expdp_data_file varchar2(1000) := 'sts_staging_export.dmp';
  expdp_log_file varchar2(1000) := 'sts_staging_export_LOG.log';
  expdp_directory varchar2(100) := 'DATA_PUMP_DIR';
begin
  -- Open a table export job.
  l_dp_handle := dbms_datapump.open(
    operation   => 'EXPORT',
    job_mode    => 'TABLE',
    remote_link => NULL,
   job_name    => 'STS_STAGING_EXPORT',
    version     => 'LATEST');

  -- 디렉토리와 파일이름을 지정합니다.
    dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => expdp_data_file,
    directory => expdp_directory); 

  -- 디렉토리와 로그파일이름을 지정합니다.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => expdp_log_file,
    directory => expdp_directory,
    filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

  -- Schema와 table명을 지정합니다. 
  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'SCHEMA_EXPR',
    value  => '= '''||staging_schema_owner||'''');

  dbms_datapump.metadata_filter(
    handle => l_dp_handle,
    name   => 'NAME_EXPR',
    value  => '= '''||staging_table_name||'''');
  -- 작업을 시작합니다.
  dbms_datapump.start_job(l_dp_handle);

  dbms_datapump.detach(l_dp_handle);

end;
/
-- 생성된 dump파일을 확인합니다.
SQL> !ls -al /opt/oracle/admin/FREE/dpdump/05EF01A1AC931F01E063A300000AB337
total 712
drwxr-x---. 2 oracle oinstall     70 Nov 30 02:41 .
drwxr-x---. 4 oracle oinstall    100 Oct 27 05:00 ..
-rw-r-----. 1 oracle oinstall 724992 Nov 30 02:42 sts_staging_export.dmp
-rw-r--r--. 1 oracle oinstall    755 Nov 30 02:42 sts_staging_export_LOG.log

-- log파일내용을 확인합니다.
SQL> !cat /opt/oracle/admin/FREE/dpdump/05EF01A1AC931F01E063A300000AB337/sts_staging_export_LOG.log
Starting "ADMIN"."STS_STAGING_EXPORT":
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Processing object type TABLE_EXPORT/TABLE/TABLE
. . exported "ADMIN"."TAB_STAGE1"                        306.9 KB     256 rows
Master table "ADMIN"."STS_STAGING_EXPORT" successfully loaded/unloaded
******************************************************************************
Dump file set for ADMIN.STS_STAGING_EXPORT is:
  /opt/oracle/admin/FREE/dpdump/05EF01A1AC931F01E063A300000AB337/sts_staging_export.dmp
Job "ADMIN"."STS_STAGING_EXPORT" successfully completed at Thu Nov 30 02:42:04 2023 elapsed 0 00:00:33

SQL>
```

### STS 파일 이동 

```bash
$> cd /opt/oracle/admin/FREE/dpdump/05EF01A1AC931F01E063A300000AB337/
$> scp sts_staging_export.dmp oracle@targetserver:<Target_Path>
```
### STS Import 및 Unpacking 절차

Export된 Stage 테이블을 import 후에 STS를 Unpacking하여 로딩합니다.

```sql
-- impdp를 위하여 디렉토리를 확인합니다.
SQL> select DIRECTORY_PATH From dba_directories where directory_name = 'DATA_PUMP_DIR';

DIRECTORY_PATH
-------------------------------------------------------------------------------------
/opt/oracle/stage


-- import 작업 수행(dbms_datapump 패키지를 통해서 수행했습니다. impdp 도구를 사용해도 동일합니다.)
-- impdp <user_id>/<password>@<tns> TABLES=admin.TAB_STAGE DIRECTORY=DATA_PUMP_DIR DUMPFILE=sts_staging_export.dmp logfile=sts_staging_import_LOG.log

SQL> declare
  l_dp_handle       number;
  expdp_data_file varchar2(1000) := 'sts_staging_export.dmp';
  impdp_log_file varchar2(1000) := 'sts_staging_import_LOG.log';
  impdp_directory varchar2(100) := 'DATA_PUMP_DIR';
  
begin

  l_dp_handle := dbms_datapump.open(
    operation   => 'IMPORT',
    job_mode    => 'TABLE',
    remote_link => NULL,
    job_name    => 'STS_STAGING_IMPORT',
    version     => 'LATEST');

  -- 디렉토리와 expdp파일이름을 지정합니다.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => expdp_data_file,
    directory => impdp_directory);

  -- 디렉토리와 로그파일이름을 지정합니다.
  dbms_datapump.add_file(
    handle    => l_dp_handle,
    filename  => impdp_log_file,
    directory => impdp_directory,
    filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

  dbms_datapump.start_job(l_dp_handle);

  dbms_datapump.detach(l_dp_handle);
  
end;
/

-- Import결과를 확인합니다.
SQL> !cat /opt/oracle/stage/sts_staging_import_LOG.log
Master table "ADMIN"."STS_STAGING_IMPORT" successfully loaded/unloaded
Starting "ADMIN"."STS_STAGING_IMPORT":
Processing object type TABLE_EXPORT/TABLE/TABLE
Processing object type TABLE_EXPORT/TABLE/TABLE_DATA
. . imported "ADMIN"."TAB_STAGE1"                        306.9 KB     256 rows
Processing object type TABLE_EXPORT/TABLE/INDEX/STATISTICS/INDEX_STATISTICS
Processing object type TABLE_EXPORT/TABLE/STATISTICS/TABLE_STATISTICS
Job "ADMIN"."STS_STAGING_IMPORT" successfully completed at Thu Nov 30 03:03:59 2023 elapsed 0 00:00:35

-- STS_CaptureCursorCache STS를 unpack합니다.
SQL> begin
 dbms_sqlset.UNPACK_STGTAB_SQLSET (
      sqlset_name        => 'STS_CaptureCursorCache',
      sqlset_owner       => 'ADMIN',
      replace            => TRUE,
      staging_table_name => 'TAB_STAGE1',
      staging_schema_owner => 'ADMIN' );
end;
/

-- STS_CaptureAWR STS를 unpack합니다.
begin
 dbms_sqlset.UNPACK_STGTAB_SQLSET (
      sqlset_name        => 'STS_CaptureAWR',
      sqlset_owner       => 'ADMIN',
      replace            => TRUE,
      staging_table_name => 'TAB_STAGE1',
      staging_schema_owner => 'ADMIN' );
end;
/

-- Unpack한 STS 목록과 SQL구문수를 확인합니다.
SQL> SELECT name, statement_count FROM dba_sqlset WHERE name in ( 'STS_CaptureCursorCache','STS_CaptureAWR');
NAME                           STATEMENT_COUNT
------------------------------ ---------------
STS_CaptureAWR                              32
STS_CaptureCursorCache                      66
```

## 마무리

STS 생성 방법 및 이동방법에 대해서 알아보았습니다. STS를 생성할때는 SYSAUX테이블스페이스의 여유공간이 있는지 확인후에 작업합니다.튜닝목적에 따라 SQL 범위가 정해지고, 데이터량이 결정됩니다. 
STS에는 SQL구문뿐만아니라 성능정보 및 실행계획 정보를 가지고 있습니다. 
STS를 다른 Advisor기능과 연동해서 튜닝을 하거나, SPM(SQL Plan Management)와 연동해서 SQL Plan baseline으로 Plan을 고정시켜서 운영할수도 있습니다.

## 참고자료 

- Documents
  - [Managing SQL Tuning Sets](https://docs.oracle.com/en/database/oracle/oracle-database/19/tgsql/managing-sql-tuning-sets.html){: target="_blank"}
  - [DBMS_SQLSET Package](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_SQLSET.html){: target="_blank"}
- Blogs
  - [STS 관련 스크립트(capture_awr.sql, capture_cc.sql, export_sts_stagingtable.sql, import_sts_stagingtable.sql)](https://mikedietrichde.com/scripts/){: target="_blank"}