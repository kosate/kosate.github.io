---
layout: single
title: 오라클 SQL 신기능 (18c)
date: 2024-06-19 23:00
categories: 
  - Oracle 
contents: PPT
tags: 
   - Oracle  
   - SQL
   - PL/SQL
   - new feature
excerpt : 오라클 데이터베이스 SQL 신기능(18c 기준)에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/writing1.jpg
  overlay_image: /assets/images/blog/writing1.jpg
toc : true  
toc_sticky: true
---

## 들어가며 

오라클 데이터베이스 18c기준으로 새로 추가된 SQL 기능에 대해서 간략적으로 정리하였습니다.

## SQL 신기능 (18c)

오라클 18c버전의 SQL 개선사항은 아래와 같습니다. 

1. Inline External Table
2. Cancel SQL

SQL 개선사항 별로 프레젠테이션 모드로 간단하게 알아보겠습니다.

{% include pptstart.html id="sql18c stretch" style="height:600px;" %}
<section data-markdown>
<textarea data-template>

## SQL 신기능 (18c)
### 목차
1. Inline External Table
2. Cancel SQL

---
## 1. Inline External Table(1/3)
### DDL생성없이 SQL문내에서 문서나 콘텐츠를 직접 선언하여 조회
- SQL문 내에서 External Table 정의를 기술
- 한번만 사용하는 External Table을 새로 생성할 필요가 없음
- CSV등에서 데이터 로드를 효율화함. 객체가 무분별하게 증가되는것을 방지 할수 있음

---
## 1. Inline External Table(2/3)
### External 테이블을 이용한 데이터 로드방법
- 12.2까지는 external 테이블을 생성하여 로드를 수행

<pre><code data-trim data-noescape>
-- External 테이블 생성
CREATE TABLE metrics_xt
    ( sensor_id NUMBER, ... )
        ORGANIZATION EXTERNAL ()
     TYPE ORACLE_LOADER 
         ... 
     LOCATION ('metrics.csv')
       REJECT LIMIT UNLIMITED );
-- 데이터 로드
INSERT INTO metrics  SELECT * FROM metrics_xt;
-- External 테이블 삭제
DROP TABLE metrics_xt;
</code></pre>
---
## 1. Inline External Table(3/3)
### External 테이블을 이용한 데이터 로드방법
- 18c부터는 SQL문에서 External절을 선언하여 로드를 수행

<pre><code data-trim data-noescape>
-- External 테이블 생성
INSERT INTO metrics
     SELECT metrics_xe.*
     FROM EXTERNAL( 
       (sensor_id NUMBER, ... )
        TYPE ORACLE_LOADER 
        ... 
        LOCATION ('metrics.csv')
        REJECT LIMIT UNLIMITED)
</code></pre>
---
## 2. Cancel SQL (1/2)
### 세션을 종료시키지 않고 , SQL만 중지
- 리소스를 과도하게 사용하는 SQL 쿼리를 종료시킬수 있음
- SQL문을 사용하여 불필요한 SQL쿼리를 종료
- 소비중인 시스템 리소스를 해제함

<pre><code data-trim data-noescape>
-- 실행중인 SQL을 중지,
ALTER SYSTEM CANCEL SQL 'SID, SERIAL, @INST_ID, SQL_ID';
</code></pre>
---
## 2. Cancel SQL (2/2)
### SQL이 실행되다 취소되면

<pre><code data-trim data-noescape>
SQL> SELECT ... 
     FROM   products p, sales s, countries c
     WHERE  p.product_id = s.product_id
     AND s.country_id = c.country_id;
(긴 시간동안 실행)
..

-- Cancel SQL을 실행되면 해당세션에서는 SQL취소(ORA-01013) 에러 발생
ERROR:
ORA-01013: User requested cancel of current operation.

-- 세션이 중지 되지 않고 실행
SQL> SELECT COUNT(*) FROM sales;
    COUNT(*)
------------
  1242435002
</code></pre>
</textarea>
</section>
{% include pptend.html id="sql18c" initialize="center: false,"%} 

## 마무리

오라클 18c기준으로 추가된 SQL기능에 대해서 간략하게 알아보았습니다. 

다음으로 19c기준으로 추가된 SQL기능에 대해서 정리할 예정입니다.