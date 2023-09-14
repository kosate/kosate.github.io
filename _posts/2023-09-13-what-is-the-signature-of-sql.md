---
layout: single
title: 비슷한 SQL문장들을 찾아내는 방법
date: 2023-09-12 03:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - signature
   - sql plan
excerpt : SQL의 SIGNATURE정보를 이용하여 Literal SQL을 찾아내는 방법을 설명합니다.
header :
  overlay_image: /assets/images/blog/signature-sql.jpg
toc : true  
toc_sticky: true
---

## 목적

오라클 데이터베이스에서는 SQL 문장을 정규화하여 서명(SIGNATURE) 값을 계산하고 SQL 튜닝에 활용합니다. 이 개념을 이해하면 Literal  SQL을 쉽게 찾아낼 수 있습니다. 

## SQL SIGNATURE은 무엇인가?

SIGNATURE는 SQL TEXT를 정규화(Normalized)한후에 계산된 ID입니다. 
SQL TEXT에 Literal 변수를 사용하거나, White space가 있거나, 대소문자가 다르더라도 결국 동일한 SQL 구문입니다. SQL들이 동일한 작업을 한다면 동일한 SQL로 인식이 되어야하겠죠. 
그래서 SQL TEXT에 정규화(Normalized)과정을 거치면 동일한 SQL로 인식할수 있는 ID를 확인할수 있습니다. 그것이 SIGNATURE입니다.

- SQL TEXT 정규화 방식
  1. 빈스페이스값도 제거됩니다.
  2. 리터널 변수는 제외한 SQL TEXT의 나머지부분을 모두 대문자로 변환시킵니다.
  3. (옵션) 리터널 변수를 바인드변수로 변환합니다. 

### SIGNATURE 생성방법

SQL TEXT로부터 SIGNATURE값을 구하는 DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE 프로시저를 제공합니다. 
DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE는 두개의 파라미터를 받습니다. 
- SQL text : SQL TEXT문
- force_match : 리터널 변수를 자동으로 바인드 변수로 변환할지를 결정(true일경우 변환, False이경우 변환안함)

```sql
SQL> SET SERVEROUTPUT ON
DECLARE
 V_SQLTEXT   VARCHAR2(200) := 'select * from dual';
 R_SIGNATURE       NUMBER;
BEGIN
 R_SIGNATURE := DBMS_SQLTUNE.SQLTEXT_TO_SIGNATURE (V_SQLTEXT, FALSE);
 DBMS_OUTPUT.PUT_LINE ('SIGNATURE=' || R_SIGNATURE);
END;
/
SIGNATURE=14103420975540283355

PL/SQL procedure successfully completed.

SQL>
```
### SIGNATURE 의 두가지 유형

SIGNATURE는 force_match파라미터에 따라서 EXACT_MATCHING_SIGNATURE, FORCE_MATCHING_SIGNATURE 두개의 유형으로 나눌수 있습니다. 
- EXACT_MATCHING_SIGNATURE = Literal 변수이 그대로인 SIGNATURE
- FORCE_MATCHING_SIGNATURE = Literal 변수가 Bind 변수로 변환된 SIGNATURE

SQL을 실행하면 자동으로 두개의 SIGNATURE가 생성이 됩니다. 
3개의 SQL을 수행해보겠습니다. 

```sql
SQL> select 1 from dual where dummy = '1';
SQL> select 1 from dual where dummy = '2'; 
SQL> SELECT 1         from dual where dummy = '2'

SQL> set lines 132
SQL> col sql_text format format a30
SQL> col EXACT_MATCHING_SIGNATURE format  99999999999999999999
SQL> col FORCE_MATCHING_SIGNATURE format  99999999999999999999

SQL> select sql_text, EXACT_MATCHING_SIGNATURE, FORCE_MATCHING_SIGNATURE from V$sqlstats where sql_text like '%dummy%';
SQL_TEXT                                            EXACT_MATCHING_SIGNATURE FORCE_MATCHING_SIGNATURE
-------------------------------------------- ------------------------ ------------------------
select 1 from dual where dummy = '1'          1821967281786142678     13154199455204052618
select 1 from dual where dummy = '2'          8674825496841288494     13154199455204052618
SELECT 1         from dual where dummy = '2'  8674825496841288494     13154199455204052618

```

Literal 변수에 해당되는 dummy = '1' 이부분이 Bind 변수로 처리된 SIGNATURE가 FORCE_MATCHING_SIGNATURE이고 변환되지 않은 SIGNATURE가 FORCE_MATCHING_SIGNATURE입니다. 
v$SQL, V$SQLSTATS, V$SQLAREA등 SQL관련된 정보를 가지고 있는 performance view에는 거의다 두개의 SIGNATURE정보를 제공합니다.

## SIGNATURE은 언제 사용될수 있을까?

### SQL 튜닝에 사용됨
오라클 내에서는 SIGNATURE는 SQL PLAN을 관리하거나, 튜닝할때 사용됩니다. 
동일한 SQL임을 확인하기 위하여 SIGNATURE가 이용됩니다. 

- SQL Plan Baseline : SQL 실행계획을 관리하는 기능(환경변화와 관계없이 실행계획을 고정하는 기능을 제공)
- SQL Profile : SQL Tuning Advisor에 의해 생성되는 튜닝 권고안으로 옵티마이저의 카디널리티 추정치를 개선하여 더 나은 실행계획으로 실행하도록 유도시키는 튜닝 기능
- SQL Patch : SQL수정없이 오라클내에서 SQL에 힌트를 적용시킬수 있는 튜닝기능

대부분 SQL 튜닝할때 SIGNATURE값을 직접 사용하지 않았을 것입니다. DBMS_SQLTUNE과 같은 SQL 튜닝 패키지에서 SQL ID나 SQL TEXT를 인자로 사용하셨겠지만 내부적으로 SIGNATURE으로 동작합니다.

사용되는 SIGNATURE는 cursor_sharing DB파라미터에 의해서 앞서 설명한 두가지 SIGNATURE중 하나가 선택됩니다
- EXTRACT(Default) : SQL TEXT가 완벽하게 동일해야 Cursor를 공유합니다. 반대로 말하면 조금이라고 틀리면 Hard Parsing을 하며 다른 SQL로 간주됩니다. SQL튜닝에 EXACT_MATCHING_SIGNATURE값이 사용됩니다. 
- FORCE : SQL TEXT의 리터널 변수를 bind변수로 변경하여 동일한 Cursor를 공유합니다. SQL튜닝에 FORCE_MATCHING_SIGNATURE값이 사용됩니다. 

대부분의 운영환경은 cursor_sharing 파라미터는 extract으로 설정되어 있을 것입니다.

### Literal SQL 찾아내기(비슷한 SQL)

SQL 튜너들은 Literal SQL들을 찾아내서 바인드 변수를 사용하도록 권고합니다. 
Literal SQL들은 개별 SQL로 인식되므로 Shared Pool에 모두 저장되고 실행건수가 많아지면 메모리가 부족해서 에러가 발생될수 있기 때문입니다. 

Literal SQL 자체가 어렵다는것은 아니지만 FORCE_MATCHING_SIGNATURE를 이용하면 Literal SQL을 좀더 쉽게 찾아낼수 있습니다. 

- SQL TEXT로 리터널 SQL찾아보기
```sql
select substr(sql_text,1,30) , count(*) cnt
from v$sql
group by substr(sql_text,1,30)
having count(*) > 10;
```

- FORCE_MATCHING_SIGNATURE로 리터널 SQL찾아보기
```sql
select FORCE_MATCHING_SIGNATURE, count (*) cnt
from v$sql
group by FORCE_MATCHING_SIGNATURE
having count(*) > 10;
```

## 정리 

우리가 SQL 튜닝한후에 SQL TEXT에 공백이 추가되어 SQL 튜닝을 다시 되어야한다면 너무 불합리적이지 않나요? 오라클 내부적으로 SIGNATURE를 이용하여 동일한 SQL로 인식하기 때문에 튜닝이 유지될수 있는것이지요. 

SIGNATURE는 10g Release 2에서 나온것으로 알고 있습니다. SIGNATURE계산하는 로직이나 방법도 계속 변화하는것 같습니다. 굳이 어떻게 동작하는지는 큰 의미는 없지만 개념정도는 이해하면 내부적으로 동작하는 방법을 이해할수 있을것 같습니다. 

참! 그리고 23c New Feature인 SQL Firewall기능에서 동일한 SQL인지 판단하기 위하여 SQL의 SIGNATURE가 사용됩니다. SQL Firewall은 DB안에서 세션정보, SQL정보를 이용하여 firewall을 설정할수 있는 기능입니다. 정상적인 접속으로 생각되는 세션정보들을 수집하여 allow list를 만들면, 허용되지 않는 세션 혹은 SQL들은 차단이 되는 기능입니다.