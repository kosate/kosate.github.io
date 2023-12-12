---
layout: single
title: RAC환경에서 Database Repaly 고려사항
date: 2023-12-11 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - db replay
   - real application testing
   - real application cluster
excerpt : RAC환경에서 Database Replay 수행방법에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

RAC환경에서 Database Replay할때 고려사항에 대해서 정리하였습니다.

## RAC 환경에서 고려사항

Single Instance에서는 DB Replay방법은 아래 블로그을 참고하시면 됩니다. 

- 블로그 : [Database Replay 수행방법](/blog/oracle/introducing-dbreplay//){: target="_blank"}

RAC환경에서 Database Replay수행시 아래와 같은 고려사항이 있습니다. 
- Capture 파일 디렉토리 관리
- 특정 노드의 워크로드만 Capture할때
- SQL Tunig Set를 수집할때

## Capture파일 디렉토리 관리

RAC환경에서는 Capture파일을 저장하는 공간을 Shared Storage를 권고하고 있습니다. (Enterprise Manager에서는 Database Replay수행시에 Shared Storage만 지원합니다. )
그러나 미리 충분한 공간이 확보가 되어 있지 않다면 Local storage를 사용할수도 있습니다. 
워크로드를 Capture할때 각 노드별로 동일한 디렉토리에 인스턴스명으로 저장공간이 분리되어 저장되기 때문입니다.
대신 각 Local storage에 저장된 Capture파일을 Pre-processing하기전에 Merge해주는 작업이 필요합니다. 

**RAC환경에서 Local Storage로 Capture 작업 수행**

```sql
-- 각 노드별로 로컬 디렉토를 생성
root@ratrac1 ~]# mkdir /u01/app/oracle/diag/capdir
root@ratrac2 ~]# mkdir /u01/app/oracle/diag/capdir

-- LocaL 영역으로 디렉토리 생성
SQL> create directory cap_local_dir as '/u01/app/oracle/diag/capdir';
 
SQL> !ls -al  /u01/app/oracle/diag/capdir
drwxr-xr-x  2 oracle oinstall 4096 Dec 12 11:01 .
drwxrwxr-x 24 oracle oinstall 4096 Dec 12 11:01 ..

-- SOE유저로 접속된 워크로드만 필터링함
SQL> execute dbms_workload_capture.add_filter (fname=>'SOE_USER', fattribute=>'USER', fvalue=>'SOE');
-- 워크로드 Capture작업을 수행 
SQL> execute dbms_workload_capture.start_capture (name=>'CAP_SOE', dir=>'CAP_LOCAL_DIR', duration=> null, default_action=> 'EXCLUDE', capture_sts=> FALSE, plsql_mode => 'extended');

-- RAC환경에서는 모든노드의 alert.log에 메시지가 확인됩니다.
2023-12-12T11:37:31.736463+09:00
RATRAC_PDB1(4):DBMS_WORKLOAD_CAPTURE.START_CAPTURE(): Starting database capture at 12/12/2023 11:37:31

-- 워크로드 수행중
-- $> ./charbench -c ../configs/SOE_Client_Side_test1.xml -v tpm,tps,users,resp,vresp   

-- 워크로드 Capture작업을 중지함.
SQL> execute dbms_workload_capture.finish_capture();

-- RAC환경에서는 모든노드의 alert.log에 메시지가 확인됩니다.
2023-12-12T11:37:47.753730+09:00
RATRAC_PDB1(4):DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE(): Stopped database capture successfully at 12/12/2023 11:37:47

-- Capture작업에 대한 리포트 생성
SQL> set pagesize 0 long 30000000 longchunksize 1000
SQL> select dbms_workload_capture.report(3,'TEXT') from dual;

Database Capture Report For RATRAC

DB Name         DB Id    Release     RAC Capture Name               Status
------------ ----------- ----------- --- -------------------------- ----------
RATRAC        2909102694 19.21.0.0.0 YES CAP_SOE                    COMPLETED

                   Start time: 11-Dec-23 19:37:31 (SCN = 2782199)
                     End time: 11-Dec-23 19:37:46 (SCN = 2788783)
                     Duration: 15 seconds
                 Capture size: 12.80 MB
  PL/SQL subcall capture size: 0 bytes
             Directory object: CAP_LOCAL_DIR
               Directory path: /u01/app/oracle/diag/capdir
      Directory shared in RAC: TRUE
                 Filters used: 1 INCLUSION filter
                  PL/SQL mode: EXTENDED
         Encryption algorithm:

```
Report자체에는 RAC에서 수행했다는 명확한 정보는 없습니다.

**Capture 파일 확인**

1번노드와 2번노드의 각 로컬 영역에 Capture파일이 생성됩니다.
start_capture 명령어를 수행한 노드에 Capture리포트(wcr_cr.html, wcr_cr.text)가 생성됩니다

```bash
-- 1번 노드의 Capture파일 확인
root@ratrac1 ~]#  du -k  /u01/app/oracle/diag/capdir
20      /u01/app/oracle/diag/capdir/cap
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ab
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ae
4       /u01/app/oracle/diag/capdir/capfiles/inst1/af
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ad
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ac
4       /u01/app/oracle/diag/capdir/capfiles/inst1/aj
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ag
4       /u01/app/oracle/diag/capdir/capfiles/inst1/aa
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ai
4       /u01/app/oracle/diag/capdir/capfiles/inst1/ah
44      /u01/app/oracle/diag/capdir/capfiles/inst1
48      /u01/app/oracle/diag/capdir/capfiles
72      /u01/app/oracle/diag/capdir

-- 2번 노드의 Capture파일 확인
root@ratrac2 ~]# du -k  /u01/app/oracle/diag/capdir
176     /u01/app/oracle/diag/capdir/cap
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ab
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ai
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ae
13116   /u01/app/oracle/diag/capdir/capfiles/inst2/aa
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ac
4       /u01/app/oracle/diag/capdir/capfiles/inst2/af
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ah
4       /u01/app/oracle/diag/capdir/capfiles/inst2/aj
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ag
4       /u01/app/oracle/diag/capdir/capfiles/inst2/ad
13156   /u01/app/oracle/diag/capdir/capfiles/inst2
13160   /u01/app/oracle/diag/capdir/capfiles
13340   /u01/app/oracle/diag/capdir
[root@ratrac2 ~]# ls -al /u01/app/oracle/diag/capdir/cap
total 180
drwxr-xr-x 2 oracle asmadmin   4096 Dec 12 11:38 .
drwxr-xr-x 4 oracle oinstall   4096 Dec 12 11:37 ..
-rw-r--r-- 1 oracle asmadmin  40472 Dec 12 11:37 wcr_cr.html
-rw-r--r-- 1 oracle asmadmin  15196 Dec 12 11:37 wcr_cr.text
-rw-r--r-- 1 oracle asmadmin 108514 Dec 12 11:38 wcr_cr.xml
-rw-r--r-- 1 oracle asmadmin    266 Dec 12 11:37 wcr_fcapture.wmd
-rw-r--r-- 1 oracle asmadmin    156 Dec 12 11:37 wcr_scapture.wmd
[root@ratrac2 ~]#
```

pre-processing 작업전에 하나의 폴더에 merge해주는 작업이 필요합니다. 
cap 폴더와 capfiles 폴더가 있는데, capfiles폴더 밑에 inst1, inst2로 구분되므로 데이터가 겹치지 않습니다. 

**만약 디렉토리가 없다면?**

앞서 언급했듯이 Local storage에서 동일한 디렉토리를 생성하면 Capture가 가능합니다. 
그러나 만약 특정노드에 Capture 디렉토리가 없으면 어떤 에러가 발생될까요?

```sql
-- SOE유저로 접속된 워크로드만 필터링함
SQL> execute dbms_workload_capture.add_filter (fname=>'SOE_USER', fattribute=>'USER', fvalue=>'SOE');
-- 워크로드 Capture작업을 수행 
SQL> execute dbms_workload_capture.start_capture (name=>'CAP_SOE', dir=>'CAP_LOCAL_DIR', duration=> null, default_action=> 'EXCLUDE', capture_sts=> FALSE, plsql_mode => 'extended');
*
ERROR at line 1:
ORA-15505: cannot start workload capture because instance 2 encountered errors  <-- 2번노드에 디렉토리관련 에러가 발생됨
while accessing directory "/u01/app/oracle/diag/capdir"
ORA-06512: at "SYS.DBMS_WORKLOAD_CAPTURE_I", line 1311
ORA-06512: at "SYS.DBMS_WORKLOAD_CAPTURE_I", line 878
ORA-06512: at "SYS.DBMS_WORKLOAD_CAPTURE_I", line 1172
ORA-06512: at "SYS.DBMS_WORKLOAD_CAPTURE_I", line 1327
ORA-06512: at "SYS.DBMS_WORKLOAD_CAPTURE", line 16
ORA-06512: at line 1

-- RAC 모든노드에 아래와 같은 메시지가 발생됩니다.
-- starting하다가 에러가발생되어 finish메시지가 발생됩니다.
2023-12-12T12:27:52.206975+09:00
RATRAC_PDB1(4):DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE(): Stopped database capture successfully at 12/12/2023 12:27:51
```

## 특정 노드의 워크로드만 Capture할때

RAC전노드의 워크로드를 동시에 Capture하지만 특정 노드의 워크로드만 Capture하도록 필터링 조건을 추가할수 있습니다. 

내가 1번노드에서만 워크로드를 Capture할고 싶을수 있습니다.
필터 조건을 인스턴스번호로 추가할수 있습니다. 대신 start_capture를 수행하는 노드가 1번이어야합니다.
(2번노드에 접속해서 Capture를 수행하면 워크로드 Capture가 되지 않습니다.)

```sql
-- SOE유저로 접속된 워크로드만 필터링함
SQL> execute dbms_workload_capture.add_filter (fname=>'SOE_USER', fattribute=>'USER', fvalue=>'SOE');
-- 1번 인스턴스 워크로드만 필터링함. 
SQL> execute dbms_workload_capture.add_filter (fname=>'INST_NUM', fattribute=>'INSTANCE_NUMBER', fvalue=>1);
-- 워크로드 Capture작업을 수행 
SQL> execute dbms_workload_capture.start_capture (name=>'CAP_SOE', dir=>'CAP_LOCAL_DIR', duration=> null, default_action=> 'EXCLUDE', capture_sts=> FALSE, plsql_mode => 'extended');
```

## RAC환경에서 STS 생성방법

RAC환경에서는 start_capture명령어 수행시 capture_sts=> True로 설정할 경우 에러가 발생됩니다. 
- Single Instance에서만 start_capture작업시 STS를 같이 생성할수 있습니다. 
- RAC에서는 "노드별"로 Cursor Cache를 수집하는 작업을 Capture작업과 병행합니다.
  - 관련문서 RAT: How To Create 'SQL Tuning Set (STS)' Along With Capture/Replay On RAC Database - Using 'CAPTURE_STS=>TRUE' In RAC Results In Error. (Doc ID 2792609.1)

```sql
-- 노드별로 STS 생성하여 수집합니다.
SQL> exec SYS.dbms_sqlset.CREATE_SQLSET(sqlset_name=>'STS_CAP_SOE_NODE1', description=>'Statements from Before-Change' );
-- 1500초동안 60초에 한번씩 수집함.
SQL> begin
  DBMS_SQLTUNE.CAPTURE_CURSOR_CACHE_SQLSET(
    sqlset_name => 'STS_CAP_SOE_NODE1',
    time_limit => 1500,
    repeat_interval => 60,
    capture_option => 'MERGE',
    capture_mode => DBMS_SQLTUNE.MODE_ACCUMULATE_STATS,
    basic_filter  => 'parsing_schema_name in (''SOE'')',
    sqlset_owner => NULL,
    recursive_sql => 'HAS_RECURSIVE_SQL');
end;
/
SQL> SELECT statement_count FROM dba_sqlset WHERE name = 'STS_CAP_SOE_NODE1';
STATEMENT_COUNT
---------------
              39
```

## Connection Mapping 관리

Replay가 수행되는 환경이 RAC라면 접속하는 노드를 지정해야할수도 있습니다.
특정노드로 접속하거나, 로드발란스해서 여러노드에 분산해서 접속하거나하는 작업들이 필요합니다.
WRC 클라이언트의 접속정보를 매핑하여 아래와 같이 다양한 접속정보 설정이 가능합니다.

```sql
select * from dba_workload_connection_map;

begin
  dbms_workload_replay.remap_connection(connection_id => 1,
                                        replay_connection => 'replay-rac2:1521/pdb');
  dbms_workload_replay.remap_connection(connection_id => 2,
                                        replay_connection => 'replay-scan/pdb');
  dbms_workload_replay.remap_connection(connection_id => 3,
                                        replay_connection => 'replay-rac1:1521/pdb');
end;
/
```


## 마무리

RAC환경에서 Database Replay수행시 고려사항에 대해서 알아보았습니다. 
다양한 옵션들을 활용하여 Database Replay수행할때 도움이 되었으면 합니다. 
