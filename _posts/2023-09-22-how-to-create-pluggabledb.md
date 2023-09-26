---
layout: single
title: Pluggable DB 생성과 기동
date: 2023-09-22 01:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - multitenant
   - container db
   - pluggable db
excerpt : Pluggable DB를 생성하고 관리하는 방법에 대해서 정리합니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 개요

Container DB에서는 이제 기존의 Non-CDB 환경과 같이 애플리케이션에서 접근할수 있는 DB를 제공합니다. 이를 Pluggable DB라고 합니다. Pluggable DB에는 접속 가능한 사용자를 관리하고, 데이터를 관리하기 위해 테이블스페이스들을 생성할 수 있습니다. 

Pluggable DB를 생성하는 방법과 기동하는 절차에 대해 설명하겠습니다.

## Pluggable DB로의 업무환경 변화

애플리케이션에서 Pluggable DB에 접속하여 데이터를 조회하거나 Dictionary정보를 조회하더라도 Non-CDB와 동일한 운영 환경을 제공합니다. 그렇기 때문에 오라클 데이터베이스를 Multiteant 아키텍처로 변경하더라도 애플리케이션 변경은 전혀 필요하지 않습니다.

Multiteant 아키텍처는 기존 애플리케이션 환경에 영향을 주지 않으면서 인프라 관점에서의 관리 편의성과 자원 효율성을 제공하는 아키텍처입니다. 그외 아키텍처의 변화로 인해 업무 관점에서 더 유연한 개발 및 테스트 환경을 제공할 수 있습니다.

- Pluggable DB의 기능
  - Pluggable DB의 라이프사이클 관리가 매우 간소화됩니다.
    - Non-CDB 환경에서는 DB를 생성하기 위해 DB 파라미터 설정, Dictionary 정보 생성 등 복잡한 과정을 거쳐야 했습니다.
    - Pluggable DB는 PDB의 템플릿(PDB$SEED)을 참조하여 DB가 생성되므로 단 5초만에 생성됩니다.
  - SQL/PLSQL로 Pluggable DB를 관리할수 있습니다.
    - CI/CD운영환경과 연동하여 SQL/PLSQL기반으로 데이터베이스 변경작업을 수행할수 있습니다.(Liquibase활용)
    - 테스트DB를 자동으로 만들고 TestCase를 만들어 자동 테스트환경을 구성할수 있습니다.
  - 개발 및 테스트 환경을 쉽게 생성하고 관리할 수 있습니다.
    - Pluggable DB를 생성할 때 다른 PDB를 참조하여 만들 수 있습니다.
    - DB 전체를 복제하거나, 특정 테이블스페이스, 혹은 데이터베이스 구조만 복제할 수 있습니다.
  - 서버 및 인프라 이동이 간편화됩니다.
    - 서버노후화나 클라우드 전환시 DB그대로 다운타임 최소화 하여 이관할수 있습니다. 

## Pluggable DB 생성

Pluggable DB를 생성하는 방법에 대해 알아보겠습니다.
우선 Container DB에 접속하여 "create pluggable database" 명령어를 사용하여 Pluggable DB를 생성할 수 있습니다.

```sql
[oracle@db-upgrade ~]$ sqlplus "/as sysdba"
SQL*Plus: Release 19.0.0.0.0 - Production on Tue Sep 26 00:29:20 2023
Version 19.3.0.0.0
Copyright (c) 1982, 2019, Oracle.  All rights reserved.
Connected to:
Oracle Database 19c Enterprise Edition Release 19.0.0.0.0 - Production
Version 19.3.0.0.0
SQL> set time on
00:29:33 SQL> set timing on
-- salespdb PDB를 생성합니다. 
00:29:34 SQL> CREATE PLUGGABLE DATABASE salespdb ADMIN USER salesadm IDENTIFIED BY password;
Pluggable database created.
Elapsed: 00:00:01.81
-- salespdb PDB를 오픈합니다.
00:29:36 SQL> alter pluggable database salespdb open;
Pluggable database altered.
Elapsed: 00:00:01.72
00:29:48 SQL>
-- PDB 목록을 확인합니다.
00:29:48 SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       READ WRITE NO
00:31:20 SQL>
```

테스트 환경에서 'salespdb'를 생성하고 오픈하는 데 소요된 시간은 약 4초입니다. Non-CDB 환경에서 데이터베이스를 생성하는 데 비하면 매우 짧은 시간이 걸린다는 것을 알 수 있습니다. 

Pluggable DB를 생성할 때 필요한 정보는 PDB명과 PDB 관리자 계정 정보(사용자명, 비밀번호)입니다. "create pluggable database" 명령어를 통해 "from" 절을 사용하지 않으면 기본적으로 PDB$SEED를 복제하여 생성됩니다. ("from" 절을 사용하면 다른 PDB를 참조하여 생성할 수 있습니다.)

Pluggable DB를 생성할 때 사용하는 다양한 리소스를 제어할 수 있습니다.

- Pluggable DB와 관련된 리소스
  - 데이터파일 위치 지정 - FILE_NAME_CONVERT절를 통해서 파일 경로를 변경합니다. 
  - Directory 위치 지정 - PATH_PREFIX절을 이용하여 Directory의 기본 위치를 지정합니다. 
  - 스토리지 공간 용량 제한 - STOREAGE절을 이용하여 테이블스페이스 총 공간을 제한합니다.
  - PDB 관리자의 권한 지정 - ROLE절을 이용하여 PDB관리자의 ROLE을 지정할수 있습니다.
  - CPU/MEM 리소스 관리 - Pluggable DB안에서 DB파라미터로 관리합니다.
  - Pluggable DB생성 예제 
```sql
CREATE PLUGGABLE DATABASE salespdb 
  ADMIN USER salesadm IDENTIFIED BY password
  STORAGE (MAXSIZE 2G)
  DEFAULT TABLESPACE sales DATAFILE '/disk1/oracle/dbs/salespdb/sales01.dbf' SIZE 250M AUTOEXTEND ON
  PATH_PREFIX = '/disk1/oracle/dbs/salespdb/'
  FILE_NAME_CONVERT = ('/disk1/oracle/dbs/pdbseed/', '/disk1/oracle/dbs/salespdb/’)
```

Pluggable DB생성이후에 "alter pluggable database"를 통해서 설정변경도 가능합니다. 

## Pluggable DB 기동순서

Multitenant 아키텍처에서는 Pluggable DB를 기동하기 전에 Container DB가 먼저 기동되어야 합니다.
Container DB는 Non-CDB 환경과 동일하게 "startup" 명령어를 통해 기동시킬 수 있고, 그 위에 Pluggable DB들을 open해야 합니다.

- Pluggable DB 기동순서
  1. Container DB 기동 ("startup")
     1. spfile 읽어서 인스턴스 기동 ("nomount"단계)
     2. controlfile 읽어서 데이터파일 확인 ("mount"단계)
     3. 데이터파일 정합성 확인하고 open됨("open"단계)
  2. Pluggable DB 기동 ("alter pluggable database open" or "startup")
     1. Container DB가 기동되면 Pluggable DB는 Mount상태임("mount"단계)
     2. Pluggable DB의 데이터파일 정합성 확인하고 open함("open"단계)

```sql
-- Container DB 접속상태에서 PDB 상태를 확인
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       MOUNTED    <-- Container DB가 기동되면 Pluggable DB는 Mounted상태임.
-- Container DB에서 Pluggable DB를 Open시킴
SQL> alter pluggable database SALESPDB open;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       READ WRITE NO <-- Open상태로 변경됨
-- Container DB에서 Pluggable DB를 중지시킴
SQL> alter pluggable database SALESPDB close immediate;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       MOUNTED
-- Pluggable DB에 접속
SQL> alter session set container=SALESPDB;
Session altered.
-- "alter pluggable database open"명렁어를 수행하면 접속한 Pluggable DB가 open됨
SQL> alter pluggable database open;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 SALESPDB                       READ WRITE NO
SQL> alter pluggable database close;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 SALESPDB                       MOUNTED
-- "startup"명령어를 수행하면 접속한 Pluggable DB가 open됨
SQL> startup
Pluggable Database opened.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 SALESPDB                       READ WRITE NO
SQL> shutdown immediate;
Pluggable Database closed.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         4 SALESPDB                       MOUNTED
SQL>
```
Pluggable DB가 기동된 상태에서 Container DB를 중지하면 Pluggable DB도 함께 중지됩니다.
Container DB가 정상적으로 중지될 때는 Pluggable DB의 최종 상태 정보를 저장하므로 Container DB가 다시 기동될 때 Pluggable DB도 자동으로 기동됩니다.

원하는 경우 현재 Pluggable DB의 상태 정보를 수동으로 저장할 수도 있습니다.
```sql
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       MOUNTED
SQL> alter pluggable database SALESPDB open;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       READ WRITE NO
-- Pluggable DB의 Open상태를 저장하도록 설정하며 ContainerDB기동시 자동으로 기동됨.
SQL> alter pluggable database SALESPDB save state;
Pluggable database altered.
-- Container DB 중지
SQL> shutdown immediate;
Database closed.
Database dismounted.
ORACLE instance shut down.
-- Container DB 기동
SQL> startup  
ORACLE instance started.
Total System Global Area 3288332208 bytes
Fixed Size                  9140144 bytes
Variable Size             738197504 bytes
Database Buffers         2533359616 bytes
Redo Buffers                7634944 bytes
Database mounted.
Database opened.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         4 SALESPDB                       READ WRITE NO   <-- 자동으로 기동됨
SQL>
```

## 마무리 

Pluggable DB를 생성하고 기동하는 절차에 대해 알아보았습니다. In-Database Container 컨셉을 통해 SQL/PLSQL을 사용하여 Container DB 안에서 Pluggable DB의 라이프사이클을 제어할 수 있습니다. 신규 Pluggable DB를 빠르게 생성할 수 있는 환경에서 운영할 수 있습니다.

또한, Pluggable DB를 생성하고 복제하며 이동하는 다양한 기능을 활용하여 다운타임을 최소화하면서 마이그레이션 및 업그레이드 작업을 쉽게 수행할 수 있습니다. 이제는 단위 데이터 이동이 아닌 데이터베이스 전체를 이동하는 방식으로, 애플리케이션의 영향을 줄일 수 있는 데이터베이스 관리 방식이 변화하고 있습니다.