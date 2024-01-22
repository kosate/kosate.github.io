---
layout: single
title: Oracle GoldenGate 23c Free 설치 방법(바이너리파일)
date: 2024-01-20 02:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - 23c
   - GoldenGate
excerpt : Oracle GoldenGate 23c Free버전 설치하는 방법에 대해서 정리했습니다.
header :
  teaser: /assets/images/blog/oracle23c.jpg
  overlay_image: /assets/images/blog/oracle23c.jpg
toc : true  
toc_sticky: true
---

## 개요

Oracle GoldenGate를 무료로 사용할수 있는 Free버전에 대해서 소개합니다. 

GoldenGate Free의 제약사항 및 설치 방법을 알아보고, 간편한 데이터 복제 절차에 대해서 같이 살펴보도록 하겠습니다. 

## Oracle GoldenGate Free란?

GoldenGate는 Oracle 사에서 제공하는 CDC(Change Data Capture) 제품입니다. 
실시간 데이터 복제기능을 제공하므로 데이터마이그레이션, 실시간 DW, Active DR과 같은 다양한 업무에 사용가능합니다. 

2022년 10월 18일부터 라이센스없이 무료로 사용가능한 GodlenGate Free버전을 제공하고 있습니다. (초기에 나오는 Free버전은 21c였지만 지금은 23c 버전으로 제공합니다.)

별도의 비용없이 없기 때문에, 
CDC 솔루션을 학습하거나 데이터 복제를 하려는 업무에 부담없이 설치하여 테스트해볼수 있습니다. (사이드 프로젝트 사용하면 좋지 않을까요?)

**Oracle GoldenGate Free는 누구를 위해 제공되는가?**

Oracle GoldenGate Free는 개발/테스트 환경에서 사용가능합니다.
운영 환경에서 사용가능하지만 Oracle Support를 지원받지 못합니다. ( Community Forum에서 문의해서 지원받을수 있습니다)
그리고 CDC솔루션을 이해하기 위한 학습목적으로도 사용가능합니다.

**Oracle GoldenGate Free의 주요 제약사항**

현재(2024.01.22)시점 GoldenGate Free는 아쉽게도 Oracle Database간에 데이터 복제기능만 제공합니다. (추후 상용버전만큼의 범용적으로 다양한 환경을 지원했으면 좋겠습니다.)

- Oracle Database간에 동기화를 지원합니다. Oracle Database의 크기는 20G를 넘을수 없습니다.
  - CDB(Container DB)환경일경우 모든 PDB의 크기를 통합한 사이즈를 의미합니다.
  - Oracle 23c Free를 지원하지만 Parallel Replicat는 지원하지 않습니다. 
  - 지원버전 :  Oracle Database 11.2.0.4, 12.1.0.2,19c,21c, 21c XE, 23c, 23c Free
※ Oracle Autonomous Database나 Wallet인증 방식은 지원하지 않습니다.
- Oracle Support대신 [GoldenGate Free Community Forum](https://forums.oracle.com/ords/apexds/domain/dev-community/category/goldengate-free){:target="_blank"} 으로 문의할수 있습니다.
- Oracle GoldenGate Free인스턴스간은 통신이 가능하지만, Oracle GoldenGate 상용버전 혹은 3rd 도구와는 연동할수 없습니다.
  - GoldenGate Free <---> GoldneGate Free(O)
  - GoldenGate(상용버전) <---> GoldneGate Free(X)
  - GoldenGate Free <---> 3rd 제품(X)
- Active DataGuard, XStream에 대한 사용 권한은 없습니다
  - GoldenGate 상용버전은 Active DataGuard와 XStream사용권한을 포함하고 있지만, Free버전은 사용권한을 가지고 있지 않습니다.
- Downstream Capture, Graph 데이터타입, ACDR(Automatic Conflict Detection and Resolution)기능은 지원하지 않습니다.

**Oracle Database 23c에서의 Capture방식**

Oracle Database 23c부터는 Multitenant 아키텍쳐로만 구성이 가능합니다. 
사용자 접근 가능한 데이터베이스는 Pluggable Database이며, 여러개의 Pluggable Database가 있다면 DB별로 Extract가 가능해야겠죠. 그래서 Oracle Database 23c부터는 CDB레벨이 아니라 PDB별로 데이터 추출이 가능합니다(옵션에서 필수으로 변경되었습니다.)

## GoldenGate Free 설치절차

GoldenGate Free는 Docker Image와 Binary 파일 두가지 설치 방법을 제공합니다.

아래 링크를 통해서 다운로드받을수 있습니다. 

- GoldenGate Free download : <https://www.oracle.com/integration/goldengate/free/download/>{: target="_blank"}

GoldenGate Free의 기본 아키텍쳐는 MSA(MicroServices Architecture) 기반입니다. 
그래서 단순히 바이너리 설치만 하는것이 아니라 내부적으로 서비스들을 만드는 작업이 필요합니다. 

두가지 설치 방안을 제공합니다. 

1. 바이너리 설치이후에 곧바로 서비스 생성하는 절차
   - runinstaller 하나의 명령어로 바이너리설치와 서비스 생성을 모두 수행합니다.
2. 바이너리 설치하고 나서 서비스 생성하는 절차
   - runinstaller로 바이너리 설치하고 ggca.sh명령어로 서비스를 생성합니다. 

위 두가지 설치 방법중 바이너리 설치와 서비스 생성하는 작업을 분리하는 2번째 방법으로 설치 및 구성작업을 진행하도록 하겠습니다.

### 1. GoldenGate Free 바이너리 설치(Slient 모드)

GoldenGate Free 설치 메뉴얼에는 GUI기반의 OUI(Oracle Universal Installer)로 설치하도록 되어 있지만, CLI에서 빠르게 설치하기 위하여 Slient모드로 설치하겠습니다.

```bash
## 바이너리 다운로드를 위하여 stage디렉토리를 생성합니다.
oracle$> mkdir stage
oracle$> cd stage
## GoldenGate Free 23c 바이너리 파일을 다운로드 받습니다.
oracle$> wget https://download.oracle.com/otn-pub/otn_software/goldengate_free/ogg_23c_Linux_x64_Oracle_services_free_shiphome.zip

ogg_23c_Linux_x64_Oracle_services_free_shiphome.zip 100%[===============>] 690.67M  40.4MB/s    in 18s

## 바이너리 파일을 압축해제합니다.
oracle$> unzip ogg_23c_Linux_x64_Oracle_services_free_shiphome.zip
oracle$> cd fbo_ggs_Linux_x64_Oracle_services_free_shiphome/Disk1

## Silent모드 설치를 위하여 response파일을 수정합니다.
oracle$> vi response/oggcore.rsp
INSTALL_OPTION=ora23c
SOFTWARE_LOCATION=/opt/oracle/product/23c/ogghomefree
INVENTORY_LOCATION=/opt/oracle/oraInventory
UNIX_GROUP_NAME=oinstall

## reponse 파일을 이용하여 Silent모드로 바이너리 설치를 수행합니다.
oracle$> ./runInstaller -silent -responseFile /home/oracle/stage/fbo_ggs_Linux_x64_Oracle_services_free_shiphome/Disk1/response/oggcore.rsp
Starting Oracle Universal Installer...

Checking Temp space: must be greater than 120 MB.   Actual 7192 MB    Passed
Checking swap space: must be greater than 150 MB.   Actual 4095 MB    Passed
Preparing to launch Oracle Universal Installer from /tmp/OraInstall2024-01-22_04-17-53AM. Please wait ...
You can find the log of this install session at:
 /opt/oracle/oraInventory/logs/installActions2024-01-22_04-17-53AM.log
Successfully Setup Software.
The installation of Oracle GoldenGate Services was successful.
Please check '/opt/oracle/oraInventory/logs/silentInstall2024-01-22_04-17-53AM.log' for more details.
```

### 2. 서비스 생성 

OGG의 MSA버전은 Service Manager와 Deployment 구성요소로 구분됩니다. 
Service manager는 여러개의 Deployment을 관리하는 역할을 담당합니다. Deployments는 한 서버에 여러개로 설치될수 있습니다. 

Deployment내 여러 구성요소들은 HTTP인터페이스로 쉽게 관리될수 있고, REST API로 서로 통신합니다.

- Deployment의 구성요소
  - Administrator Server : Admin Server는 Extract(데이터추출)와 Replicat(데이터 적재)프로세스를 생성관리합니다.
  - Distribution Server : Trail File을 전송하는 역할을 담당합니다.
  - Receive Server : Trail file을 받는 역할을 담당합니다.
  - Performance Metrice Server : 각 프로세스들의 성능정보를 수집하는 역할을 담당합니다.

참고로 GoldenGate Free에서는 하나의 Deployment만 지원합니다.

**OGG Configuration Assistant 실행**

OGG의 여러 서비스들을 Configuration Assistant를 통해서 생성할수 있습니다. 
/opt/oracle/ogg 폴더 밑에 여러개의 서비스들을 생성하도록 하겠습니다.

```bash
oracle$> cd /opt/oracle/product/23c/ogghomefree/bin
oracle$> ./oggca.sh
```

처음 설치하는것이기 때문에 Service Manager 설정 작업이 필요합니다. 

- Service Manager 설정작업
  - - [X] Create New Service Manager
    - Deployment Home : /opt/oracle/ogg/sm_deployment_home1
  - - [X] register Service Manager as a system service/daemon
  - Listeneing hostname/address : 127.0.0.1
  - Listeneing Port : 9001

![](/assets/images/blog/oggfree/p1.jpg)

새로운 GoldenGate Deployment를 추가합니다.

- [X] Add new GoldenGate deployment

![](/assets/images/blog/oggfree/p2.jpg)

Deployment 이름를 설정합니다. 

- Deployment Name : ogg_deployment1
  
![](/assets/images/blog/oggfree/p3.jpg)

Deployment home을 설정합니다

- Deployment home : /opt/oracle/ogg/ogg_deployment_home1

![](/assets/images/blog/oggfree/p4.jpg)

환경 변수를 설정합니다. 

- TNS_ADMIN : /opt/oracle/ogg/ogg_deployment_home1/network/admin

![](/assets/images/blog/oggfree/p5.jpg)

관리자 계정을 설정합니다. 

- Username : oggadmin
- Password : ***********

![](/assets/images/blog/oggfree/p6.jpg)

보안을 설정합니다.

저는 SSL/TLS 보안을 체크해제하여 설정하지 않도록 했습니다.

![](/assets/images/blog/oggfree/p7.jpg)

서비스별 포트를 설정합니다.

Administrator Service port를 9500으로 넣으면 나머지 서비스 포트가 자동으로 설정됩니다.
필요시 임의대로 변경하여 설정합니다.

![](/assets/images/blog/oggfree/p8.jpg)

OGG 복제를 위한 기본 유저를 설정합니다.

- Default Schema : oggadmin  (추후 DB유저를 생성할 예정입니다.)

![](/assets/images/blog/oggfree/p9.jpg)

OGG Free UI관련 설정을 합니다. 

- Listening Port : 8020(Default)
- Data Storage home Directory : /opt/oracle/ogg/ds_home1 (내부적으로 berkeleydb를 사용합니다.)

![](/assets/images/blog/oggfree/p10.jpg)

설정정보를 확인합니다. 

![](/assets/images/blog/oggfree/p11.jpg)

설치 중간에 popup 메시지가 나옵니다.

1. The deployment will be stopped before registering the Service Manager as a daemon.
   (데몬으로 service Manager가 등록되기전에 Deployment는 중지될것입니다.)
2. A new popup window will show the details of the script used to register the Service Manager as a daemon.
  (새로운 popup 창에서 Service manager가 등록되기 위한 스크립트의 상세 정보가 보여질것입니다. )
3. After the register script is executed, the Service Manager daemon will be started in the background and the deployment will be automatically restarted.
   (등록 스크립트가 실행되고나면 Service manager 데몬은 백그라운드로 시작하고, 자동으로 Deployment가 재 실행될것입니다.)

![](/assets/images/blog/oggfree/p12.jpg)

서비스 등록작업을 수행합니다. 

root유저로 접속하여 Oracle GoldenGate서비스를 등록합니다. 
![](/assets/images/blog/oggfree/p13.jpg)

```bash
root$> /opt/oracle/ogg/sm_deployment_home1/bin/registerOracleGoldenGate.sh
Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
----------------------------------------------------
     Oracle GoldenGate Install As Service Script
----------------------------------------------------
OGG_HOME=/opt/oracle/product/23c/ogghomefree
OGG_CONF_HOME=/opt/oracle/ogg/sm_deployment_home1/etc/conf
OGG_VAR_HOME=/opt/oracle/ogg/sm_deployment_home1/var
OGG_USER=oracle
Running OracleGoldenGateFreeInstall.sh...
Created symlink /etc/systemd/system/multi-user.target.wants/OracleGoldenGateFree.service → /etc/systemd/system/OracleGoldenGateFree.service.
Running OracleGoldenGateInstall.sh...
Created symlink /etc/systemd/system/multi-user.target.wants/OracleGoldenGate.service → /etc/systemd/system/OracleGoldenGate.service.
root$>
```

설치가 완료되었습니다. 

![](/assets/images/blog/oggfree/p14.jpg)

GoldenGate Free UI로 접속합니다. 

- URL : http://127.0.0.1:8020
- 계정정보를 입력합니다. (oggadmin/*********)
  
![](/assets/images/blog/oggfree/p15.jpg)


GoldenGate Free UI에 접속하여 Data Replication 작업을 구성할수 있습니다. 

![](/assets/images/blog/oggfree/p16.jpg)


## Data Replication 절차

Oracle GoldenGate Free버전이 설치가 되었으니 지에 데이터베이스간에 데이터 복제 작업을 구성하려고 합니다.

- 업무 요건 : Oracle Database 23c Free간 데이터 복제 
- 대상 방식 : SRCPDB -> TGTPDB (단방향)
- 복제 대상 테이블 : pdbadmin의 모든 테이블

Oracle Database 23c Free 생성작업을 아래 절차를 참고하시기 바랍니다. 

- [Oracle Database 23c Free 설치(RPM)](/blog/oracle/how-to-install-oracle23cfree/){: target="_blank"}

**소스/타켓 데이터베이스 생성**

SRCPDB 에서 데이터를 추출하여 TGTPDB로 데이터를 실시간 복제작업을 수행하기 위하여 
데이터베이스를 신규로 생성하도록 하겠습니다. 

- SRCPDB : 데이터 추출 DB
- TGTPDB : 데이터 적재 DB

```sql
## SQLPLUS로 접속합니다. 
oracle$> sqlplus "/as sysdba"

-- PDB 목록을 확인합니다.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 FREEPDB1                       READ WRITE NO

-- 소스 PDB를 생성합니다.
SQL> create pluggable database SRCPDB admin user pdbadmin identified by "**********" FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed','/opt/oracle/oradata/FREE/SRCPDB');
SQL> alter pluggable database SRCPDB open;

-- 타켓 PDB를 생성합니다.
SQL> create pluggable database TGTPDB admin user pdbadmin identified by "**********" FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed','/opt/oracle/oradata/FREE/TGTPDB');
SQL> alter pluggable database SRCPDB open;

-- PDB 목록을 확인합니다
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 FREEPDB1                       READ WRITE NO
         4 SRCPDB                         READ WRITE NO  <-- 데이터 추출대상
         5 TGTPDB                         READ WRITE NO  <-- 데이터 적재대상

```

### 1. Connection 생성

소스 DB와 타켓 DB에 대한 접속정보를 생성합니다. 
접속정보를 생성할때 GoldenGate 가 접속하는 DB유저를 생성하고 필요한 권한을 부여하도록 하겠습니다. 

GoldenGate Free UI에서 왼쪽 햄버거 버튼을 클릭하면 Database Connection과 Pipeline 메뉴가 나옵니다. 

Connection을 설정하기 때문에 Database connection을 클릭하겠습니다. 

기본적으로 Database Connection 목록을 확인할수 있습니다.아직 만들어진 Connection이 없으므로 목록에 보이지 않습니다.

오른쪽 상단에 "Create Database connection" 버튼을 클릭하여 Connection을 생성하도록 하겠습니다.

![](/assets/images/blog/oggfree/c1.jpg)

Connection생성을 위한 Wizard가 나옵니다. 
Connection name을 설정합니다. 

- Database Connection Name : SRCPDB

![](/assets/images/blog/oggfree/c2.jpg)

Connection을 위한 상세 정보를 설정합니다. 

- Connection Role : 
  - - [X] Source
- Hostname : localhost , port : 1521
- Database Type : 
  - - [X] Pluggable Database(PDB) in Oracle Database 21c or above
- Pluggable Database Service Name : SRCPDB

![](/assets/images/blog/oggfree/c3.jpg)

GoldenGate를 위한 DB 유저를 생성합니다. 

- [X] Add GoldenGate Admin Database User
- UserName : oggadmin / password : ***********

![](/assets/images/blog/oggfree/c4.jpg)

GoldenGate를 위한 DB설정작업을 합니다. 

- [X] SYSDBA Privilige available 를 선택하면  SYS권한을 가지고 있는 계정정보를 입력할수 있습니다.

![](/assets/images/blog/oggfree/c5.jpg)

SYS권한을 가지고 있는 계정정보를 입력합니다.

![](/assets/images/blog/oggfree/c6.jpg)

Run analysis 버튼이 활성화됩니다. Run Analysis버튼을 클릭합니다. 

![](/assets/images/blog/oggfree/c7.jpg)

Run Analysis버튼을 클릭하면 자동으로 DB에 접속하여 GoldenGate 구동을 위한 설정정보를 분석합니다.
필요한 권한 및 설정작업을 가이드합니다. 

- [X] I have reviewed the SQL Scription and am aware of the change it will apply to my database 를 선택하고 Run SQL 버튼을 클릭합니다.

- GoldenGate 구성을 위한 DB변경작업 (run SQL을 클릭하면 아래 SQL이 수행됩니다.)

```sql
--########################################################################################
--          Database Information
--########################################################################################
--Database Name:                FREE
--Database Host Name:           instance-20230922-1608
--Database Instance Name:       FREE
--Database Unique Name:         FREE
--Database Version:             23
--Database is Container (CDB):  YES
--Database CDB Service Name:    FREE
--Database PDB Service Name:    SRCPDB
--Database CDB User Exist:      NO    (User Name:  )
--Database PDB User Exist:      NO    (User Name:  OGGADMIN)
--
--########################################################################################
--          Database GoldenGate Status  
--########################################################################################
--Database Restart Required:    NO   
--Database Archived Log Mode:   YES       (Required value for GoldenGate: YES)
--Database Force Logging Mode:  NO        (Required value for GoldenGate: YES)
--Database Supplemental Mode:   NO        (Required value for GoldenGate: YES)
--Database Stream Pool Size Mb: 0         (Recommended value for GoldenGate: 512Mb)
--GoldenGate Enable Parameter:  TRUE      (Required value for GoldenGate: TRUE)
--
--########################################################################################
--          SQL Script to Enable GoldenGate in the FREE Database  
--########################################################################################
--
-- Database is in Archived Log Mode, NO RESTART required

-- Database FREE STREAMS_POOL_SIZE current size is 0Mb and it will be modified to 512Mb
-- The STREAMS_POOL_SIZE value helps determine the size of the Streams pool.
--
-- Property            Description
-- Parameter type      Big integer
-- Syntax              STREAMS_POOL_SIZE = integer [K | M | G]
-- Default value       0
-- Modifiable          ALTER SYSTEM
-- Modifiable in a PDB No
-- Range of values     Minimum: 0
--                     Maximum: operating system-dependent
-- Basic               No
-- 
-- Oracle's Automatic Shared Memory Management feature manages the size of
-- the Streams pool when the SGA_TARGET initialization parameter is set to 
-- a nonzero value. If the STREAMS_POOL_SIZE initialization parameter also 
-- is set to a nonzero value, then Automatic Shared Memory Management uses 
-- this value as a minimum for the Streams pool.
-- Oracle GoldenGate recommends streams_pool_size to be set at 1G or 10% of allocated SGA, whichever is smaller
ALTER SYSTEM SET STREAMS_POOL_SIZE=512M SCOPE=BOTH SID='FREE';
--
-- Database FREE is not in the recommended Force Logging Mode, alter database is required
--
-- Use this clause to put the database into or take the database out of FORCE LOGGING mode. 
-- The database must be mounted or open.
-- 
-- In FORCE LOGGING mode, Oracle Database logs all changes in the database except changes in 
-- temporary tablespaces and temporary segments. This setting takes precedence over and is 
-- independent of any NOLOGGING or FORCE LOGGING settings you specify for individual 
-- tablespaces and any NOLOGGING settings you specify for individual database objects.
-- Oracle strongly recommends putting the Oracle source database into forced logging mode. 
-- Forced logging mode forces the logging of all transactions and loads, overriding any user 
-- or storage settings to the contrary. This ensures that no source data in the Extract configuration gets missed.
-- 
-- If you specify FORCE LOGGING, then Oracle Database waits for all ongoing unlogged operations to finish.
--
ALTER DATABASE FORCE LOGGING;
--
-- Database FREE GoldenGate Parameter is ENABLED, NO ACTION is required.
--
-- Database FREE does not have SUPPLEMENTAL LOGGING enabled and an alter database is required.
-- 
-- In addition to force logging, the minimal supplemental logging, a database-level option, is required for an Oracle source database 
-- when using Oracle GoldenGate. This adds row chaining information, if any exists, to the redo log for update operations.
-- 
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA FOR PROCEDURAL REPLICATION;
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;
--
--
-- CDB User already exist or it is not needed for PDB Extract in databases greater then 19c, no action required.
--
--
--#######################################################################
--#### Create and Grant Privileges to the PDB GoldenGate Admin user. ####
--######################################################################
--
-- GoldenGate PDB User does not exist, create PDB user is required to extract transactions from the database.
ALTER SESSION SET CONTAINER = SRCPDB;
CREATE TABLESPACE GG_ADMIN_DATA DATAFILE '/opt/oracle/oradata/FREE/SRCPDB/ggadmin_data.dbf' SIZE 100m AUTOEXTEND ON NEXT 100m;
CREATE USER OGGADMIN IDENTIFIED BY "******" CONTAINER=CURRENT DEFAULT TABLESPACE GG_ADMIN_DATA QUOTA UNLIMITED ON GG_ADMIN_DATA;
--
--#######################################################################
--####     Grant Privileges to the PDB GoldenGate Admin user.        ####
--#######################################################################
--
GRANT CONNECT TO OGGADMIN CONTAINER=CURRENT;
GRANT RESOURCE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE SESSION TO OGGADMIN CONTAINER=CURRENT;
GRANT SELECT_CATALOG_ROLE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER SYSTEM TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER USER TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER DATABASE TO OGGADMIN CONTAINER=CURRENT;
GRANT DATAPUMP_EXP_FULL_DATABASE TO OGGADMIN CONTAINER=CURRENT;
GRANT DATAPUMP_IMP_FULL_DATABASE TO OGGADMIN CONTAINER=CURRENT;
GRANT SELECT ANY DICTIONARY TO OGGADMIN CONTAINER=CURRENT;
GRANT SELECT ANY TRANSACTION TO OGGADMIN CONTAINER=CURRENT;
GRANT INSERT ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT UPDATE ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT DELETE ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT LOCK ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY INDEX TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY CLUSTER TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY INDEXTYPE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY OPERATOR TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY PROCEDURE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY SEQUENCE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY TRIGGER TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY TYPE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY SEQUENCE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE ANY VIEW TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY TABLE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY INDEX TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY CLUSTER TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY INDEXTYPE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY OPERATOR TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY PROCEDURE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY SEQUENCE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY TRIGGER TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY TYPE TO OGGADMIN CONTAINER=CURRENT;
GRANT ALTER ANY SEQUENCE TO OGGADMIN CONTAINER=CURRENT;
GRANT CREATE DATABASE LINK TO OGGADMIN CONTAINER=CURRENT;
GRANT OGG_CAPTURE TO OGGADMIN CONTAINER=CURRENT;
GRANT OGG_APPLY TO OGGADMIN CONTAINER=CURRENT;
--
--########################################################################################
-- Database Configuration Status for GoldenGate: REQUIRE ATTENTION
--########################################################################################
--
```

![](/assets/images/blog/oggfree/c8.jpg)

DB변경작업이 완료되었습니다. 

![](/assets/images/blog/oggfree/c9.jpg)

마지막 으로 connection 정보를 생성합니다. 

![](/assets/images/blog/oggfree/c10.jpg)

Connection 목록에 새로 추가된 SRCPDB 정보를 확인할수 있습니다. 

![](/assets/images/blog/oggfree/c11.jpg)

동일한 방식으로 TGTPDB를 추가합니다. 

- Database Connection Name : TGTPDB
- Connection Role : 
  - - [X] TARGET
- Hostname : localhost , port : 1521
- Database Type : 
  - - [X] Pluggable Database(PDB) in Oracle Database 21c or above
- Pluggable Database Service Name : TGTPDB

![](/assets/images/blog/oggfree/c12.jpg)


### 2. pipeline 생성 

설정된 Connection정보를 이용하여 데이터 복제 작업을 수행하기 위해서는 pipeline을 생성해야합니다. 

GoldenGate Free UI에서 왼쪽 햄버거 버튼을 클릭하면 Database Connection과 Pipeline 메뉴가 나옵니다. 

pipeline메뉴를 클릭하면 pipeline목록을 확인할수 있습니다. 

왼쪽 "Create pipeline" 버튼을 클릭하여 추가합니다

![](/assets/images/blog/oggfree/r1.jpg)

GoldenGate Free에서는 2개의 recipe를 제공하고 있습니다. 

- One-way Database Replication : 단반향 복제
- Active-Active Database Replication : 양방향 복제

위 2가지 recipe중에 단방향 복제 방식으로 구성하겠습니다. 
- [X] One-way Database Replication를 클릭합니다.

![](/assets/images/blog/oggfree/r2.jpg)

pipeline 이름을 설정합니다. 

- pipeline Name : DataReplication1

![](/assets/images/blog/oggfree/r3.jpg)

Connections 선택합니다. 

- Source Database : SRCPDB
- Target Database : TGTPDB

![](/assets/images/blog/oggfree/r4.jpg)

pipeline의 Mapping정보를 확인합니다. 

SRCPDB의 PDBADMIN유저와 TGTPDB의 PDBADMIN유저와 매핑됩니다.

![](/assets/images/blog/oggfree/r5.jpg)

pipeline의 Mapping Rules정보를 확인합니다. 

SRCPDB의 PDBADMIN유저의 모든 테이블이 TGTPDB로 매핑됩니다. 
테이블이름이 그대로 매핑됩니다.

![](/assets/images/blog/oggfree/r6.jpg)

pipeline의 Options을 확인합니다. 

신규로 테이블이 추가되면 datapump로 초기 적재하고 이후에 변경 적재하도록 설정되어 있습니다.
또한 DDL도 복제되도록 설정되어 있습니다.

왼쪽 상단에 "SAVE"버튼을 클릭합니다. 

![](/assets/images/blog/oggfree/r7.jpg)

pipeline의 Overview로 화면 이동이 됩니다.

왼쪽 상단에 "Start"버튼을 클릭하면 GoldenGate 설정작업이 수행됩니다.

![](/assets/images/blog/oggfree/r8.jpg)

모드 정상적으로 설정이 완료되었습니다. 

![](/assets/images/blog/oggfree/r9.jpg)

### 3. 데이터 복제 확인

GoldenGate가 정상적으로 수행되는지 실제 데이터를 수정해서 복제되는지 확인하겠습니다. 

소스 DB(SRCPDB)에서 테이블 생성과 데이터 변경 작업을 수행합니다. PDBADMIN유저에 TEST테이블를 생성하고 데이터 1건을 insert합니다

```sql
SQL> alter session set container=srcpdb;
Session altered.
SQL> create table pdbadmin.test (id number primary key, name varchar2(100));
Table created.
SQL> insert into pdbadmin.test values (1,'gil-dong hong');
1 row created.
SQL> commit;
Commit complete.
SQL>
```

타켓 DB(TGTPDB)에 접속해서 데이터를 조회합니다.
GoldenGate가 정상적으로 동작했으면 테이블생성도 되고 데이터도 들어가 있어야합니다. 

```sql
SQL> alter session set container=tgtpdb;
SQL> select * from pdbadmin.test;
        ID NAME
---------- --------------------
         1 gil-dong hong
SQL>
```

데이터 조회를 통해서 테이블생성과 데이터변경을 같이 확인하였습니다. 

GoldenGate Free UI에서는 pipeline의 runtime정보를 확인할수 있습니다. 

데이터는 약 5초이내로 동기화되고 있고, 
operation extract/replicat 차트에서 operation에 대한 자세한 정보를 확인할수 있습니다. 

- DDL복제 : 보라색 (CREATE TABLE구문)
- insert건수 : 남색 (INSERT INTO PDBADMIN.TEST구문)
- update건수 : 주황색 (UPDATE HEARTBEAT테이블) - 기본적으로 heartbeat테이블이 활성화되어 약 5초에 한번씩 Scheduler job에 의하여 update구문이 발생됩니다. 

![](/assets/images/blog/oggfree/r10.jpg)

## 마무리

지금까지 GoldenGate Free버전에 대해서 알아보았습니다. 
GoldenGate Free버전을 설치하는 절차와 실제 데이터 복제를 위한 pipeline 작업까지 구성해보았는데요. 생각보다 에러없이 너무 간편하게 설정했습니다. 

사실 GoldenGate 상용버전을 사용할때는 CLI기반으로 하나부터 열까지 세세하게 관리해야되지만, FREE버전에서는 보다 사용자 중심의 UI와 간편함을 장점으로 사용자 확대를 위해 노력한다는 느낌을 받았습니다. GoldenGate Free는 GoldenGate MSA컴포넌트와 GoldenGate Free UI로 구성이 됩니다.  GoldenGate MSA컴포넌트는 내부적으로 설치되어 있기 때문에 adminclient를 통해서 세부적으로 관리가 가능하고, GoldenGate Free UI에서 REST API를 통해서 recipe라는 개념을 추가하여 보다 쉽게 데이터 복제가 가능합니다.

다만 아쉬운 점은 Oracle Database간에만 데이터 복제가 가능한점, 리소스의 제약이 있다는점인데요,  Free이기 때문에 어쩔수 없지만, 좀더 다양한 환경(Non-Oracle, Bigdata, Cloud), 최신 앱기술들을 지원하는 기능이 추가되었으면 좋겠습니다. 

## 참조문서

- Documents
  - <https://www.oracle.com/integration/goldengate/free/>{: target="_blank"}
  - <https://docs.oracle.com/en/middleware/goldengate/free/23/index.html>{: target="_blank"}
- Blogs
  - <https://blogs.oracle.com/dataintegration/post/oracle-goldengate-free>{: target="_blank"}
  - <https://blogs.oracle.com/dataintegration/post/oracle-goldengate-free-release-23c-233-on-oci-container-instances>{: target="_blank"}

