---
layout: single
title: 오라클 SQL 신기능 (12.2)
date: 2024-06-08 15:00
categories: 
  - Oracle 
contents: PPT
tags: 
   - Oracle  
   - SQL
   - PL/SQL
   - new feature
excerpt : 오라클 데이터베이스 SQL 신기능(12cR2 기준)에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/writing1.jpg
  overlay_image: /assets/images/blog/writing1.jpg
toc : true  
toc_sticky: true
---

## 들어가며 

오라클 데이터베이스 12cR2기준으로 새로 추가된 SQL 기능에 대해서 간략적으로 정리하였습니다.

## SQL 신기능 (12cR2)

오라클 12cR2버전의 SQL 개선사항은 아래와 같습니다. 

1. 객체 이름의 최대 길이가 128 bytes로 확장
2. 대소문자를 구분하지 않는 문자 비교 (COLLATION)
3. LISTAGG OVERFLOW 절

SQL 개선사항 별로 프레젠테이션 모드로 간단하게 알아보겠습니다.

{% include pptstart.html id="sql12r2 stretch" style="height:600px;" %}
<section data-markdown>
<textarea data-template>

## SQL 신기능 (12cR2)
### 목차
1. 객체 이름의 최대 길이가 128 bytes로 확장
2. 대소문자를 구분하지 않는 문자 비교 (COLLATION)
3. LISTAGG OVERFLOW 절
---
## 1. 객체 이름의 최대 길이가 128 bytes로 확장
### 객체 이름의 최대 길이가 30 bytes에서 128 bytes로 확장
- 많은 데이터베이스 객체 이름의 최대 크기가 30 Bytes에서 128 bytes로 확장되었음
- 지원되는 객체: Table, column, index,view, stored procedure, function등

<pre><code data-trim data-noescape>
-- 테이블 및 컬럼 생성
-- 테이블명 길이 37 bytes, 컬럼명 길이 54 bytes
SQL> CREATE TABLE VERY_VERY_LONG_TABLE_NAME_IDENTIFIER
(
VERY_VERY_LONG_TEXT_COLUMN_WITH_DATA_TYPE_VARCHAR2_25 VARCHAR2(25)
);

Table VERY_VERY_LONG_TABLE_NAME_IDENTIFIER created.
</code></pre>
---
## 2. 대소문자를 구분하지 않는 문자 비교 (COLLATION) (1/2)
### 문자열 검색시 대소문자를 구분하지 않고 데이터를 매칭
- 기본 동작방식
  - 문자열 비교는 바이너리로 수행되며 대소문자를 구별
  - A의 이진표현은 01000001이고 a 의 이진표현  01100001임  
- 12.2부터는
  - 대소문자를 구분하지 않는 COLLATE 절 사용가능 
  - 컬럼 또는 테이블단위로 COLLATE BINARY_CI속성 지정
  - 미지정 컬럼의 Collations은 부모 테이블이나 스키마의 기본 collation 속성을 상속함
---
## 2. 대소문자를 구분하지 않는 문자 비교 (COLLATION) (2/2)
### 예제

<pre><code data-trim data-noescape>
-- 테이블 및 컬럼 레벨에서 COLLATE 지정
SQL> CREATE TABLE product(id NUMBER,
name VARCHAR2(50) COLLATE BINARY_CI,
comments VARCHAR2(500)) 
DEFAULT COLLATION BINARY;
-- SQL문장레벨에서 COLLATE 지정
SQL> SELECT name, comments 
FROM product
WHERE name LIKE '%BASE%' OR
comments COLLATE BINARY_CI LIKE '%REPORT%’;

NAME                       COMMENTS        
-------------------------- -----------------
Oracle Database
Activity-Based Management 
Business Intelligence      Replaces Reports 
</code></pre>
---
## 3. LISTAGG OVERFLOW 절(1/1)
### Overflow한 데이터를 잘라내어 표시
- 12.1까지는
  - LISTAGG 함수에 의해 반환된 연결값이 반환값의 데이터 유형에 지원하는 최대 길이를 초과하는 경우 오류가 발생됨  
- 12.2부터는
  - 반환 문자열이 반환값의 데이터 유형에서 지원하는 최대 길이내에 맞도록 반환문자열을 잘라내고, 데이터 유형의 최대 길이를 초과하는 경우, 반환값이 잘려졌음을 나타내는 문자를 표시함
---
## 3. LISTAGG OVERFLOW 절(2/2)
### 예제
<pre><code data-trim data-noescape>
SQL> SELECT o.OWNER, 
 LISTAGG (o.OBJECT_NAME,', ' on overflow truncate with count)
 WITHIN GROUP (order by o.OBJECT_NAME) object_name 
FROM all_objects o
WHERE o.OWNER in ('SYS','SYSTEM')
GROUP BY o.OWNER;

OWNER            OBJECT_NAME
---------------- ------------------------------------------------------------------------------
SYS              ACCESS$, ACCHK_EVENTS, ACCHK_EVENTS_FK, (Short) , ALL_COL_PRIVS, ...(51545)
</code></pre>
</textarea>
</section>
{% include pptend.html id="sql12r2" initialize="center: false,"%} 

## 마무리

오라클 12cR2기준으로 추가된 SQL기능에 대해서 간략하게 알아보았습니다. 

다음으로 18c기준으로 추가된 SQL기능에 대해서 정리할 예정입니다.