---
layout: single
title: SQL 신기능 (12.1)
date: 2024-06-07 15:00
categories: 
  - Oracle 
author: 
tags: 
   - Oracle  
   - SQL
   - PL/SQL
   - new feature
excerpt : 오라클 데이터베이스 SQL 신기능(12cR1 기준)에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/writing1.jpg
  overlay_image: /assets/images/blog/writing1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

오라클 12c는 2013년 정도에 출시되었습니다. (약 11년 전이네요 )
SQL기능에 대해서 이미 잘알고 사용할 수도 있지만, 업무에 집중하다보면 간편한 기능이 있음에도 불구하고 모르고 있는경우가 있습니다.

오라클 데이터베이스 12cR1기준으로 새로 추가된 SQL 기능에 대해서 간략적으로 정리하였습니다.

## SQL 신기능 (12cR1)

오라클 12cR1버전의 SQL 개선사항은 아래와 같습니다. 

1. VARCHAR2 최대 크기가 32k까지 확장
2. IDENTITY 컬럼 (ISO SQL Standard)
3. Row Limit OFFSET 절과 FETCH FIRST 절
4. SQL의 With절에 PL/SQL 함수 작성

SQL 개선사항 별로 프레젠테이션 모드로 간단하게 알아보겠습니다.

{% include pptstart.html id="sql12r1 stretch" style="height:600px;" %}
<section data-markdown>
<textarea data-template>

## SQL 신기능 (12cR1)
### 목차
  1. VARCHAR2 최대 크기가 32k까지 확장
  2. IDENTITY 컬럼 (ISO SQL Standard)
  3. Row Limit OFFSET 절과 FETCH FIRST 절
  4. SQL의 With절에 PL/SQL 함수 작성
---
## 1. VARCHAR2의 크기 확장
### 최대 크기가 32k까지 확장
- 11.2까지는
  - VARCHAR2의 최대 크기는 4000 bytes 였음
- 12.1부터는
  - VARCHAR2의 최대 크기가 32767 bytes까지 확장 가능
  - MAX_STRING_SIZE 초기화 매개변수를 EXTENDED로 설정
  - 설정후에 데이터베이스 재기동 및 스크립트(utl32k.sql) 수행 필요
  - 한번 설정하면 STANDARD(기존 설정)로 되돌릴수 없음

<pre><code data-trim data-noescape>
SQL> ALTER SYSTEM SET MAX_STRING_SIZE = EXTENDED;
</code></pre>
---
## 2. IDENTITY 컬럼 (ISO SQL Standard)
### INSERT시 자동으로 숫자가 증가하는 컬럼
- 11.2까지는
  - 테이블에 추가되는 각 행을 고유하게 식별해야할 경우, 테이블에 INSERT 트리거를 생성하고 사전에 생성한 SEQUENCE번호를 할당, or INSERT구문에서 SEQUENCE호출하여 데이터 추가
- 12.1부터는
  - IDENTITY 컬럼을 사용하여 SEQUENCE를 별도로 생성할 필요가 없어짐(자동으로 생성됨)
  - IDENTITY 컬럼과 내부에서 생성된 SEQUENCE는 ALL_TAB_IDENTITY_COLS에서 확인가능

<pre><code data-trim data-noescape>
SQL> CREATE TABLE tickets (
       ticket_id NUMBER GENERATED AS IDENTITY,
       desc  VARCHAR2(255)
);
</code></pre>
---
## 3. Row Limit OFFSET 절과 FETCH FIRST 절 (1/2)
### 결과를 정렬하고 특정 행만 추출하는 SQL
- 11.2까지는
  - 질의 결과를 행을 제한할 경우, ROW_NUMBER 함수를 사용함.
- 12.1부터는
  - OFFSET N ROWS FETCH FIRST M ROWS ONLY
  - OFFSET 절에서는 row limit이 시작하기 전에 건너뛸 행수를 지정
  - FETCH FIRST 절에서는 반환되는 행수나 행의 비율을 지정
  - OFFSET절을 생략하고 FETCH FIRST n ROWS ONLY로 설정하면 Top N개의 행을 조회
---
## 3. Row Limit OFFSET 절과 FETCH FIRST 절 (2/2)
### 실행예시
- OFFSET 과  FETCH FIRST 절을 사용시

<pre><code data-trim data-noescape>
SQL> SELECT employee_id, last_name 
     FROM employees 
     ORDER BY employee_id 
     OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;

 EMPLOYEE_ID LAST_NAME
----------- -------------------------
 105          Austin
 106          Pataballa
 107          Lorentz
 108          Greenberg
 109          Faviet 
</code></pre>
---
## 4. SQL의 With절에 PL/SQL 함수 작성
### SQL문을 복잡하게 만드는것을 방지하기 위하여 복잡한 계산은 SQL의 외부로 분리함
- WITH절 내에서 PL/SQL함수를 포함
- 별도 함수를 생성할 필요가 없음
- 복잡한 계산을 SQL 외부로 분리하여 SELECT문의 복잡성을 방지

<pre><code data-trim data-noescape>
SQL> WITH
  FUNCTION with_function (param NUMBER)RETURN NUMBER IS
    result NUMBER;
  BEGIN
    result := param * 2;
    RETURN result;
  END;

SELECT with_function(column1) FROM my_table;
</code></pre>
</textarea>
</section>
{% include pptend.html id="sql12r1" initialize="center: false,"%}

## 마무리

오라클 12cR1기준으로 추가된 SQL기능에 대해서 간략하게 알아보았습니다. 

오라클의 옵티마이저는 SQL실행계획작성전에 Query Transformer단계가 수행됩니다. 
Query Transformer는 사용자 작성한 Query를 좀더 효율적으로 처리 될수 있도록 의미적으로 동일한 SQL문으로 변환해주는 기능입니다. 

오라클은 Query Transformer기능을 개선하여 사용자들이 SQL을 좀더 간단하게 사용할수있도록 SQL syntax관련하여 많은 개선사항들을 추가하고 있습니다.

다음으로 12R2기준으로 추가된 SQL기능에 대해서 정리할 예정입니다.