---
layout: single
title: 23c신기능 - SQL Domains
date: 2023-10-26 02:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - 23c
   - SQL Domains
excerpt : 오라클데이터베이스의 신기능인 SQL Domains에 대해서 정리했습니다.
header :
  teaser: /assets/images/blog/oracle23c.jpg
  overlay_image: /assets/images/blog/oracle23c.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스 23c에 추가된 SQL Domain기능에 대해서 설명합니다.
데이터의 사용법과 의도를 관리하기 위한 SQL Domain기능에 대해서 알아보고 예제를 통해 사용법을 알아보겠습니다.

## 데이터 의도(intention)를 파악하자

데이터를 이해하는 방법은 데이터를 직접 조회해서 raw데이터를 보거나, 데이터 타입이나 컬럼명들을 확인하여 유추합니다.
처음에는 애플리케이션이 필요하여 데이터가 저장되었지만, 데이터가 추가되고 커지면서 데이터가 생성된 목적과 의미를 점점 더 파악하기 어려워집니다.
어쩌면 필요없는(활용되지 않는) 데이터가 만들어지고 있을지도 모릅니다. 

업무담당자는 자신이 관리하는 데이터에 대해서 누구보다 잘알고 있지만, 다른 업무와 관련된 데이터는 일부분만 알뿐 모든 데이터를 이해하기에 많는 시간과 노력이 필요합니다.
데이터의 사용목적과 의도를 파악할수 있는 방법을 제공한다면 데이터를 활용하는 측면에 대해서 많은 변화가 있을것입니다. 

대부분의 데이터는 애플리케이션에 의해서 사용이 되고, 데이터를 제공하는 관점, 데이터를 사용하는 관점에서 사용목적 및 의도를 가지고 있습니다.(데이터의 저장 목적은 애플리케이션에 의해서 사용되기 위해서입니다.)

사용목적과 의도를 구분하면 아래와 같습니다.

- 접근 의도(Access Intent):  데이터 저장방식과 무관하게 계층적 객체, 분석 큐브, 속성 그래프등에 접근할수 있습니다. 
- 사용 의도(Usage Intent):  데이터는 신용카드, 전화 번호, 주소, 잔액등과 같이 의도된 사용 용도가 있습니다.
- 스키마 의도(Schema Intent):  종종 컬럼, 테이블, 뷰 등에 의도된 속성을 가집니다. 컬럼 형식, 데이터 민감도, 테이블 표시 이름등이 포함됩니다.
- 유효성 검사 의도(Validation Intent):  데이터 유효성 검사 규칙을 가지고 있습니다. 예를 들어, 주문 객체는 유효한 신용카드 번호를 가져야하고 고객 객체는 유효한 전화번호를 가져야합니다. 

불행하게도, 이러한 의도는 데이터베이스에서 표현하기 어렵습니다. 
데이터베이스 스키마는 표현력이 있지만, 애플리케이션 의도를 완전히 모델링하지 못합니다.  

- 테이블과 외래 키:  테이블과 관계는 데이터 모델의 기본 구성요소이지만 이것만으로는 접근의도를 추론하기 어렵습니다.(데이터 관리도 어렵고, Bundle된 패키지가 아닌이상 실제 업무에서는 외래키를 거의사용안하는것 같습니다. )
- 뷰 : 뷰는 좀더 논리적인 접근 모델을 제공하지만 일반적인 관계형 조인 뷰는 업데이트에 대한 제약이 있으며 수평적이므로 계층 구조를 파악하지 못합니다. 
- 기본 데이터 타입:  CHAR, NUMBER, DATE와 같은 기본 데이터 유형은 효율적이지만 데이터 사용의도를 파악하기 어렵습니다. (숫자인지 문자, 날짜정도의 데이터 특성만 파악가능합니다.)
- 스키마 이름과 주석: 애플리케이션은 종종 명명규칙이나 SQL 주석을 의존할수 있지만. 이름에서 의미를 유추하는것은 오류가 발생하기 쉽고, 표준방식이 아닙니다.

논리적인 모델 설계이후 실제 데이터베이스환경에 적용되기 위하여 물리적 모델으로 변환될때 대부분의 데이터의 사용목적 및 의도는 유지할수 없게 됩니다.
그나마 남아 있는 유의미한 정보는 스키마 이름에서오는 명명규칙에 따른 표현과 주석(Comment)이 될것 같습니다.

## 데이터를 설명하기 위한 새로운 SQL유형(Data Intention Language)

SQL은 대부분 두가지 유형에 속하게 됩니다.
- Data Definition Language (DDL): 메타데이터를 정의하는데 사용됩니다. 예로, CREATE/ALTER TABLE등이 있습니다. 
- Data Manipulation Language (DML):  데이터를 조회하거나 수정하는데 사용됩니다. 예로, INSERT, DELETE, UPDATE등이 있습니다. 

위의 SQL들은 데이터베이스 객체를 정의하기 위한 메타데이터와 데이터를 조작하기 위한 구문들로 데이터의 성질을 표현하기에는 부적합합니다. 
데이터의 사용목적과 의도를 표현할수 있는 새로운 SQL구문이 필요하게 됩니다. 
Oracle 23c에서는 새로운 종류의 SQL구문이 추가되었습니다. 바로 DIL 구문입니다.

- Data Intention Language (DIL): 데이터에 대한 애플리케이션 의도를 정의하는데 사용합니다.

DIL 구문은 실제 데이터를 변경하거나, 기존 메타데이터 정의를 수정하지 않고 기존의 스키마 객체에 추가하는 오버레이 정의(overlay definition) 방식을 가지고 있습니다.
그렇기 때문에 기존 운영환경에 영향없이 DIL을 추가하여 애플리케이션에 활용할수가 있습니다. 

오라클 데이터베이스에서는 아래 4가지 방식으로 DIL를 지원합니다. 
  - CREATE DOMAIN 는 데이터의 의도된 사용법을 선언합니다.
  - ALTER TABLE FOO ANNOTATIONS(...) 는 테이블과 컬럼의 의도된 사용법을 선언합니다.
  - CREATE JSON DUALITY VIEW 는 업데이트 가능한 JSON문서로서 테이블에 접근하는 의도를 선언합니다. RDBMS의 테이블 구조를 유지하면서 JSON방식의 접근방식(Mongo DB API, SQL/JSON)을 허용합니다. 
  - CREATE PROPERTY GRAPH 는 속성그래프로서 테이블에 접근하는 의도를 선언합니다. RDBMS의 테이블 구조를 유지하면서 Graph Query(SQL/PGQ)를 지원합니다.

위 기능중에 본문에서는 먼저 DOMAIN에 대해서 정리해보고자 합니다. 나머지는 추후에 다른 글로 정리하도록 하겠습니다.

## 데이터 설명을 위한 방법들은?

애플리케이션은 데이터를 다양한 방식으로 사용할수 있습니다. 

- 데이터 사용 예시 
  - 신용카드(Credit card), 전화번호(phone number), 주민등록번호(SSN), 생년월일(date of birth), etc.

그러나 대부분 이러한 데이터들은 VARCHAR2, NUMBER, DATE등과 같은 기본 유형을 사용합니다. 
그러므로 데이터베이스는 데이터에 대한 제한된 정보만을 제공할수밖에 없습니다. 
표시하는 방법이나 데이터의 유효성들 애플리케이션 레벨에서 관리됩니다. 

하나의 데이터가 하나의 애플리케이션에서 사용되면 큰 문제 없이 데이터를 잘 사용할수 있겠지만, 
애플리케이션들은 좀더 분산화되고 모듈이 나누어져 개발이 되고 있습니다. 그런 환경에서는 데이터에 대한 표준 관리방법이 더 중요해지게 됩니다.

분산된 환경에서의 데이터 사용의 어려움
- 의도된 데이터 사용법은 애플리케이션 수준의 개념에 머물러 있습니다.
- 사용법은 애플리케이션 계층의 툴과 카탈로그에만 기록됩니다.
- 모듈과 마이크로서비스 사이에 분산될수 있습니다.
- 동일한 데이터를 공유하는 애플리케이션간에 사용법이 일치하지 않거나 사용법에 대한 정보가 소실될수 있습니다.

### 가능한 해결책: 더 많은 내장 데이터타입을 추가

어떻게 하면 데이터를 이해하기 위한 정보를 제공할수 있을까요?
데이터베이스의 기능을 좀더 활용해서 더 많는 데이터 타입을 추가하는것입니다. 

예를 들어 통화(CURRENCY), 온도(TEMPERATURE), 생년월일(DATE_OF_BIRTH) 등과 같은 유형을 추가할수 있습니다.

초기에는 더 많이 데이터를 잘 표현한것으로 생각할수 있습니다. 그러나 새로운 데이터 타입은 애플리케이션의 복잡성을 높이게됩니다.

새로운 데이터타입 추가로 인한 문제점
- 애플리케이션 타입과 불일치 증가됩니다.
- 새로운 타입에 대한 작업이 제한될수 있습니다.
- 예로 온도타입에 숫자를 추가할수 없으므로 CAST를 사용해야합니다. 또한 이로인해 이식 가능하지 않는 SQL이 발생됩니다.

따라서, 애플리케이션은 데이터베이스에서 제공되는 풍부한 데이터 타입을 사용하는것보다 간단한 기본 타입을 사용하게 됩니다.

### 다 나은 접근법 - SQL Domain을 사용

더 나은 접근 방법은 없을까요?  DIL중에 SQL Domain을 사용하는 방법이 있습니다. 

기본 데이터 타입을 변경하지 않으면서 사용 정보와 함께 데이터 정의를 확장할수 있습니다. 
데이터는 여전히 NUMBER, DATE, VARCHAR2등으로 유지되지만 사용 정보를 추가하여 선언할수 있습니다.
SQL 표준의 도메인 개념을 확장하여 데이터 사용법을 나타낼수 있습니다.
SQL Domain은 데이터의 의도된 사용법을 문서화하는것입니다. 필요한 경우 데이터 사용 규칙을 포함할수 있습니다. 예를 들어 유효성 검사 규칙, 표시 규칙, 정렬 규칙등이 있습니다.

Domain을 추가해도 기존 데이터에 대한 작업을 제한하지 않습니다. 앞서 언급했던데로 DIL은 Overlay definition이기 때문입니다. 

SQL Doamin의 특징
- 용도 명시하고 타입을 지정합니다. 
  - 애플리케이션을 위해 데이터 용도 목적을 문서화할수 있습니다.
  - 선택적으로 데이터베이스에서 강제성을 부여합니다.
- 용도 속성을 갖고 재사용 가능한 내장된 객체입니다. 
  - Check 제약조건, 문자 정렬, 사용자 정의 정렬방법을 정의할수 있습니다.
- 애플리케이션수준의 메타데이터에 의존하지 않고 표준화된 작업지원합니다.
  - Mask : 신용카드 번호를 마스킹 표현방법을 정의할수 있니다.
  - Format : 핸드폰 번호와 통화 값의 형식을 지정할수 있습니다.
  - Display : 파이차트에서 사용될수 있도록 컬럼에서 퍼센트 값으로 표시하도록 정의할수 있습니다.

SQL Domain을 사용할 경우 애플리케이션은 자신이 사용하는 데이터를 좀 더 잘 이해할수 있도록 데이터 사용관련된 다양한 메타데이터를 제공합니다.

### SQL Domain 사용법 

SQL Domain에서 사용할수 있는 속성은 아래와 같습니다. 
- data type : NUMBER, VARCHAR2와같은 데이터 타입을 지정 (필수사항)
- default value : INSERT문에 열이 생략되어 삽입될때 사용되는 값
- check constraints : 컬럼에 적용되어야하는 제약조건 절, JSON 스키마도 지정가능 
- collation specification : VARCHAR, CHAR 의 데이터 타입의 도메인에 대한 정렬(비교)
- display : 도메인 컬럼을 보여줄때 사용되는 표시 표현식
- ordering : 주어진 도메인값들을 정렬하거나 비교할때 사용되는 정렬표현식

SQL Domain 생성 문법
```sql
CREATE DOMAIN [IF NOT EXISTS] DomainName AS <Type> 
[ DEFAULT [ON NULL..] <expression>]
[ [NOT] NULL]
[ CONSTRAINT [Name] CHECK (<expression>) ]
[ VALIDATE USING <json_schema_string>]
[ COLLATE collation ]
[ DISPLAY <expression> ]
[ ORDER <expression> ] 
```

SQL Domain 설정예시  - 하나의 컬럼에는 하나의 도메인만 설정가능

```sql
-- email를 위한 myemail_domain 도메인 생성
SQL> create domain if not exists myemail_domain AS VARCHAR2(100)
default on null 'XXXX' || '@missingmail.com'
constraint email_ck CHECK
   (regexp_like (myemail_domain, '^(\S+)\@(\S+)\.(\S+)$'))
display substr(myemail_domain, instr(myemail_domain, '@') + 1)
order substr(myemail_domain, instr(myemail_domain, '@')+1) || substr(myemail_domain, 1, instr(myemail_domain, '@'));

-- 테이블 생성시 컬럼에 myemail_domain 도메인 지정
SQL> create table test (
  id number primary key, 
  email domain myemail_domain
 );

-- 테이블 컬럼에 myemail_domain 도메인 지정 
SQL> alter table test modify (email) add domain myemail_domain;
```

SQL Domain관련 dictionary 테이블
- ALL_DOMAINS - 도메인 목록을 확인
- ALL_DOMAIN_COLS - 도메인이 정의된 컬럼목록을 확인
- ALL_DOMAIN_CONSTRAINTS - 도메인안에 정의된 제약조건을 확인

SQL Domain을 사용한다고 해서 display나 order의 사용법에 강제성이 부여되지 않습니다. (다만 check 제약조건은 도메인이 적용되는 순간 강제성이 부여됩니다.)
애플리케이션에서는 SQL Domain에서 정의된 사용법을 호출할수 있도록 Domain 함수를 사용할수 있습니다.
SQL Domain이 적용된 컬럼에 아래와 같은 함수를 사용하여 Domain에 정의된 정보를 사용할수 있습니다. 

- SQL Domain을 위한 함수
  - DOMAIN_NAME(컬럼명..) : 도메인 이름을 반환
  - DOMAIN_DISPLAY(컬럼명..) : 도메인 표시 표현식을 반환
  - DOMAIN_ORDER(컬럼명..) : 도메인 정렬 표현식을 반환
  - DOMAIN_CHECK(도메인명, 컬럼명/데이터) : 도메인 제약 조건에 만족하는지 확인(true/false 리턴)
  - DOMAIN_CHECK_TYPE(도메인명, 컬럼명/데이터) : 도메인 데이터타입이 맛는지 확인(true/false 리턴)

```sql
-- employee 테이블 생성
SQL> create table employee (
  id number primary key, 
  email varchar2(100)
 );

-- 데이터 입력 2건,  이메일형식이 아닌 데이터(bbb-abc.com)를 입력
SQL> insert into employee values (1,'abc@xyz.com'),(2,'bbb-abc.com');
SQL> commit;

-- 도메인 설정시 bbb-abc.com데이터로 인해서 에러 발생
SQL> alter table employee modify (email) add domain myemail_domain;
*
ERROR at line 1:
ORA-02293: cannot validate (ADMIN.) - check constraint violated
Help: https://docs.oracle.com/error-help/db/ora-02293/

-- 제약 조건 확인해서 에러 발생되는 데이터 확인 
SQL> select id, email, domain_check(myemail_domain, email), domain_check_type(myemail_domain, email)  
from employee;
        ID EMAIL           DOMAIN_CHEC DOMAIN_CHEC
---------- --------------- ----------- -----------
         1 abc@xyz.com     TRUE        TRUE
         2 bbb-abc.com     FALSE       TRUE   <-- 도메인 제약조건에 맞지 않는 데이터임

-- 해당 데이터를 변경 
SQL> update employee set email = 'bbb@abc.com' where id = 2;
SQL> commit;

-- 도메인 설정(설정하는 순간부터 제약조건이 적용됨)
SQL> alter table employee modify (email) add domain myemail_domain;

-- 도메인 함수를 사용하여 도메인여부, 표시방법, 정렬규칙 확인
SQL> select id, email, domain_name(email) isdomain, domain_display(email) display 
  from employee
order by domain_order(email);

        ID EMAIL           ISDOMAIN             DISPLAY
---------- --------------- -------------------- ----------
         1 abc@xyz.com     ADMIN.MYEMAIL_DOMAIN xyz.com
         2 bbb@abc.com     ADMIN.MYEMAIL_DOMAIN abc.com
```

Check 제약조건는 정규표현식으로 작성하기 어려울수 있습니다. 그래서 오라클 데이터베이스내에서는 일반적으로 사용되는 Built-in Domain들을 지원합니다. 

데이터베이스에 기본 지원하는 내장 Domoain 목록

```sql
-- Built-in 도메인을 확인
SQL> select owner, name  from all_domains where BUILTIN = true;
OWNER      NAME
---------- ------------------------------
SYS        CIDR_D
SYS        CREDIT_CARD_NUMBER_D
SYS        DAY_D
SYS        DAY_SHORT_D
SYS        EMAIL_D
SYS        IPV4_ADDRESS_D
SYS        IPV6_ADDRESS_D
SYS        MAC_ADDRESS_D
SYS        MIME_TYPE_D
SYS        MONTH_D
SYS        MONTH_SHORT_D
SYS        NEGATIVE_NUMBER_D
SYS        NON_NEGATIVE_NUMBER_D
SYS        NON_POSITIVE_NUMBER_D
SYS        PHONE_NUMBER_D
SYS        POSITIVE_NUMBER_D
SYS        SHA1_D
SYS        SHA256_D
SYS        SHA512_D
SYS        SSN_D
SYS        SUBNET_MASK_D
SYS        YEAR_D
```

## SQL Domains의 3가지 사용방법

도메인은 하나의 커럼에 지정하거나 여러 컬럼에 하나의 도메인으로 설정할수 있습니다. 
아래 시나리오를 통해서 사용법에 대해서 알아보겠습니다. 

고객정보(customers)이라는 테이블이 있습니다.  
customers 테이블에는 고객아이디(cust_id), 고객명(name) , Email(contact_email) 컬럼을 가지고 있습니다.

```sql
-- 고객관리테이블을 생성
SQL> create table customers (
  cust_id        number         primary key,
  name           varchar2(4000) not null,
  contact_email  varchar2(1000) 
);

-- 데이터 추가
SQL> insert into customers( cust_id, name, contact_email) values ( 1000, 'gildong hong','gildong.hong@example.com');
SQL> commit;

-- 데이터 확인
SQL> col name format a15
SQL> col contact_email format a30
SQL> select cust_id, name, contact_email from customers;
   CUST_ID NAME            CONTACT_EMAIL
---------- --------------- ------------------------------
      1000 gildong hong    gildong.hong@example.com
```

customers 테이블에 다음과 같은 변경사항이 발생되었습니다. 

1. 먼저 contact_email에 유효성 검증이 가능하도록 기능추가해달라는 요청이 왔습니다. email 도메인을 통해서 유효성 검사조건을 추가합니다. 필요하면 사용할수 있도록 display, order 방법에 대해서 같이 정의합니다.
2. 데이터가 들어올때 자동으로 insert시간을 저장해달라는 요청이 왔습니다. insert_timestamp 도메인과 함께 insert_datetime 컬럼을 추가합니다. not null속성을 가지고 default는 systimstamp값을 지정합니다. 필요하면 사용할수 있도록 display방법에 대해서 같이 정의합니다.
3. salary관련 데이터를 저장하도록 컬럼 추가요청이 왔습니다. 글로벌 회사여서 각 region별로 통화코드가 다릅니다. currency 도메인을 추가하여 USD기준으로 정렬하고 통화코드가 보여질수 있도록 display 방법을 정의합니다.
4. address관련 데이터를 저장하도록 컬럼 추가요청이 왔습니다. region마다 address 표현방식과 제약사항이 틀립니다. address 도메인을 추가하여 region 다른 address 제약조건을 정의합니다. 

위 변경사항들을 하나씩 수행하면서 SQL Domain방법에 대해서 살펴보도록 하겠습니다.

### 단일 컬럼에 적용되는 Domain(Single-column Usage Domains) 

단일 컬럼을 하나의 도메인으로 설정하는 예시입니다.
customers 테이블의 contact_email 컬럼에 email 도메인을 설정합니다.
email 도메인은 유효성규칙(check), 표시방법(display), 정렬방법(order)에 대해서 정의합니다.

```sql
-- 이메일 도메인을 생성
SQL> create domain email as varchar2(255)
constraint email_c check (regexp_like (email, '^(\S+)\@(\S+)\.(\S+)$'))
display '---' || substr(email, instr(email, '@')) 
order substr(email, instr(email, '@')+1) || substr(email, 1, instr(email, '@'));

-- 이메일 도메인을 적용
SQL> alter table customers modify ( contact_email domain email );

-- 도메인 적용된 Email의 display 방법을 확인
SQL> col email_display format a30
SQL> select cust_id, name, domain_display(contact_email) email_display from customers;
   CUST_ID NAME            EMAIL_DISPLAY
---------- --------------- ------------------------------
      1000 gildong hong    ---@example.com

```

customers 테이블의 insert_datetime 컬럼을 추가합니다. 
insert시 데이터가 명시적으로 추가되지 않으면 systimestamp값이 들어가도록 정의하고, display방법에 대해서 같이 정의합니다.

```sql
-- insert_timestamp 도메인을 생성
SQL> create domain insert_timestamp as timestamp 
default systimestamp  not null
display to_char(insert_timestamp, 'YYYY-MM-DD HH24:MI:SS:FF3') ;

-- 컬럼을 추가할때 도메인명과 같이 정의합니다. (3가지 방식이 가능)
-- 1) domain의 데이터타입으로 컬럼이 설정됩니다.
SQL> alter table customers add ( insert_datetime domain insert_timestamp );
-- 2) alter table customers add ( insert_datetime insert_timestamp );
-- domain의 데이터타입과 컬럼의 데이터타입이 호환되어야합니다.
-- 3) alter table customers add ( insert_datetime timsestamp domain insert_timestamp );

-- display 확인
SQL> col insert_datetime format a30
SQL> select cust_id, name, 
     domain_display(contact_email) email_display, 
     domain_display(insert_datetime) insert_datetime 
from customers;
   CUST_ID NAME            EMAIL_DISPLAY                  INSERT_DATETIME
---------- --------------- ------------------------------ ------------------------------
      1000 gildong hong    ---@example.com                2023-11-06 03:04:14:787

```

### 여러 컬럼에 적용되는 Domain(Multi-column Usage Domains)

여러개의 컬럼을 하나의 도메인으로 설정하는 예시입니다.
통화는 가격/통화코드/환율등의 값들을 조합하여 사용될수 있습니다. 통화코드는 3자리의 캐릭터문자로 고정되어 있습니다. 
화면에 보여줄때는 통화코드와 가격정보를, 정렬할때 USD달러기준으로 정렬되도록 설정하겠습니다. 

```sql
-- 통화를 위하여 curruncy 도메인을 생성
SQL> create domain currency as (
  amount            as number(10,2),
  iso_currency_code as char(3 char) strict,
  exchange_rate     as number
);

-- 3개의 컬럼을 추가하면서 도메인설정을 같이함.
SQL> alter table customers add (
  total_salary        integer, 
  currency_code     char (3 char),
  usd_exchange_rate number(*,6),
  domain currency ( 
    total_salary, currency_code, usd_exchange_rate 
  ));

SQL> desc customers
Name                   Null?    Type
---------------------- -------- --------------------------------------
CUST_ID                NOT NULL NUMBER
NAME                   NOT NULL VARCHAR2(4000)
CONTACT_EMAIL                   VARCHAR2(1000) ADMIN.EMAIL
INSERT_DATETIME        NOT NULL TIMESTAMP(6) ADMIN.INSERT_TIMESTAMP
TOTAL_SALARY                    NUMBER(38) ADMIN.CURRENCY
CURRENCY_CODE                   CHAR(3 CHAR) ADMIN.CURRENCY
USD_EXCHANGE_RATE               NUMBER(38,6) ADMIN.CURRENCY

-- 데이터를 2건 추가함.
SQL> insert into customers( cust_id, name, contact_email,total_salary,currency_code, usd_exchange_rate) 
values ( 1001, 'chulsu kim','chulsu.kim@example.com', 1000, 'USD', 1), 
( 1002, 'yonghee park','yonghee.park@example.com', 1000000, 'KRW', 0.00074);
SQL> commit;

-- currency 도메인에 정렬방식을 추가
SQL> alter domain currency 
  add order amount * exchange_rate;

-- currency 도메인에 화면 표시 방법을 추가
SQL> alter domain currency 
  add display '(' || iso_currency_code || ')' || 
              round ( amount * exchange_rate, 2 );

-- 데이터를 조회 (USD달러기준정렬)
SQL> select cust_id, name, domain_display(contact_email) email_display, domain_display(insert_datetime) insert_datetime,
       total_salary,
       domain_display ( 
         total_salary, currency_code, usd_exchange_rate 
       ) usd_amount
from   customers
order  by domain_order ( 
  total_salary, currency_code, usd_exchange_rate 
);
CUST_ID NAME                 EMAIL_DISPLAY                  INSERT_DATETIME                TOTAL_SALARY USD_AMOUNT
---------- -------------------- ------------------------------ ------------------------------ ------------ ----------
  1002 yonghee park         ---@example.com                2023-11-06 03:13:43:118             1000000 (KRW)740
  1001 chulsu kim           ---@example.com                2023-11-06 03:13:43:118                1000 (USD)1000
  1000 gildong hong         ---@example.com                2023-11-06 03:13:34:358                     ()
```

### 컬럼값에 따라 선택되는 SQL Domain(Flexible Usage Domains)

도메인은 하나의 컬럼에 설정할수 있습니다. 
데이터의 속성이 나라마다 틀리거나 상태에 따라 변경이 될경우도 있습니다.
예를 들면 주소표현방식은 나라마다 틀릴수가 있습니다. 

특정 컬럼값을 기준으로 도메인을 설정할수 있는 Flexible Domain설정방법을 제공합니다. 

```sql
-- US를 위한 주소 도메인을 생성
SQL> create domain us_address as (
  line_1  as varchar2(255 char) not null,
  town    as varchar2(255 char) not null,
  state   as varchar2(255 char) not null,
  zipcode as varchar2(10 char) not null
) constraint us_address_c check ( 
  regexp_like ( zipcode, '^[0-9]{5}(-[0-9]{4}){0,1}$' ) 
);

-- GB(Greate Britain)를 위한 주소 도메인을 생성(우편변호 표기방식과 not null컬럼이 us_address와 다름)
SQL> create domain gb_address as ( 
  street   as varchar2(255 char) not null,
  locality as varchar2(255 char),
  town     as varchar2(255 char) not null,
  postcode as varchar2(10 char) not null
) constraint gb_postcode_c check (   
  regexp_like ( postcode, '^[A-Z]{1,2}[0-9][A-Z]{0,1} [0-9][A-Z]{2}$' )
);

-- 기본으로 사용되는 주소 도메인을 생성
SQL> create domain global_address as ( 
  line_1   as varchar2(255) not null,
  line_2   as varchar2(255),
  line_3   as varchar2(255),
  line_4   as varchar2(255),
  postcode as varchar2(10)); 
  
-- country_code값에 따라 도메인이 변경됨.
SQL> create flexible domain address (
  line_1, line_2, line_3, line_4, postal_code      
) choose domain using ( 
  country_code varchar2(2 char) 
) from ( case country_code
    WHEN 'GB' THEN gb_address ( line_1, line_2, line_3, postal_code ) -- GB일경우 gb_address를 선택
    WHEN 'US' THEN us_address ( line_1, line_2, line_3, postal_code ) -- US일경우 us_address를 선택
    ELSE global_address ( line_1, line_2, line_3, line_4, postal_code ) -- 기타코드일때 global_address를 선택
  end
);

-- 테이블에 컬럼과 도메인을 추가
SQL> alter table customers add (
  country_code varchar2(2 char) ,
  line_1       varchar2(255 char) ,
  line_2       varchar2(255 char),
  line_3       varchar2(255 char),
  line_4       varchar2(255 char),
  postal_code  varchar2(10 char),
  domain address ( 
    line_1, line_2, line_3,line_4, postal_code 
  ) using ( country_code )
);

-- 데이터를 수정함(나라마다 postal_code가 틀려도 도메인이 잘 적용됨.) 
SQL> update customers set line_1= '10 another road', line_2 ='Las Vegas' , line_3='NV' ,country_code = 'US', postal_code = '87654-3210'  where  cust_id=1001;
SQL> update customers set line_1= '10 Big street' , line_3 ='London' ,country_code = 'GB' , postal_code = 'N1 2LA'  where  cust_id= 1002;
SQL> commit;
```

## 마무리

데이터의 논리적인 모델링을 할때 주제영역, 엔티티, 관계, 식별자, 속성들을 정의합니다.
속성은 업무에 필요한 항목이고 데이터를 저장할수 있는 최소 단위입니다. 

지금까지 설명드린 SQL Domain기능은 데이터 모델링의 속성과 연관될수 있습니다. 
SQL Domain은 현재의 물리적인 테이블 구조나 데이터 변경을 요구하지 않습니다.

공동퇸 데이터 속성을 관리하는것은 데이터의 품질을 높이기 위한 가장 기본적인 방법이 될것이고, 
이후 신뢰성 있고 예측 가능한 시스템을 구축하고 유지하기 위한 중요한 정보가 될것입니다. 

미래의 데이터베이스는 데이터의 정보를 얼마나 잘 표현하는지가 중요한 요소가 될것입니다.
Generative AI이 LLM학습모델로 자연어를 처리하듯이,
데이터를 잘 이해시키기 위한 메타데이터를 제공하고 Low-code 플랫폼과 연계된다면 더 생산적인 애플리케이션 개발이 가능해질 것입니다.

## 참고자료

- [Domains in Oracle Database 23c](https://oracle-base.com/articles/23c/domains-23c){: target="_blank"}
- [Less coding using new SQL Domains in 23c](https://blogs.oracle.com/coretec/post/less-coding-with-sql-domains-in-23c){: target="_blank"}
- [Registering Application Data Usage with the Database](https://docs.oracle.com/en/database/oracle/oracle-database/23/adfns/registering-application-data-usage-database.html#GUID-6F630041-B7AE-4183-9F97-E54682CA6319){: target="_blank"}