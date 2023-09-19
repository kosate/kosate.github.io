---
layout: single
title: 오라클 접속관리를 위한 도구(CMAN) 소개
date: 2023-09-16 18:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - Connection Manager
   - 19c
   - 21c
   - 23c
excerpt : CMAN(Connection Manager)를 이용한 오라클 접속관리 방법을 설명합니다.
header :
  teaser: /assets/images/blog/cman.jpg
  overlay_image: /assets/images/blog/cman.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클 클라이언트에는 CMAN(Connection Manager)이라는 기능이 제공됩니다. 
CMAN은 오라클 리스너를 확장하여 데이터베이스 서버와 애플리케이션 간의 접속 정보를 추상화하는 레이어로 사용될 수 있습니다. 
CMAN을 설정하는 방법에 대해 알아보겠습니다.

## 오라클 접속 정보 관리의 필요성

애플리케이션 담당자는 주로 오라클 데이터베이스 서버 환경 변화에 큰 관심을 두지 않습니다. (예를 들어, Single 또는 RAC 여부 등)
애플리케이션은 표준 방식(JDBC 등)으로 데이터베이스에 접속하여 필요한 업무를 수행하고, 결과를 확인하며 데이터를 조작합니다.
다시 말해, 애플리케이션 레벨에서 세션이 끊기지 않고 작업의 연속성이 유지된다면 인프라 및 데이터베이스 작업이 수월해집니다.

그러나 데이터베이스 운영 중에는 다운타임이 발생할 수 있습니다.

- DB작업유형별 고려사항
  - DB 패치 - RAC환경이라면 Rolling 작업가능(타운타임 최소화가능)
  - DB 업그레이드 - 다운타임발생
  - DB 구성 변경(Single -> RAC) - 인프라가 준비되어있으면 온라인가능, 접속정보 변경필요
  - 인프라 작업(서버 패치등) - RAC환경이라면 Rolling 작업가능(타운타임 최소화가능)
  - DB 마이그레이션(서버노후화) - 다운타임발생, 접속정보 변경필요
  

DB 구성 변경 및 마이그레이션 등 인프라 구성이 변경되어 접속정보가 변하는 작업이 필요할 때가 있습니다.
이런 경우, 애플리케이션 담당자에게 미리 공지하고 인프라 작업과 함께 애플리케이션의 접속정보를 변경하는 작업을 동시에 진행하게 됩니다.
대부분의 경우 애플리케이션 접속정보에는 데이터베이스 서버의 IP 정보를 가지고 있기 때문입니다.

CMAN을 사용한다면 제공되는 Endpoint IP을 애플리케이션에서 사용한다면, 애플리케이션의 접속 정보를 변경하지 않고도 인프라 및 데이터베이스 변경 작업을 수행할 수 있습니다.

## Oracle Connection Manager (CMAN) 소개

CMAN(Connection Manager)은 오라클 데이터베이스와 연동되는 네트워크 프록시 서비스입니다. Firewall Proxy와 Traffic Director기능을 통해 서비스를 논리적으로 분리하고 각종 작업 및 장애로부터 서비스에 미치는 영향을 최소화할 수 있습니다.


- CMAN이 지원하는 기능
  - 오라클 데이터베이스와 연동됩니다. TNS 리스너와 Cross-registration기능을 이용하여 DB서버내에서 서비스가 변경되면 자동으로 CMAN에 반영됩니다.  DB 장애 및 작업시 세션 Failover를 지원합니다. 
  - SQL*Net 프로토콜 지원(변환)합니다. IPv4와 IPv6간사이 bridge로 사용될수 있습니다.  
  - 규칙기반의 ACL(Access Control List)제어가능합니다. 동일한 Endpoint로 논리적인 Tenant 분리가능합니다.
  - Session Multiplexing을 지원합니다. Shared Server기반의 네트워크접속기능을 통하여 여러개의 클라이언트 세션을 제어가능합니다. 

- 아키텍쳐 비교 
  - 현재 운영 방식 : APP서버 -> DB서버 
  - CMAN적용시 : APP서버 -> CMAN서버 -> DB서버

## CMAN기반의 아키텍쳐 변경방안

CMAN 기반 아키텍처를 적용하는 과정을 통해서 어떻게 동작하는지 살펴보겠습니다. 
기존의 App-DB 아키텍처에 CMAN 인스턴스를 중간에 추가하고 App의 접속 정보를 수정하여 이를 적용할 수 있습니다.
애플리케이션에서는  DB 서버에 직접 접속하는 대신 CMAN 인스턴스를 통해 접속해야 하므로, 접속 정보를 변경해야 하는 작업이 필요합니다. 이는 실제 운영 중에 적용하기 어려울 수 있습니다.
모든 애플리케이션을 동시에 접속 정보를 변경하는 것보다는 각 애플리케이션을 구분하여 점진적으로 적용하는 것이 더 나은 방법으로 보입니다.

- CMAN적용을 위한 준비사항
  - CMAN인스턴스를 실행하기 위한 서버가 필요합니다. 
  - 가능하다면 CMAN인스턴스를 두개를 구성하여 이중화를 구성합니다. (서버이중화)

### 1. CMAN 서비스 생성 및 설정방법 (CMAN Host)

CMAN을 설치하고 인스턴스를 생성하는 방법은 다음과 같습니다. 

- CMAN설치 방법
  1. 오라클 클라이언트 설치
  2. cman.ora 파일 생성 ($ORACLE_HOME/network/admin/cman.ora)
  3. cmctl로 CMAN인스턴스 기동

오라클 클라이언트 다운받아서 설치합니다. 
<https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html>

Oracle Database 19c Client (19.3) for Linux x86-64에서 설치파일(LINUX.X64_193000_client.zip)은 다운로드합니다.
오라클 클라이언트 설치시 "Administrator"모드로 설치하면 CMAN도 같이 설치됩니다.
CMAN 설정을 위한 cman.ora파일을 생성후에 CMAN을 실행하면 CMAN인스턴스가 기동됩니다. 

**CMAN 설정정보**

CMAN의 설정정보는  $ORACLE_HOME/network/admin/cman.ora에 있습니다. 
CMAN이 리스닝할 아이피와 포트를 설정할수 있습니다. (Listener 설정과 유사합니다)

아래 cman.ora내용을 보면 3부분으로 나뉘는것을 알수 있습니다. 

- cman 구성파일 내용
  - Listening endpoint(ADDRESS_LIST) :  리스닝하는 Endpoint정의
  - Access control rule list(RULE_LIST) : ACL를 위한 Rule정의
  - Parameter List(PARAMETER_LIST) : 로깅 설정, 프로세스/네트워크 설정등

아래 cman구성파일은 CMAN인스턴스의 리스닝아이피는 10.0.0.31이고 포트는 1555를 사용하는 예제입니다.
그리고 CMAN1은 CMAN인스턴스의 이름을 의미합니다.
```sql
CMAN1 =
  (CONFIGURATION=
    (ADDRESS_LIST= 
      (ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.31)(PORT=1555))   
    )
    (RULE_LIST=  
      (RULE=  (SRC=*)(DST=*)(SRV=*)(ACT=accept)
           (action_list=(aut=off)(moct=0)(mct=0)(mit=0)(conn_stats=on))
       )
    )
    (PARAMETER_LIST= 
      (log_level=ADMIN)
      (max_connections=1024)
      (idle_timeout=0)
      (registration_invited_nodes = *)
      (inbound_connect_timeout=0)
      (session_timeout=0)
      (outbound_connect_timeout=0)
      (max_gateway_processes=16)
      (min_gateway_processes=2)
      (remote_admin=on)
      (trace_level=off)
      (max_cmctl_sessions=4)
      (event_group=init_and_term,memory_ops)
    )
  )

```

**CMAN 인스턴스 실행**

CMAN구성파일이 있으면 CMAN인스턴스를 실행할수 있습니다. 
아래 작업은 CMAN구성파일에 cman1에 대한 설정정보가 있으므로 cman1 인스턴스가 기동되는 예제입니다. 

```sql
[oracle@cman1 ~]$ $ORACLE_HOME/bin/cmctl

CMCTL for Linux: Version 19.0.0.0.0 - Production on 16-APR-2020 06:41:50

Copyright (c) 1996, 2019, Oracle.  All rights reserved.

Welcome to CMCTL, type "help" for information.

CMCTL> admin cman1
Current instance cman1 is not yet started
Connections refer to (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.31)(PORT=1555))).
The command completed successfully.
CMCTL:cman1> startup
Starting Oracle Connection Manager instance cman1. Please wait...
CMAN for Linux: Version 19.0.0.0.0 - Production
Status of the Instance
----------------------
Instance name             cman1
Version                   CMAN for Linux: Version 19.0.0.0.0 - Production
Start date                16-APR-2020 06:41:56
Uptime                    0 days 0 hr. 0 min. 9 sec
Num of gateways started   2
Average Load level        0
Log Level                 ADMIN
Trace Level               OFF
Instance Config file      /u01/app/oracle/network/admin/cman.ora
Instance Log directory    /u01/app/oracle/diag/netcman/cman1/cman1/alert
Instance Trace directory  /u01/app/oracle/diag/netcman/cman1/cman1/trace
The command completed successfully.
CMCTL:cman1>
```

서버 이중화를 위하여 두개의 서버에 각각 CMAN인스턴스를 생성합니다.

### 2. CMAN에 서비스 등록 작업 수행 (DB서버)

CMAN인스턴스에는 DB서버와 서비스정보가 없습니다. 
DB서버에서 CMAN인스턴스에 연결해서 DB서버에서 가지고 있는 서비스들을 CMAN인스턴스에 등록하는 절차가 필요합니다. 

- DB서버에서 CMAN등록 절차
  1. CMAN 접속정보를 추가
  2. DB인스터스에 remote_listener파라미터 설정
  3. CMAN 인스턴스에서 서비스등록확인

**CMAN 접속정보를 추가**

DB서버의 tnsnames.ora에 CMAN서버 접속정보를 추가합니다.

```sql
-- DB서버에서 CMAN의 Endpoint를 모두 등록
[oracle@testdb1] vi $ORACLE_HOME/network/admin/tnsnames.ora
listener_cman =
 (DESCRIPTION=
  (ADDRESS_LIST=
   (ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.31)(PORT=1555))
   (ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.32)(PORT=1555))))
```

**DB인스턴스에 remote_listener파라미터 설정**

DB서버에 remote_listener파라미터로 listener_cman접속정보를 등록합니다. 
DB서버의 PMON프로세스가 cross-registationr기능을 통해서 CMAN인스턴스에 서비스를 등록합니다.

```sql
[oracle@testdb1]$ sqlplus "/as sysdba"
SQL> alter system set remote_listener=listener_cman;
System altered.
SQL> alter system register;
System altered.
SQL> SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 DB0416_PDB1                    READ WRITE NO
SQL> alter session set container=DB0416_PDB1;
Session altered.
SQL> select name from v$services;
NAME
----------------------------------------------------------------
db0416_pdb1
SQL> show parameter domain
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_domain                            string      
SQL>
```

**CMAN 인스턴스에서 서비스등록확인**

CMAN인스턴스에서 show service명령어를 수행하면 등록된 서비스목록을 확인할수 있습니다.

```sql
[oracle@cman1 ]$ $ORACLE_HOME/bin/cmctl

CMCTL for Linux: Version 19.0.0.0.0 - Production on 16-APR-2020 06:41:50

Copyright (c) 1996, 2019, Oracle.  All rights reserved.

Welcome to CMCTL, type "help" for information.

CMCTL> admin cman1
Current instance cman1 is not yet started
Connections refer to (ADDRESS_LIST=(ADDRESS=(PROTOCOL=tcp)(HOST=10.0.0.31)(PORT=1555))).
The command completed successfully.
CMCTL:cman1> show service
Services Summary...
…..
….
Service "db0416_pdb1" has 1 instance(s).  <-- 서비스 등록확인 
  Instance "DB0416", status READY, has 1 handler(s) for this service...
    Handler(s):
      "DEDICATED" established:1 refused:0 state:ready
         REMOTE SERVER
         (ADDRESS=(PROTOCOL=TCP)(HOST=testdb1)(PORT=1521))
The command completed successfully.
CMCTL:cman1>
```

### 3. DB접속 정보 변경(Client서버) 
애플리케이션의 DB접속정보를 CMAN Host에서 리스닝하는 아이피와 포트정보(예시:1555)로 변경합니다.(서비스명을 그대로사용합니다)
```sql
-- 변경전
TESTDB1 =
  (DESCRIPTION =
     (CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)
     (ADDRESS_LIST =
       (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.29)(PORT = 1521))  <-- DB서버아이피
     )
     (CONNECT_DATA=
           (SERVICE_NAME = db0416_pdb1)
     )
 )

-- 변경후
TESTDB1  =
  (DESCRIPTION =
    (CONNECT_TIMEOUT=5)(TRANSPORT_CONNECT_TIMEOUT=3)(RETRY_COUNT=3)
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.31)(PORT = 1555)) <-- 접속 아이피와 포트를 CMAN의 End Point로 변경
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.0.0.32)(PORT = 1555)) <-- 접속 아이피와 포트를 CMAN의 End Point로 변경 
     )
     (CONNECT_DATA =
       (SERVICE_NAME = db0416_pdb1)
     )
  )
```

정상적으로 접속되는지 테스트합니다.

### 4. CMAN인스턴스 장애 테스트

이중화된 CMAN서비스중 한개를 중지할경우 서비스의 영향없이 정상수행되는지 확인합니다.
강제적으로 CMAN1의 인스턴스를 중지합니다. 
```sql
CMCTL:cman1> shutdown abort
The command completed successfully.
CMCTL:cman1>
```

DB세션이 영향을 주는지 서비스를 확인합니다.
```sql
YYMMDDHH24MISS      NODE     INSTANCE_NAME   HOST_NAME 
------------------- -------- --------------- --------------
2020/04/17 01:25:47 PDB1     DB0416           testdb1

<<CMAN중지 시점--> 서비스 영향없음 >>

YYMMDDHH24MISS      NODE     INSTANCE_NAME   HOST_NAME 
------------------- -------- --------------- --------------
2020/04/17 01:25:48 PDB1     DB0416           testdb1

OBJECT_NAME
--------------------------------------------------------------------------------
I_FILE#_BLOCK#
I_FILE#_BLOCK#
<<CMAN중지 시점--> 서비스 영향없음 >>
I_FILE#_BLOCK#
```

## CMAN의 활용방안
CMAN을 통해 애플리케이션과 데이터베이스 간을 물리적/논리적으로 분리하여 아키텍처를 더욱 유연하게 구성할 수 있습니다. 또한 Cache 및 ACL 기능을 통해 성능과 보안을 강화할 수 있습니다.

- DB 서비스의 접속 포인트(CMAN)와 DB 서버 간의 분리
  -  애플리케이션은 변경 사항이 없습니다. (단, 접속 정보는 변경되어야 합니다.)
  -  애플리케이션은 CMAN을 통해서만 DB 서비스에 접속합니다.
  -  DB 서비스(예: PDB 추가)를 추가할 경우 자동으로 CMAN에 서비스가 등록됩니다.
  -  DB 서비스별로 ACL을 적용하여 논리적으로 분리할 수 있습니다. (애플리케이션 IP와 DB 서버 IP 지정 가능)
  -  DB 서버 작업 시 유연하게 대처할 수 있습니다. (PDB relocate 등)
  -  표준 접속 방식에서 지원하는 CTF와 TAF를 모두 지원합니다. (가용성 보장)

- 성능 제어
  - 네트워크 대역폭을 제어합니다. (21c에서 가능)
  - 세션의 Live Migration을 지원합니다. (21c에서 가능)
  - CMAN Server와 CMAN Client 간에 Tunneling 모드를 지원합니다. (21c에서 가능)
  - DoS(서비스 거부 공격)로부터 보호할 수 있습니다. (23c에서 가능)
  - CMAN의 Traffic Director Mode에서 Connection Pool, Load Balancing, Result Cache를 지원합니다.

- 접속 로그 이력 확인
  - CMAN 로그는 기본적으로 Listener로그패턴과 유사합니다.

## 마무리

애플리케이션과 DB 서버 사이에 CMAN 인스턴스를 위치시킴으로써 접속 정보의 추상화 환경을 제공할 수 있습니다. MSA 환경에서는 지속적으로 서비스가 생성되고 삭제되는데, 이런 환경에서 CMAN을 활용할 수 있습니다. 또한 Multitenant 환경에서는 PDB(Pluggable DB)의 이동성을 지원하기 위해 CMAN이 사용될 수 있습니다. 변경이 많지 않은 환경에서는 큰 도움이 되지 않을 수 있지만, 데이터베이스 운영 환경을 더 유연하게 관리하고 싶다면 CMAN을 한 번 검토해보시기 바랍니다.