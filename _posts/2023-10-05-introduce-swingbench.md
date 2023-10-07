---
layout: single
title: Swingbench 소개 및 설치 방법
date: 2023-10-05 07:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle 
   - swingbench
   - benchmarkl
excerpt : 오라클 데이터베이스 Benchmark 도구인 Swingbench에 대해서 소개합니다.
header :
  teaser: /assets/images/blog/benchmark.jpg
  overlay_image: /assets/images/blog/benchmark.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스운영환경에서 다양한 작업들을 수행할때 업무에 대한 영향도를 검증해야되는 경우가 있습니다. 테스트 및 검증 환경에서 부하 테스트 도구를 이용하여 사전에 작업에대한 검증을 할수 있는데요. 이때 Swingbench 도구를 활용하면 보다 쉽게 데이터 로딩 및 부하 발생 작업을 할수 있습니다.

Swingbench 도구의 기본 소개 및 설치 방법에 대해서 정리하였습니다.
설치 방법은 GUI방식과 CLI방식이 모두 제공되며 본문에서는 CLI방식으로 설치 및 작업을 진행하였습니다.

## Swingbench 소개 

SwingBench는 오라클 직원이 직접 개발한 **오라클 데이터베이스 부하 테스트 도구**입니다. 
다양한 benchmark데이터를 제공하며 간단한 커맨드로 데이터를 적재, 테스트 작업을 수행할수 있습니다. 

Swingbench 홈페이지 : <https://www.dominicgiles.com/swingbench.html>

- SwingBench도구의 특징 
  - 다양한 Benchmark 데이터를 제공합니다(OLTP, OLAP, TPC-DS like, TPC-H like)
  - 데이터 생성 부터 부하 테스트까지 GUI혹은 CLI기반으로 쉽게 작업이 가능합니다.
  - 부하관련된 모든 파라미터는 XML로 관리합니다. 
  - 결과는 XML로 생성이 되며 PDF변환툴도 같이 제공합니다.(명령어 : results2pdf)

Swingbench는 비공식적으로 많이 사용하는 부하테스트툴입니다.
부하테스트를 하거나 작업에 대한 영향도를 평가할때 주로 사용합니다.

- Swingbench 활용예
  - PoC 환경에서 OTLP, OLAP과 같은 업무를 대신하여 부하 발생시키는 애플리케이션으로 활용될수 있습니다. (업무가 유입되는 상황에서 다양한 데이터베이스 기능을 테스트할때 사용될수 있습니다.)
  - Online 작업에 대한 영향도 평가를 위하여 부하 발생시 TPS 변화를 모니터링 할수 있습니다. (Online Operation 작업을 수행하거나, RAC node 증설시에 대한 업무 영향도를 미리 검증할수 있습니다.)
  - 신규 DB환경이 구성되고 Stress Test를 통해서 안정적인 시스템 구성이 되었는지 검증할때 사용될수 있습니다. (예 : CPU 80%운영환경에서 안정적으로 동작하는지 확인하는 목적으로 활용될수 있습니다.)

### SwingBench의 4가지 인터페이스

Swingbench는 4가지의 인터페이스를 제공하고 있습니다. 모두다 동일한 kernel로 동작하므로 부하 생성방식을 동일합니다. 대신 테스트를 시작하고 모니터링 하는 방법(Frontend)에 대해서 4가지 방법을 제공하고 있습니다. 

- Swingbench의 4가지 인터페이스
  - Swingbench (명령어 : swingbench)
    - 다양한 Real-Time Chart을 제공하여 실시간 모니터링을 제공합니다. 
    - GUI기반으로 파라미터 변경 및 설정가능합니다.     
    - Demo시연하기 유용합니다.
  - Minibench(명령어 : minibench)
    - Swingbech에 비해 더 적은 Graph를 제공합니다. 간단한 Real-Time Chart를 제공합니다. 
    - 실행시 파라미터 설정하거나 XML파일에서 파라미터 변경할수 있습니다. 
  - Chartbench (명령어 : charbench)
    - CLI기반로 실행되며 vmstat/sar와 같은 결과를 제공합니다.
    - Benchmark 테스트할때 결과를 직관적으로 확인할수 있어 유용합니다.
    - 실행시 파라미터 설정하거나 XML파일에서 파라미터 변경할수 있습니다. 
  - ClusterOverview(명령어 : ccwizard)
    - Swingbech와 유사하게 GUI기반의 실시간 모니터링을 제공합니다.
    - Real Application Cluster 환경에서 여러노드의 부하모니터링할때 유용합니다.

GUI관점에서는 Swingbench가 가장 많은 기능을 제공하고, Benchmark 테스트환경에서는 Chartbench가 더 직관적인 결과를 확인할수 있어 더 유용한것 같습니다. 

Swingbench는 하나의 프로그램에서 여러개의 Thread에서 동시 접속자를 생성하여 부하를 발생시키지만, Coordinator(명령어 : coordinator)를 이용하면 여러개의 Swingbench프로그램에서 동시에 부하를 발생시킬수 있습니다.

### Swingbench에서 제공하는 Benchmark 데이터유형

Swingbench는 Benchmark 테스트를 여러개의 Schema유형을 제공하고 있습니다. 
테스트하고자 하는 업무 유형을 확인후에 DB유저 생성작업과 함께 데이터를 생성할수 있습니다. 
데이터의 크기는 Scale을 지정하여 조정할수 있으며 Scale=1은 데이터 1G를 의미하고 기타 오브젝트(인덱스등)을 포함할 경우 총 데이터는 Scale의 약 3.2배정도의 용량이 필요합니다.
(Scale = 1 일경우 3.2GB필요) 

- Swingbench가 제공하는 Schema 유형
  - Order Entry Schema(명령어 : oewizard) - Heavy write 워크로드(오라클의 OE Schema와 동일)
  - Star Schema(명령어 : shwizard) - 분석 워크로드(오라클의 SH Schema와 동일)
  - JSON Schema(명령어 : jsonwizard) - JSON CRUD 워크로드
  - TPC-DS like Schema(명령어 : tpcdswizard) - 복잡한(Complex) 분석 워크로드
  - TPC-H like Schema(명령어 : tpchwizard) - 중간 정도의 복잡한 분석 워크로드 
  - Movie Stream(명령어 : moviewizard) - Movie Stream 애플리케이션을 위한 워크로드 

각 Schema유형별로 데이터 생성 툴을 별도로 제공하고 있습니다.

데이터 생성이후에 swingbench 툴에서 혹은 Configuration(XML) 파일에서 각 워크로드별 DML의 세부 비율을 조정하여 테스트하고자하는 워크로드를 재현할수 있습니다.

## Swingbench 설치 

Swingbench를 실행하기 위해서는 Java가 필요합니다. Oracle JDK를 사용하거나 Open JDK를 사용할수 있습니다. 

- 지원환경
  - JDK (OpenJDK, Oracle JDK), 최신 SwingBench(June 2023 Release)기준는 JDK 17을 권고(JDK 11지원)
  - OS 플랫폼 (Mac, Windows, Linux)

본문에서는 아래와 같은 환경에서 Swingbench를 설치하였습니다.

- 설치환경
  - Swingbench 설치 환경 : Oracle Linux 8, Oracle JDK 17, 
  - Benchmark Schema : Order Entry Schema(Scale = 1) = 총 3.2G
  - 테스트 DB버전 : Oracle Database 23c Free
  - 부하테스트 방법 : 동시접속유저 10명, 실행시간 5분

※ Swingbench 서버와 DB서버는 분리되어 있어야 애플리케이션 간섭없이 DB자체의 부하과 성능을 확인할수 있습니다.

### 1. Java 및 Swingbench 다운로드 및 설치
#### Java 설치(Linux RPM)

오라클 사이트에서 Oracle JDK(약 173MB)를 다운로드 받습니다.<br>
Oracle JDK 다운로드 사이트 : <https://www.oracle.com/java/technologies/downloads/>

root유저로 Java RPM을 설치합니다. 
저는 Oracle JDK 17를 다운로드 받고 설치했습니다. 

```shell
## root유저로 접속하여 java.rpm파일을 다운로드 받습니다. 
[root@swingbenchserver ~]# curl -L -o jdk-17_linux-x64_bin.rpm https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  173M  100  173M    0     0  58.1M      0  0:00:02  0:00:02 --:--:-- 58.0M
[root@swingbenchserver ~]# ls -al
-rw-r--r--.  1 root root  182097730 Oct  6 06:29 jdk-17_linux-x64_bin.rpm
## root유저로 java.rpm파일을 설치합니다.
[root@swingbenchserver ~]# rpm -ivh jdk-17_linux-x64_bin.rpm
warning: jdk-17_linux-x64_bin.rpm: Header V3 RSA/SHA256 Signature, key ID ec551f03: NOKEY
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:jdk-17-2000:17.0.8-9             ################################# [100%]
## java 버전을 확인합니다.
[root@swingbenchserver ~]# java -version
java version "17.0.8" 2023-07-18 LTS
Java(TM) SE Runtime Environment (build 17.0.8+9-LTS-211)
Java HotSpot(TM) 64-Bit Server VM (build 17.0.8+9-LTS-211, mixed mode, sharing)
[root@swingbenchserver ~]#
```

#### Swingbench 설치

Swingbench 도구를 다운로드 받습니다. 
2023년 10월기준, Swingbnech 도구의 최신버전은 June 2023 Release(약 39MB)입니다. 

Swingbench 최신버전 다운로드 사이트 : <https://github.com/domgiles/swingbench-public/releases/tag/production>

root유저 혹은 oracle유저로 다운로드합니다. 별도의 설치과정은 없고, 다운로드 받고 압축을 해제합니다.

저는 oracle 유저로 swingbench 설치하도록 하겠습니다.

```bash
## Oracle유저로 Swingbench 프로그램을 다운로드 받습니다.
[oracle@swingbenchserver ~]$ curl -L -o swingbench25052023.zip https://github.com/domgiles/swingbench-public/releases/download/production/swingbench25052023.zip
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 38.6M  100 38.6M    0     0  14.2M      0  0:00:02  0:00:02 --:--:-- 20.1M
[oracle@swingbenchserver ~]$ ls -arlt
-rw-r--r--. 1 oracle oinstall 40524749 Oct  6 06:44 swingbench25052023.zip
## Swingbench 프로그램을 압축해야합니다. 
[oracle@swingbenchserver ~]$ unzip swingbench25052023.zip
Archive:  swingbench25052023.zip
   creating: swingbench/
   creating: swingbench/launcher/
  inflating: swingbench/launcher/launcher.xml
  inflating: swingbench/launcher/LauncherBootstrap.class
  inflating: swingbench/launcher/launcher.properties
  inflating: swingbench/launcher/commons-launcher.jar
..

  inflating: swingbench/sql/saleshistory/shdg_indexes.sql
  inflating: swingbench/sql/saleshistory/shdg_tables.sql
  inflating: swingbench/sql/saleshistory/shdg_indexes_none.sql
  inflating: swingbench/sql/saleshistory/shdg_mergepartitions.sql
## 압축해제되면 swingbench 폴더가 생성된것을 확인합니다. 
[oracle@swingbenchserver ~]$ ls -arlt
drwx------. 12 oracle oinstall      160 May 25 19:08 swingbench
-rw-r--r--.  1 oracle oinstall 40524749 Oct  6 06:44 swingbench25052023.zip
drwx------.  3 oracle oinstall      145 Oct  6 06:45 .
[oracle@swingbenchserver ~]$ cd swingbench
[oracle@swingbenchserver swingbench]$ ls -alrt
total 24
drwxr-xr-x.  2 oracle oinstall    6 Mar  3  2010 log
drwxr-xr-x.  2 oracle oinstall   61 May 13  2022 utils
drwxr-xr-x.  2 oracle oinstall  112 Feb  9  2023 launcher
drwx------.  3 oracle oinstall 4096 Feb 23  2023 winbin <--  windows환경에서 실행파일
drwxr-xr-x.  3 oracle oinstall 4096 Apr  5  2023 bin   <-- Linux환경에서 실행파일
-rw-rw-rw-.  1 oracle oinstall 6842 Apr  5  2023 README.md
drwxr-xr-x.  2 oracle oinstall 4096 Apr 11 10:27 configs  <-- 부하테스트 파라미터 파일
drwxr-xr-x.  2 oracle oinstall  178 May 17 20:14 wizardconfigs
drwxr-xr-x. 12 oracle oinstall  182 May 25 19:08 sql
drwx------. 12 oracle oinstall  160 May 25 19:08 .
drwxr-xr-x.  3 oracle oinstall   50 May 25 19:08 source
drwxr-xr-x.  3 oracle oinstall 4096 May 25 19:08 lib
drwx------.  3 oracle oinstall  145 Oct  6 06:45 ..
[oracle@swingbenchserver swingbench]$
```

### 2. DB 유저 생성 및 데이터 로딩(CLI기반)

Benchmark를 위한 DB 유저를 생성하고, 테이블스페이스를 생성하여 데이터를 로딩하는 작업을 수행합니다. 

- 고려사항
  - 1GB 스키마를 생성할때 약 Temp 0.6GB정보가 필요합니다. 
  - 새로운 Benchmark 테스트를 할때 마다 새로운 Schema유저를 생성하여 수행합니다.
  - 오브젝트 생성시 파티션테이블, 인덱스 생성여부를 지정할수 있고, 데이터로딩시 병렬도를 지정할수 있습니다.

- 설치 환경
  - DB유저 생성 : soe/soepasword
  - 테이블스페이스 : TS_SOE_01 , 데이터파일(/opt/oracle/oradata/FREE/FREEPDB1/TS_SOE_01.dbf)
  - 데이터크기 : Scale = 1
  - 데이터로딩 병렬도 : 4 Thread

```bash
[oracle@swingbenchserver swingbench]$ cd bin
## Order Entry Schema 생성을 위하여 다양한 옵션을 확인합니다. 
[oracle@swingbenchserver bin]$ ./oewizard -h
usage: parameters:
 -allindexes             build all indexes for schema
 -async_off              run without async transactions
 -async_on               run with async transactions (default)
 -bigfile                use big file tablespaces
 -bs <size>              the batch size of rows inserted into the database
 -c <filename>           wizard config file
 -cf <file>              the location of a credentials file for Oracle
                         Autonomous Database
 -cl                     run in character mode
 -compositepart          use a composite paritioning model if it exisits
 -compress               use default compression model if it exists
 -constraints            only create primary/foreign keys for schema
 -create                 create benchmarks schema
 -cs <connectString>     connectring for database
 -dba <username>         dba username for schema creation
 -dbap <password>        password for schema creation
 -debug                  turn on debugging output
 -debugf <debugfile>     turn on debugging. Write output to <debugfile>
                         defaults to debug.log
 -df <datafile>          datafile name used to create schema in
 -drop                   drop benchmarks schema
 -dt <driverType>        driver type (oci|thin)
 -g                      run in graphical mode (default)
 -generate               generate data for benchmark if available
 -h,--help               print this message
 -hashpart               use hash paritioning model if it exists
 -hcccompress            use HCC compression if it exisits
 -idf <datafile>         index datafile used to create indexes in
 -its <datafile>         index tablespace used to create indexes in
 -nc                     Don't use color output
 -nocompress             don't use any database compression
 -noindexes              don't build any indexes for schema
 -nopart                 don't use any database partitioning
 -normalfile             use normal file tablespaces
 -oltpcompress           use OLTP compression if it exisits
 -ot <output type>       output type (json or std), defaults to std
 -p <password>           password for benchmark schema
 -part                   use default paritioning model if it exists
 -rangepart              use a range paritioning model if it exisits
 -ro                     reverse the order in which data is generated
                         (smallest first)
 -s                      run in silent mode
 -scale <scale>          mulitiplier for default config
 -sp <soft partitions>   the number of softparitions used. Defaults to cpu
                         count
 -tc <thread count>      the number of threads(parallelism) used to
                         generate data. Defaults to cpus*2
 -ts <tablespace>        tablespace to create schema in
 -u <username>           username for benchmark schema
 -v                      run in verbose mode when running from command
                         line
 -version <version>      version of the benchmark to run
 ## Order Entry Schema 생성작업을 수행합니다. 
[oracle@swingbenchserver bin]$ ./oewizard -cl -create -cs //10.0.0.163:1521/FREEPDB1 -u soe -p soepassword -scale 1 -tc 4 -dba "sys as sysdba" -dbap welcome1 -ts TS_SOE_01 -df /opt/oracle/oradata/FREE/FREEPDB1/TS_SOE_01.dbf
SwingBench Wizard
Author  :       Dominic Giles
Version :       2.7.0.1313

Running in Lights Out Mode using config file : ../wizardconfigs/oewizard.xml

Data Generation Runtime Metrics
+-------------------------+-------------+
| Description             | Value       |
+-------------------------+-------------+
| Connection Time         | 0:00:00.002 |
| Data Generation Time    | 0:02:22.450 |
| DDL Creation Time       | 0:01:21.112 |
| Total Run Time          | 0:03:43.569 |
| Rows Inserted per sec   | 111,370     |
| Actual Rows Generated   | 15,828,685  |
| Commits Completed       | 814         |
| Batch Updates Completed | 79,167      |
+-------------------------+-------------+

Validation Report
The schema appears to have been created successfully.

Valid Objects
Valid Tables : 'ORDERS','ORDER_ITEMS','CUSTOMERS','WAREHOUSES','ORDERENTRY_METADATA','INVENTORIES','PRODUCT_INFORMATION','PRODUCT_DESCRIPTIONS','ADDRESSES','CARD_DETAILS'
Valid Indexes : 'PRD_DESC_PK','PROD_NAME_IX','PRODUCT_INFORMATION_PK','PROD_SUPPLIER_IX','PROD_CATEGORY_IX','INVENTORY_PK','INV_PRODUCT_IX','INV_WAREHOUSE_IX','ORDER_PK','ORD_SALES_REP_IX','ORD_CUSTOMER_IX','ORD_ORDER_DATE_IX','ORD_WAREHOUSE_IX','ORDER_ITEMS_PK','ITEM_ORDER_IX','ITEM_PRODUCT_IX','WAREHOUSES_PK','WHS_LOCATION_IX','CUSTOMERS_PK','CUST_EMAIL_IX','CUST_ACCOUNT_MANAGER_IX','CUST_FUNC_LOWER_NAME_IX','ADDRESS_PK','ADDRESS_CUST_IX','CARD_DETAILS_PK','CARDDETAILS_CUST_IX'
Valid Views : 'PRODUCTS','PRODUCT_PRICES'
Valid Sequences : 'CUSTOMER_SEQ','ORDERS_SEQ','ADDRESS_SEQ','LOGON_SEQ','CARD_DETAILS_SEQ'
Valid Code : 'ORDERENTRY'
Schema Created
[oracle@swingbenchserver bin]$
```

테이블, 인덱스, 시퀀스, 뷰등의 오브젝트가 생성되었습니다.
Thread(-tc)를 2개로 1G 데이터를 생성하는데 약 3분 43초가 소요되었습니다.
서버 리소스가 충분하면 Thread를 늘리고 Scale 키우면 됩니다.

### 3. 테이블 및 인덱스 정보 확인(CLI기반)

sbutil를 이용하면 benchmark 데이터의 상태를 확인할수 있습니다.
또한 테이블 및 인덱스, 시퀀스에 대한 변경작업등을 지원합니다. 

- sbutil 기능
  - 데이터 복제작업을 통해 데이터 크기를 늘릴수 있습니다.
  - 인덱스를 생성, 압축, 삭제작업등의 작업을 지원합니다.
  - 테이블 압축 작업을 지원합니다. 
  - 스키마의 상태를 검증할수 있습니다. 
  - 테이블 및 인덱스 정보를 확인할 수 있습니다.
  - 통계정보 생성 및 삭제작업을 수행합니다.

```bash
## sbutil의 다양한 옵션을 확인합니다. 
[oracle@swingbenchserver bin]$ ./sbutil
ERROR : Missing required options: [-soe duplicate and expand data in the SOE schema, -sh duplicate and expand data in the SH schema , -tpcds List and validate tables in the TPC-DS schema, -tpch List and validate tables in the TPC-H schema, -movie List and validate tables in the moviestream schema], p, cs, u is missing or incorrectly specified.
usage: parameters:
 -ac                       use advanced compression on new tables
 -cf <file>                the location of a crendentials file for Oracle
                           Exadata Express
 -ci                       create indexes and constraints
 -cih                      create compressed indexes (high) and
                           constraints
 -cil                      create compressed indexes (low) and constraints
 -code                     reload and recompile needed code
 -cs <connectstring>       connect string
 -debug                    turn on debug information
 -delstats                 purge the stats for the schema
 -di                       drop indexes and constraints
 -dup <duplication>        number of times to duplicate
 -h,--help                 print this message
 -hcc                      use hcc compression on new tables
 -indexes                  display schema\'s indexes info
 -its <tablespace>         index tablespace
 -movie                    List and validate tables in the moviestream
                           schema
 -nc                       use no compression on new tables
 -nic                      don\'t create indexes or constraint after
                           duplication
 -p <password>             password
 -parallel <parallelism>   level of parallelism
 -seq                      recreate needed sequences
 -sh                       duplicate and expand data in the SH schema
 -soe                      duplicate and expand data in the SOE schema
 -sort                     sort the initial seed data
 -stats                    run stats collection for schema
 -tables                   display schema\'s table info
 -tpcds                    List and validate tables in the TPC-DS schema
 -tpch                     List and validate tables in the TPC-H schema
 -ts <tablespace>          tablespace
 -u <username>             specify config file
 -uc                       update the meta data in the soe benchmark
 -val                      validate schema
 ## Order Entry(-soe)의 Table목록을 확인합니다.
[oracle@swingbenchserver bin]$ ./sbutil -u soe -p soepassword -cs //10.0.0.163:1521/FREEPDB1 -soe -tables

Order Entry Schemas Tables
+----------------------+-----------+--------+---------+-------------+--------------+
| Table Name           | Rows      | Blocks | Size    | Compressed? | Partitioned? |
+----------------------+-----------+--------+---------+-------------+--------------+
| ORDER_ITEMS          | 7,112,651 | 66,202 | 520.0MB | Disabled    | No           |
| ORDERS               | 1,429,790 | 25,403 | 200.0MB | Disabled    | No           |
| INVENTORIES          | 900,260   | 22,343 | 176.0MB | Disabled    | No           |
| CUSTOMERS            | 1,000,000 | 19,411 | 153.0MB | Disabled    | No           |
| ADDRESSES            | 1,500,000 | 16,988 | 134.0MB | Disabled    | No           |
| CARD_DETAILS         | 1,500,000 | 11,761 | 93.0MB  | Disabled    | No           |
| LOGON                | 2,382,984 | 8,191  | 65.0MB  | Disabled    | No           |
| WAREHOUSES           | 1,000     | 124    | 1024KB  | Disabled    | No           |
| PRODUCT_INFORMATION  | 1,000     | 124    | 1024KB  | Disabled    | No           |
| PRODUCT_DESCRIPTIONS | 1,000     | 124    | 1024KB  | Disabled    | No           |
| ORDERENTRY_METADATA  | 0         | 0      | 1024KB  | Disabled    | No           |
+----------------------+-----------+--------+---------+-------------+--------------+
                                Total Space     1.3GB
## Order Entry(-soe)의 Index목록을 확인합니다.
[oracle@swingbenchserver bin]$ ./sbutil -u soe -p soepassword -cs //10.0.0.163:1521/FREEPDB1 -soe -indexes
Order Entry Schemas Indexes
+----------------------+-------------------------+---------------------------+---------+--------+--------+--------------+-------------+
| Table Name           | Index Name              | Indexed Columns           | Size    | Status | Levels | Partitioned? | Compression |
+----------------------+-------------------------+---------------------------+---------+--------+--------+--------------+-------------+
| ADDRESSES            | ADDRESS_PK              | ADDRESS_ID                | 26.0MB  | Valid  | 2      | No           | Disabled    |
| ADDRESSES            | ADDRESS_CUST_IX         | CUSTOMER_ID               | 27.0MB  | Valid  | 2      | No           | Disabled    |
| CARD_DETAILS         | CARD_DETAILS_PK         | CARD_ID                   | 26.0MB  | Valid  | 2      | No           | Disabled    |
| CARD_DETAILS         | CARDDETAILS_CUST_IX     | CUSTOMER_ID               | 27.0MB  | Valid  | 2      | No           | Disabled    |
| CUSTOMERS            | CUST_FUNC_LOWER_NAME_IX | SYS_NC00017$,SYS_NC00018$ | 28.0MB  | Valid  | 2      | No           | Disabled    |
| CUSTOMERS            | CUST_EMAIL_IX           | CUST_EMAIL                | 44.0MB  | Valid  | 2      | No           | Disabled    |
| CUSTOMERS            | CUST_DOB_IX             | DOB                       | 22.0MB  | Valid  | 2      | No           | Disabled    |
| CUSTOMERS            | CUST_ACCOUNT_MANAGER_IX | ACCOUNT_MGR_ID            | 17.0MB  | Valid  | 2      | No           | Disabled    |
| CUSTOMERS            | CUSTOMERS_PK            | CUSTOMER_ID               | 17.0MB  | Valid  | 2      | No           | Disabled    |
| INVENTORIES          | INV_WAREHOUSE_IX        | WAREHOUSE_ID              | 15.0MB  | Valid  | 2      | No           | Disabled    |
| INVENTORIES          | INV_PRODUCT_IX          | PRODUCT_ID                | 15.0MB  | Valid  | 2      | No           | Disabled    |
| INVENTORIES          | INVENTORY_PK            | PRODUCT_ID,WAREHOUSE_ID   | 18.0MB  | Valid  | 2      | No           | Disabled    |
| ORDERS               | ORD_WAREHOUSE_IX        | WAREHOUSE_ID,ORDER_STATUS | 29.0MB  | Valid  | 2      | No           | Disabled    |
| ORDERS               | ORD_SALES_REP_IX        | SALES_REP_ID              | 24.0MB  | Valid  | 2      | No           | Disabled    |
| ORDERS               | ORD_ORDER_DATE_IX       | ORDER_DATE                | 37.0MB  | Valid  | 2      | No           | Disabled    |
| ORDERS               | ORD_CUSTOMER_IX         | CUSTOMER_ID               | 26.0MB  | Valid  | 2      | No           | Disabled    |
| ORDERS               | ORDER_PK                | ORDER_ID                  | 25.0MB  | Valid  | 2      | No           | Disabled    |
| ORDER_ITEMS          | ORDER_ITEMS_PK          | ORDER_ID,LINE_ITEM_ID     | 144.0MB | Valid  | 2      | No           | Disabled    |
| ORDER_ITEMS          | ITEM_PRODUCT_IX         | PRODUCT_ID                | 118.0MB | Valid  | 2      | No           | Disabled    |
| ORDER_ITEMS          | ITEM_ORDER_IX           | ORDER_ID                  | 128.0MB | Valid  | 2      | No           | Disabled    |
| PRODUCT_DESCRIPTIONS | PROD_NAME_IX            | TRANSLATED_NAME           | 1024KB  | Valid  | 1      | No           | Disabled    |
| PRODUCT_DESCRIPTIONS | PRD_DESC_PK             | PRODUCT_ID,LANGUAGE_ID    | 1024KB  | Valid  | 1      | No           | Disabled    |
| PRODUCT_INFORMATION  | PROD_SUPPLIER_IX        | SUPPLIER_ID               | 1024KB  | Valid  | 1      | No           | Disabled    |
| PRODUCT_INFORMATION  | PROD_CATEGORY_IX        | CATEGORY_ID               | 1024KB  | Valid  | 1      | No           | Disabled    |
| PRODUCT_INFORMATION  | PRODUCT_INFORMATION_PK  | PRODUCT_ID                | 1024KB  | Valid  | 1      | No           | Disabled    |
| WAREHOUSES           | WHS_LOCATION_IX         | LOCATION_ID               | 1024KB  | Valid  | 1      | No           | Disabled    |
| WAREHOUSES           | WAREHOUSES_PK           | WAREHOUSE_ID              | 1024KB  | Valid  | 1      | No           | Disabled    |
+----------------------+-------------------------+---------------------------+---------+--------+--------+--------------+-------------+
                                                                Total Space    820.0MB
## Order Entry(-soe) 검증작업을 확인합니다. 
[oracle@swingbenchserver bin]$ ./sbutil -u soe -p soepassword -cs //10.0.0.163:1521/FREEPDB1 -soe -val
The Order Entry Schema appears to be valid.
--------------------------------------------------
|Object Type    |     Valid|   Invalid|   Missing|
--------------------------------------------------
|Table          |        10|         0|         0|
|Index          |        26|         0|         0|
|Sequence       |         5|         0|         0|
|View           |         2|         0|         0|
|Code           |         1|         0|         0|
--------------------------------------------------
[oracle@swingbenchserver bin]$ 
```

### 4. Swingbench 실행(CLI기반)

Swingbench로 부하 테스트를 하기 위해서 파라미터 파일(Configiration file)이 필요합니다.
파리미터는 XML파일로 관리되며 샘플 예제를 복사하여 수정하여 사용할수 있습니다. 

#### Configuration 파일 생성

파라미터XML 파일의 경로는 swingbench/configs 폴더입니다.
Order Entry Schema의 예제는 SOE_Server_Side_V2.xml 파일입니다.
SOE_Server_Side_V2.xml파일을 복사하여 사용합니다. 

```bash
[oracle@swingbenchserver bin]$ pwd
/home/oracle/swingbench/bin
[oracle@swingbenchserver bin]$ cd ../configs
[oracle@swingbenchserver configs]$ ls -al
total 1448
drwxr-xr-x.  2 oracle oinstall    4096 Apr 11 10:27 .
drwx------. 12 oracle oinstall     160 May 25 19:08 ..
-rw-r-----.  1 oracle oinstall    5082 Nov  8  2016 Calling_Circle.xml
-rw-r-----.  1 oracle oinstall    6553 Apr 11 10:27 JSON_Workload.xml
-rw-r--r--.  1 oracle oinstall    7766 Feb 20  2023 MovieStream.xml
-rwx------.  1 oracle oinstall    8541 Feb 20  2023 Sales_History.xml
-rwxr--r--.  1 oracle oinstall    6794 Feb 20  2023 SOE_Client_JDBC_Sharded.xml
-rwxr--r--.  1 oracle oinstall    6616 Feb 20  2023 SOE_Client_PLSQL_Sharded.xml
-rw-rw-r--.  1 oracle oinstall    8192 Feb 20  2023 SOE_Client_Side_AC.xml
-rwx------.  1 oracle oinstall    7072 Feb 20  2023 SOE_Client_Side.xml
-rwx------.  1 oracle oinstall    7887 Feb 20  2023 SOE_Server_Side_V1.xml
-rwx------.  1 oracle oinstall    7600 Feb 20  2023 SOE_Server_Side_V2.xml
-rw-r--r--.  1 oracle oinstall    4638 Mar 27  2017 SqlBuilder_Template.xml
-rwx------.  1 oracle oinstall    5564 Feb 20  2023 Stored_Procedure_Stubs.xml
-rwxr--r--.  1 oracle oinstall    4619 Feb 20  2023 Stress_Test.xml
-rw-r--r--.  1 oracle oinstall    5427 Mar 15  2022 TPCDS_Like_Workload.xml
-rw-r--r--.  1 oracle oinstall 1305526 Jan 23  2020 tpcds_statements.xml
-rwxr-xr-x.  1 oracle oinstall    5550 Mar 15  2022 TPCDS_Transactions.xml
-rw-r--r--.  1 oracle oinstall    4466 Mar 15  2022 TPCH_Like_Workload.xml
-rw-r--r--.  1 oracle oinstall   34081 Mar 13  2022 tpch_queries.xml
## 파라미터파일 복사
[oracle@swingbenchserver configs]$ cp SOE_Server_Side_V2.xml SOE_Server_Side_V2_test1.xml
[oracle@swingbenchserver configs]$ ls -al SOE_Server_Side_V2_test1.xml
-rwx------. 1 oracle oinstall 7600 Oct  6 12:05 SOE_Server_Side_V2_test1.xml
[oracle@swingbenchserver configs]$
```
#### DB 접속정보 수정

Configiration 파일에서 6~9번째 줄을 수정하여 DB 접속정보를 변경합니다.

```xml
oracle@swingbenchserver configs]$ vi SOE_Server_Side_V2_test1.xml
  5     <Connection>
  6         <UserName>soe</UserName>
  7         <Password>soepassword</Password>
  8         <ConnectString>//10.0.0.163:1521/FREEPDB1</ConnectString>
  9         <DriverType>Oracle jdbc Driver</DriverType>
```

Configiration 파일에서 25~36번째 줄을 수정하여 사용자유저수와 실행시간을 지정합니다.
사용자수는 10명으로 수행시간은 5분으로 변경하였습니다.

```xml
 24     <Load>
 25         <NumberOfUsers>10</NumberOfUsers> (사용자수)
 26         <MinDelay>0</MinDelay> (트랜잭션내 DML사이의 Min Delay(ms))
 27         <MaxDelay>0</MaxDelay> (트랜잭션내 DML사이의 max delay(ms))
 28         <InterMinDelay>0</InterMinDelay> (트랜잭션간 Min Delay(ms))
 29         <InterMaxDelay>0</InterMaxDelay> (트랜잭션간 max Delay(ms))
 30         <QueryTimeout>120</QueryTimeout>
 31         <MaxTransactions>-1</MaxTransactions>
 32         <RunTime>0:5</RunTime> (실행시간 0:0일경우 중지전까지 계속수행, 0:10일경우 10분후 종료)
 33         <LogonGroupCount>1</LogonGroupCount>
 34         <LogonDelay>20</LogonDelay> (로그인 Delay(ms))
 35         <LogOutPostTransaction>false</LogOutPostTransaction>
 36         <WaitTillAllLogon>false</WaitTillAllLogon> (모든세션이 로그인전까지 부하대기여부)
 37         <StatsCollectionStart>0:0</StatsCollectionStart>
 38         <StatsCollectionEnd>0:0</StatsCollectionEnd>
 39         <ConnectionRefresh>0</ConnectionRefresh>
```

Configiration 파일에서 40~103번째 줄을 수정하여 상세 워크로드를 조정합니다.
Enabled 태그에 true 로 설정된 작업이 수행됩니다.

아래 트랜잭션 명을 보면 DML유형이 추측이 되지만 좀더 명확하게 파악하려면 소스코드를 직적 확인해야합니다. 트랜재션별로 ClassName로 구분되어 있고, Class내에 call되는 function을 확인할수 있습니다.

- 소스링크 : <https://github.com/domgiles/swingbench-public/tree/master/src/com/dom/benchmarking/swingbench/benchmarks/orderentryplsql>
 
swingbench 설치된 폴더내 sql/orderentry/soedgpackage.sql 파일에 orderentry 패키지 생성문이 있으니 Call되는 function명으로 찾으면 DML유형을 파악할수 있습니다. 

- Order Entry 워크로드(OLTP성 write작업이 많습니다. )
  - Customer Registration - 15%, orderentry.newcustomer(insert)
  - Update Customer Details - 10%,  orderentry.updateCustomerDetails(update)
  - Browse Products - 50%  orderentry.browseproducts(select)
  - Order Products - 40%  orderentry.neworder(select & insert)
  - Process Orders - 5%  orderentry.processorders (select & update)
  - Browse Orders - 5% orderentry.browseandupdateorders(select & update)

```xml
 40         <TransactionList>
 41             <Transaction>
 42                 <Id>Customer Registration</Id>
 43                 <ShortName>NCR</ShortName>
 44                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.NewCustomerProcessV2</ClassName>
 45                 <Weight>15</Weight>
 46                 <Enabled>true</Enabled>
 47             </Transaction>
 48             <Transaction>
 49                 <Id>Update Customer Details</Id>
 50                 <ShortName>UCD</ShortName>
 51                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.UpdateCustomerDetailsV2</ClassName>
 52                 <Weight>10</Weight>
 53                 <Enabled>true</Enabled>
 54             </Transaction>
 55             <Transaction>
 56                 <Id>Browse Products</Id>
 57                 <ShortName>BP</ShortName>
 58                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.BrowseProducts</ClassName>
 59                 <Weight>50</Weight>
 60                 <Enabled>true</Enabled>
 61             </Transaction>
 62             <Transaction>
 63                 <Id>Order Products</Id>
 64                 <ShortName>OP</ShortName>
 65                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.NewOrderProcess</ClassName>
 66                 <Weight>40</Weight>
 67                 <Enabled>true</Enabled>
 68             </Transaction>
 69             <Transaction>
 70                 <Id>Process Orders</Id>
 71                 <ShortName>PO</ShortName>
 72                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.ProcessOrders</ClassName>
 73                 <Weight>5</Weight>
 74                 <Enabled>true</Enabled>
 75             </Transaction>
 76             <Transaction>
 77                 <Id>Browse Orders</Id>
 78                 <ShortName>BO</ShortName>
 79                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.BrowseAndUpdateOrders</ClassName>
 80                 <Weight>5</Weight>
 81                 <Enabled>true</Enabled>
 82             </Transaction>
 83             <Transaction>
 84                 <Id>Sales Rep Query</Id>
 85                 <ShortName>SQ</ShortName>
 86                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.SalesRepsOrdersQuery</ClassName>
 87                 <Weight>2</Weight>
 88                 <Enabled>false</Enabled>
 89             </Transaction>
 90             <Transaction>
 91                 <Id>Warehouse Query</Id>
 92                 <ShortName>WQ</ShortName>
 93                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.WarehouseOrdersQuery</ClassName>
 94                 <Weight>2</Weight>
 95                 <Enabled>false</Enabled>
 96             </Transaction>
 97             <Transaction>
 98                 <Id>Warehouse Activity Query</Id>
 99                 <ShortName>WA</ShortName>
100                 <ClassName>com.dom.benchmarking.swingbench.benchmarks.orderentryplsql.WarehouseActivityQuery</ClassName>
101                 <Weight>2</Weight>
102                 <Enabled>false</Enabled>
103             </Transaction>
```

#### Swingbench을 통해 부하발생

Configuration File을 이용하여 부하를 발생시킵니다. 
CLI기반으로 TPS를 확인하기 위하여 charbench를 사용하였습니다.

```bash
[oracle@swingbenchserver configs]$ pwd
/home/oracle/swingbench/configs
[oracle@swingbenchserver configs]$ cd ../bin
## charbench의 다양한 옵션을 확인합니다.
[oracle@swingbenchserver bin]$ ./charbench -h
usage: parameters:
 -a                            run automatically
 -be <stopafter>               end recording statistics after. Value is in
                               the form hh:mm.sec
 -bg                           indicate that charbench will be run in the
                               background
 -bs <startafter>              start recording statistics after. Value is
                               in the form hh:mm.sec
 -c <filename>                 specify config file
 -cf <username>                the location of a crendentials file for
                               Oracle Cloud (ADW/ATP./ExaExp)
 -co <hostname>                specify/override coordinator in
                               configuration file.
 -com <comment>                specify comment for this benchmark run (in
                               double quotes)
 -cpuloc <hostname >           specify/overide location/hostname of the
                               cpu monitor.
 -cpupass <arg>                specify/overide os password of the user
                               used to monitor cpu.
 -cpuuser <arg>                specify/overide os username of the user
                               used to monitor cpu.
 -cs <connectstring>           override connect string in configuration
                               file
 -D <variable=value>           use value for given environment variable
 -dbap <password>              the password of admin user (used for
                               collecting DB Stats)
 -dbau <username>              the username of admin user (used for
                               collecting DB stats)
 -debug                        turn on debugging. Written to standard out
 -debugf <debugfile>           turn on debugging. Write output to
                               <debugfile> defaults to debug.log.
 -debugfine                    turn on finest level of debugging
 -di <shortname(s)>            disable transactions(s) by short name,
                               comma separated
 -dt <drivertype>              override driver type in configuration file
                               (thin, oci, ttdirect, ttclient)
 -dumptx                       output transaction response times to file
 -dumptxdir <directory name>   directory for transaction response times
                               files
 -en <shortname(s)>            enable transactions(s) by short name, comma
                               separated
 -env                          display environment configuration
 -f                            force data collection and run termination
                               regardless of state
 -g <groupID>                  distributed group identifier
 -h,--help                     print this message
 -i                            run interactively (default)
 -intermax <milliseconds>      override minimum inter transaction sleep
                               time (default = 0)
 -intermin <milliseconds>      override minimum inter transaction sleep
                               time (default = 0)
 -ld <milliseconds>            specify/overide the logon delay
                               (milliseconds)
 -max <milliseconds>           override maximum intra transaction think
                               time in configuration file
 -min <milliseconds>           override minimum intra transaction think
                               time in configuration file
 -mr                           produce a mini report of the results of a
                               run
 -mt <maxtrans>                maximum tasks to be executed before
                               terminating run
 -nc                           Don't use color output
 -nr                           don't produce a results file at the end of
                               a run
 -ot <output type>             output type (json or std), defaults to std
 -p <password>                 override password in configuration file
 -P <property=value>           set connection properties. <Key>:<Value>
                               seperated by commas no spaces
 -r <filename>                 specify results file
 -rr <arg>                     specify/overide refresh rate for charts in
                               secs
 -rt <runtime>                 specify/overide run time for the benchmark.
                               Value is in the form hh:mm.sec
 -s                            run silent
 -sr                           Suppress results file output
 -stats <stats level>          specify level result stats detail (full or
                               simple)
 -u <username>                 override username in configuration file
 -uc <user count>              override user count in configuration file.
 -v <options>                  display run statistics (vmstat/sar like
                               output), options include (comma separated
                               no spaces).
                               trans|cpu|disk|dml|errs|tpm|tps|users|resp|
                               vresp|tottx|trem|pool
 -ver                          display version and exit
 -vo <verboseOutput>           output file for verbose output (defaults to
                               stdout)
 -wc                           wait until all session have disconnected
                               from the database
## charbench를 이용하여 부하를 발생시킵니다.
[oracle@swingbenchserver bin]$ ./charbench -c ../configs/SOE_Server_Side_V2_test1.xml -v tpm,tps,users,resp,vresp
Swingbench
Author  :        Dominic Giles
Version :        2.7.0.1313

Results will be written to results.xml
Hit Return to Terminate Run...

Time     TPM      TPS     Users       Response NCR   UCD   BP    OP    PO    BO    SQ    WQ    WA
12:50:43 0        0       [0/10]      0        0     0     0     0     0     0     0     0     0
12:50:44 0        0       [0/10]      0        0     0     0     0     0     0     0     0     0
12:50:45 11       11      [10/10]     60       106   319   1     0     77    58    0     0     0
12:50:46 328      317     [10/10]     33       5     2     2     7     20    6     0     0     0
12:50:47 742      414     [10/10]     24       18    1     18    81    2     1     0     0     0
12:50:48 1233     491     [10/10]     20       2     10    20    57    5     18    0     0     0
12:50:49 1754     521     [10/10]     18       2     5     5     44    18    28    0     0     0
12:50:50 2316     562     [10/10]     17       2     12    15    40    16    27    0     0     0
12:50:51 2849     533     [10/10]     17       26    3     39    90    7     3     0     0     0
12:50:52 3388     539     [10/10]     16       46    0     7     43    26    9     0     0     0
12:50:53 3911     523     [10/10]     16       12    15    17    8     2     1     0     0     0
12:50:54 4527     616     [10/10]     15       4     0     25    7     2     1     0     0     0
12:50:55 5127     600     [10/10]     15       6     1     17    6     3     1     0     0     0
12:50:56 5705     578     [10/10]     15       42    1     1     19    10    11    0     0     0
12:50:57 6342     637     [10/10]     15       21    17    7     28    22    17    0     0     0
12:50:58 6921     579     [10/10]     15       37    32    10    48    3     19    0     0     0
12:50:59 7500     579     [10/10]     14       2     7     12    54    4     19    0     0     0
12:51:00 8082     582     [10/10]     14       5     1     2     28    36    8     0     0     0
12:51:01 8716     634     [10/10]     14       23    27    5     13    4     4     0     0     0
12:51:02 9324     608     [10/10]     14       14    1     12    45    14    21    0     0     0
...

12:55:21 37758    687     [10/10]     11       19    6     1     32    3     9     0     0     0
12:55:22 37765    681     [10/10]     11       6     0     2     10    43    14    0     0     0
12:55:23 37784    666     [10/10]     11       7     14    1     27    3     3     0     0     0
12:55:24 37751    635     [10/10]     11       3     2     23    14    2     1     0     0     0
12:55:25 37793    664     [10/10]     11       3     1     11    51    2     3     0     0     0
12:55:26 37796    679     [10/10]     11       29    5     2     116   10    9     0     0     0
12:55:27 37759    598     [10/10]     11       6     0     2     5     9     16    0     0     0
12:55:28 37805    670     [10/10]     11       7     0     5     18    11    1     0     0     0
12:55:29 37831    700     [10/10]     11       3     10    1     24    13    4     0     0     0
12:55:30 37853    725     [10/10]     11       2     1     3     16    12    17    0     0     0
12:55:31 37828    664     [10/10]     11       3     9     9     22    3     4     0     0     0
12:55:32 37858    702     [10/10]     11       2     0     10    50    2     4     0     0     0
12:55:33 37819    654     [10/10]     11       3     2     22    6     4     10    0     0     0
12:55:34 37815    647     [10/10]     11       4     12    5     36    5     4     0     0     0
12:55:35 37884    692     [10/10]     11       3     4     15    41    4     1     0     0     0
12:55:36 37887    698     [10/10]     11       22    1     5     24    28    2     0     0     0
12:55:37 37896    683     [10/10]     11       7     1     9     10    14    1     0     0     0
12:55:38 37898    701     [10/10]     11       18    15    20    50    3     4     0     0     0
12:55:39 37947    699     [10/10]     11       3     6     4     25    3     2     0     0     0
12:55:40 37940    661     [10/10]     11       26    3     3     26    3     1     0     0     0
12:55:41 37954    677     [10/10]     11       13    2     5     23    3     6     0     0     0
12:55:42 37968    688     [10/10]     11       25    0     4     51    8     2     0     0     0
12:55:43 37909    631     [10/10]     11       5     0     3     11    15    2     0     0     0
Saved results to results.xml
12:55:44 37671    360     [0/10]      11       5     3     25    39    4     3     0     0     0
Completed Run.
## 5분이 지나서 부하 테스트가 완료되었습니다. 부하 결과는 Results.xml파일로 생성됩니다. 
[oracle@swingbenchserver bin]$ ls -arlt
total 80
-rwxr-xr-x.  1 oracle oinstall   121 Nov  2  2016 sqlbuilder
-rwxr-xr-x.  1 oracle oinstall   141 Jul 19  2017 oewizard
-rwxr-xr-x.  1 oracle oinstall   143 Jul 19  2017 jsonwizard
-rwxr-xr-x.  1 oracle oinstall   110 Jul 19  2017 minibench
-rwxr-xr-x.  1 oracle oinstall   141 Jul 19  2017 ccwizard
-rwxr-xr-x.  1 oracle oinstall   114 Jul 19  2017 results2pdf
-rwxr-xr-x.  1 oracle oinstall   107 Jul 19  2017 sbutil
-rwxr-xr-x.  1 oracle oinstall   141 Jul 19  2017 shwizard
-rwxr-xr-x.  1 oracle oinstall   112 Jul 19  2017 swingbench
-rwxr-xr-x.  1 oracle oinstall   150 Jul 19  2017 tpcdswizard
-rwxr-xr-x.  1 oracle oinstall   147 Mar 13  2022 tpchwizard
-rwxr-xr-x.  1 oracle oinstall   195 May  6  2022 coordinator
-rwxr-xr-x.  1 oracle oinstall   150 Jan 14  2023 moviewizard
drwxr-xr-x.  2 oracle oinstall  4096 Feb 14  2023 data
-rwxr-xr-x.  1 oracle oinstall  1134 Apr  5  2023 charbench
drwx------. 12 oracle oinstall   160 May 25 19:08 ..
drwxr-xr-x.  3 oracle oinstall  4096 Oct  6 12:55 .
-rw-r--r--.  1 oracle oinstall 13223 Oct  6 12:55 results.xml <-- 결과파일 생성
[oracle@swingbenchserver bin]$
```

테스트 이후에 results.xml파일이 생성이 되었습니다. 

### 5. 테스트 결과 확인(CLI기반)

results.xml파일은 XML형식으로 결과를 직관적으로 확인하기 어렵습니다. 
results2pdf 도구를 사용하면 xml 파일을 PDF로 변환할수 있습니다. 

```bash
## xml 파일을 PDF 파일로 변환합니다. 
[oracle@swingbenchserver bin]$ ./results2pdf -c results.xml -o result.pdf
Results2Pdf
Author  :        Dominic Giles
Version :        2.7.0.1313
Success : Pdf file result.pdf was created from results.xml results file.
[oracle@swingbenchserver bin]$
```

PDF로 변환된 결과에는 아래와 같은 정보를 제공하고 있습니다. 

- 결과 정보 
  - Benchmark Configuration : 총 수행시간 및 사용자수 확인
    ![](/assets/images/blog/swingbench/swingbench_overview.jpg)
  - Connection Pool Settings : 내부 connection Pool설정 정보
    ![](/assets/images/blog/swingbench/swingbench_connection_pool.jpg)
  - Results Overview : 전체 트랜잭션 건수 및 TPS확인, 시간에 따른 TPS 추이 확인
    ![](/assets/images/blog/swingbench/swingbench_result_overview.jpg)
  - Transaction Results : 각 트랜잭션별 처리건수 및 응답속도 확인 
    ![](/assets/images/blog/swingbench/swingbench_transaction_results.jpg)

## 마무리 

Swingbench 도구에 대해서 알아보았습니다. 테스트 환경이 구성되면 원하는 benchmark 데이터를 선정합니다. oewizard 도구를 통해서 DB유저와 테이블스페이스를 생성하고, Order Entry Schema의 테이블과 데이터를 로딩합니다. 그리고나서 Configuration file을 변경하여 워크로드를 세부적으로 설정하고 charbench 도구를 이용하여 부하테스트를 수행하여 결과를 확인하였습니다.

전체적으로 수행 절차는 어렵지는 않습니다. 여러번 숙지하면 어느 툴보다 간편하게 사용할수 있습니다. 운영환경의 업무를 캡쳐하여 수행할수 있는 상용툴에 비해서 기능이나 요건들이 부족할수 있겠지만 PoC환경이나 부하 테스트용으로 간편하게 사용할수 있을것 같습니다.

## 참고문서

- Swingbench 홈페이지 : <https://www.dominicgiles.com/swingbench.html>
- Swingbnech github : <https://github.com/domgiles/swingbench-public>
