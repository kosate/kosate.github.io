---
layout: single
title: Oracle Database 23c Free 설치 방법(Linux RPM)
date: 2023-09-19 02:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - 23c
excerpt : 오라클데이터베이스 23c Free버전을 설치하는 방법에 대해서 정리했습니다.
header :
  teaser: /assets/images/blog/oracle23c.jpg
  overlay_image: /assets/images/blog/oracle23c.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클에서 Oracle Database Free버전을 2023년 4월에 처음 출시했습니다. 
그리고 2023년 9월에 클라우드서비스와 같이 업그레이드 버전(23.3)이 출시되었습니다. 
Oracle Database 23c은 프로덕트환경용으로 아직 정식으로 출시되지 않았지만, 소규모 시스템에서 Oracle Database 23c Free버전을 사용해볼수 있을것 같습니다. 

Oracle Database 23c Free 설치 방법에 대해서 알아보겠습니다. 

## 리소스 제약

Oracle Database Free버전은 웹에서 직접 다운로드 받아서 설치할수 있습니다. 
아무래도 Free로 제공되는 버전이어서 리소스 제약과 오라클 지원(Support) 제약을 가지고 있습니다. 
(이전에 무료로 제공했던 Oracle Express Edition버전의 제약과 거의 비슷합니다.)

- 리소스 제약
  - CPU 제약 : 2 CPUs(2 Threads), Forground Proccess의 갯수 제약
  - Memory 제약 : 2 GB (SGA 및 PGA포함)
  - User Data 제약 : 12 GB (데이터가 초과되면 ORA-12954: The request exceeds the maximum allowed database size of 12 GB 에러가 발생됩니다.)

- 오라클 지원 제약
  - 서비스요청을 할수 없음 
  - 패치는 제공되지 않음.
  - Commnutiry Forum에서 질문가능([Oracle Database Free Forum](https://forums.oracle.com/ords/apexds/domain/dev-community/category/oracle-database-free))

- 오라클 기능 제약
  - [Database Licensing Information User Manual 참조](https://docs.oracle.com/en/database/oracle/oracle-database/23/dblic/Licensing-Information.html#GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4)메뉴얼에서 Free 에 해당되는 기능을 사용할수 있습니다.
    - 상당부분의 옵션을 무료로 사용할수 있습니다.(Partioning, Diagnostic & Tunning Pack, Compression, Security, In-Memory, SQL firewall, Spatial & graph등 )
    - 주로 가용성기능의 대해서는 제약이 있습니다.(Active DataGuard, Real Application Testing, Real Application Cluster)

## 설치 환경

Oracle Database Free버전을 설치하기 위한 RPM패키지나 VM이미지를 제공하고 있습니다. 

- 설치 파일 정보 
  - docker 이미지 제공 
  - Virtual Box 이미지 제공
  - Linux RPM 제공 (Oracle Linux 8, Redhat 호환Linux환경)

- 참조문서<https://www.oracle.com/database/free/get-started/#installing>

※ 윈도우에서는 Docker이미지 혹은 Virutal box이미지를 사용해야합니다. (아직 윈도우에서 설치버전은 출시되지 않았습니다. )

여기에서는 Oracle Linux 8 환경에서 Linux RPM을 이용하여 Oracle Database를 설치하는 방법에 대해서 알아보겠습니다.

## 설치 절차(Linux RPM이용)

Oracle Linux 8이 설치된 환경에서 설치 작업을 시작하겠습니다.

- 설치 절차 
  1. OS 환경 설정(Oracle유저 및 커널값변경) (dnf -y localinstall oracle-database-preinstall-23c-1.0-1.el8.x86_64.rpm)
  2. Linux RPM 다운로드 및 설치(yum -y localinstall oracle-database-free*)
  3. 23c DB 생성 (/etc/init.d/oracle-free-23c configure)
 
### 1. OS 환경 설정(Oracle유저 및 커널값변경)

Oracle Database설치를 위한 OS 유저와 커널 파라미터 설정이 필요합니다. 
Linux RPM에는 Oracle Database설치를 위한 preinstall rpm을 제공합니다. 

```bash
## preinstall 패키지를 다운로드 받습니다.
[root@freedbserver ~]# curl -L -o oracle-database-preinstall-23c-1.0-1.el8.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL8/developer/x86_64/getPackage/oracle-database-preinstall-23c-1.0-1.el8.x86_64.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 31212  100 31212    0     0   179k      0 --:--:-- --:--:-- --:--:--  178k
## preinstall 패키지를 실행하여 환경설정을 합니다.
[root@freedbserver ~]# dnf -y localinstall oracle-database-preinstall-23c-1.0-1.el8.x86_64.rpm
Last metadata expiration check: 0:26:38 ago on Fri 22 Sep 2023 07:12:00 AM GMT.
Dependencies resolved.
================================================================================================================
 Package                                 Architecture       Version                    Repository          Size
================================================================================================================
Installing:
 oracle-database-preinstall-23c          x86_64             1.0-1.el8                  @commandline        30 k
Installing dependencies:
 compat-openssl10                        x86_64             1:1.0.2o-4.el8_6           ol8_appstream      1.1 M
 ksh                                     x86_64             20120801-257.0.1.el8       ol8_appstream      929 k
 libICE                                  x86_64             1.0.9-15.el8               ol8_appstream       74 k
 libSM                                   x86_64             1.2.3-1.el8                ol8_appstream       47 k
 libX11-xcb                              x86_64             1.6.8-5.el8                ol8_appstream       14 k
 libXcomposite                           x86_64             0.4.4-14.el8               ol8_appstream       28 k
 libXi                                   x86_64             1.7.10-1.el8               ol8_appstream       49 k
 libXinerama                             x86_64             1.1.4-1.el8                ol8_appstream       15 k
 libXmu                                  x86_64             1.1.3-1.el8                ol8_appstream       75 k
 libXrandr                               x86_64             1.5.2-1.el8                ol8_appstream       34 k
 libXt                                   x86_64             1.1.5-12.el8               ol8_appstream      185 k
 libXtst                                 x86_64             1.2.3-7.el8                ol8_appstream       22 k
 libXv                                   x86_64             1.0.11-7.el8               ol8_appstream       20 k
 libXxf86dga                             x86_64             1.1.5-1.el8                ol8_appstream       26 k
 libXxf86misc                            x86_64             1.0.4-1.el8                ol8_appstream       23 k
 libXxf86vm                              x86_64             1.1.4-9.el8                ol8_appstream       19 k
 libdmx                                  x86_64             1.1.4-3.el8                ol8_appstream       22 k
 xorg-x11-utils                          x86_64             7.5-28.el8                 ol8_appstream      136 k
 xorg-x11-xauth                          x86_64             1:1.0.9-12.el8             ol8_appstream       39 k

Transaction Summary
================================================================================================================
Install  20 Packages

Total size: 2.9 M
Total download size: 2.8 M
Installed size: 7.9 M
Downloading Packages:
(1/19): libICE-1.0.9-15.el8.x86_64.rpm                       769 kB/s |  74 kB     00:00
(2/19): ksh-20120801-257.0.1.el8.x86_64.rpm                  6.6 MB/s | 929 kB     00:00
(3/19): compat-openssl10-1.0.2o-4.el8_6.x86_64.rpm           6.8 MB/s | 1.1 MB     00:00
(4/19): libSM-1.2.3-1.el8.x86_64.rpm                         464 kB/s |  47 kB     00:00
(5/19): libX11-xcb-1.6.8-5.el8.x86_64.rpm                    202 kB/s |  14 kB     00:00
(6/19): libXcomposite-0.4.4-14.el8.x86_64.rpm                480 kB/s |  28 kB     00:00
(7/19): libXi-1.7.10-1.el8.x86_64.rpm                        635 kB/s |  49 kB     00:00
(8/19): libXmu-1.1.3-1.el8.x86_64.rpm                        859 kB/s |  75 kB     00:00
(9/19): libXinerama-1.1.4-1.el8.x86_64.rpm                    88 kB/s |  15 kB     00:00
(10/19): libXrandr-1.5.2-1.el8.x86_64.rpm                    166 kB/s |  34 kB     00:00
(11/19): libXt-1.1.5-12.el8.x86_64.rpm                       1.1 MB/s | 185 kB     00:00
(12/19): libXtst-1.2.3-7.el8.x86_64.rpm                      166 kB/s |  22 kB     00:00
(13/19): libXv-1.0.11-7.el8.x86_64.rpm                       295 kB/s |  20 kB     00:00
(14/19): libXxf86dga-1.1.5-1.el8.x86_64.rpm                  419 kB/s |  26 kB     00:00
(15/19): libXxf86misc-1.0.4-1.el8.x86_64.rpm                 332 kB/s |  23 kB     00:00
(16/19): libXxf86vm-1.1.4-9.el8.x86_64.rpm                   327 kB/s |  19 kB     00:00
(17/19): libdmx-1.1.4-3.el8.x86_64.rpm                       354 kB/s |  22 kB     00:00
(18/19): xorg-x11-xauth-1.0.9-12.el8.x86_64.rpm              687 kB/s |  39 kB     00:00
(19/19): xorg-x11-utils-7.5-28.el8.x86_64.rpm                884 kB/s | 136 kB     00:00
---------------------------------------------------------------------------------------------
Total                                                        3.8 MB/s | 2.8 MB     00:00
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                      1/1
  Installing       : libXi-1.7.10-1.el8.x86_64                           1/20
  Installing       : libICE-1.0.9-15.el8.x86_64                          2/20
  Installing       : libSM-1.2.3-1.el8.x86_64                            3/20
  Installing       : libXt-1.1.5-12.el8.x86_64                           4/20
  Installing       : libXmu-1.1.3-1.el8.x86_64                           5/20
  Installing       : xorg-x11-xauth-1:1.0.9-12.el8.x86_64                6/20
  Installing       : libXtst-1.2.3-7.el8.x86_64                          7/20
  Installing       : libdmx-1.1.4-3.el8.x86_64                           8/20
  Installing       : libXxf86vm-1.1.4-9.el8.x86_64                       9/20
  Installing       : libXxf86misc-1.0.4-1.el8.x86_64                    10/20
  Installing       : libXxf86dga-1.1.5-1.el8.x86_64                     11/20
  Installing       : libXv-1.0.11-7.el8.x86_64                          12/20
  Installing       : libXrandr-1.5.2-1.el8.x86_64                       13/20
  Installing       : libXinerama-1.1.4-1.el8.x86_64                     14/20
  Installing       : libXcomposite-0.4.4-14.el8.x86_64                  15/20
  Installing       : libX11-xcb-1.6.8-5.el8.x86_64                      16/20
  Installing       : xorg-x11-utils-7.5-28.el8.x86_64                   17/20
  Installing       : ksh-20120801-257.0.1.el8.x86_64                    18/20
  Running scriptlet: ksh-20120801-257.0.1.el8.x86_64                    18/20
  Installing       : compat-openssl10-1:1.0.2o-4.el8_6.x86_64           19/20
  Running scriptlet: compat-openssl10-1:1.0.2o-4.el8_6.x86_64           19/20
  Installing       : oracle-database-preinstall-23c-1.0-1.el8.x86_64    20/20
  Running scriptlet: oracle-database-preinstall-23c-1.0-1.el8.x86_64    20/20
  Verifying        : compat-openssl10-1:1.0.2o-4.el8_6.x86_64            1/20
  Verifying        : ksh-20120801-257.0.1.el8.x86_64                     2/20
  Verifying        : libICE-1.0.9-15.el8.x86_64                          3/20
  Verifying        : libSM-1.2.3-1.el8.x86_64                            4/20
  Verifying        : libX11-xcb-1.6.8-5.el8.x86_64                       5/20
  Verifying        : libXcomposite-0.4.4-14.el8.x86_64                   6/20
  Verifying        : libXi-1.7.10-1.el8.x86_64                           7/20
  Verifying        : libXinerama-1.1.4-1.el8.x86_64                      8/20
  Verifying        : libXmu-1.1.3-1.el8.x86_64                           9/20
  Verifying        : libXrandr-1.5.2-1.el8.x86_64                       10/20
  Verifying        : libXt-1.1.5-12.el8.x86_64                          11/20
  Verifying        : libXtst-1.2.3-7.el8.x86_64                         12/20
  Verifying        : libXv-1.0.11-7.el8.x86_64                          13/20
  Verifying        : libXxf86dga-1.1.5-1.el8.x86_64                     14/20
  Verifying        : libXxf86misc-1.0.4-1.el8.x86_64                    15/20
  Verifying        : libXxf86vm-1.1.4-9.el8.x86_64                      16/20
  Verifying        : libdmx-1.1.4-3.el8.x86_64                          17/20
  Verifying        : xorg-x11-utils-7.5-28.el8.x86_64                   18/20
  Verifying        : xorg-x11-xauth-1:1.0.9-12.el8.x86_64               19/20
  Verifying        : oracle-database-preinstall-23c-1.0-1.el8.x86_64    20/20

Installed:
  compat-openssl10-1:1.0.2o-4.el8_6.x86_64    ksh-20120801-257.0.1.el8.x86_64    
  libICE-1.0.9-15.el8.x86_64                  libSM-1.2.3-1.el8.x86_64            
  libX11-xcb-1.6.8-5.el8.x86_64               libXcomposite-0.4.4-14.el8.x86_64           
  libXi-1.7.10-1.el8.x86_64                   libXinerama-1.1.4-1.el8.x86_64                     
  libXmu-1.1.3-1.el8.x86_64                   libXrandr-1.5.2-1.el8.x86_64
  libXt-1.1.5-12.el8.x86_64                   libXtst-1.2.3-7.el8.x86_64         
  libXv-1.0.11-7.el8.x86_64                   libXxf86dga-1.1.5-1.el8.x86_64      
  libXxf86misc-1.0.4-1.el8.x86_64             libXxf86vm-1.1.4-9.el8.x86_64               
  libdmx-1.1.4-3.el8.x86_64                   oracle-database-preinstall-23c-1.0-1.el8.x86_64    
  xorg-x11-utils-7.5-28.el8.x86_64            xorg-x11-xauth-1:1.0.9-12.el8.x86_64

Complete!
## oracle OS유저가 생성된것을 확인합니다. 
[root@freedbserver ~]# cat /etc/passwd
oracle:x:54321:54321::/home/oracle:/bin/bash
[root@freedbserver ~]#
```
Oracle DB유저가 생성된것을 확인할수 있습니다.

### 2. RPM 다운로드 및 설치

Oracle Database 23c Free설치를 위한 RPM을 다운로드합니다.
아래 참조문서에서 Free RPM의 경로를 확인할수 있습니다. 

- 참조문서 <https://www.oracle.com/database/free/get-started/#installing>

RPM이 다운로드되면 설치 작업을 수행합니다. (RPM 크기는 약 1.6G입니다.)

```bash
## RPM 다운로드를 합니다.
[root@freedbserver ~]# curl -L -o oracle-database-free-23c-1.0-1.el8.x86_64.rpm https://download.oracle.com/otn-pub/otn_software/db-free/oracle-database-free-23c-1.0-1.el8.x86_64.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100   509  100   509    0     0    944      0 --:--:-- --:--:-- --:--:--   944
100 1670M  100 1670M    0     0  66.3M      0  0:00:25  0:00:25 --:--:-- 66.0M

## RPM 설치 작업수행을 수행합니다.
[root@freedbserver ~]# dnf -y localinstall oracle-database-free-23c-1.0-1.el8.x86_64.rpm
Last metadata expiration check: 0:35:27 ago on Fri 22 Sep 2023 07:12:00 AM GMT.
Dependencies resolved.
========================================================================================================
 Package                             Architecture      Version            Repository               Size
========================================================================================================
Installing:
 oracle-database-free-23c            x86_64            1.0-1              @commandline            1.6 G

Transaction Summary
========================================================================================================
Install  1 Package

Total size: 1.6 G
Installed size: 4.0 G
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                 1/1
  Running scriptlet: oracle-database-free-23c-1.0-1.x86_64                                           1/1
  Installing       : oracle-database-free-23c-1.0-1.x86_64                                           1/1
  Running scriptlet: oracle-database-free-23c-1.0-1.x86_64                                           1/1
[INFO] Executing post installation scripts...
[INFO] Oracle home installed successfully and ready to be configured.
To configure Oracle Database Free, optionally modify the parameters in '/etc/sysconfig/oracle-free-23c.conf' and then run '/etc/init.d/oracle-free-23c configure' as root.

  Verifying        : oracle-database-free-23c-1.0-1.x86_64                                           1/1

Installed:
  oracle-database-free-23c-1.0-1.x86_64

Complete!
[root@freedbserver ~]#

```

### 3. 23c DB 설치

RPM을 설치되면 DB를 설치를 위하여 "/etc/init.d/oracle-free-23c" 파일이 생성됩니다.
파일내용을 변경하면 데이터베이스이름과 설치 위치를 변경할수 있습니다. 
/etc/init.d/oracle-free-23c confgiure 명령어를 통해서 DB유저 패스워드 및 리스너 설정, DB생성작업이 수행됩니다.

```bash
## DB 설치 환경을 확인합니다.
[opc@freedbserver ~]$ cat /etc/init.d/oracle-free-23c
...

# DB defaults
export ORACLE_HOME=/opt/oracle/product/23c/dbhomeFree
export ORACLE_SID=FREE
export TEMPLATE_NAME=FREE_Database.dbc
export PDB_NAME=FREEPDB1
export LISTENER_NAME=LISTENER
export NUMBER_OF_PDBS=1
export CREATE_AS_CDB=true

## DB 설치 작업을 수행합니다. 패스워드에 대해서는 prompt에 입력해야합니다.
[root@freedbserver ~]# /etc/init.d/oracle-free-23c configure
Specify a password to be used for database accounts. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9]. Note that the same password will be used for SYS, SYSTEM and PDBADMIN accounts: <패스워드 입력>
Confirm the password: <패스워드 입력>
Configuring Oracle Listener.
Listener configuration succeeded.
Configuring Oracle Database FREE.
Enter SYS user password:
*************
Enter SYSTEM user password:
*************
Enter PDBADMIN User Password:
*************
Prepare for db operation
7% complete
Copying database files
29% complete
Creating and starting Oracle instance
30% complete
33% complete
36% complete
39% complete
43% complete
Completing Database Creation
47% complete
49% complete
50% complete
Creating Pluggable Databases
54% complete
71% complete
Executing Post Configuration Actions
93% complete
Running Custom Scripts
100% complete
Database creation complete. For details check the logfiles at:
 /opt/oracle/cfgtoollogs/dbca/FREE.
Database Information:
Global Database Name:FREE
System Identifier(SID):FREE
Look at the log file "/opt/oracle/cfgtoollogs/dbca/FREE/FREE.log" for further details.

Connect to Oracle Database using one of the connect strings:
     Pluggable database: freedbserver/FREEPDB1
     Multitenant container database: freedbserver
[root@freedbserver ~]#

```
### 4. 설치 환경 확인

먼저 프로세스를 확인해보겠습니다.  LISTENER와 PMON이 실행되고 있는것을 확인할수 있습니다. 
```bash
[root@freedbserver ~]# ps -ef| grep tns
root           6       2  0 07:09 ?        00:00:00 [netns]
oracle     67702       1  0 07:53 ?        00:00:00 /opt/oracle/product/23c/dbhomeFree/bin/tnslsnr LISTENER -inherit
[root@freedbserver ~]# ps -ef| grep pmon
oracle     73210       1  0 08:00 ?        00:00:00 db_pmon_FREE
[root@freedbserver ~]#
```
Oracle Home은 "/opt/oracle/product/23c/dbhomeFree" 입니다.(Oracle Home을 변경하고 싶을경우 앞서 설정파일에서 변경하여 설치하면 됩니다 )

DB에 접속해보겠습니다.
먼저 Oracle 유저로 변경후에 SID 및 Path를 설정하여 DB에 접속합니다.
23.3버전으로 설치가 되어 있습니다.  

```sql
[root@freedbserver ~]# su - oracle
Last login: Fri Sep 22 07:53:05 GMT 2023
[oracle@freedbserver ~]$ . oraenv
ORACLE_SID = [oracle] ? FREE
The Oracle base has been set to /opt/oracle
[oracle@freedbserver ~]$ sqlplus "/as sysdba"

SQL*Plus: Release 23.0.0.0.0 - Production on Fri Sep 22 08:04:29 2023
Version 23.3.0.23.09

Copyright (c) 1982, 2023, Oracle.  All rights reserved.

Connected to:
Oracle Database 23c Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
Version 23.3.0.23.09
-- PDB목록 확인
SQL> show pdbs

    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 FREEPDB1                       READ WRITE NO
-- SGA영역 확인
SQL> show sga

Total System Global Area 1603679416 bytes
Fixed Size                  5313720 bytes
Variable Size             402653184 bytes
Database Buffers         1191182336 bytes
Redo Buffers                4530176 bytes
-- 메모리 할당확인
SQL> show parameter target

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
pga_aggregate_target                 big integer 512M
sga_target                           big integer 1536M
SQL>
```

```bash
## 리스너 포트를 확인합니다. 
[oracle@freedbserver ~]$ lsnrctl status LISTENER

LSNRCTL for Linux: Version 23.0.0.0.0 - Production on 22-SEP-2023 08:07:59

Copyright (c) 1991, 2023, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=freedbserver)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 23.0.0.0.0 - Production
Start Date                22-SEP-2023 07:53:05
Uptime                    0 days 0 hr. 14 min. 54 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           FREE
Listener Parameter File   /opt/oracle/product/23c/dbhomeFree/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/freedbserver/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=freedbserver.subnet.vcn.oraclevcn.com)(PORT=1521)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1521)))
Services Summary...
Service "05ef01a1ac931f01e063a300000ab337" has 1 instance(s).
  Instance "FREE", status READY, has 1 handler(s) for this service...
Service "FREE" has 1 instance(s).
  Instance "FREE", status READY, has 1 handler(s) for this service...
Service "FREEXDB" has 1 instance(s).
  Instance "FREE", status READY, has 1 handler(s) for this service...
Service "freepdb1" has 1 instance(s).
  Instance "FREE", status READY, has 1 handler(s) for this service...
The command completed successfully
[oracle@freedbserver ~]$
```
## 마무리

Oracle Database Free는 리소스의 제약은 있지만 무료로 운영혹은 테스트환경에 사용할수 있는 버전입니다. 아직 23c의 프로덕션 버전이 나오지 않았지만, Oracle의 23c새로운 기능들을 미리 테스트해볼수 있을것 같습니다.

## 참고문서

- [Oracle Database Free](https://www.oracle.com/database/free/)
- [Introducing Oracle Database 23c Free – Developer Release](https://blogs.oracle.com/database/post/oracle-database-23c-free)