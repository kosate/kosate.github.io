---
layout: single
title: Database Replay 수행방법
date: 2023-11-30 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - db replay
   - real application testing
excerpt : Database Replay 수행방법에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스는 운영 업무무 워크로드를 캡쳐(Capture)하여 재생(Replay)할수 있는 부하 발생기 도구를 제공합니다. 

Database(DB) Replay기능에 대해서 알아보겠습니다. 

swingbench에서 발생되는 워크로드를 이용하여 작업 절차를 정리하였습니다.

## Database Replay기능이란?

Database Replay는 오라클 데이터베이스에서 제공하는 튜닝 도구 중 하나로, 실제 운영 환경에서 발생한 워크로드를 기록하고, 이를 이용하여 테스트 환경에서 동일한 작업을 재현하는 기능을 제공합니다. 이를 통해 데이터베이스 성능을 향상시키는 데 도움이 됩니다.

- 주요기능
  - 워크로드 캡쳐(Capture) 작업 : 운영DB에서 발생되는 SQL 쿼리들을 기록합니다.
  - 워크로드 재생(Replay) 작업 : 기록된 워크로드를 사용하여 테스트환경에서 동일한 워크로드를 수행합니다. 이를 통해 성능변화를 분석하여 튜닝대상을 식별하고 개선할수 있습니다.
  - 워크로드 부하 발생 : 운영DB에서 발생된 워크로드기반으로 테스트 DB에서 발생시키지만 더 많은 사용자를 처리한다는 가정으로 더 많은 부하를 발생시킬수 있습니다. 
  - 성능 분석 및 최적화 : 캡쳐 작업과 재생작업을 비교하면 튜닝대상을 선별할수 있습니다. 반복적으로 수행하여 성능 최적화 작업을 할수 있습니다. 

※  Database Replay는 여러사용자가 접속하는 실 업무워크로드를 기반으로 DB전체의 성능을 보는데 사용됩니다. 인스턴스 튜닝관점으로 접근하는것이 더 낫습니다.

- Database Replay와 연관된 DBMS 패키지 
  - [dbms_workload_capture](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_WORKLOAD_CAPTURE.html){: target="_blank"} : 운영서버에서 워크로드를 Capture할때 사용합니다. 
  - [dbms_workload_replay](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_WORKLOAD_REPLAY.html){: target="_blank"} : Capture된 워크도르를 재 실행할때 사용합니다.

- Database Replay가 지원하지 않는 세션이나 트랜잭션 유형 
  - 주로 XA, Flashback query, SQL*Loader작업, DBRP같은 작업은 Capture되지 않습니다. 
  - 자세한 내용은 아래 메뉴얼문서를 참고하세요.
    - [Workload Capture Restrictions](https://docs.oracle.com/en/database/oracle/oracle-database/19/ratug/capturing-a-database-workload.html#GUID-4A1995F1-78F9-4080-8DFC-1E3EBCB3F4B8){: target="_blank"}


## RAT 활성화 확인

database repaly는 Real Application Testing(RAT)옵션중 하나의 기능입니다. 따라서 RAT옵션이 DBMS 엔진내 활성화되어 있어야 사용가능합니다. (RAC인경우 모든 노드에서 활성화해야합니다.)

관련문서 : [Enabling and Disabling Database Options After Installation](https://docs.oracle.com/en/database/oracle/oracle-database/19/ntdbi/enabling-and-disabling-database-options-after-installation.html){: target="_blank"}

RAT 옵션 활성화 작업
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
--RAT 옵션 활성화 여부 확인
SQL> select value from v$option where parameter = 'Real Application Testing';
VALUE
----------------------------------------------------------------
TRUE
SQL>
```

## 운영서버(Capture작업)

운영 DB서버에서 워크로드를 Capture하면 세션별 SQL수행이력을 파일로 저장합니다.
우선 Capture대상 업무를 선정하고, 모든 SQL 수행이력을 저장하므로 OS에 여유공간이 필요합니다. 

- 운영서버에서 고려사항
  - Capture 대상 업무 선정 
    - Database Replay도구의 특성상 부하 발생기 이므로 부하가 많은 업무를 선정하는것이 유의미한 결과를 도출할수 있습니다
  - OS 여유공간 확인
  - Capture 작업에 대한 부하

### 1. Capture 대상 업무 선정

Capture 대상 업무 선정을 합니다. Database Replay는 특정 시간에 특정 업무를 Filtering해서 Capture가 가능합니다. Capture 대상 업무는 Replay 방법와 같이 연관지어 생각해볼수 있습니다. 
낮에는 OLTP, 밤에는 Batch Job이 동작한다면 낮에 특정시간에 OLTP업무를 Capture하고 밤에 Batch 작업이 수행되는 시간에 Capture하여 Replay시에는 두개의 업무를 Merge해서 수행할수도 있습니다.(테스트환경도 동일한 데이터셋이 있어야 동일한 워크로드가 발생됩니다.). 

- Capture 업무 대상 선정시 고려사항
  - 업무 유형을 고려한 업무선정예시
    - Peak시점에 모든 워크로드 수집 
    - 하나의 복잡한 비즈니스 업무을 선정하여 수집
    - 그외 관심이 있는 업무를 선정하여 수집
  - Capture 시간 확인
    - 선택한 업무에 실행시간을 확인합니다. 이전에 동일한 업무가 수행되었던 시간에 대한 워크로드 분석을 합니다. AWR Report생성하여 Capture 파일 생성량을 미리계산합니다.
    - 배치작업이 있을경우 배치 작업시작부터 완료시간을 Capture할수 있습니다.
  - 테스트DB서버 구성
    - Capture시점의 데이터로 데이터 DB가 구성되어야합니다. 테스트 DB에서는 운영DB에서 수집한 동일한 SQL구문과 바인드변수가 사용되므로 동일한 데이터로 준비되어 있어야 운영과 동일한 워크로드로 재현이 가능합니다.

**테스트 환경구성**

Capture시점과 동일한 데이터가 있어야 동일한 워크로드를 수행할수 있습니다. 

```sql
-- 테스트 환경을 구성합니다.
-- CDB환경에서는 복제 DB를 쉽게 만들수 있습니다.
SQL> create pluggable database pdb1_clone from pdb1;
SQL> alter pluggable database pdb1_clone open;
-- 운영 DB에 부하를 주기 위하여 사용하지 않는 리소스를 내려놓습니다.
SQL> alter pluggable database pdb1_clone close;
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 PDB1                           READ WRITE NO  <--운영 DB로 활용 
         8 PDB1_CLONE                     MOUNTED    NO  <--테스트 DB로 활용
```

**업무 발생 예시(Swingbench업무)**

- Capture 대상업무를 Swingbench업무로 SOE유저로 수행되는 워크로드를 Capture합니다.
  - 업무 발생 방법 : [Swingbench 소개(2.7) 및 설치 방법 ](/blog/oracle/introduce-swingbench/){: target="_blank"}
  - Swingbench는 두가지 부하 처리 방식을 제공
    - DB서버에서 PL/SQL수행 방식 : SOE_Server_Side_V2.xml
    - Client에서 SQL Call수행 방식 : SOE_Client_Side.xml(본문에서 사용한 템플릿입니다.)

```bash
-- 일반적인 애플리케이션을 고려하여 JDBC로 SQL Call하는 방식으로 부하를 발생
$> ./charbench -c ../configs/SOE_Client_Side_test1.xml -v tpm,tps,users,resp,vresp    
```
- Capture 작업에 대한 필터를 적용 : 필터는 제외필터(EXCLUDE), 포함필터(INCLUDE) 두가지 방식으로 구분됩니다. Capture를 시작할때 현재 적용된 필터에 대한 속성을 지정하여 수행합니다.

```sql
-- INSTANCE_NUMBER, USER, MODULE, ACTION, PROGRAM, SERVICE, PDB_NAME를 조건으로 필터적용가능
-- SOE유저로 수행되는 워크로드를 캡쳐하기 위하여 필터를 적용
-- 해당필터는 start_capture할때 결정됩니다. 
-- start_capture(default_action=>'INCLUDE') 일경우 정의한 필터를 제외한 워크로드를 캡쳐하고, 
-- start_capture(default_action=>'EXCLUDE') 일경우 정의한 조건에 맞는 워크로드만 캡쳐합니다.
SQL> execute dbms_workload_capture.add_filter (fname=>'SOE_USER', fattribute=>'USER', fvalue=>'SOE');

-- 설정된 필터 확인
-- start_capture작업으로 필터가 사용되면 STATUS가 NEW 에서 USED로 변경됩니다.
-- 그래서 사용된 필터는 재사용이 되지 않습니다. capture 작업전에 매번 설정해야합니다.
SQL> select name, status, type, set_name, attribute, value from dba_workload_filters;
NAME       STATUS TYPE       SET_NAME   ATTRIBUTE  VALUE
---------- ------ ---------- ---------- ---------- ----------
SOE_USER   NEW    CAPTURE               USER       SOE
```

### 2. OS 디스크 공간 할당(확인)

클라이언트로 부터 발생된 모든 요청내용은 Capture파일로 저장됩니다(바이너리 형식). 클라이언트 요청량을 계산하면 어느정도 필요한 용량산정이 가능합니다. Capture하려는 대상업무가 수행되는 시점의 AWR Report에서 client 네트워크 전송량을 가지고 계산할수 있습니다. 

- Capture를 위해 필요한 디스크 공간 계산식
  - Capture시 생성될 파일 사이즈는 AWR Report로 부터 계산해볼수 있습니다..
  - 디스크 용량 계산식 : Instance Activity Stats의 "bytes received via SQL*Net from client"값 * 2배

```sql 
-- Capture대상 업무의 네트워크 요청 사이즈를 계산  
-- PDB에서는 AWR_PDB_SYSSTAT, Non-CDB에서는 DBA_HIST_SYSSTAT로 조회하면 됩니다.
SQL> SELECT min(snap_id)||'~'||max(snap_id) snap, stat_name,max(value) -  min(value) delta
  FROM awr_pdb_sysstat b
  WHERE b.snap_id in (88,89)
    and stat_name in ('bytes received via SQL*Net from client')
group by stat_name;
SNAP       STAT_NAME                                   DELTA
---------- -------------------------------------- ----------
88~89      bytes received via SQL*Net from client 3897884081

-- Capture시 필요한 디스크 공간 : 3.6G * 2 = 약 7.2G 
```
> 위 디스크공간계산식은 예측일뿐 짧은 시간이라도 수행해서 네트워크 전송량과 생성된 파일 크기를 비교해서 검증해야합니다.
> PL/SQL로 호출하는 업무가 많을 경우 더 많은 데이터를 저장할수 있습니다.

세션별로 Capture 파일(.rec)이 생성됩니다.(SQL구문과 바인드변수저장). 만약 100개의 세션이 Capture되면 100개의 wcr_.rec파일이 생성됩니다.

- 디스크 공간할당시 고려사항
  - Capture파일이 저장되는 디스크는 일반적인 Datafile과 동일한 스토리지로 권고합니다.
    - Capture파일이 저장되는 속도가 느리면 SQL를 실행하는 세션까지 영향이 발생됩니다.
  - RAC환경에서는 Shared 공간을 권고하지만 Local 공간에 저장할수 있습니다.
    - Local공간에 저장했을대는 Capture완료이후에 하나의 디렉토리에 Merge해주는 작업이 필요합니다.


**부하발생(OLTP)**

swingbench도구를 사용하여 부하를 발생시킵니다. 

```bash
-- 약 20분동안 swingbench 부하를 발생됩니다.
$> ./charbench -c ../configs/SOE_Client_Side_test1.xml -v tpm,tps,users,resp,vresp
Swingbench
Time     TPM      TPS     Users       Response NCR   UCD   BP    OP    PO    BO    SQ    WQ    WA
00:23:00 0        0       [0/10]      0        0     0     0     0     0     0     0     0     0
00:23:02 2664     1784    [10/10]     6        4     2     2     8     10    3     0     0     0
00:23:04 6399     1855    [10/10]     6        3     3     5     7     13    4     0     0     0
(생략)
00:35:06 112949   1891    [10/10]     6        3     3     5     5     23    3     0     0     0
00:35:08 113068   1983    [10/10]     6        3     2     2     8     24    3     0     0     0
```

**Capture 작업 시작**

Capture할 업무가 선정이 되면 워크로드 수집작업을 시작합니다.

```sql
-- CAP_DIR 디렉토리에 최소 7.6G이상의 여유공간이 있어야합니다.
SQL> create directory cap_dir as '/oradata/capdir';

-- CAP_DIR 디렉토리에 empty상태여합니다.
-- 만약 파일이 존재할경우 "ORA-38500: capture directory not empty" 에러가 발생됩니다.
SQL> !ls -al  /oradata/capdir
drwxr-xr-x. 2 oracle oinstall 4096 Dec  7 04:55 .
drwxr-xr-x. 9 oracle oinstall 4096 Dec  7 04:55 ..

-- 워크로드 Capture작업을 수행
-- 필터는 EXCLUDE속성(업무를 지정)으로 사용함. duration을 주지 않으면 finish_capture할때까지 워크로드를 계속 Capture함.
-- Capture작업과 병행하여 cursor로부터 sql tuning set를 생성함
-- . sts_cap_interval 초에 한번씩 수집(기본 300초)
-- . RAC환경은 STS수집을 지원하지 않으며 에러 발생됨
-- . SQL Tuning Set에는 Capture에 적용된 Filter가 적용되지 않음
-- . export_awr작업을 하면 sts도 같이 export됨.
-- plsql_mode를 extended설정하면 top-level뿐만 아니라 호출된 SQL까지 같이 capture됨
SQL> execute dbms_workload_capture.start_capture (name=>'CAP_SOE', dir=>'CAP_DIR', duration=> null, default_action=> 'EXCLUDE', capture_sts=> TRUE, sts_cap_interval=> 60, plsql_mode => 'extended');

-- alert.log에 아래와 같은 메시지가 발생됩니다.
2023-12-08 00:23:57.235000 +00:00
DBMS_WORKLOAD_CAPTURE.START_CAPTURE(): Starting database capture at 12/08/2023 00:23:57

-- start_capture를 수행하면 AWR Snapshot이 한번 수행됩니다.
-- PDB일경우 AWR_PDB_SNAPSHOT을 조회, Non-CDB일경우 dba_hist_snapshot을 조회합니다.
SQL> SELECT min(snap_id) begin_id, max(snap_id) end_id FROM awr_pdb_snapshot;
 BEGIN_ID     END_ID
---------- ----------
         1         88 

```

> RAC환경에서 Database Repaly 고려사항에 대해서 정리했으니 참고하시기 바랍니다.
> - 참고블로그 : [RAC환경에서 Database Repaly 고려사항](/blog/oracle/how-to-capture-workload-on-rac/){: target="_blank"}

**Capture 작업 중지**

워크로드 수집이 완료되면 Capture작업을 중지합니다.

```sql
-- 워크로드 Capture 작업 중지수행
SQL> execute dbms_workload_capture.finish_capture();
-- alert.log에 아래와 같은 메시지가 발생됩니다.
2023-12-08 00:29:18.972000 +00:00
DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE(): Stopped database capture successfully at 12/08/2023 00:29:18

-- finish_capture를 수행하면 AWR Snapshot이 한번 수행됩니다.
-- PDB일경우 AWR_PDB_SNAPSHOT을 조회, Non-CDB일경우 dba_hist_snapshot을 조회합니다.
SQL> SELECT min(snap_id) begin_id, max(snap_id) end_id FROM awr_pdb_snapshot;
  BEGIN_ID     END_ID
---------- ----------
         1         89

-- Capture대상 업무의 네트워크 요청 사이즈를 계산  
-- PDB에서는 AWR_PDB_SYSSTAT, Non-CDB에서는 DBA_HIST_SYSSTAT로 조회하면 됩니다.
SQL> SELECT min(snap_id)||'~'||max(snap_id) snap, stat_name,max(value) -  min(value) delta
  FROM awr_pdb_sysstat b
  WHERE b.snap_id in (88,89)
    and stat_name in ('bytes received via SQL*Net from client')
group by stat_name;
SNAP       STAT_NAME                                   DELTA
---------- -------------------------------------- ----------
88~89      bytes received via SQL*Net from client 3897884081

-- 예상되는 사이즈는 3.6G * 2 = 7.2G였지만, 실제 발생된 데이터량은 6.8G의 Capture파일이 생성되었습니다.
-- 디렉토리 구조도 확인됩니다. 
SQL> !du -m /oradata/capdir
6811    /oradata/capdir/capfiles/inst1/aa
1       /oradata/capdir/capfiles/inst1/ae
1       /oradata/capdir/capfiles/inst1/ah
1       /oradata/capdir/capfiles/inst1/ag
1       /oradata/capdir/capfiles/inst1/ai
1       /oradata/capdir/capfiles/inst1/af
1       /oradata/capdir/capfiles/inst1/ac
1       /oradata/capdir/capfiles/inst1/ad
1       /oradata/capdir/capfiles/inst1/ab
1       /oradata/capdir/capfiles/inst1/aj
6811    /oradata/capdir/capfiles/inst1
6811    /oradata/capdir/capfiles
1       /oradata/capdir/cap
6811    /oradata/capdir

-- 추가 테스트 사례 
-- Swingbench 도구는 PL/SQL기반(SOE_Server_Side_V2.xml 템플릿사용시)으로 동작했을때 
-- 예상되었던 파일사이즈는 72M * 2 = 144M였지만, 
-- case #1) plsql_mode => 'extended'  일때는 Capture된 사이즈는 4229M로 약 30배 더 발생되었습니다.  
-- case #2) plsql_mode => 'top-level' 일때는 Capture된 사이즈는 981M로 약 7배 더 발생되었습니다.  
-- PL/SQL기반의 애플리케이션은 Capture파일 사이즈 예측이 어렵습니다.
 
-- Capture 작업에 대한 결과입니다.  
-- Capture파일 사이즈도 같이 확인됩니다.
SQL> select id, name, status, errors, awr_exported, duration_secs, filters_used, dbtime_total, user_calls_total, user_calls, user_calls_unreplayable,transactions, transactions_total, sqlset_name, sqlset_owner,  
capture_size/1024/1024 from dba_workload_captures where id = (select max(id) from dba_workload_captures where name  like 'CAP_SOE');

        ID NAME    STATUS         ERRORS AWR_EXPORTED DURATION_SECS FILTERS_USED DBTIME_TOTAL USER_CALLS_TOTAL USER_CALLS USER_CALLS_UNREPLAYABLE TRANSACTIONS TRANSACTIONS_TOTAL SQLSET_NAME       SQL CAPTURE_SIZE/1024/1024
---------- ------- ---------- ---------- ------------ ------------- ------------ ------------ ---------------- ---------- ----------------------- ------------ ------------------ ----------------- --- ----------------------
        52 CAP_SOE COMPLETED           3 NO                     320            0   2275402243         16216739   16216739                 8152325       336755             336755 CAP_SOE_c_5225687 SYS             6810.06681

-- STS에 수집된 문장은 34개입니다.
SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'CAP_SOE_c_5225687';
STATEMENT_COUNT
---------------
             28
SQL>
```

**Capture 결과 확인** 

Capture한 워크로드에 대한 결과를 확인합니다. Capture파일 사이즈, User Calls개수등.

```sql
-- Report ID를 찾습니다. 
SQL> select id, name, status, start_time,end_time, dir_path 
from dba_workload_captures 
where id = (select max(id) from dba_workload_captures where name = 'CAP_SOE');
        ID NAME       STATUS     START_TIM END_TIME  DIR_PATH
---------- ---------- ---------- --------- --------- ------------------------------
        52 CAP_SOE    COMPLETED  08-DEC-23 08-DEC-23 /oradata/capdir

SQL> set pagesize 0 long 30000000 longchunksize 1000
SQL> select dbms_workload_capture.report(52,'TEXT') from dual;

Database Capture Report For CDB1

DB Name         DB Id    Release     RAC Capture Name               Status
------------ ----------- ----------- --- -------------------------- ----------
CDB1           909607496 19.3.0.0.0  NO  CAP_SOE                    COMPLETED


                   Start time: 08-Dec-23 00:23:57 (SCN = 40115299)
                     End time: 08-Dec-23 00:29:17 (SCN = 41095488)
                     Duration: 5 minutes 20 seconds
                 Capture size: 6.65 GB
  PL/SQL subcall capture size: 0 bytes
             Directory object: CAP_DIR
               Directory path: /oradata/capdir
      Directory shared in RAC: TRUE
                 Filters used: 1 INCLUSION filter
                  PL/SQL mode: EXTENDED
         Encryption algorithm:

Captured Workload Statistics                            DB: CDB1  Snaps: 87-90
-> 'Value' represents the corresponding statistic aggregated
      across the entire captured database workload.
-> '% Total' is the percentage of 'Value' over the corresponding
      system-wide aggregated total.

Statistic Name                                   Value   % Total
---------------------------------------- ------------- ---------
DB time (secs)                                 2275.40    100.00
Average Active Sessions                           7.11
User calls captured                           16216739    100.00
User calls captured with Errors                      3
PL/SQL calls captured                               13
PL/SQL DB time (secs)                             1.45      0.06
PL/SQL subcalls captured                             0
Session logins                                      13    100.00
Transactions                                    336755    100.00
   -------------------------------------------------------------
(생략)
```

위에 리포트 내용이 Capture file 디렉토리에도 동일하게 생성(text,html)되어 있습니다. 
```bash
$> cat /oradata/capdir/cap/wcr_cr.text
```

**Capture정보를 이동**

테스트서버로 Capture정보를 옮기기 위하여 Capture시점의 AWR정보를 export합니다.

```sql
-- 27번호의 Capture정보를 Export를 수행합니다.
SQL> execute dbms_workload_capture.export_awr(capture_id =>52);
-- 파일은 초기 Capture를 수행했던 CAP_DIR 디렉토리에 생성이 됩니다. 
-- start_capture시에 STS를 같이 생성하여 export_awr할때 STS도 같이 export됩니다.
-- 별도로 STS생성작업을 했었으면 STS를 packing하여 export하는 작업을 수동으로 해야합니다.
SQL> !ls -al /oradata/capdir/cap
-rw-r--r--. 1 oracle oinstall      129 Dec  8 00:23 wcr_scapture.wmd
-rw-r--r--. 1 oracle oinstall      258 Dec  8 00:29 wcr_fcapture.wmd
-rw-r--r--. 1 oracle oinstall    60004 Dec  8 00:29 wcr_cr.html
-rw-r--r--. 1 oracle oinstall    23422 Dec  8 00:29 wcr_cr.text
-rw-r-----. 1 oracle oinstall 13901824 Dec  8 00:49 wcr_ca.dmp <-- AWR정보 
-rw-r--r--. 1 oracle oinstall    34798 Dec  8 00:49 wcr_ca.log
-rw-r-----. 1 oracle oinstall    12288 Dec  8 00:49 wcr_cap_uc_graph.extb
-rw-r-----. 1 oracle oinstall   536576 Dec  8 00:50 wcr_ca_sts.dmp  <-- STS 정보
SQL>
```

### 3. Capture 작업에 의한 부하

Capture 작업을 하면 OS상에 I/O가 발생되므로 업무에 영향을 줄수 있습니다. 업무유형에 따라서 영향도가 상이하므로 직접 테스트를 해서 확인하는 수 밖에 없습니다. 운영서버에 테스트해본다는것이 리스크가 있다고 판단될수 있습니다. 테스트서버에서 Capture작업절차를 검증하고, 운영서버에서 가장 부하가 적은 시점에 작업해보고 검증하고나서 Capture대상 업무에 수행하는식으로 단계적인 접근이 필요합니다. 

- Capture 작업에 대한 부하(Overhead) 
  - Client에서 전송되는 데이터량에 따라 비례하여 성능에 영향을 받습니다. 
    - Client에서 전송되는 데이터는 SQL을 의미하며, SQL의 유형에 따라서 업무 영향도가 다릅니다.
    - SQL처리시 SQL문장과 바인드변수를 Capture파일로 저장하는 작업(Disk I/O)이 수반되어 성능에 영향이 발생됩니다. (세션별 PGA 메모리중 64Kb 메모리를 요구됩니다.)
  - SQL업무 유형에 따라 영향받는 부하가 다릅니다. 
    - DSS와 같이 Long runing SQL유형은 SQL처리시간중에 SQL저장하는 시간이 차지하는 비율이 적으므로 Capture부하가 적습니다.
    - OLTP성 Query는 Short DML이므로 SQL처리시간중 SQL 저장시간이 차지하는 비중이 커질수 밖에 없으므로 DSS유형 SQL에 비해서 Capture부하가 더 발생될수 있습니다. 
  - 관련문서 : 오라클 문서(MOS)에는 Capture시 0~3%의 CPU부하가 추가 발생된다고 언급되어 있습니다. (Real Application Testing: Database Capture FAQ (Doc ID 1920275.1))

Capture로 인한 부하를 줄이기 위해서는 원하지 않는 작업들과 워크로드는 Filter할수 있습니다. JOB, OMS, EM 등의 백그라운드 작업들은 Filter하여 제외합니다. Capture부하를 확인하기 위하여 처음에는 약 30분이내로 짧게 수행하여 부하발생량과 Capture파일 발생량을 테스트하는것이 좋습니다.
 
**AWR 비교 리포트 예시**

Swingbench로 30분간 부하발생하고 있는 상태에서 5분의 성능정보와 Capture상태에서의 성능정보를 비교하였습니다. 
  - 비교시점 #1(Capture미수행시 업무 부하) vs  비교시점 #2(Capture수행시 업무부하)

Swingbench는 두가지 방식을 제공합니다. 
1. Order Entry (PLSQL) V2(SOE_Server_Side_V2.xml) : PLSQL기반으로 트랜잭션 처리 방식
   - Capture작업할때 약 9%정도의 트랜잭션 처리량이 감소되었습니다. 이는 Swingbench 부하 발생방법이 PL/SQL기반하기 때문에 더 영향을 받았습니다. PL/SQL내에서 업무 처리할경우 네트워크 전송이 없이 DB내에서 로직이 처리되므로 일반적으로 네트워크로 round robin되어 처리되는 방식에 대해서 더 영향을 받은것으로 판단됩니다.
2. Order Entry (jdbc)(SOE_Client_Side.xml) : SQL기반으로 트랜잭션 처리 
   - Capture작업할때 약 5%정도의 트랜잭션 처리량이 감소되었습니다.

```sql
-- Capture수행전과 수행후의 성능지표를 비교
-- Order Entry (jdbc)(SOE_Client_Side.xml) 수행결과 입니다.
SQL> @?/rdbms/admin/awrddrpt.sql
WORKLOAD REPOSITORY COMPARE PERIOD REPORT (PDB snapshots)

Snapshot Set    DB Id    Unique Name DB Role          Edition Release     Cluster CDB Host          Std Block Size
------------ ----------- ----------- ---------------- ------- ----------- ------- --- ------------ ---------------
First (1st)    909607496 CDB1        PRIMARY          EE      19.0.0.0.0  NO      YES db-upgrade       8192
Second (2nd)   909607496 CDB1        PRIMARY          EE      19.0.0.0.0  NO      YES db-upgrade       8192

Snapshot Set  Begin Snap Id Begin Snap Time            End Snap Id End Snap Time                  Avg Active Users           Elapsed Time (min)            DB time (min)
------------ -------------- ------------------------- ------------ ------------------------- -------------------------- -------------------------- --------------------------
1st                      91 08-Dec-23 00:29:40 (Fri)           92 08-Dec-23 00:34:40 (Fri)                       7.0                       5.0                      35.2
2nd                      88 08-Dec-23 00:23:57 (Fri)           89 08-Dec-23 00:28:57 (Fri)                       7.1                       5.0                      35.5
                                                                                      ~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~~~~~~~~~~~~~~~~~~~~~~~~~
                                                                                      %Diff:                     0.6%                       0.0%                       0.6%
~~~~~~~~~~~~~~~~~~~                      1st Per Sec          2nd Per Sec      %Diff              1st Per Txn          2nd Per Txn      %Diff
                                     ---------------      ---------------     ------          ---------------      ---------------     ------
                       DB time:                  7.0                  7.1        0.6                      0.0                  0.0        0.0
                      CPU time:                  5.8                  5.7       -1.7                      0.0                  0.0        0.0
           Background CPU time:                  0.0                  0.0        0.0                      0.0                  0.0        0.0
             Redo size (bytes):          5,362,725.0          4,971,434.4       -7.3                  4,835.4              4,727.2       -2.2
         Logical read (blocks):            590,645.5            505,760.4      -14.4                    532.6                480.9       -9.7
                 Block changes:             34,927.3             33,087.5       -5.3                     31.5                 31.5       -0.1
        Physical read (blocks):                  0.2                  0.3       52.4                      0.0                  0.0        0.0
       Physical write (blocks):                  0.0                  0.0      100.0                      0.0                  0.0        0.0
              Read IO requests:                  0.1                  0.2       23.1                      0.0                  0.0        0.0
             Write IO requests:                  0.0                  0.0      100.0                      0.0                  0.0        0.0
                  Read IO (MB):                  0.0                  0.0        0.0                      0.0                  0.0        0.0
                 Write IO (MB):                  0.0                  0.0        0.0                      0.0                  0.0        0.0
                  IM scan rows:                  0.0                  0.0        0.0                      0.0                  0.0        0.0
       Session Logical Read IM:                  0.0                  0.0        0.0                      0.0                  0.0        0.0
                    User calls:             53,379.8             50,651.8       -5.1                     48.1                 48.2        0.1
                  Parses (SQL):             26,548.3             25,189.8       -5.1                     23.9                 24.0        0.0
             Hard parses (SQL):                  0.0                  0.0      -60.0                      0.0                  0.0        0.0
            SQL Work Area (MB):                  0.1                  0.2       14.3                      0.0                  0.0       14.3
                        Logons:                  0.0                  0.0     -100.0                      0.0                  0.0        0.0
                   User logons:                  0.0                  0.0        0.0                      0.0                  0.0        0.0
                Executes (SQL):             28,370.8             26,922.8       -5.1                     25.6                 25.6        0.1
                  Transactions:              1,109.1              1,051.7       -5.2

                                               First               Second       Diff
                                     ---------------      ---------------     ------
     % Blocks changed per Read:                  5.9                  6.5        0.6
              Recursive Call %:                  5.2                  5.2        0.0
    Rollback per transaction %:                  0.0                  0.0        0.0
                 Rows per Sort:                242.0                248.4        6.4
    Avg DB time per Call (sec):                  0.0                  0.0        0.0

Top Timed Events   First DB/Inst: CDB1/CDB1 Snaps: 91-92 (Elapsed time: 300.339 sec  DB time: 2113.89 sec),  Second DB/Inst: CDB1/CDB1 Snaps: 88-89 (Elapsed time: 300.328 sec  DB time: 2127.24 sec)
-> Events with a "-" did not make the Top list in this set of snapshots, but are displayed for comparison purposes

                                              1st                                                                                               2nd
-----------------------------------------------------------------------------------------------   -----------------------------------------------------------------------------------------------
Event                          Wait Class           Waits      Time(s)     Avg Time    %DB time   Event                          Wait Class           Waits      Time(s)     Avg Time    %DB time
------------------------------ ------------- ------------ ------------ ------------ -----------   ------------------------------ ------------- ------------ ------------ ------------ -----------
 CPU time                                             N/A      1,752.2                     82.9    CPU time                                             N/A      1,721.5                     80.9
 log file sync                 Commit             332,963        711.7       2.14ms        33.7    log file sync                 Commit             315,745        753.1       2.39ms        35.4
 SQL*Net message to client     Network          8,289,224          9.7       1.17us         0.5    SQL*Net message to client     Network          7,862,109          9.8       1.25us         0.5
 enq: CR - block range reuse c Other                   98          5.7      58.06ms         0.3    WCR: capture file IO write    Other              266,819          8.7      32.48us         0.4
 resmgr:internal state change  Concurrency              6          0.6     100.07ms         0.0    enq: CR - block range reuse c Other                   23          1.4      60.46ms         0.1
 log file switch (checkpoint i Configuration           57          0.6      10.19ms         0.0    log file switch (checkpoint i Configuration           87          0.9      10.51ms         0.0
 cursor: pin S                 Concurrency            286          0.3       1.08ms         0.0    cursor: pin S                 Concurrency            267          0.3       1.10ms         0.0
 buffer busy waits             Concurrency          5,573          0.3      50.46us         0.0    buffer busy waits             Concurrency          5,179          0.1      27.74us         0.0
 log file switch completion    Configuration           25          0.2       9.21ms         0.0    enq: TX - row lock contention Application            836          0.1     167.80us         0.0
 enq: TX - row lock contention Application          1,162          0.2     171.11us         0.0    library cache: mutex X        Concurrency             90          0.1       1.13ms         0.0
-library cache: mutex X        Concurrency             74          0.2       2.06ms         0.0   -                                                     N/A          N/A                      N/A
                          --------------------------------------------------------------------------------------------------------------------

(생략)
```

> Database Replay의 Caputre에 대한 부하는 업무 유형과 처리 방식에 따라 다릅니다. 
> 처음부터 부하에 대해서 고민하기보다는 부하가 적은 시점에 Capture작업을 수행해서 영향도를 평가하는것이 좋을것 같습니다.
> DB성능 수치 변화만으로 판단하기 보다는 애플리케이션 서비스 영향도관점으로 접근하면 어느정도 부하는 큰 영향이 없을수 있습니다.

Capture 작업이 수행되면 Capture file를 생성하기 위하여 "WCR: capture file IO write" 이벤트가 추가적으로 발생됩니다. 
위 결과를 보면 "32.48us" 의 Wait시간이 걸리는것을 확인할수 있고, SQL처리시간에 32.48us시간이 추가될수 있음을 알수 있습니다.

"log file sync"시간도 기존 2.14ms에서 2.39ms로 증가되었습니다. 테스트 환경 영향으로 local disk에 online redo log영역과 Capture flie를 같은 위치에 잇어서 약 11%정도의 영향이 발생된것 같습니다.
스토리지가 분리되거나, 고성능 스토리지를 사용하면 영향도는 감소될것입니다.

## 테스트서버(preprocess, replay, report)

테스트서버에서는 3단계작업을 수행합니다. 

- 테스트서버에서 작업 단계
  1. preprocessing 작업 : capture파일을 가져와서 replay가 가능한 메타데이터를 생성합니다.
  2. replay 작업 : replay client를 통해서 운영서버에서 Capture한 워크로드를 그대로 재생(replay)합니다
  3. report 작업 : Capture된 워크로드와 Replay된 워크로드를 비교하여 성능차이를 확인합니다.

**테스트 DB시작**

운영DB에서 수집한 워크로드를 테스트DB에서 수행하기 위하여 테스트 DB를 기동합니다.

```sql
-- 테스트 환경을 시작합니다.
SQL> alter pluggable database pdb1_clone open;
SQL> alter pluggable database pdb1 close immediate;
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         3 PDB1                           MOUNTED         <-- 운영 DB
         8 PDB1_CLONE                     READ WRITE NO   <-- 테스트 DB
```

**Capture파일 이동**

Capture파일을 테스트서버로 이동합니다.

```bash
-- 같은서버에서 테스트할 예정이므로 디렉토리명을 변경하였습니다.
$> mv /oradata/capdir /oradata/ratdir
```

### 1. preprecess 작업

운영 DB 서버에서 Capture한 파일을 테스트 환경으로 복사합니다. preprocessing작업을 통해서 Caputre 파일들은 replay가 가능한 포멧으로 변환합니다.(한번 변환된 파일은 반복적으로 수행이 가능합니다.)RAC환경에서 Capture된 파일이라면 하나의 디렉토리에 전 노드의 Capture파일을 모아서 preprocess작업을 수행합니다. 


**AWR 데이터 이관**

운영서버에서 캡쳐된 워크로드를 등록하는 작업을 수행하고, 추후에 성능 비교를 위하여 AWR데이터를 이관합니다.

```sql
-- RAT_DIR 디렉토리를 생성합니다.
SQL> create directory rat_dir as '/oradata/ratdir';

-- RAT_DIR디렉토리에 있는 Capture ID를 확인합니다.
-- Capture info조회한것만으로도 capture id를 새로 발급되고 dba_workload_captures에 정보가 등록됩니다.
SQL> select  DBMS_WORKLOAD_CAPTURE.GET_CAPTURE_INFO(dir =>'RAT_DIR') cap_id from dual;
    CAP_ID
----------
        64

-- import작업이후에 새롭게 랜덤으로 DBID가 생성되어 return됩니다.
-- RAT_DIR디렉토리에 Export된 AWR데이터가 있어서 Import작업이 가능합니다.
SQL> select dbms_workload_capture.import_awr(capture_id => 64, staging_schema => 'ADMIN') dbid from dual;
                DBID
--------------------
          2061353802
SQL>
```

**preprocessing 작업 수행**

Capture파일을 이용하여 메타데이터파일을 생성합니다. 

```sql
-- preprocessing 작업을 수행합니다.
-- parallel_level는 null일경우(default) auto parallel이 적용, 1을 줄경우 seiral하게 작업합니다.
-- synchronization는 TIME,SCN, OBJECT_ID를 사용할수 있습니다.
-- . TIME모드로 processing하면 replay시에 TIME으로만 실행할수 있습니다.
-- . SCN모드로 processing하면 replay시에 TIME과 SCN 을 선택하여 실행할수 있습니다.
-- plsql_mode는 capture시에 extended로 수행해서 processing작업시에 extended로 수행할수 있습니다.
-- 6.65 G처리하는데 약 5분정도 소요되었습니다.
SQL> execute dbms_workload_replay.process_capture(capture_dir => 'RAT_DIR', parallel_level=>null, synchronization=> 'SCN', plsql_mode => 'extended');

-- preprocessing 모니터링
SQL> select dbms_workload_replay.process_capture_completion percentage, dbms_workload_replay.process_capture_remaining_time remaining_time from dual;
PERCENTAGE REMAINING_TIME
---------- --------------
99.5916059              0

-- preprocessing이후의 파일 변화
-- plsq_mode를 extended로 수행했을때 ppe_X.X.X 폴더가 생성됩니다.
-- ppe19.3.0.0.0, pp19.3.0.0.0 폴더가 추가되었으며 약 254M가 증가되었습니다.
SQL> !du -m /oradata/ratdir
45      /oradata/ratdir/ppe19.3.0.0.0/capfiles/inst1/aa
45      /oradata/ratdir/ppe19.3.0.0.0/capfiles/inst1
45      /oradata/ratdir/ppe19.3.0.0.0/capfiles
127     /oradata/ratdir/ppe19.3.0.0.0
45      /oradata/ratdir/pp19.3.0.0.0/capfiles/inst1/aa
45      /oradata/ratdir/pp19.3.0.0.0/capfiles/inst1
45      /oradata/ratdir/pp19.3.0.0.0/capfiles
127     /oradata/ratdir/pp19.3.0.0.0
6811    /oradata/ratdir/capfiles/inst1/aa
1       /oradata/ratdir/capfiles/inst1/ae
1       /oradata/ratdir/capfiles/inst1/ah
1       /oradata/ratdir/capfiles/inst1/ag
1       /oradata/ratdir/capfiles/inst1/ai
1       /oradata/ratdir/capfiles/inst1/af
1       /oradata/ratdir/capfiles/inst1/ac
1       /oradata/ratdir/capfiles/inst1/ad
1       /oradata/ratdir/capfiles/inst1/ab
1       /oradata/ratdir/capfiles/inst1/aj
6811    /oradata/ratdir/capfiles/inst1
6811    /oradata/ratdir/capfiles
14      /oradata/ratdir/cap
7078    /oradata/ratdir

SQL>
```

**워크로드 분석(Workload Analyzer)**

Capture파일을 이용하여 워크로드를 분석합니다. 
- Capture하기 전에 접속한 세션을 in-flight session이라고 합니다. Capture안되어 있는 워크로드로 인하여 영향을 받을수 있습니다.
- PL/SQL워크로드는 내부적으로 재현하기 어렵습니다. 
- SYSDATE를 참조하는 데이터는 replay시에 바뀔수도 있습니다(정확하게 테스트하기 위해서는 서버시간을 변경해야될수도 있습니다.)
- Capture가 되지 않는 워크로드가 존재할수 있습니다. Filter조건을 주었거나, MMON/PMON등 백그라운드에 의한 SQL은 Capture되지 않습니다.

```java
-- Capture파일을 참조하여 워크로드분석합니다. 
-- 내부적인 동작방식은 **AWR 데이터 이관** 작업과 동일합니다. 디렉토리 만들고 Capture_id생성하고 AWR Import작업하는 작업을 수행합니다. 
$> java -classpath $ORACLE_HOME/jdbc/lib/ojdbc8.jar:$ORACLE_HOME/rdbms/jlib/dbrparser.jar:$ORACLE_HOME/rdbms/jlib/dbranalyzer.jar oracle.dbreplay.workload.checker.CaptureChecker /oradata/ratdir jdbc:oracle:thin:@localhost:1521/pdb1_clone

-- 결과
In-flight sessions : Maximum Workload Impact: 99 % of DB Time
Rationale : A significant part of your captured files have been captured in-flight.
This means that the captured session already existed before capture started, and could have already modified its state (e.g. through 'alter session') or be inside a transaction at this time.
This can cause some divergence (since only a part of some transactions was captured) or even bigger problems if some key session parameters are not set during replay.
Action : The best practice is to avoid in-flight session by restarting the database before capturing.
In case an in-flight session needs some missing session parameters to perform durin replay, consider using a login trigger to set those parameters correctly.

PL/SQL : Maximum Workload Impact: 13 % of DB Time
Rationale : If the replay is much slower than expected, try to run in unsynchronized mode.
Action : A significant part of your workload comes from PL/SQL.
If the PL/SQL blocks or functions have 'complicated' logic or multiple commits in them, they are hard to synchronize and they behavior might change during replay.
You might see a different workload profile during replay if this is the case.

SYSDATE and other time-dependent functions : Maximum Workload Impact: Unknown
Rationale : A significant part of your SQL workload is referencing SYSDATE.
Action : The system clock needs to be restored to its capture value before replay.

Non captured workload : Maximum Workload Impact: 5 % of DB Time
Rationale : A significant amount of the workload running during the capture period was not captured, most likely because of capture filters.
Action : This part of the workload will not be replayed and will not appear in the AWR reports.
```
### 2.replay 작업

Replay Client는 DB서버내에서 실행하지 않고, 외부 서버에서 실행합니다.(DB서버내에서 같이 Client가 실행되면 환경 변경에 따른 SQL영향도 분석이 힘들어집니다.)
Replay를 수행할때는 아무런 변경없이 수행하여 baseline으로 설정합니다. 
한번에 하나만 변경하여 replay작업을 반복합니다. 

Replay 작업시 고려사항
  - Replay Client(wrc프로세스)가 실행되어야 합니다.
  - Replay Client는 replay가 가능한 형식을 변환된 파일을 읽어서 DB서버로 워크로드를 요청 합니다. 
  - 하나의 Replay Client 프로세스는 Thread기반으로 여러개의 session을 만듭니다(최대 50개정도 만듭니다.)
  - calibrate작업을 수행하면 권고되는 프로세스 Replay Client 개수를 계산해줍니다.
  - Replay Client의 접속방식을 변경할수 있습니다. connection mapping작업을 통해서 테스트서버접속정보로 변경합니다.(RAC환경일경우 접속정보변경을 통해 노드를 지정하거나, loadbalancing작업이 가능하도록 할수도 있습니다.) 

**테스트 DB에서 준비 작업**

```sql
-- replay작업을 등록합니다.
SQL> execute dbms_workload_replay.initialize_replay(replay_name=>'REP_SOE', replay_dir=>'RAT_DIR', plsql_mode=>'extended');
SQL> select id, name, dbid, capture_id, status  from DBA_WORKLOAD_REPLAYS;
        ID NAME            DBID CAPTURE_ID STATUS
---------- --------- ---------- ---------- ----------------------------------------
         1 REP_SOE   3587696336         64 INITIALIZED

-- connect 정보를 매핑하는 작업을 수행합니다.
-- 기본 null로 설정되어 있는 wrc클라이언트가 접속된 세션으로 replay작업을 수행합니다. 
-- 때에따라 특정 노드나 특정 서비스로, 부하분산을 해서 연결해야될경우 변경할수 있습니다. 
SQL> select conn_id,replay_id, replay_conn  from dba_workload_connection_map;
   CONN_ID  REPLAY_ID REPLAY_CONN
---------- ---------- --------------------
         1          1 
... 
        11          1
        12          1
-- 접속정보 오류가 있을수 있으므로 명확하게 선언해주는것이 좋습니다.
--SQL> exec DBMS_WORKLOAD_REPLAY.REMAP_CONNECTION (connection_id => 1,replay_connection =>'TEST서버');
```

Replay 작업시 옵션
  - synchronization : SCN(TRUE)혹은 TIME(FALSE)기반으로 수행됩니다. SCN은 Commit순서를 유지하여 실행하고 TIME은 Capture된 실행시간을 기반으로 수행합니다. 
  - connect_time_scale : Connection간의 간격을 의미합니다. 단위는 %이고 기본 100%입니다. 감소시킬경우 동시접속자가 많아지는 효과를 볼수 있습니다.
    - 예로 50으로 지정할경우, Connection과 Connection Capture당시는 동시에 2개세션접속되었지만, replay시점에는 동시에 3개, 4개의 세션이 접속되어 수행할수 있습니다.
  - think_time_scale : 같은 세션에 있는 실행되는 SQL간격을 의미합니다. 단위는 %이고 기본 100%입니다. 감소시킬경우 세션안에서 SQL실행간격이 줄어들어, 전체적으로 SQL 실행횟수가 증가되는 효과를 볼수 있습니다. 
  - think_time_auto_correct : captrue한것보다 replay성능이 느릴경우 think_time_scale을 조정(감소)하는 작업을 수행합니다. (기본 True입니다.)
  - scale_up_multiplier : DML중에 Query작업을 더 수행합니다. SELECT구문의 부하를 추가할수 있어 Capture부하보다 더 많은 부하를 발생시키도록 조정할수 있습니다. 

```sql
-- repaly를 위한 준비 작업을 합니다.
-- synchronization은 TIME기반, capture_sts 생성, query_only 속성을 적용하였습니다. (나머지 매개변수만 default 값입니다)
SQL> BEGIN
  dbms_workload_replay.prepare_replay(
    synchronization=>FALSE,
    connect_time_scale=> 100,
    think_time_scale=> 100, 
    think_time_auto_correct=> TRUE,
    scale_up_multiplier => 1,
    capture_sts=>TRUE,
    sts_cap_interval=>300,
    query_only=> TRUE);
END;
/
```

**Replay Client(wrc) 프로세스 실행**

wrc 클라이언트에서 calibrate모드로 수행하면 필요한 client개수를 계산합니다. (내부적으로 DBMS_WORKLOAD_REPLAY.CALIBRATE 수행합니다.)
하나의 Client가 100개 동시접속세션을 만드는걸로 가정하므로 필요한 세션은 12개, 1개의 Client만으로도 가능합니다.

```bash
$> wrc admin/WElcome1234##@pdb1_clone replaydir=/oradata/ratdir mode=calibrate
Workload Replay Client: Release 19.3.0.0.0 - Production on Fri Dec 8 04:46:34 2023
Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.
Report for Workload in: /oradata/ratdir
-----------------------
Recommendation:
Consider using at least 1 clients divided among 1 CPU(s)
You will need at least 45 MB of memory per client process.
If your machine(s) cannot match that number, consider using more clients.

Workload Characteristics:
- max concurrency: 12 sessions
- total number of sessions: 12

Assumptions:
- 1 client process per 100 concurrent sessions
- 4 client processes per CPU
- 256 KB of memory cache per concurrent session
- think time scale = 100
- connect time scale = 100
- synchronization = TRUE

$> wrc admin/WElcome1234##@pdb1_clone replaydir=/oradata/ratdir mode=replay workdir=/home/oracle/replay_work
Workload Replay Client: Release 19.3.0.0.0 - Production on Fri Dec 8 04:56:56 2023
Copyright (c) 1982, 2019, Oracle and/or its affiliates.  All rights reserved.

Wait for the replay to start (04:56:56)
```
** Replay 작업 실행

테스트 서버에서 start_replay 프로시저를 호출하면 wrc프로세스가 받아서 캡쳐된 워크로드를 수행합니다.

```sql
SQL> execute dbms_workload_replay.start_replay();
-- alert.log에 보면 replay되었다는 메시지가 나옵니다.
2023-12-08 04:57:21.253000 +00:00
DBMS_WORKLOAD_REPLAY.START_REPLAY(): Starting database replay at 12/08/2023 04:57:21

-- wrc 클라이언트에서는 아래와 같이 메시지가 발생됩니다.
Replay client 1 started (04:57:21)

-- 중지하거나 취소가 가능합니다. 
--exec   DBMS_WORKLOAD_REPLAY.PAUSE_REPLAY ();
--exec   DBMS_WORKLOAD_REPLAY.RESUME_REPLAY ();
--exec   DBMS_WORKLOAD_REPLAY.CANCEL_REPLAY ();

--alert.log를 보면 replay가 완료되면 아래와 같은 메시지가 발생됩니다.
2023-12-08 05:03:02.816000 +00:00
DBMS_WORKLOAD_REPLAY: Database replay ran to completion at 12/08/2023 05:03:02
2023-12-08 05:03:04.399000 +00:00
DM00 started with pid=91, OS id=987727, job SYS.SYS_EXPORT_TABLE_01
2023-12-08 05:03:06.337000 +00:00
DW00 started with pid=96, OS id=987753, wid=1, job SYS.SYS_EXPORT_TABLE_01
2023-12-08 05:03:16.870000 +00:00
XDB initialized.
2023-12-08 05:03:47.465000 +00:00
DM00 started with pid=91, OS id=988119, job SYS.SYSTEMwrr10037050
2023-12-08 05:03:48.799000 +00:00
DW00 started with pid=96, OS id=988127, wid=1, job SYS.SYSTEMwrr10037050
2023-12-08 05:03:58.287000 +00:00
XDB initialized.
2023-12-08 06:00:00.008000 +00:00

-- wrc 클라이언트에서는 실행이 완료되면 아래와 같이 메시지가 발생됩니다. 
Replay client 1 finished (05:04:09)
```

alert.log를 확인하면 실제 작업시간은  04:57:21~ 05:03:02 인걸 확인할수 있습니다. 
wrc 클라이언트에서는 replay 작업이후 export awr 작업까지완료해서 finished메시지가 발생됩니다.

```sql
-- replay 작업을 확인하면 작업수행시간를 확인할수 있습니다.
-- AWR_EXPORTED작업도 자동으로 수행된것을 알수 있습니다.
SQL> alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';
SQL> select name, id, status, user_calls, awr_exported, start_time, end_time,sqlset_name  from dba_workload_replays order by start_time;
NAME              ID STATUS          USER_CALLS AWR_EXPORTED START_TIME          END_TIME             SQLNET_NAME
--------- ---------- --------------- ---------- ------------ ------------------- -------------------- ----------------
REP_SOE            1 COMPLETED         16216720 YES          2023-12-08 04:57:21 2023-12-08 05:03:02  REP_SOE_r_125177

```

### 3.report 작업

Report 작업시 고려사항
  - Capture한 결과와 Replay한 결과를 비교하여 성능 분석이 가능합니다.
  - Replay중에는 Error가 발생될수 있습니다.(external table, dblink, sysdate) 
  - Capture한 시점의 데이터와 Replay한 시점의 데이터가 틀릴경우 데이터 결과가 틀릴수 있습니다.

DB replay는 운영DB의 워크로드를 재현할수 있지만 완벽하게 동일하게 수행되지 않으므로 아래와 같은 목표를 가지고 수행하는것이 좋습니다. 
- 기능적 요건 : Replay수행시 SQL 수행 비율(Capture대비) : 약 80~90%을 목표
- 성능 분석 : 기능적 요건이 만족되면 워크로드 분석합니다(AWR, ADDM, Report등)

**Capture작업와 Replay작업 비교**
```sql
SQL> set pagesize 0 long 30000000 longchunksize 1000
SQL> select DBMS_WORKLOAD_REPLAY.REPORT(replay_id=>1, format=>'TEXT') tt from dual;
B Replay Report for REP_SOE
---------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------
| DB Name | DB Id      | Release    | RAC | Replay Name | Replay Status |
-------------------------------------------------------------------------
| CDB1    | 3587696336 | 19.3.0.0.0 | NO  | REP_SOE     | COMPLETED     |
-------------------------------------------------------------------------

Replay Information
-------------------------------------------------------------------------
|       Information       | Replay               | Capture              |
-------------------------------------------------------------------------
| Name                    | REP_SOE              | CAP_SOE              |
-------------------------------------------------------------------------
| Status                  | COMPLETED            | COMPLETED            |
-------------------------------------------------------------------------
| Database Name           | CDB1                 | CDB1                 |
-------------------------------------------------------------------------
| Database Version        | 19.3.0.0.0           | 19.3.0.0.0           |
-------------------------------------------------------------------------
| Start Time              | 08-12-23 04:57:21    | 08-12-23 00:23:57    |
-------------------------------------------------------------------------
| End Time                | 08-12-23 05:03:02    | 08-12-23 00:29:17    |
-------------------------------------------------------------------------
| Duration                | 5 minutes 41 seconds | 5 minutes 20 seconds |
-------------------------------------------------------------------------
| Directory Object        | RAT_DIR              | RAT_DIR              |
-------------------------------------------------------------------------
| Directory Path          | /oradata/ratdir      | /oradata/ratdir      |
-------------------------------------------------------------------------
| AWR DB Id               | 3587696336           | 2061353802           |
-------------------------------------------------------------------------
| AWR Begin Snap Id       | 1                    | 87                   |
-------------------------------------------------------------------------
| AWR End Snap Id         | 2                    | 90                   |
-------------------------------------------------------------------------
| PL/SQL Mode             | EXTENDED             | EXTENDED             |
-------------------------------------------------------------------------
| Encryption Algorithm    |                      |                      |
-------------------------------------------------------------------------
| Replay Directory Number | 835823064            | N/A                  |
-------------------------------------------------------------------------

Replay Options
-----------------------------------------------------------
|        Option Name        | Value                       |
-----------------------------------------------------------
| Synchronization           | FALSE                       |
-----------------------------------------------------------
| Connect Time              | 100%                        |
-----------------------------------------------------------
| Connect Time Auto Correct | YES                         |
-----------------------------------------------------------
| Think Time                | 100%                        |
-----------------------------------------------------------
| Think Time Auto Correct   | TRUE                        |
-----------------------------------------------------------
| Query Only                | Y                           |
-----------------------------------------------------------
| Number of WRC Clients     | 1 (1 Completed, 0 Running ) |
-----------------------------------------------------------

Replay Statistics
--------------------------------------------------------------------------------
|        Statistic         | Replay                  | Capture                 |
--------------------------------------------------------------------------------
| DB Time                  | 22 minutes 5.66 seconds | 37 minutes 55.4 seconds |
--------------------------------------------------------------------------------
| PL/SQL DB Time           |               0 seconds |            1.45 seconds |
--------------------------------------------------------------------------------
| User calls               |                16216720 |                16216739 |
--------------------------------------------------------------------------------
| PL/SQL user calls        |                       0 |                      13 |
--------------------------------------------------------------------------------
| PL/SQL subcalls          |                       0 |                       0 |
--------------------------------------------------------------------------------
| Average Active Sessions  |                    3.89 |                    7.11 |
--------------------------------------------------------------------------------
| Capture Files            |                      12 |                      12 |
--------------------------------------------------------------------------------
| Finished Replay Sessions |                      12 |                      12 |
--------------------------------------------------------------------------------

Replay Divergence Summary
-------------------------------------------------------------------
|                Divergence Type                | Count | % Total |
-------------------------------------------------------------------
| Session Failures During Replay                |     0 |    0.00 |
-------------------------------------------------------------------
| Errors No Longer Seen During Replay           |     0 |    0.00 |
-------------------------------------------------------------------
| New Errors Seen During Replay                 |     0 |    0.00 |
-------------------------------------------------------------------
| Errors Mutated During Replay                  |     0 |    0.00 |
-------------------------------------------------------------------
| DMLs with Different Number of Rows Modified   |     0 |    0.00 |
-------------------------------------------------------------------
| SELECTs with Different Number of Rows Fetched |     0 |    0.00 |
-------------------------------------------------------------------
```
Query_only속성을 주었는데도 불구 하고 20초더 걸렸습니다. 
이제부터는 튜닝의 영역입니다. wrc프로세스를 추가하거나, think_time과 Connect_time을 조정하여 워크로드를 더 실행하도록 조정이 필요합니다. 

**에러 상세분석(Divergence)**

Replay작업을 하다보면 성능이슈나 Error가 발생될수 있습니다. 
아래 Report는 replay수행하는 테스트 DB가 Capture시점의 데이터와 동일하지 않아 발생되는 결과입니다.
대부분 DML시에 ORA-00001 Unique 제약조건에 위반되어 에러가 발생되었습니다. 
전체적으로 에러 Summary가 나오고 각 SQL ID별로 발생된 에러건수를 확인할수 있습니다. 

```sql
Replay Divergence Summary
--------------------------------------------------------------------
|                Divergence Type                | Count  | % Total |
--------------------------------------------------------------------
| Session Failures During Replay                |      0 |    0.00 |
--------------------------------------------------------------------
| Errors No Longer Seen During Replay           |      0 |    0.00 |
--------------------------------------------------------------------
| New Errors Seen During Replay                 | 833810 |    5.14 |
--------------------------------------------------------------------
| Errors Mutated During Replay                  |      0 |    0.00 |
--------------------------------------------------------------------
| DMLs with Different Number of Rows Modified   | 833810 |    5.14 |
--------------------------------------------------------------------
| SELECTs with Different Number of Rows Fetched |   4922 |    0.03 |
--------------------------------------------------------------------

Error Divergence By Application
---------------------------------------------------------------------------
| Service Name | Module Name      | Capture Error | Replay Error | Count  |
---------------------------------------------------------------------------
| pdb1_clone   | JDBC Thin Client | Successful    | ORA-00001    | 833810 |
---------------------------------------------------------------------------
By SQL
---------------------------------------------------------
| SQL ID        | Capture Error | Replay Error | Count  |
---------------------------------------------------------
| 07d1xa9mbymgu | Successful    | ORA-00001    | 69205  |
---------------------------------------------------------
| 09pzy8x10gjkg | Successful    | ORA-00001    | 404884 |
---------------------------------------------------------
| 5573s2518pk36 | Successful    | ORA-00001    | 69205  |
---------------------------------------------------------
| 6au7zzgu3tuum | Successful    | ORA-00001    | 69205  |
---------------------------------------------------------
| 8xqdxjkbt9ghg | Successful    | ORA-00001    | 43841  |
---------------------------------------------------------
| a6hdpzrqqhc7d | Successful    | ORA-00001    | 177470 |
---------------------------------------------------------

DML Data Divergence By Application
--------------------------------------------
| Service Name | Module Name      | Count  |
--------------------------------------------
| pdb1_clone   | JDBC Thin Client | 833810 |
--------------------------------------------

SELECT Data Divergence By Application
-------------------------------------------
| Service Name | Module Name      | Count |
-------------------------------------------
| pdb1_clone   | JDBC Thin Client | 4922  |
-------------------------------------------
```

좀더 상세하게 SQL_ID에 더불어 어떤 바인드변수를 사용했는지 까지도 분석이 가능합니다. 

```sql
SQL> SELECT stream_id,call_counter FROM DBA_WORKLOAD_REPLAY_DIVERGENCE WHERE replay_id = 21 and rownum =1 ;
                   STREAM_ID CALL_COUNTER
---------------------------- ------------
         8242182703634448384           53

SQL> select DBMS_WORKLOAD_REPLAY.GET_DIVERGING_STATEMENT(21, 8242182703634448384,55) from dual;
<replay_divergence_info>
  <sql_id>09pzy8x10gjkg</sql_id>
  <sql_text>insert into order_items(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRI
CE, QUANTITY, GIFT_WRAP, CONDITION, ESTIMATED_DELIVERY) values (:1 , :2 , :3 , :
4 , :5 , :6 , :7 , (SYSDATE+ 3))</sql_text>
  <full_sql_text>insert into order_items(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNI
T_PRICE, QUANTITY, GIFT_WRAP, CONDITION, ESTIMATED_DELIVERY) values (:1 , :2 , :
3 , :4 , :5 , :6 , :7 , (SYSDATE+ 3))</full_sql_text>
  <binds>
    <iteration value="1">
      <bind>
        <BIND_POS>1</BIND_POS>
        <BIND_VARNAME>1</BIND_VARNAME>
        <BIND_VALUE>9157906</BIND_VALUE>
      </bind>
      (생략)
      <bind>
        <BIND_POS>7</BIND_POS>
        <BIND_VARNAME>7</BIND_VARNAME>
        <BIND_VALUE>New</BIND_VALUE>
      </bind>
    </iteration>
  </binds>
</replay_divergence_info>
```


**Replay 작업간 비교**

여러번 replay작업을 하다보면 replay작업간에도 비교해야될수도 잇습니다.
그럴경우 아래 명령어로 통해서 리포트를 생성할수 있습니다.

```sql
variable comp_report clob
begin
 DBMS_WORKLOAD_REPLAY.COMPARE_PERIOD_REPORT(replay_id1 => 1 , replay_id2 => 21, format=> 'TEXT', result=> :comp_report);
end;
/
-- or DBMS_WORKLOAD_REPLAY.COMPARE_SQLSET_REPORT 도 있습니다.

set heading off set long 100000 set pagesize 0
spool comparereport.text rep
print comp_report
spool off
```

## SQL 성능(SPA) 비교 

Capture당시의 SQL Tuning Set과 Replay작업의 SQL Tuning Set정보를 이용하여 성능 분석이 가능합니다. 

STS를 이용하여 SPA수행하면 DBID가 불일치가 되어 SQL_ID가 동일하더라도 성능비교가 잘 안됩니다.
SQL Tuning Set의 DBID 변경작업을 우선수행합니다.
Capture당시의 SQL Tuning Set상세 정보를 보면 DBID가 다른것을 확인할수 있습니다.

```sql
-- Replay 정보로 부터 SQL Tuning Set과 Capture ID를 확인
SQL> select capture_id, sqlset_owner, sqlset_name from dba_workload_replays  where id = 1;
CAPTURE_ID SQLSET_OWN SQLSET_NAME
---------- ---------- ------------------------------
        64 SYS        REP_SOE_r_125177

--Capture ID를 이용하여 Capture당시의 SQL Tuning Set정보 확인
SQL> select sqlset_owner,sqlset_name  from dba_workload_captures where id = 64;
SQLSET_OWN SQLSET_NAME
---------- ------------------------------
SYS        CAP_SOE_c_5225687_c_1375574271

-- SQL Tuning SET의 DBID가 동일하지만,
SQL> select owner,name, con_dbid from dba_sqlset where name in ('CAP_SOE_c_5225687_c_1375574271','REP_SOE_r_125177');
OWNER NAME                             CON_DBID
----- ------------------------------ ----------
SYS   CAP_SOE_c_5225687_c_1375574271 3587696336
SYS   REP_SOE_r_125177               3587696336

-- 실제 SQL구문레벨로 보면 DBID가 다릅니다.
SQL> SELECT distinct sqlset_name,con_dbid FROM dba_sqlset_statements where SQLSET_NAME in ( 'CAP_SOE_c_5225687_c_1375574271','REP_SOE_r_125177')
SQLSET_NAME                      CON_DBID
------------------------------ ----------
CAP_SOE_c_5225687_c_1375574271  909607496
REP_SOE_r_125177               3587696336

-- 따라서 CON_DBID를 동일하게 변경하는 작업을 진행할수 있습니다.
-- 기존 CAP_SOE_c_5225687_c_1375574271를 stage 테이블에 넣고 db_id를 변경하여 새로운 CAP_SOE_REMAP을 만듭니다.
SQL> exec dbms_sqlset.CREATE_STGTAB (table_name  => 'TAB_STAGE1',schema_name => 'ADMIN');
SQL> exec dbms_sqlset.PACK_STGTAB( sqlset_name =>'CAP_SOE_c_5225687_c_1375574271', sqlset_owner=>'SYS',staging_schema_owner  =>'ADMIN', staging_table_name  =>'TAB_STAGE1');
SQL> exec dbms_sqlset.REMAP_STGTAB (old_sqlset_name =>'CAP_SOE_c_5225687_c_1375574271', old_sqlset_owner=>'SYS',new_sqlset_name=> 'CAP_SOE_REMAP', new_sqlset_owner => 'ADMIN' , old_con_dbid=>'909607496', new_con_dbid=>'3587696336', staging_schema_owner  =>'ADMIN', staging_table_name  =>'TAB_STAGE1')
SQL> exec dbms_sqlset.UNPACK_STGTAB ( sqlset_name => 'CAP_SOE_REMAP',  sqlset_owner => 'ADMIN', staging_table_name => 'TAB_STAGE1', staging_schema_owner => 'ADMIN', REPLACE=>false );

```

**SPA 수행**

DBID가 변경된 SQL tuning Set과 Replay 시점의 SQL Tuning SET를 비교하여 성능 비교를 할수 있습니다. 
Replay 작업을 read_only로 설정하여 MISSING SQL이 많은것을 알수 있습니다. 

```sql
var atname varchar2(30);
var exec_name_1 VARCHAR2(4000);
var exec_name_2 VARCHAR2(4000);
var exec_name VARCHAR2(4000);

exec :atname := dbms_sqlpa.create_analysis_task;
exec :exec_name_1 := dbms_sqlpa.execute_analysis_task(:atname, 'convert',execution_params =>dbms_advisor.arglist('sqlset_name','CAP_SOE_REMAP','sqlset_owner','ADMIN'));
exec :exec_name_2 := dbms_sqlpa.execute_analysis_task(:atname, 'convert',execution_params =>dbms_advisor.arglist('sqlset_name','REP_SOE_r_125177','sqlset_owner','SYS'));
exec :exec_name := dbms_sqlpa.execute_analysis_task( task_name => :atname, execution_type => 'compare', execution_params => dbms_advisor.arglist('execution_name1', :exec_name_1,'execution_name2', :exec_name_2));

set long 10000000 longchunksize 10000000 linesize 200
SELECT dbms_sqlpa.report_analysis_task(task_name => :atname, type => 'TEXT', section => 'ALL') FROM dual;
General Information
---------------------------------------------------------------------------------------------

 Task Information:                              Workload Information:
 ---------------------------------------------  ---------------------------------------------
  Task Name    : TASK_187                        SQL Tuning Set Name        : CAP_SOE_REMAP
  Task Owner   : ADMIN                           SQL Tuning Set Owner       : ADMIN
  Description  :                                 Total SQL Statement Count  : 28

Execution Information:
---------------------------------------------------------------------------------------------
  Execution Name  : EXEC_327               Started             : 12/08/2023 08:26:50
  Execution Type  : COMPARE PERFORMANCE    Last Updated        : 12/08/2023 08:26:50
  Description     :                        Global Time Limit   : UNLIMITED
  Scope           : COMPREHENSIVE          Per-SQL Time Limit  : UNUSED
  Status          : COMPLETED              Number of Errors    : 0

Analysis Information:
---------------------------------------------------------------------------------------------
 Before Change Execution:                       After Change Execution:
 ---------------------------------------------  ---------------------------------------------
  Execution Name      : EXEC_325                 Execution Name      : EXEC_326
  Execution Type      : CONVERT SQLSET           Execution Type      : CONVERT SQLSET
  Scope               : COMPREHENSIVE            Scope               : COMPREHENSIVE
  Status              : COMPLETED                Status              : COMPLETED
  Started             : 12/08/2023 08:26:50      Started             : 12/08/2023 08:26:50
  Last Updated        : 12/08/2023 08:26:50      Last Updated        : 12/08/2023 08:26:50
  Global Time Limit   : UNLIMITED                Global Time Limit   : UNLIMITED
  Per-SQL Time Limit  : UNUSED                   Per-SQL Time Limit  : UNUSED

 Before Change Workload:                        After Change Workload:
 ---------------------------------------------  ---------------------------------------------
  SQL Tuning Set Name        : CAP_SOE_REMAP     SQL Tuning Set Name        : REP_SOE_r_125177
  SQL Tuning Set Owner       : ADMIN             SQL Tuning Set Owner       : SYS
  Total SQL Statement Count  : 28                Total SQL Statement Count  : 20

 ---------------------------------------------
 Comparison Metric: ELAPSED_TIME
 ------------------
 Workload Impact Threshold: 1%
 --------------------------
 SQL Impact Threshold: 1%
 ----------------------

Report Summary
---------------------------------------------------------------------------------------------

Projected Workload Change Impact:
-------------------------------------------
 Overall Impact      :  41.72%
 Improvement Impact  :  0%
 Regression Impact   :  18.14%
 Missing-SQL Impact  :  23.64%
 New-SQL Impact      :  -.06%

SQL Statement Count
-------------------------------------------
 SQL Category   SQL Count  Plan Change Count
 Overall               36                  0
 Common                12                  0
  Regressed             5                  0
  Unchanged             7                  0
 Different             24                  0
  Missing SQL          16                  0
  New SQL               8                  0

Top 36 SQL Sorted by Absolute Value of Change Impact on the Workload
---------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
|           |               | Impact on | Total Metric | Total Metric | Impact    | Plan   |
| object_id | sql_id        | Workload  |    Before    |    After     | on SQL    | Change |
--------------------------------------------------------------------------------------------
|        26 | 9wxc21rf6fdfw |    20.34% |    660260209 |    144615387 |     -.67% | n      |
|        34 | g1znkya370htg |    16.27% |    582412892 |    169813096 |     -4.5% | n      |
|         8 | 34mt4skacwwwd |     9.44% |    518509080 |    279243727 |   -69.71% | n      |
|        20 | 8uk8bquk453q8 |    -6.01% |     15971703 |    168339456 | -3673.44% | n      |
|         2 | 09pzy8x10gjkg |     5.35% |    135784170 |              |           | n      |
|        27 | a6hdpzrqqhc7d |     4.48% |    113513813 |              |           | n      |
|        31 | djj5txv2dzwb6 |     3.73% |     94466955 |              |           | n      |
|         4 | 0t61wk161zz87 |    -3.44% |      9411416 |     96741977 | -3723.13% | n      |
|        14 | 5g00dq4fxwnsw |     2.45% |     62075917 |              |           | n      |
|         7 | 2yp5w5a36s5xv |     2.26% |     57347486 |              |           | n      |
|        30 | csasr8ct2051v |     1.89% |     64359593 |     16437483 |    -7.43% | n      |
|         1 | 07d1xa9mbymgu |     1.48% |     37548321 |              |           | n      |
|        13 | 5573s2518pk36 |     1.18% |     29948935 |              |           | n      |
|        21 | 8xqdxjkbt9ghg |      .97% |     24643493 |              |           | n      |
|        35 | g3kf1ppky3627 |      .91% |     33051514 |     10087934 |    -20.3% | n      |
|        24 | 9v9ky32fg9hy7 |     -.84% |      3920432 |     25289836 |    -1919% | n      |
|        15 | 6au7zzgu3tuum |      .82% |     20785608 |              |           | n      |
|        28 | amaapqt3p9qd0 |      .62% |     22906970 |      7097927 |   -10.96% | n      |
|        33 | dxv2z78scnr7s |       .3% |      7527109 |              |           | n      |
|        18 | 8mfg9xd623ywd |      .29% |      7421833 |              |           | n      |
|         3 | 0c11vprf4881w |      .24% |      9673853 |      3511995 |  -149.38% | n      |
|        12 | 4h624tuydrjnh |      .23% |      5724045 |              |           | n      |
|        36 | g9wsbkb2jag3j |      .18% |      8734819 |      4045963 |   -44.95% | n      |
|        16 | 6u5z0z8btr8x0 |      .14% |      7096543 |      3456384 |  -234.43% | n      |
|        11 | 491wcfyfd6wc1 |      .06% |      1410869 |              |           | n      |
|         6 | 1uy98g4asqg6p |     -.05% |              |      1384636 |           | n      |
|        29 | b2664tcwjxwj0 |      .03% |       779379 |              |           | n      |
|        25 | 9w2b610hcgqkd |      .02% |       433344 |              |           | n      |
|        17 | 88whbbrqbfp1r |        0% |              |        67167 |           | n      |
|        32 | dwjfhksff9ypg |        0% |              |        24181 |           | n      |
|        23 | 9cbh3k57an2a8 |        0% |              |        22414 |           | n      |
|        10 | 3v59pf5ztkxcq |        0% |              |        15374 |           | n      |
|         5 | 1623up3zxhd1v |        0% |              |        12563 |           | n      |
|        22 | 9babjv8yq8ru3 |        0% |              |         7292 |           | n      |
|         9 | 359f7t2yhyu00 |        0% |              |         4378 |           | n      |
|        19 | 8uhqyg5jz06c8 |        0% |         2601 |              |           | n      |
--------------------------------------------------------------------------------------------
Note: time statistics are displayed in microseconds
---------------------------------------------------------------------------------------------
(생략)

-- missing된 SQL을 확인해보니 insert구문이었습니다(read_only로 replay실행되어 insert구문은 실행되지 않아서 누락되었습니다.)
SQL> SELECT sql_text FROM dba_sqlset_statements where SQLSET_NAME in ( 'CAP_SOE_REMAP') and sql_id = '09pzy8x10gjkg';
SQL_TEXT
--------------------------------------------------------------------------------
insert into order_items(ORDER_ID, LINE_ITEM_ID, PRODUCT_ID, UNIT_PRICE, QUANTITY

SQL>
```
## 마무리

Database Replay 작업 방식 및 고려사항에 대해서 알아보았습니다. 
Database Replay작업이외 SQL Performance Analyzer를 사용하고 각종 Report를 생성하는 작업이 추가되면서 작업 절차가 복잡해 보일수 있습니다.
운영서버에 Database 워크로드를 Capture하는 작업이 필요하므로 고려사항에 대해서 좀더 자세히 정리하려고 노력했습니다. 

운영환경에서 Database Replay를 위한 워크로드 Capture작업이 부담으로 느껴지실수 있습니다. (스토리지 공간 필요, Capture부하등등)
하지만 테스트 환경에서 절차를 검증하고, 좀더 적은 부하상황에서 적용해봄으로써 리스크를 줄일수 있습니다. (실제 해보기전까지 모르는 부분이기도 합니다.)

시스템에 대한 변경, DB변경에 의한 영향도를 파악하기에는 너무 많은 인력과 업무 협력이 필요합니다.
당장 업그레이드 작업을 준비할때도 느껴지실것 같습니다. 
DB자체 기능으로 워크로드를 생산하고 성능을 비교할수 있는 기능을 이용한다면 좀더 운영의 안정성을 확보할수 있는 기회가 되지 않을까 싶습니다.

## 참고문서

- Blogs
  - [Testing with Oracle Database Replay](https://blogs.oracle.com/coretec/post/testing-with-oracle-database-replay){: target="_blank"}
  - [Real Application Testing Database Replay Demo](https://blogs.oracle.com/coretec/post/rat-demo){: target="_blank"}
  - [Autonomous Database Replay](https://blogs.oracle.com/coretec/post/adb-database-replay){: target="_blank"}
  - [Smooth transition to Autonomous Database using SPA](https://blogs.oracle.com/coretec/post/spa-in-autonomous-database){: target="_blank"}
