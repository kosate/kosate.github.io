---
layout: single
title: SQLcl 도구 소개
date: 2023-11-20 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - sqlcl
excerpt : Java기반의 Command Line도구인 SQLcl도구에 대해서 설명합니다.
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터를 관리하기 위하여 SQL*Plus 도구를 많이 사용합니다. 
SQL*Plus 와 유사한 기능을 제공하면서 기능확장이 가능한 Java기반의 Command Line 도구를 제공하고 있습니다

SQLcl 기능에 대해서 알아보겠습니다. 

## SQLcl(SQL Developer Command Line) 소개

SQLcl은 오라클 데이터베이스를 위한 Java기반의 Command Line도구입니다. SQLcl을 사용하면 SQL, PL/SQL을 편리하게 수행할수 있습니다. 
SQLcl은 자동완성기능, 편집기가 내장되어 있습니다. 기능을 확장하면 사용자 정의 명령어를 만들수 있어 다양한 환경과 연동이 가능합니다.
SQLcl은 Oracle SQL Developer의 Script Engine을 그대로 사용하고 있습니다. SQLcl에서 수행할수 있는 명령어는 SQL Developer에서도 사용가능합니다. 

- 기본 기능
  - 접속정보관리
  - Auto-Formatting 기능제공
  - Query History를 관리
  - 사용자 정의 Command 설정(alias)
  - Liquibase 과 연동하여 데이터베이스 객체 변경관리
  - Inline-Editing기능제공(VI편집기)
  - JavaScript를 사용
  - SQLcl Extention기능 제공 (사용자 정의 명령어를 만들수 있음)
    - DataPump/Data Guard관리 기능
    - OCI 연계기능

## 설치 방법

SQLcl은 Java에서 동작하므로 JRE 11이상 필요합니다. SQLcl의 최신버전을 다운로드합니다.

- SQLcl 다운로드 사이트 : <https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/>

다음은 SQLcl을 설치하는 예시입니다. zip파일을 다운로드후에 압축해제후에 Java환경변수만 설정하면 곧바로 사용할수 있습니다.
```bash
-- Java는 최소 11이상이어야합니다.
[oracle@instance-20230922-1608 sqlcl]$ java -version
java version "17.0.8" 2023-07-18 LTS
Java(TM) SE Runtime Environment (build 17.0.8+9-LTS-211)
Java HotSpot(TM) 64-Bit Server VM (build 17.0.8+9-LTS-211, mixed mode, sharing)
-- SQLcl의 최신 버전을 다운로드합니다. (2023년 11월 기준 23.3입니다)
[oracle@instance-20230922-1608 sqlcl]$ wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip

--2023-11-20 07:27:34--  https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip
Resolving download.oracle.com (download.oracle.com)... 59.151.138.201
Connecting to download.oracle.com (download.oracle.com)|59.151.138.201|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41859690 (40M) [application/zip]
Saving to: ‘sqlcl-latest.zip’
sqlcl-latest.zip                         100%[===============================================================================>]  39.92M  54.4MB/s    in 0.7s
2023-11-20 07:27:35 (54.4 MB/s) - ‘sqlcl-latest.zip’ saved [41859690/41859690]
[oracle@instance-20230922-1608 sqlcl]$ ls -arlt
total 40880
-rw-r--r--. 1 oracle oinstall 41859690 Oct 10 09:24 sqlcl-latest.zip
[oracle@instance-20230922-1608 sqlcl]$ unzip sqlcl-latest.zip
Archive:  sqlcl-latest.zip
   creating: sqlcl/
   creating: sqlcl/bin/
   creating: sqlcl/lib/
   creating: sqlcl/lib/ext/
  inflating: sqlcl/README.md
  inflating: sqlcl/Release-Notes.md
  inflating: sqlcl/third-party-licenses.txt
  ..
[oracle@instance-20230922-1608 sqlcl]$ cd sqlcl
[oracle@instance-20230922-1608 sqlcl]$ ls -arlt
total 208
drwxr-xr-x. 2 oracle oinstall    111 Sep 27 12:50 bin
-rw-r--r--. 1 oracle oinstall 190195 Sep 27 12:53 third-party-licenses.txt
-rw-r--r--. 1 oracle oinstall   4404 Sep 27 12:53 README.md
-rw-r--r--. 1 oracle oinstall     44 Sep 27 12:53 23.3.0.270.1251
drwxr-xr-x. 4 oracle oinstall    124 Sep 27 12:53 .
-rw-r--r--. 1 oracle oinstall   3975 Sep 27 12:53 Release-Notes.md
drwxr-xr-x. 3 oracle oinstall   4096 Sep 27 12:54 lib
drwxr-xr-x. 3 oracle oinstall     43 Nov 20 07:29 ..
```

SQLcl을 통해서 오라클 데이터베이스 접속합니다.
```sql
[oracle@instance-20230922-1608 sqlcl]$ cd bin
-- SQL cl버전은 23.3입니다.
[oracle@instance-20230922-1608 sqlcl]$ ./sql /nolog

SQLcl: Release 23.3 Production on Mon Nov 20 07:31:08 2023

Copyright (c) 1982, 2023, Oracle.  All rights reserved.

-- 명령어들 목록들을 확인합니다.
SQL> help
For help on a topic type help <topic>
List of Help topics available:
/                  @                  @@                 ACCEPT             ALIAS              APEX               APPEND             AQ
ARBORI             ARCHIVE_LOG        ARGUMENT           BLOCKCHAIN_TABLE   BREAK              BRIDGE             BTITLE             CD
CERTIFICATE        CHANGE             CLEAR              CLOUDSTORAGE       CODESCAN           COLUMN             COMPUTE            CONNECT
CONNMGR            COPY               CS                 CTAS               DATAPUMP           DBCCRED            DDL                DEFINE
DEL                DESCRIBE           DG                 DISCONNECT         EDIT               EXECUTE            EXIT               FIND
FORMAT             GET                HISTORY            HOST               IMMUTABLE_TABLE    INFORMATION        INPUT              LIQUIBASE
LIST               LOAD               MIGRATEADVISOR     MKSTORE            MODELER            NET                OCI                OCIDBMETRICS
OERR               ORAPKI             PASSWORD           PAUSE              PRINT              PROMPT             QUIT               REMARK
REPEAT             RESERVED_WORDS     REST               RUN                SAVE               SCRIPT             SECRET             SET
SHOW               SHUTDOWN           SODA               SPOOL              SSHTUNNEL          START              STARTUP            STORE
TIMING             TNSPING            TOSUB              TTITLE             UNDEFINE           UNLOAD             VARIABLE           VAULT
WHENEVER           WHICH              XQUERY
```

명령어(show version) : SQLcl의 버전을 확인합니다.
```sql
-- SQLcl의 버전을 확인합니다.
SQL> show version
Oracle SQLDeveloper Command-Line (SQLcl) version: 23.3.0.0 build: 23.3.0.270.1251
SQL>
```
명령어(show instance) : DB instance정보를 확인합니다.
```sql
-- 데이터베이스 접속방법은 SQL Plus와 동일합니다. TNSNAME을 통해서 접속했습니다.
SQL> connect admin@freepdb1
Connected.
SQL> show user
USER is "ADMIN"
-- 기본적으로 SQL result결과는 ansiconsole로 되어 있습니다.
SQL> select banner from v$version;
BANNER
_________________________________________________________________________________
Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
-- 접속한 instance정보를 확인합니다.
SQL> show instance
USERNAME ADMIN
INSTANCE_NAME FREE
HOST_NAME instance-20230922-1608
SID 34
VERSION 23.0.0.0.0
STARTUP_DAY 20231124
```

명령어(show jdbc) : 현재 접속된 환경에서 사용된 jdbc드라이버와 DB정보를 확인합니다.
```sql
-- jdbc driver버전을 확인합니다. 
SQL> show jdbc
-- Database Info --
Database Product Name: Oracle
Database Product Version: Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
Version 23.3.0.23.09
Database Major Version: 23
Database Minor Version: 3
-- Driver Info --
Driver Name: Oracle JDBC driver
Driver Version: 23.3.0.23.09
Driver Major Version: 23
Driver Minor Version: 3
Driver URL: jdbc:oracle:thin:@localhost:1521/freepdb1
Driver Location:
resource: oracle/jdbc/OracleDriver.class
jar: /opt/oracle/product/23c/dbhomeFree/jdbc/lib/ojdbc11.jar
JarSize: 7105082
JarDate: Fri Sep 01 05:02:24 GMT 2023
resourceSize: 6385
resourceDate: Thu Aug 31 22:02:20 GMT 2023
SQL>
```

## 기본 예제

SQLcl에는 SQLPlus에서 제공되는 기능외의 다양한 기능을 제공하고 있습니다. 주로 SQLPlus와 대비하여 차별화되는 기능위주로 정리하였습니다. 

### 접속정보 관리

SQL Developer를 사용하면 GUI환경에서 Connection정보를 관리할수 있습니다. 
SQLcl안에서도 Connection정보를 관리하는 기능을 제공합니다. (생성, 변경, 복제)
(내부적으로 /home/oracle/.dbtools/connections 디렉토리에  Connection 명으로 파일폴더가 생성되어 관리됩니다.)

- 주의사항 : 접속정보는 JDBC Connection String으로 해야됩니다. TNSNAME을 사용하면 접속테스트할때 에러발생됩니다.(TNSNAME명을 JDBC Connection String으로 사용되어 hostname로 인식하여 ORA-17868에러발생됨)

명령어(connect) : 접속정보를 관리합니다.
```sql
-- SQLcl에서 Connect 예제를 확인합니다.
SQL> help connect examples
To connect to an Oracle database:
  SQL>CONNECT user/password@url

To connect to an Oracle database using sysdba role:
  SQL>CONNECT user/password@url as sysdba

To save the database connection:
  SQL>CONNECT -save <connection_name> user/password@url

More examples are available under topics for each of the different kind of connection.
```

명령어(connect -save) : 접속정보를 저장합니다
```sql
-- "free" Connection를 저장합니다. (패스워드는 저장되지 않습니다.) 
SQL> connect -save free admin@localhost:1521/freepdb1
Name: free
Connect String: localhost:1521/freepdb1
User: admin
Password: not saved
Connected.
```

명령어(connmgr) : 접속 정보와 내용을 확인합니다. 
```sql
-- Conneciton 목록을 확인합니다. 
SQL> connmgr list
free
-- "free"  Connection 정보를 확인합니다.
SQL> connmgr show free
Name: free
Connect String: localhost:1521/freepdb1
User: admin
Password: not saved
-- "free"  Connection 를 테스트합니다. 
SQL> connmgr test free
Password? (**********?) *************
Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
Connection Test Successful
-- "free" Connection 정보를 "free_clone"으로 복제합니다.
SQL> connmgr clone -original free free_clone
-- Conneciton 목록을 확인합니다. 
SQL> connmgr list
free
free_clone
SQL>
```

명령어(connect -name) : 저장된 접속정보를 사용하여 접속합니다.
```sql
-- "free_clone" Connection 접속합니다.
SQL> conn -name free_clone
Password? (**********?) *************
Connected.
-- 접속한 Connection 정보를 확인합니다.
SQL> show connection
COMMAND_PROPERTIES:
 type: STORE
 name: free_clone
 user: admin
CONNECTION:
 ADMIN@jdbc:oracle:thin:@localhost:1521/freepdb1
CONNECTION_IDENTIFIER:
 jdbc:oracle:thin:@localhost:1521/freepdb1
CONNECTION_DB_VERSION:
 Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
 Version 23.3.0.23.09
NOLOG:
 false
PRELIMAUTH:
 false
```

### SQL Result Format 지정

SQL Plus를 사용하다보면 pretty하게 결과를 보기 위해서 컬럼 포멧(길이)를 지정하여 봅니다.
SQLcl에서는 간단하게 컬럼크기를 조정해주는 기능을 제공하고, 더불어 결과를 다양한 형식으로 제공합니다. 

- sql format형식
  - table, casv, html, xml, json, fixed, insert, loader, delimited, ansiconsole

명령어 (set sqlformat) : SQL format 정보를 확인합니다.
```sql
-- SQL Format 목록을 확인합니다.
SQL> help set sqlformat
SET SQLFORMAT
  SET SQLFORMAT { default,csv,html,xml,json,fixed,insert,loader,delimited,ansiconsole}

   default        : SQL*PLUS style formatting
   csv            : comma separated and string enclosed with "
   html           : html tabular format
   xml            : xml format of /results/rows/column/*
   json           : json format matching ORDS Collection Format
   json-formatted : json format matching ORDS Collection Format and pretty printed
   fixed          : fixed width
   insert         : generates insert statements from sql results
                    Example
                      Insert into EMP (EMPNO,ENAME,JOB,MGR,HIREDATE,SAL,COMM,DEPTNO)
                      values (7369,'SMITH','CLERK',7902,to_timestamp('17-DEC-80','DD-MON-RR HH.MI.SSXFF AM'),800,null,20);

   loader         : pipe (|) delimited enclosed with "
                    Example:
                       7369|"SMITH"|"CLERK"|7902|"1980-12-17 00:00:00"|800||20|5555555555554444|

   delimited      : CSV format with optional separator , left, and right enclosure
                    set sqlformat delimited [separator] [left enclosure] [right enclosure]
                    Example:
                    set sqlformat delimited , < >
                       7369,<SMITH>,<CLERK>,7902,17-DEC-80,800,,20,5555555555554444

   ansiconsole    : advanced formatting based on data and terminal size
                    set sqlformat ansiconsole                       : base format
                    set sqlformat ansiconsole default               :  number formatting to ###,###.###
                    set sqlformat ansiconsole <number format mask>  : Mask following Java DecimalFormat

                               https://docs.oracle.com/javase/8/docs/api/java/text/DecimalFormat.html

                    set sqlformat ansiconsole -config=highlight.json : highlight matches in results

                    highlight options :
                    Example :
                    {"highlights":[
                        {"type":"startWith","test":"W","color":"INTENSITY_BOLD,CYAN"},
                        {"type":"endWith","test":"MAN","color":"BLUE"},
                        {"type":"contains","test":"MIT","color":"YELLOW"},
                        {"type":"exact","test":"FORD","color":"GREEN"},
                        {"type":"regex","test":"[0-9]{2}","color":"MAGENTA"}
                      ]
                    }

```

명령어 (set sqlformat ansiconsole) : 기본설정값으로 컬럼크기를 조정해서 보여줍니다.
```sql
-- SQLcl의 기본 포멧형식은 ansiconsole입니다. 
-- ansiconsole은 데이터크기를 고려하여 자동으로 컬럼크기를 조정해서 보여줍니다.
SQL> show sqlformat
SQL Format : ansiconsole
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
   EMPLOYEE_ID FIRST_NAME    LAST_NAME    EMAIL      PHONE_NUMBER      HIRE_DATE    JOB_ID        SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ __________ _________________ ____________ __________ _________ _________________ _____________ ________________
           100 Steven        King         SKING      1.515.555.0100    17-JUN-13    AD_PRES        24000                                               90
           101 Neena         Yang         NYANG      1.515.555.0101    21-SEP-15    AD_VP          17000                             100               90
           102 Lex           Garcia       LGARCIA    1.515.555.0102    13-JAN-11    AD_VP          17000                             100               90
-- sqlformat을 default로 변경하면 기존 SQL plus와 같은 방식으로 수동으로 컬럼크기를 조정해야합니다.
SQL> set sqlformat default
SQL Format Cleared
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
EMPLOYEE_ID FIRST_NAME           LAST_NAME                 EMAIL                     PHONE_NUMBER         HIRE_DATE JOB_ID         SALARY
----------- -------------------- ------------------------- ------------------------- -------------------- --------- ---------- ----------
COMMISSION_PCT MANAGER_ID DEPARTMENT_ID
-------------- ---------- -------------
        100 Steven               King                      SKING                     1.515.555.0100       17-JUN-13 AD_PRES         24000
                                     90

        101 Neena                Yang                      NYANG                     1.515.555.0101       21-SEP-15 AD_VP           17000
                      100            90

        102 Lex                  Garcia                    LGARCIA                   1.515.555.0102       13-JAN-11 AD_VP           17000
                      100            90
```

명령어 (set sqlformat csv) : csv 형식으로 화면에 출력됩니다.
```sql
-- sqlformat을 cvs로 설정하면 결과가 csv로 출력됩니다.
SQL> set sqlformat csv
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
"EMPLOYEE_ID","FIRST_NAME","LAST_NAME","EMAIL","PHONE_NUMBER","HIRE_DATE","JOB_ID","SALARY","COMMISSION_PCT","MANAGER_ID","DEPARTMENT_ID"
100,"Steven","King","SKING","1.515.555.0100",17-JUN-13,"AD_PRES",24000,,,90
101,"Neena","Yang","NYANG","1.515.555.0101",21-SEP-15,"AD_VP",17000,,100,90
102,"Lex","Garcia","LGARCIA","1.515.555.0102",13-JAN-11,"AD_VP",17000,,100,90
```

명령어 (set sqlformat json) : json 형식으로 화면에 출력됩니다.
```sql
-- sqlformat을 json로 설정하면 결과가 json로 출력됩니다.
SQL>  set sqlformat json
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
{"results":[{"columns":[{"name":"EMPLOYEE_ID","type":"NUMBER"},{"name":"FIRST_NAME","type":"VARCHAR2"},{"name":"LAST_NAME","type":"VARCHAR2"},{"name":"EMAIL","type":"VARCHAR2"},{"name":"PHONE_NUMBER","type":"VARCHAR2"},{"name":"HIRE_DATE","type":"DATE"},{"name":"JOB_ID","type":"VARCHAR2"},{"name":"SALARY","type":"NUMBER"},{"name":"COMMISSION_PCT","type":"NUMBER"},{"name":"MANAGER_ID","type":"NUMBER"},{"name":"DEPARTMENT_ID","type":"NUMBER"}],"items":
[
{"employee_id":100,"first_name":"Steven","last_name":"King","email":"SKING","phone_number":"1.515.555.0100","hire_date":"17-JUN-13","job_id":"AD_PRES","salary":24000,"department_id":90}
,{"employee_id":101,"first_name":"Neena","last_name":"Yang","email":"NYANG","phone_number":"1.515.555.0101","hire_date":"21-SEP-15","job_id":"AD_VP","salary":17000,"manager_id":100,"department_id":90}
,{"employee_id":102,"first_name":"Lex","last_name":"Garcia","email":"LGARCIA","phone_number":"1.515.555.0102","hire_date":"13-JAN-11","job_id":"AD_VP","salary":17000,"manager_id":100,"department_id":90}
]}]}
```

명령어 (set sqlformat insert) : insert구문으로 화면에 출력됩니다.
```sql
-- sqlformat을 insert로 설정하면 결과가 insert문으로 출력됩니다.
SQL> set sqlformat insert
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
REM INSERTING into HR.EMPLOYEES
SET DEFINE OFF;
Insert into HR.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values (100,'Steven','King','SKING','1.515.555.0100',to_timestamp('17-JUN-13','DD-MON-RR HH.MI.SSXFF AM'),'AD_PRES',24000,null,null,90);
Insert into HR.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values (101,'Neena','Yang','NYANG','1.515.555.0101',to_timestamp('21-SEP-15','DD-MON-RR HH.MI.SSXFF AM'),'AD_VP',17000,null,100,90);
Insert into HR.EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE,JOB_ID,SALARY,COMMISSION_PCT,MANAGER_ID,DEPARTMENT_ID) values (102,'Lex','Garcia','LGARCIA','1.515.555.0102',to_timestamp('13-JAN-11','DD-MON-RR HH.MI.SSXFF AM'),'AD_VP',17000,null,100,90);
```

명령어 (set sqlformat loader) : load이 가능한 형식으로 화면에 출력됩니다.
```sql
-- sqlformat을 loader로 설정하면 결과가 |를 구분자로 하여 loader에 사용하기 적합한 형식으로 출력됩니다.
SQL> set sqlformat loader
SQL> select * from hr.EMPLOYEES fetch first 3 rows only;
 100|"Steven"|"King"|"SKING"|"1.515.555.0100"|"2013-06-17 00:00:00"|"AD_PRES"|24000|||90|
 101|"Neena"|"Yang"|"NYANG"|"1.515.555.0101"|"2015-09-21 00:00:00"|"AD_VP"|17000||100|90|
 102|"Lex"|"Garcia"|"LGARCIA"|"1.515.555.0102"|"2011-01-13 00:00:00"|"AD_VP"|17000||100|90|
SQL>
```
### History 기능 

SQL이나 명령어의 실행이력을 확인할수 있습니다. 저장되는 기본 갯수는 100개이며 필요시 갯수를 늘릴수 있습니다(set history limit 10000). 저장된 명령어들의 실행 횟수, 수행시간을 확인할수 있습니다. 
실행하였으니 실패한 SQL들은 이력으로 관리되지 않습니다.
프롬프트에서 up/down을 누르면 이전에 실행했던 명령어를 선택할수 있습니다. 
($HOME/.sqlcl/history.log에 이력으로 저장되어 있습니다. 세션이 종료되어도 OS에 파일에 저장되기 때문에 다시 접속하면 이력을 확인할수 있습니다. )


명령어 (history) : 수행된 명령어 목록들이 출력됩니다.
```sql
-- history가 활성화되어 있습니다. show, history, connect, clear, secret명령어들은 이력을 저장되지 않습니다.(필요시 set history filter를 이용하여 변경가능)
SQL> show history
HISTORY
        enabled
        filter: show, history, connect, clear, secret
        Do not show failed statements
-- 전체 저장된 명령어들을 확인합니다. 
SQL> history
History:
  1  desc v$database
  2  select NAME from v$database;
  3  select * from v$database;
  4  select * from v$version;
  5  select banner from v$version;
  6  tnsping freepdb1
  ...
 29  set sqlformat default
 30  set sqlformat csv
 31  set sqlformat json
 32  set sqlformat insert
 33  set sqlformat loader
 34  select * from hr.EMPLOYEES fetch first 3 rows only;
SQL>
```

명령어 (history usage) : 실행된 명령어들의 횟수가 표시됩니다.
```sql
-- 실행된 명령어들의 횟수가 표시됩니다.
SQL> history usage
  1  (1) desc v$database
  2  (1) select NAME from v$database;
  3  (1) select * from v$database;
  4  (1) select * from v$version;
  5  (1) select banner from v$version;
  6  (1) tnsping freepdb1
   ..
 29  (1) set sqlformat default
 30  (1) set sqlformat csv
 31  (1) set sqlformat json
 32  (1) set sqlformat insert
 33  (1) set sqlformat loader
 34  (6) select * from hr.EMPLOYEES fetch first 3 rows only;
```

명령어 (history time) : 실행된 명령어들의 수행시간이 표시됩니다.
```sql
-- 실행된 명령어들의 수행시간이 표시됩니다.
SQL> history time
  1  (00.383) desc v$database
  2  (00.014) select NAME from v$database;
  3  (00.092) select * from v$database;
  4  (00.012) select * from v$version;
  5  (00.005) select banner from v$version;
  6  (      ) tnsping freepdb1
 ..
 29  (      ) set sqlformat default
 30  (      ) set sqlformat csv
 31  (      ) set sqlformat json
 32  (      ) set sqlformat insert
 33  (      ) set sqlformat loader
 34  (00.011) select * from hr.EMPLOYEES fetch first 3 rows only;
SQL>
```


### 코드 자동완성 기능

특정 위치에서 tab을 누르면 키워드, 오브젝트, 파일들을 선택할수 있도록 command line 밑에 목록들이 나오게 됩니다. 나온 목록들중에 커서를 이용하여 선택하여 자동완성을 합니다.


명령어 ([tab]) : 객체, 키워드뒤에 tab을 누르면 사용가능한 명령어나 키워드가 나옵니다.
```sql
-- 특정위치에서 tab을 누르면 밑에 선택 가능한 키워드가 나오게 됩니다. 
-- 키워드는 화살표로 이동하여 선택합니다.
SQL> select * [tab을 누름]
-         CONNECT   FROM      GROUP     INTO      MODEL     ORDER     UNION     WHERE  <-- 목록이 보임

-- 테이블목록이 자동 완성됩니다.
SQL> select * from hr.EMP[tab을 누름]
hr.EMPLOYEES          hr.EMP_DETAILS_VIEW<-- 목록이 보임

-- 파일명이 자동 완성됩니다. 
SQL> @[tab을 누름]
README.md          afiedt.buf         dependencies.txt   history.log        license.txt        sql*               sql.exe*           version.txt<-- 목록이 보임
```

### 데이터베이스 객체 보기

테이블 및 패키지에 대해서 상세한 정보를 확인할수 있습니다.
SQL Plus에서는 테이블의 구조만 확인할수 있었지만, SQLcl에서는 인덱스, 통계정보까지 같이 확인할수 있습니다. 그리고 DDL문장도 생성이 가능합니다(내부적으로는 DBMS_METADATA를 사용하는것 같습니다.)

명령어(info) : 데이터베이스 객체에 대한 정보를 확인합니다. 
```sql
-- 데이터베이스 객체에 대해서 구조를 파악할수 있습니다. SQL Plus에 있는 기능입니다.
SQL> desc hr.EMPLOYEES ;

Name              Null?       Type
_________________ ___________ _______________
EMPLOYEE_ID       NOT NULL    NUMBER(6)
FIRST_NAME                    VARCHAR2(20)
LAST_NAME         NOT NULL    VARCHAR2(25)
EMAIL             NOT NULL    VARCHAR2(25)
PHONE_NUMBER                  VARCHAR2(20)
HIRE_DATE         NOT NULL    DATE
JOB_ID            NOT NULL    VARCHAR2(10)
SALARY                        NUMBER(8,2)
COMMISSION_PCT                NUMBER(2,2)
MANAGER_ID                    NUMBER(6)
DEPARTMENT_ID                 NUMBER(4)

-- 테이블과 컬럼에 대해서 좀더 상세한 정보를 확인할수 있고, Index, Reference 정보도 같이 확인할수 있습니다. 
SQL> info  hr.EMPLOYEES ;
TABLE: EMPLOYEES
         LAST ANALYZED:2023-11-20 11:25:14.0
         ROWS         :107
         SAMPLE SIZE  :107
         INMEMORY     :DISABLED
         COMMENTS     :employees table. References with departments,
                       jobs, job_history tables. Contains a self reference.

Columns
NAME             DATA TYPE           NULL  DEFAULT    COMMENTS
*EMPLOYEE_ID     NUMBER(6,0)         No               Primary key of employees table.
 FIRST_NAME      VARCHAR2(20 BYTE)   Yes              First name of the employee. A not null column.
 LAST_NAME       VARCHAR2(25 BYTE)   No               Last name of the employee. A not null column.
 EMAIL           VARCHAR2(25 BYTE)   No               Email id of the employee
 PHONE_NUMBER    VARCHAR2(20 BYTE)   Yes              Phone number of the employee; includes country
                                                      code and area code
 HIRE_DATE       DATE                No               Date when the employee started on this job. A not
                                                      null column.
 JOB_ID          VARCHAR2(10 BYTE)   No               Current job of the employee; foreign key to job_id
                                                      column of thejobs table. A not null column.
 SALARY          NUMBER(8,2)         Yes              Monthly salary of the employee. Must be
                                                      greaterthan zero (enforced by constraint
                                                      emp_salary_min)
 COMMISSION_PCT  NUMBER(2,2)         Yes              Commission percentage of the employee; Only
                                                      employees in salesdepartment elgible for
                                                      commission percentage
 MANAGER_ID      NUMBER(6,0)         Yes              Manager id of the employee; has same domain as
                                                      manager_id indepartments table. Foreign key to
                                                      employee_id column of employees table.(useful for
                                                      reflexive joins and CONNECT BY query)
 DEPARTMENT_ID   NUMBER(4,0)         Yes              Department id where employee works; foreign key to
                                                      department_idcolumn of the departments table

Indexes
INDEX_NAME              UNIQUENESS    STATUS    FUNCIDX_STATUS    COLUMNS
_______________________ _____________ _________ _________________ ________________________
HR.EMP_JOB_IX           NONUNIQUE     VALID                       JOB_ID
HR.EMP_NAME_IX          NONUNIQUE     VALID                       LAST_NAME, FIRST_NAME
HR.EMP_EMAIL_UK         UNIQUE        VALID                       EMAIL
HR.EMP_EMP_ID_PK        UNIQUE        VALID                       EMPLOYEE_ID
HR.EMP_MANAGER_IX       NONUNIQUE     VALID                       MANAGER_ID
HR.EMP_DEPARTMENT_IX    NONUNIQUE     VALID                       DEPARTMENT_ID


References
TABLE_NAME     CONSTRAINT_NAME    DELETE_RULE    STATUS     DEFERRABLE        VALIDATED    GENERATED
______________ __________________ ______________ __________ _________________ ____________ ____________
DEPARTMENTS    DEPT_MGR_FK        NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME
EMPLOYEES      EMP_MANAGER_FK     NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME
JOB_HISTORY    JHIST_EMP_FK       NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME
```

명령어(info+) : 명령어(info) 의 결과에서 컬럼별 통계정보가 추가됩니다.
```sql
-- 통계정보값을 추가적으로 확인할수 있습니다. 
SQL> info+ hr.EMPLOYEES
TABLE: EMPLOYEES
         LAST ANALYZED:2023-11-20 11:25:14.0
         ROWS         :107
         SAMPLE SIZE  :107
         INMEMORY     :DISABLED
         COMMENTS     :employees table. References with departments,
                       jobs, job_history tables. Contains a self reference.

Columns
NAME             DATA TYPE           NULL  DEFAULT    LOW_VALUE             HIGH_VALUE            NUM_DISTINCT   HISTOGRAM
*EMPLOYEE_ID     NUMBER(6,0)         No                   100                   206                   107            NONE
 FIRST_NAME      VARCHAR2(20 BYTE)   Yes                  Adam                  Winston               92             NONE
 LAST_NAME       VARCHAR2(25 BYTE)   No                   Abel                  Zlotkey               102            NONE
 EMAIL           VARCHAR2(25 BYTE)   No                   ABANDA                WTAYLOR               107            NONE
 PHONE_NUMBER    VARCHAR2(20 BYTE)   Yes                  1.515.555.0100        44.1632.960034        107            NONE
 HIRE_DATE       DATE                No                   2011.01.13.00.00.00   2018.04.21.00.00.00   98             NONE
 JOB_ID          VARCHAR2(10 BYTE)   No                   AC_ACCOUNT            ST_MAN                19             FREQUENCY
 SALARY          NUMBER(8,2)         Yes                  2100                  24000                 58             NONE
 COMMISSION_PCT  NUMBER(2,2)         Yes                  .1                    .4                    7              NONE
 MANAGER_ID      NUMBER(6,0)         Yes                  100                   205                   18             FREQUENCY
 DEPARTMENT_ID   NUMBER(4,0)         Yes                  10                    110                   11             FREQUENCY

Indexes
INDEX_NAME              UNIQUENESS    STATUS    FUNCIDX_STATUS    COLUMNS
_______________________ _____________ _________ _________________ ________________________
HR.EMP_JOB_IX           NONUNIQUE     VALID                       JOB_ID
HR.EMP_NAME_IX          NONUNIQUE     VALID                       LAST_NAME, FIRST_NAME
HR.EMP_EMAIL_UK         UNIQUE        VALID                       EMAIL
HR.EMP_EMP_ID_PK        UNIQUE        VALID                       EMPLOYEE_ID
HR.EMP_MANAGER_IX       NONUNIQUE     VALID                       MANAGER_ID
HR.EMP_DEPARTMENT_IX    NONUNIQUE     VALID                       DEPARTMENT_ID


References
TABLE_NAME     CONSTRAINT_NAME    DELETE_RULE    STATUS     DEFERRABLE        VALIDATED    GENERATED
______________ __________________ ______________ __________ _________________ ____________ ____________
DEPARTMENTS    DEPT_MGR_FK        NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME
EMPLOYEES      EMP_MANAGER_FK     NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME
JOB_HISTORY    JHIST_EMP_FK       NO ACTION      ENABLED    NOT DEFERRABLE    VALIDATED    USER NAME

```

명령어(ddl) : DDL 구문을 생성합니다. 
```sql
-- DDL 구문을 추출할수 있습니다.
SQL> ddl hr.EMPLOYEES

  CREATE TABLE "HR"."EMPLOYEES"
   (    "EMPLOYEE_ID" NUMBER(6,0),
           ...
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;

  CREATE UNIQUE INDEX "HR"."EMP_EMP_ID_PK" ON "HR"."EMPLOYEES" ("EMPLOYEE_ID")
  ...
ALTER TABLE "HR"."EMPLOYEES" ADD CONSTRAINT "EMP_EMP_ID_PK" PRIMARY KEY ("EMPLOYEE_ID")
  USING INDEX "HR"."EMP_EMP_ID_PK"  ENABLE;

  COMMENT ON COLUMN "HR"."EMPLOYEES"."EMPLOYEE_ID" IS 'Primary key of employees table.';
   ...

  CREATE INDEX "HR"."EMP_DEPARTMENT_IX" ON "HR"."EMPLOYEES" ("DEPARTMENT_ID")
 ...

  CREATE OR REPLACE EDITIONABLE TRIGGER "HR"."SECURE_EMPLOYEES"
  ....

SQL>
```

### 공통 작업에 대해서 편의성제공

자주사용하는 공통작업에 대해서 명령어로 제공하고 있습니다. 
SQLcl에서 디렉토리를 이동하거나, CTAS(Create table as select)를 구문을 생성하거나 , load/unload작업을 쉽게할수 있습니다. 

명령어(cd) :  SQLcl안에서 디렉토리 이동이 가능합니다. 
```sql
SQL> pwd
/home/oracle/sqlcl/sqlcl/bin/
SQL> cd ../../
SQL> pwd
/home/oracle/sqlcl 
```

명령어(unload/load) : loadformat을 지정하여 load/unload작업을 쉽게 수행할수 있습니다. 
```sql
-- loadformat을 확인합니다. load가 가능한 포멧은 default, csv, delimited입니다. 나머지 포멧은 unload만 지원합니다.
SQL> help set LOADFORMAT
SET LOADFORMAT [ default|csv|delimited|html|insert|json|json-formatted|loader|t2|xml] [options...]

  default        : Load format properties return to default values
  csv            : comma separated values
  delimited      : (CSV synonym) delimited format, comma separated values by default
  html           : UNLOAD only, Hypertext Markup Language
  insert         : UNLOAD only, SQL insert statements
  json           : UNLOAD only, Java Script Object Notation
  json-formatted : UNLOAD only, "pretty" formatted JSON
  loader         : UNLOAD only, Oracle SQLLoader format
  t2             : UNLOAD only, T2 Metrics
  xml            : UNLOAD only, Extensible Markup Language
SQL> set LOADFORMAT delimited
SQL> unload table hr.EMPLOYEES

format csv

column_names on   <-- 컬럼명을 같이 남김
delimiter ,
enclosures ""
encoding UTF8
row_terminator default

** UNLOAD Start ** at 2023.11.24-07.25.35
Export Separate Files to /home/oracle/sqlcl
DATA TABLE EMPLOYEES
File Name: /home/oracle/sqlcl/EMPLOYEES_DATA_TABLE.csv
Number of Rows Exported: 107
** UNLOAD End ** at 2023.11.24-07.25.35
-- 맨앞에 컬럼명이 포함됨.(set loadformat column_names off로 설정을 변경할수 있음)
SQL> !head -n 10 /home/oracle/sqlcl/EMPLOYEES_DATA_TABLE.csv
"EMPLOYEE_ID","FIRST_NAME","LAST_NAME","EMAIL","PHONE_NUMBER","HIRE_DATE","JOB_ID","SALARY","COMMISSION_PCT","MANAGER_ID","DEPARTMENT_ID"
100,"Steven","King","SKING","1.515.555.0100",17-JUN-13,"AD_PRES",24000,,,90
101,"Neena","Yang","NYANG","1.515.555.0101",21-SEP-15,"AD_VP",17000,,100,90
102,"Lex","Garcia","LGARCIA","1.515.555.0102",13-JAN-11,"AD_VP",17000,,100,90
103,"Alexander","James","AJAMES","1.590.555.0103",03-JAN-16,"IT_PROG",9000,,102,60
104,"Bruce","Miller","BMILLER","1.590.555.0104",21-MAY-17,"IT_PROG",6000,,103,60
105,"David","Williams","DWILLIAMS","1.590.555.0105",25-JUN-15,"IT_PROG",4800,,103,60
106,"Valli","Jackson","VJACKSON","1.590.555.0106",05-FEB-16,"IT_PROG",4800,,103,60
107,"Diana","Nguyen","DNGUYEN","1.590.555.0107",07-FEB-17,"IT_PROG",4200,,103,60
108,"Nancy","Gruenberg","NGRUENBE","1.515.555.0108",17-AUG-12,"FI_MGR",12008,,101,100

-- load스크립트를 확인합니다.
SQL> load table emp_load EMPLOYEES_DATA_TABLE.csv show_ddl
Show DDL for table ADMIN.EMP_LOAD

csv
column_names on
delimiter ,
enclosures ""
double off
encoding UTF8
row_limit off
row_terminator default
skip_rows 0
skip_after_names

#INFO DATE format detected: DD-MON-RR

CREATE TABLE ADMIN.EMP_LOAD
 (
  EMPLOYEE_ID NUMBER(5),
  FIRST_NAME VARCHAR2(26),
  LAST_NAME VARCHAR2(26),
  EMAIL VARCHAR2(26),
  PHONE_NUMBER VARCHAR2(26),
  HIRE_DATE DATE,
  JOB_ID VARCHAR2(26),
  SALARY NUMBER(7),
  COMMISSION_PCT NUMBER(4, 2),
  MANAGER_ID NUMBER(5),
  DEPARTMENT_ID NUMBER(5)
 )
;

SUCCESS: Processed without errors
-- load 작업을 수행합니다(테이블 생성 및 load작업을 수행합니다.)
SQL> load table emp_load EMPLOYEES_DATA_TABLE.csv new
Create new table and load data into table ADMIN.EMP_LOAD

csv
column_names on
delimiter ,
enclosures ""
double
encoding UTF8
row_limit off
row_terminator default
skip_rows 0
skip_after_names

#INFO DATE format detected: DD-MON-RR

CREATE TABLE ADMIN.EMP_LOAD
 (
  EMPLOYEE_ID NUMBER(5),
  FIRST_NAME VARCHAR2(26),
  LAST_NAME VARCHAR2(26),
  EMAIL VARCHAR2(26),
  PHONE_NUMBER VARCHAR2(26),
  HIRE_DATE DATE,
  JOB_ID VARCHAR2(26),
  SALARY NUMBER(7),
  COMMISSION_PCT NUMBER(4, 2),
  MANAGER_ID NUMBER(5),
  DEPARTMENT_ID NUMBER(5)
 )
;

#INFO Table created
#INFO Number of rows processed: 107
#INFO Number of rows in error: 0
#INFO Last row processed in final committed batch: 107
SUCCESS: Processed without errors
```

명령어(ctas) : CTAS(Create table as select)구문을 생성하는 작업을 제공합니다.
제공되는 DDL을 수정하여 CTAS를 수행합니다.
```sql
-- 같은 Schema에서만 동작합니다.
SQL> ctas EMP_LOAD EMP_LOAD1
  CREATE TABLE "ADMIN"."EMP_LOAD1"
   (    "EMPLOYEE_ID",
        "FIRST_NAME",
        "LAST_NAME",
        "EMAIL",
        "PHONE_NUMBER",
        "HIRE_DATE",
        "JOB_ID",
        "SALARY",
        "COMMISSION_PCT",
        "MANAGER_ID",
        "DEPARTMENT_ID"
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"
 as
select * from EMP_LOAD
SQL>
```

### 명령어 재사용(alias, repeat) 기능

자주 사용하는 SQL구문들을 alias을 통해서 간편하게 사용할수 있습니다. 
또한 모니터링과 같이 반복적으로 실행이 필요한 경우 간편하게 실행할수 있습니다.

명령어(alias) : 명령어를 재사용할수 있습니다.
```sql
SQL> help alias
ALIAS
------
alias [NULLDEFAULTS] [GROUP=<the_group>] [<name>=<SQL statement>;| LOAD [<filename>]|
                  SAVE [<filename>] | LIST [<NAME>] | GROUPS | <group_name> |
                  DROP <name> | DESC <name> <Description String>]
..
-- alias 설정함 (바인드 변수 설정항가능)
SQL> alias group=user select_emp=select * from hr.EMPLOYEES where EMPLOYEE_ID = :id;
-- alias 내용 확인
SQL> alias list select_emp
select_emp user
---------------

select * from hr.EMPLOYEES where EMPLOYEE_ID = :id
SQL>
-- 인자를 넣어서 alias를 사용
SQL> select_emp 100
   EMPLOYEE_ID FIRST_NAME    LAST_NAME    EMAIL    PHONE_NUMBER      HIRE_DATE    JOB_ID        SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ________ _________________ ____________ __________ _________ _________________ _____________ ________________
           100 Steven        King         SKING    1.515.555.0100    17-JUN-13    AD_PRES        24000                                               90

-- alias를 파일에 저장(이후에 다시 사용가능)
SQL> alias save
ALIAS-007 - Aliases saved to /home/oracle/.sqlcl/aliases.xml
```

명령어(repeat) : 방금전에 실행한 명령어를 반복적으로 수행할수 있습니다.
```sql 
-- 바로 전에 실행한 SQL이나 명령어를 반복적으로 실행함. 
-- 주의사항 - 중간에 중지가 잘 되지 않음 (계속 반복적으로 실행함)
SQL> repeat 20 1
Running 2 of 20  @ 6:1:17.321 with a delay of 1s   <-- 실행횟수가 계속 변경됩니다.

   EMPLOYEE_ID FIRST_NAME    LAST_NAME    EMAIL    PHONE_NUMBER      HIRE_DATE    JOB_ID        SALARY    COMMISSION_PCT    MANAGER_ID    DEPARTMENT_ID
______________ _____________ ____________ ________ _________________ ____________ __________ _________ _________________ _____________ ________________
           100 Steven        King         SKING    1.515.555.0100    17-JUN-13    AD_PRES        24000                                               90

SQL> help repeat
repeat <iterations> <sleep>
        Repeats the current sql in the buffer the specified times with sleep intervals
        Maximum sleep is 120s
```

## 고급 기능

SQLcl은 명령어 Extention기능을 제공합니다. 
help명령어를 수행하면 확장된 기능들을 확인할수 있습니다.

- 확장기능들(명령어 / 관련기술)
  - OCI / 오라클 클라우드(OCI) Profile을 관리하여 Bucket(Object Storage)의 데이터 업로드 및 다운로드 작업을 지원합니다.
  - OCIDBMETRICS / 오라클 데이터베이스의 정보를 OCI Metric service에 전달할때 사용합니다.
  - MIGRATEADVISOR / Cloud Premigration Advisor Tool로 사전에 오라클 Automuouse database로 이관이 될수 있는지 확인할수 있습니다. 
  - DG / Data Guard Broker기능을 쉽게 사용할수 있도록 DG명령어가 추가되었습니다.(Failover, Switchover 등등 작업등이 가능합니다.)
  - DATAPUMP / datapump작업을 간편하게 사용할수 있는 명령어입니다. 
  - BRIDGE / 다른 데이터베이스의 테이블의 데이터를 가져옵니다. JDBC Connection을 사용하므로 JDBC Driver를 지원하는 이기종 DB간에도 작업이 가능합니다.
  - BLOCKCHAIN_TABLE,IMMUTABLE_TABLE / 21c부터 나온 blockchain, immutable 테이블관리를 위한 명령어입니다.
  - SODA / NoSQL방식으로 Document DB(JSON데이터)작업할때 사용합니다.
  - AQ / 오라클 데이터베이스에 있는 AQ(Advanced Queue)/TEQ(Transactional Event Queue)를 관리하기 위한 명령어입니다.  

DG와 DATAPUMP(DP)명령어의 옵션확인
```sql
SQL> help DG
DG
------

 Run DG commands

 DG ADD DATABASE "<database name>"
        AS CONNECT IDENTIIFIER IS <connect identifier>
        [ INCLUDE CURRENT DESTINATIONS ];
 DG CREATE CONFIGURATION "<config_name>"
        AS PRIMARY DATABASE IS <database name>
        CONNECT IDENTIIFIER IS <connect_identifier>
        [ INCLUDE CURRENT DESTINATIONS ];
 DG DISABLE CONFIGURATION;
 DG DISABLE { DATABASE | RECOVERY_APPLIANCE | FAR_SYNC | MEMBER } <member name>;
 DG EDIT CONFIGURATION SET PROPERTY <property name> = '<property value>';
 DG EDIT { DATABASE | RECOVERY_APPLIANCE | FAR_SYNC | MEMBER } <member name>
        SET PROPERTY <property name> = '<property value>';
 DG ENABLE CONFIGURATION;
 DG ENABLE { DATABASE | RECOVERY_APPLIANCE | FAR_SYNC | MEMBER } <member name>;
 DG FAILOVER TO <database name> [IMMEDIATE];
 DG REINSTATE DATABASE <database name>;
 DG REMOVE CONFIGURATION [PRESERVE DESTINATIONS];
 DG REMOVE { DATABASE | RECOVERY_APPLIANCE | FAR_SYNC | MEMBER } <name>
        [PRESERVE DESTINATIONS];
 DG SHOW CONFIGURATION [<property name>];
 DG SHOW DATABASE <database name> [<property name];
 DG SWITCHOVER TO <database name> [WAIT [<timeout in seconds]];

SQL> help DATAPUMP

  Usage:
  datapump|dp COMMAND {OPTIONS}
  datapump|dp  help|he [-example|-ex]
  datapump|dp  help|he COMMAND [-syntax|-sy] [-example|-ex]

  The following commands are available within the datapump feature.

  Commands:
    export|ex
    Export schema or list of schemas with the datapump utility using DBMS_DATAPUMP
    package.

    import|im
    Import schema or list of schemas from a dump file using DBMS_DATAPUMP package.

SQL>
```
## 마무리

SQLcl은 SQL*Plus에서 지원하는 거의 모든기능을 지원하며 추가적으로 개발 생산성을 향상시키기 위하여 다양한 표현방식과 기능들을 지원합니다.
사실 sqlformat ansiconsole기능만으로도 저는 만족합니다. 컬럼길이 조정하는게 워낙 귀찮은일이 아니었거든요.
SQLcl은 기본적인 명령어이외 데이터베이스 기능을 좀더 쉽게 사용할수 있는 기능들이 추가적으로 내장되어 있습니다.

SQLcl은 Java기반이므로 SQLPlus에 비해서 플랫폼에 의존적이지 않아 꽤 유용하게 사용할것 같습니다. 
alias명령어를 통해서 모니터링이나 튜닝관련된 스크립트들을 잘만들어 놓으면 운영할때 크게 도움이 될것 같습니다.

## 참고문서

- Documents
  - [Oracle SQLcl Documents](https://docs.oracle.com/en/database/oracle/sql-developer-command-line/){: target="_blank"}
  - [Oracle SQLcl Download](https://www.oracle.com/database/sqldeveloper/technologies/sqlcl/){: target="_blank"}
- Blogs
  - [Easy Oracle Database Migration with SQLcl](https://blogs.oracle.com/developers/post/easy-oracle-database-migration-with-sqlcl){: target="_blank"}
  - [SQLcl now under the Oracle Free Use Terms and Conditions license](https://blogs.oracle.com/database/post/sqlcl-now-under-the-oracle-free-use-terms-and-conditions-license){: target="_blank"}