---
layout: single
title: Sample Schema 생성방법
date: 2023-12-13 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - Sample Schema
excerpt : 오라클이 제공하는 Sample Schema생성방법에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

SCOTT유저의 EMP테이블, DEPT테이블을 보신적이 있죠?
이러한 테이블들을 오라클 데이터베이스에서 제공하는 Sample Schemas의 한 예입니다. 
좀더 업무적인 역할을 구분하고 여러개의 Schema를 제공하고 있습니다. 

설치 절차에 대해서 알아보도록 하겠습니다.

## Sample Schemas 소개

오라클 데이터베이스의 Sample Schemas은 github에 공개되어 있습니다. 오라클 데이터베이스 19c이상 설치가능합니다.

- Oracle Database Sample Schemas 23c(lastest) 다운로드 위치 : <https://github.com/oracle-samples/db-sample-schemas/releases>{: target="_blank"}

Sample Schema의 Diagrams은 아래 메뉴얼에서 확인할수 있습니다. 
- [Introduction to Sample Schemas](https://docs.oracle.com/en/database/oracle/oracle-database/19/comsc/toc.htm){: target="_blank"}

Sample Schemas는 아래와 같은 스키마들을 가지고 있습니다.
- HR: Human Resources 
- CO: Customer Orders
- SH: Sales History (adb에 생성되어있음)
- OE: Order Entry (archived)
- PM: Product Media (archived)
- BI: Business Intelligence (archived)

최근 개선점은 아래와 같습니다. 
- 모든 데이터세트가 새로 수정되었습니다.
- 스키마는 서로 독립적으로 설치가 됩니다.
- SYS/SYSTEM 사용자 계정 접근이 필요하지 않습니다.
- SQL*Loader 는 더이상 필요하지 않습니다.

## HR 스키마 (Human Resource Sample) 생성방법

HR스키마는 인적관리 시스템의 한예입니다. 
직원정보, 부서정보, 조직내 직무정보로 저장되고, 부서는 특정 지역에 위치해 있습니다. 

```sql
-- 스키마설치파일 압축해제
unzip db-sample-schemas-23.2.zip
cd human_resources

-- SQLcl 혹은 SQL Plus로 접속하여 설치
-- SQLcl는 인터넷에서 다운받음(JAVA 11이상필요)
$> sql /nolog
SQLcl: Release 23.2 Production on Fri Nov 10 11:31:17 2023
Copyright (c) 1982, 2023, Oracle.  All rights reserved.
-- autonomous db에서는 wallet파일을 설정합니다.
--SQL> set cloudconfig <directory>/Wallet_XX.zip
SQL> connect admin/<password>@<tnsname>
Connected.

-- HR스키마 설치 
SQL> @hr_install.sql

Thank you for installing the Oracle Human Resources Sample Schema.
This installation script will automatically exit your database session
at the end of the installation or if any error is encountered.
The entire installation will be logged into the 'hr_install.log' log file.
Enter a password for the user HR: <password>
Enter a tablespace for HR [DATA]:
Do you want to overwrite the schema, if it already exists? [YES|no]:
******  Creating REGIONS table ....
(생략)
Installation
-------------
Verification:

Table         provided     actual
----------- ---------- ----------
regions              5          5
countries           25         25
departments         27         27
locations           23         23
employees          107        107
jobs                19         19
job_history         10         10

Thank you!
--------------------------------------------------------
The installation of the sample schema is now finished.
Please check the installation verification output above.

You will now be disconnected from the database.

Thank you for using Oracle Database!

-- 삭제할경우
SQL> @hr_uninstall.sql
```
## 마무리

오라클 메뉴얼에 있는 많은 예제들은 Sample Schema를 기반으로 작성되어 있습니다. Sample Schema설치절차를 활용하시면 좀더 쉽게 테스트를 할수 있습니다.

## 관련문서

- Documents
  - [Introduction to Sample Schemas](https://docs.oracle.com/en/database/oracle/oracle-database/19/comsc/toc.htm){: target="_blank"}
- Github 
  - [Oracle Database Sample Schemas 23c](https://github.com/oracle-samples/db-sample-schemas/releases){: target="_blank"}