---
layout: single
title: (SQL)RAG - 답변에 필요한 데이터를 스스로 검색 기술 - SQL 생성(Generation)
date: 2024-07-01 21:00
categories: 
  - Oracle
books:
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
   - RAG
excerpt : 오라클 데이터베이스 23ai에 벡터 검색을 위한 Oracle AI Vector Search기능을 제공합니다. 벡터 검색기능이 RAG에서 많이 사용되고 있지만, 좀더 진보적으로 답변에 필요한 데이터를 자동검색하는 방안에 대해서 정리하였습니다.
header : 
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

RAG(Retrieval Augmented Generation)는 답변에 필요한 데이터을 검색(Retrieve)하여 프롬프트를 강화(Augmented)하여 LLM에 답변을 요청(Generation)하는 기술입니다. 

프롬프트를 강화한다는 것은 프롬프트에 맥락(CONTEXT)를 추가하는것을 의미합니다.

예를 들어 CONTEXT에 개인정보를 추가하거나, 질의의 세부적인 정보를 추가할 경우 질의하려는 사람을 이해하는것처럼 개인화된 답변을 제공하거나 질의내용을 이해한것 처럼 답변할수 있게 됩니다. 

결국 질문자에 의도에 맞게 정확한 답변을 하므로 답변의 만족성은 높아지고 LLM을 기업에서 다양한 업무에 쉽게 적용하여 활용할수 있게 됩니다. 

질문에 적합한 데이터를 제공하는것이 곧 답변의 품질을 좌우됩니다. 

본 블로그에서는 어떻게 하면 질문에 적합한 데이터를 제공할지에 대한 방안에 대해서 정리하였습니다. 

## RAG 애플리케이션에서 가장 중요한 요소 - 데이터 검색기술 

RAG의 3가지 요소는 용어에 설명되어 있듯이, 검색기술, 증각프롬프트작성, LLM통신등이 있습니다. 

일반 적인 RAG 애플리케이션의 흐름을 예를 들어 설명하면 제일 먼저 프롬프트 작성을 위하여 검색기술을 사용합니다. 이때 보통 벡터 검색기술을 사용하여 질문에 가장 가까운 텍스트를 찾습니다.

1. LLM에 컨텍스트를 제공하기 위해 최신 데이터를 사용합니다.
2. 벡터 데이터베이스에 벡터로 저장되는 인코딩(임베딩)을 생성합니다.
3. 사용자 쿼리가 인코딩되고 저장된 벡터와 유사성검색을 수행합니다.
4. 상위 일치 항목(K-top)이 검색되어프롬프트와 함께 제공됩니다.

위에서 보았듯이 대부분의 RAG애플리케이션에서는 특정 스토어 특히 벡터 데이터베이스에서 검색된 데이터를 이용하여 프롬프트를 강화합니다. 그렇기 때문에 특정 도메인 지식 기반으로 답변하는 등의 기업내 특정 업무에서만 사용됩니다. 
데이터 스토어의 분산, 백터 검색기술로 인하여 검색할수 있는 데이터가 한계가 있다면 당연히 LLM가 적용될수 있는 업무나 역할이 한계가 있을수 밖에 없습니다. 

- 사용자가 질의한 내용에 적합한 데이터는 모두 백터데이터베이스에 존재하는가? 
- 내가 구매한 물품에 대해서 질의를 한다면, 개인정보 혹은 구매내역과 같은 정보들은 어떻게 제공할수 있을까?(실제 정보들은 테이블형태의 RDBMS데이터가 될수 있습니다.)

> 사용자가 어떤 질문을 할지 알고, 필요한 데이터를 제공할것인가? 혹은 준비할수 있을것인가?

벡터 검색 기술을 당연히 LLM연동하여 데이터를 검색하기 위한 중요한 요소이지만, 벡터 검색기술로만 데이터 검색 기술을 한정할경우 LLM 활용성어 그에 맞게 한정될수 밖에 없습니다.

RAG 애플리케이션에서 가장 중요한 요소는 데이터 검색기술과 더불어 필요한 데이터을 제공하는 방법을 모두 포함합니다. 

- 질문에 답변하게 위하여 필요한 데이터를 어떻게 제공할수 있을것인가? 어떻게 검색할것인가?

조금 생각을 달리할 부분은 벡터 검색은 검색기술중 한 부분일뿐이라는 점입니다. 
그것이 텍스트가 될것인가? 아니면 정형화된 테이블구조의 데이터가 될것인가 하는것을 LLM에게 스스로 물어보게 하여 답변에 필요한 데이터를 알아서 검색하는 방법이 필요합니다. 

RAG 애플리케이션을 구성 방식이 좀더 단순화되고 더욱 유연한 구성이 가능합니다.

1. LLM에 컨텍스트를 제공하기 위해 최신 데이터를 사용합니다.
2. LLM에게 필요한 데이터가 무엇인지를 물어봅니다. 그리고 SQL을 자동으로 작성시킵니다.
3. 데이터베이스에서 검색된결과를 프롬프트와 함께 제공됩니다.

**LLM에게 필요한 데이터가 무엇인지를 물어봅니다**단계처럼 LLM에게 답변에 필요한 데이터를 직접 검색하도록 SQL을 자동 작성하고, 이를 실행한 결과를 프롬프트 증강하는데 사용되도록 합니다.

> 필요한 데이터를 검색하는 기술 - SQL 자동 생성, 비정형, 정형 데이터 모두 지원하는 스토어가 있다면 답변에 필요한 데이터를 알아서 검색합니다. 

데이터 검색 기술이 매우 중요하지만 검색할수 있는 데이터 범위 또한 중요합니다. 데이터 범위를 한계 짓는 가장 중요한 요소는 데이터 저장소의 특성이 될수 있습니다. 벡터 스토어는 순수 백터를 저장하고 검색하기 위한 기능만을 제공합니다. 업무에 필요한 테이블 목록들을 조회할경우 RDBMS로 엑세스해서 데이터 검색해야합니다. LLM과 연동할때는 한번에 접근하여 모든 데이터를 검색할수 있는 통합 스토어혹은 멀티 모델 데이터베이스가 어느 업무보다 필요할수 있습니다. 

질문에 필요한 데이터를 스스로 검색하는 기능, 이기능을 구현하는 방법에 대해서 알아보도록 하겠습니다. 

### SQL 생성을 위한 프롬프트 예시

오라클데이터베이스는 45년의 가장 많이 사용되는 데이터베이스로 메뉴얼과 관련지식들이 많이 있습니다. 따라서 LLM은 누구보다도 오라클 데이터베이스 SQL을 잘 알고 있습니다. (이미 학습되어 있음)

아래와 같은 프롬프트 작성으로 쉽게 SQL작성이 가능합니다.

{% include codeHeader.html copyable="true" codetype="text"%}
```sql
Instructions: 당신은 오라클 SQL 전문가입니다. 주어진 입력 질문에 대해 먼저 실행할 구문적으로 올바른 오라클 SQL 쿼리를 작성하십시오. 질문에 답하는 데 필요한 컬럼만 질의해야합니다. 아래 테이블에서 볼 수 있는 열 이름만 사용하십시오. 존재하지 않는 열을 조회하지 않도록 주의하십시오. 또한 각 열이 어느 테이블에 있는지 주의하십시오. 

Use the following format:
Question: Question here
SQL: Generated SQL query

Context: 다음 테이블과 열만 사용하십시오. 

Table: HR.DEPARTMENTS, Columns: DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID
Table: HR.EMPLOYEES, Columns: EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY, MANAGER_ID, DEPARTMENT_ID
Primary keys: HR.DEPARTMENTS.DEPARTMENT_ID, HR.EMPLOYEES.EMPLOYEE_ID
Foreign keys: HR.EMPLOYEES.DEPARTMENT_ID -> HR.DEPARTMENTS.DEPARTMENT_ID, HR.DEPARTMENTS.MANAGER_ID -> HR.EMPLOYEES.EMPLOYEE_ID

Question: 각 부서별 직원의 평균 급여 정보를 알려주세요.
```

Chatgpt에 문의하면 아래와 같은 답변을 얻을수 있습니다. 

```sql
Question: 각 부서별 직원의 평균 급여 정보를 알려주세요.
SQL:
SELECT 
    D.DEPARTMENT_NAME, 
    AVG(E.SALARY) AS AVERAGE_SALARY
FROM 
    HR.EMPLOYEES E
JOIN 
    HR.DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
GROUP BY 
    D.DEPARTMENT_NAME;
```

## SQL 자동 생성기능

SQL 자동 생성 기능을 구현하기 위하여 먼저 구성요소에 대해서 알아보고, 예제를 들어 상세하게 알아보겠습니다. 

### 1. SQL 작성을 위해 필요한 구성요소

SQL 자동 생성 구현하기 위하여 고려되어야한 요소들을 먼저 알아보겠습니다. 

"LLM연동"부분은 데이터베이스에서 직접 LLM과 통신하거나 APP레벨에서 LLM과 통신할수 있습니다.
오라클 데이터베이스 23ai에서는 DBMS_VECTOR_CHAIN 패키지를 통하여 LLM과 통신하는 기능을 제공하고 있어, DBMS에서 직접 통신하는 방법으로 작성하였습니다. 

|구분|구성요소|지원방법|비고|
|---|---|---|---|
|LLM연동|LLM모델|외부 모델 활용(OpenAI, Google AI,OCI Gen AI, Cohere등)|Multilingual 지원|
||LLM통신인증|DBMS_VECTOR_CHAIN.CREATE_CREDENTIAL 사용|API Key등록|
||LLM통신방법|DBMS_VECTOR_CHAIN.UTL_TO_GENERATE_TEXT 사용|LLM에게 답변 요청|
||네트워크 권한|권한부여(DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE)||
|프롬프트작성|테이블 범위 지정|어떤 유저가 어떤 테이블을 접근할지 목록지정(예 : 임의 AI_PROFILE테이블생성)||
||테이블의 메타데이터|Table 명, 컬럼명, 데이터형식, Comments, Annotations, SQL Domain, Primary Key, Foreign Key|테이블목록을 가지고 메타데이터 생성가능|
|검색|데이터 스토어|Multi-Model지원(JSON, XML, Spatial, Graph, Vector Search, CLOB, BLOB)|최신 SQL은 One-shot learning|
|보안|데이터 보안(DBMS엔진레벨)|접근 행 제어(Virtual Private Database), 동적 마스킹 ( Data Redaction(ASO필요) ) ||

오라클 데이터베이스는 데이터 이해를 위한 풍부한 메타 데이터 제공(Comments, Annotations, SQL Domains)하고 있습니다. 예제에서는 테이블의 Comments정보만 사용하였지만, 더욱더 정확한 SQL작성을 위하여 추가적인 정보제공을 제공할수 있습니다. 

LLM에 의해서 SQL 작성이 되면 데이터 조건만으로 데이터 보안을 유지하기 어렵습니다. 혹시라도 불순한 목적으로 질문을 할경우 데이터 탈취가 가능할수도 있습니다. 특히 SQL 자동작성에서는 엄격한 보안적용이 필요합니다. 오라클 데이터베이스는 DBMS엔진레벨에서 적용할수 있는 많은 보안 방법들이 있습니다. 예로, DB 세션 컨텍스트 기반으로 조건을 강제 추가하는 VPD기능, 접속한 유저에 따라서 특정 정보를 조회할때 마스킹할수 있는 동적 마스킹(Redaction)기능들을 제공하고 또한 Audit기능도 제공하고 있습니다. 

### 2. LLM 통신 설정

데이터베이스에서 직접 LLM통신 하기 위해서는 API Key등록이 필요합니다. 
OpenAI기반으로 작성하였습니다. 

#### 1. API Key등록(LLM)

**OPENAI_CRED**이름으로 인증 정보를 생성합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
declare
  v_params json_object_t;
  v_name varchar2(1000) :=  'OPENAI_CRED';
  v_api_token varchar2(1000) := '{API_KEY}'; 
begin
   v_params := json_object_t();
   v_params.put('access_token',v_api_token); 
   begin
        DBMS_VECTOR_CHAIN.DROP_CREDENTIAL ( CREDENTIAL_NAME  => v_name);
   exception 
     when others then
        null;
   end;
   
   DBMS_VECTOR_CHAIN.CREATE_CREDENTIAL ( CREDENTIAL_NAME => v_name, PARAMS => json(v_params.to_string));
end;
/
```

LLM 모델과 관련된 파라미터 설정이 필요합니다. JSON형식으로 설정할수 있습니다. 
설정된 파라미터를 관리하고 재사용하기 위하여 JSON형식으로 테이블(my_models)에 저장하였습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
create table my_models(
    model_id number generated by default on null as identity primary key,
    model_params json);

insert into my_models (model_params)
    values (json('{
  "provider": "openai",
  "credential_name": "OPENAI_CRED",
  "url": "https://api.openai.com/v1/chat/completions",
  "model": "gpt-3.5-turbo",
  "max_tokens":1000,
  "temperature": 1.0
}'));
    
commit;
```

JSON형식으로 저장된 파라미터를 모델명으로 간편하게 조회하기 위하여 View로 생성했습니다.
오라클 데이터베이스는 테이블 데이터를 JSON형식으로 JSON형식을 테이블로 구조하는 작업일 위하여 다양한 SQL 함수들을 제공하고 있습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
create or replace view vw_my_models 
as
select m.model_id, mt.*,m.model_params from my_models m
   CROSS JOIN JSON_TABLE(
        m.model_params, 
        '$[*]' COLUMNS (
            provider VARCHAR2(4000) PATH '$.provider',
            credential_name VARCHAR2(4000) PATH '$.credential_name',
            model VARCHAR2(4000) PATH '$.model'
        )
) as mt;
```

#### 2.답변 요청 테스트

LLM과 통신하기 위하여 인증정보와 모델과 관련된 파라미터정보를 설정하였으므로 LLM과 직접 통신할수 있습니다. 
dbms_vector_chain.utl_to_generate_text 함수를 직접 사용할수 있지만, 저장된 파라미터를 사용하고 HTTP통신시 인코딩이 필요하여 generate_text 사용자 함수를 생성하였습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
 CREATE OR REPLACE FUNCTION generate_text(p_model_name varchar2, p_prompt CLOB) RETURN CLOB 
IS 
   output CLOB;
   v_model_params json;
BEGIN 
    --모델 정보가져오기
   select model_params into v_model_params from vw_my_models where model = p_model_name;
   -- REST API 통신할때 문자 인코딩 설정
   utl_http.set_body_charset('UTF-8'); 
   -- 결과요청
   output := dbms_vector_chain.utl_to_generate_text(p_prompt, v_model_params);
   return output;
END;
/
```

LLM모델을 선택하여 답변을 요청합니다. 데이터베이스에서 직접 LLM과 통신이 가능한지 테스트하였습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
set serveroutput on 
declare
    v_model_name varchar2(100) := 'gpt-3.5-turbo';
    v_prompt clob;
begin
   v_prompt := '[
        {"role":"system", "content":"당신은 친철한 지원자입니다."},
        {"role":"user", "content":"질문하면 되나요?"}
    ]';
   dbms_output.put_line('답변 : '||generate_text(v_model_name, v_prompt));
end;
/
```

답변결과는 아래와 같습니다. 

```sql
답변 : 네, 질문하세요. 무엇을 도와드릴까요?
```

### 3. SQL 작성을 위한 프롬프트 작성


#### 1. 테이블 범위 지정

LLM에 의해서 SQL이 자동 생성되지만 어떤 데이터를 제공할것인가하는 정보를 제공해야합니다. 그래서 업무 혹은 역할별로 테이블 목록을 지정해야합니다.

- 테이블 범위 중요성
  - 테이블 목록기반으로 메타데이터 생성
  - 업무 혹은 역할별로 테이블 범위 지정(1차 보안)

일부 업무를 가정하여 테이블 범위를 지정하는 방법에 대해서 알아보겠습니다. 
업무(역할)별 접근할수 있는 테이블목록 관리를 위하여 테이블 생성(AI_PROFILE)이 필요합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE TABLE AI_PROFILE(
    PROFILE_NAME VARCHAR2(1000),
    OBJECT_LIST JSON
);
```

챗봇서비스를 제공한다면 각자 역할이 있을수 있습니다. 각 역할별로 테이블 목록을 지정하는 방식으로 구현하였습니다.
"고객", "서비스센터","AS기사"와 같은 역할로 구분되고, 각 역할별로 엑세스해야하는 테이블 목록이 있습니다. 

- 고객 : 자신이 구매한 상품을 확인하고 문의합니다. 
- 서비스센터 : 고객이 구매한 상품에 대한 답변, 재고 정보를 확인, 필요할경우 AS기사에게 요청합니다. 
- AS기사 : 고객이 구매한 상품의 부품을 교체, 교체 방법을 확인합니다.

각 역할별로 테이블 목록(AI_PRIFILE)을 테이블로 저장합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
INSERT INTO AI_PROFILE(PROFILE_NAME, OBJECT_LIST) 
VALUES(
    '고객','
            { object_list : [{"owner": "VECTOR","name":"CUSTOMERS"},
                {"owner": "VECTOR","name":"ORDERS"},
                {"owner": "VECTOR","name":"ITEMS"},
                {"owner": "VECTOR","name":"ITEM_PARTS"},
                {"owner": "VECTOR","name":"ITEMS_AS_GUIDE"}, 
                {"owner": "VECTOR","name":"PARTS"}    
            ]}
    '),
   ('서비스센터','
            { object_list : [{"owner": "VECTOR","name":"CUSTOMERS"},
                {"owner": "VECTOR","name":"ORDERS"},
                {"owner": "VECTOR","name":"ITEMS"},
                {"owner": "VECTOR","name":"ITEM_PARTS"},
                {"owner": "VECTOR","name":"PARTS"},
                {"owner": "VECTOR","name":"PART_STOCKS"},
                {"owner": "VECTOR","name":"BRANCHES"}
            ]}
    '),
    ('AS기사','
            { object_list : [{"owner": "VECTOR","name":"CUSTOMERS"},
                {"owner": "VECTOR","name":"ORDERS"},
                {"owner": "VECTOR","name":"ITEMS"},
                {"owner": "VECTOR","name":"ITEM_PARTS"},
                {"owner": "VECTOR","name":"PARTS"},
                {"owner": "VECTOR","name":"PARTS_GUIDE"}
            ]}
    ')
    ;
    
COMMIT;
```
> 각 테이블별로 DDL구문은 본문에 넣지 않았습니다. 업무에 맞게 테이블과 데이터를 생성하여 넣으시면 됩니다. 


#### 2. 테이블 메타데이터 생성 

테이블이 정의되면 테이블별로 메타데이터를 생성할수 있습니다. 이는 SQL 작성을 위한 필요합니다. 
메타데이터는 테이블 구조(컬럼등)와 테이블 관계로 구분할수 있습니다. 

먼저 테이블 구조를 조회하는 SQL 작성합니다. 
SQL을 조회하면 JSON형식으로 메타데이터를 출력합니다. SQL 작성을 위한 프롬프트 작성시에 JSON형식으로 제공하면 LLM에서 잘 이해할수 있습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select json_arrayagg(
        json_object(a.owner,a.table_name, c.comments,
        'columns' is (
           select json_arrayagg(
                json_object( a.owner, b.column_name, b.data_type, d.comments)
                )
            from dba_tab_cols b, dba_col_comments d
              where a.owner = b.owner
                and  a.table_name = b.table_name 
                and b.owner = d.owner
                and b.table_name = d.table_name
                and b.column_name = d.column_name
                and b.hidden_column = 'NO'
            )
       ) returning CLOB)
 from dba_tables a, dba_tab_comments c 
 where (a.owner, a.table_name) in ( select t.owner, t.name from ai_profile a 
    CROSS JOIN JSON_TABLE(
        a.object_list, 
        '$.object_list[*]' COLUMNS (
            owner VARCHAR2(4000) PATH '$.owner',
            name VARCHAR2(4000) PATH '$.name'
        )
 ) t
 where profile_name = '고객')
 and a.owner = c.owner
 and a.table_name = c.table_name;
 ```

테이블 구조와 관련 메타데이터입니다. 

```json
[{"owner":"VECTOR","table_name":"CUSTOMERS","comments":"고객 정보 테이블","columns":[{"owner":"VECTOR","column_name":"USER_ID","data_type":"NUMBER","comments":"고객ID"},{"owner":"VECTOR","column_name":"USER_NAME","data_type":"VARCHAR2","comments":"고객이름"},{"owner":"VECTOR","column_name":"PHONE","data_type":"VARCHAR2","comments":"전화번호"}]},{"owner":"VECTOR","table_name":"ORDERS","comments":"아이템 구매 정보 테이블","columns":[{"owner":"VECTOR","column_name":"ORDER_ID","data_type":"NUMBER","comments":"주문번호"},{"owner":"VECTOR","column_name":"USER_ID","data_type":"NUMBER","comments":"고객ID\n"},{"owner":"VECTOR","column_name":"ITEM_ID","data_type":"NUMBER","comments":"상품ID"},{"owner":"VECTOR","column_name":"QUANTITY","data_type":"NUMBER","comments":"구매개수"}]},{"owner":"VECTOR","table_name":"ITEMS","comments":"아이템 정보 테이블","columns":[{"owner":"VECTOR","column_name":"ITEM_ID","data_type":"NUMBER","comments":"상품ID"},{"owner":"VECTOR","column_name":"ITEM_NAME","data_type":"VARCHAR2","comments":"상품명"},{"owner":"VECTOR","column_name":"MODEL_NAME","data_type":"VARCHAR2","comments":"모델명"}]},{"owner":"VECTOR","table_name":"ITEM_PARTS","comments":"아이템의 부품 매핑 테이블","columns":[{"owner":"VECTOR","column_name":"ID","data_type":"NUMBER","comments":null},{"owner":"VECTOR","column_name":"ITEM_ID","data_type":"NUMBER","comments":null},{"owner":"VECTOR","column_name":"PART_ID","data_type":"NUMBER","comments":null}]},{"owner":"VECTOR","table_name":"PARTS","comments":"부품 정보 테이블","columns":[{"owner":"VECTOR","column_name":"PART_ID","data_type":"NUMBER","comments":null},{"owner":"VECTOR","column_name":"PART_NAME","data_type":"VARCHAR2","comments":null},{"owner":"VECTOR","column_name":"PART_DETAILS","data_type":"VARCHAR2","comments":null}]},{"owner":"VECTOR","table_name":"ITEMS_AS_GUIDE","comments":"상품에 대한 AS정책에 대한 문서","columns":[{"owner":"VECTOR","column_name":"ID","data_type":"NUMBER","comments":"PK\n"},{"owner":"VECTOR","column_name":"ITEM_ID","data_type":"NUMBER","comments":"상품ID\n"},{"owner":"VECTOR","column_name":"CHUNK_ID","data_type":"NUMBER","comments":"청크ID"},{"owner":"VECTOR","column_name":"CHUNK_TEXT","data_type":"CLOB","comments":"문서텍스트"},{"owner":"VECTOR","column_name":"CHUNK_META","data_type":"JSON","comments":"문서메타"},{"owner":"VECTOR","column_name":"EMBEDDING","data_type":"VECTOR","comments":"벡터"}]}]
```

다음은 테이블 관계와 관련된 메타정보를 조회하는 SQL구문입니다. 이 메타데이터도 JSON형식으로 출력합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
 select json_arrayagg(
        json_object( 'key' is decode(a.constraint_type,'P','Primary keys : ','R','Foreign keys : '), 'column_list' is json_arrayagg(
        (b.owner||'.'||b.table_name||'.'||b.column_name)||
        (case when a.r_constraint_name is not null then '->'||(select d.owner||'.'||d.table_name||'.'||d.column_name from dba_constraints  c,  dba_cons_columns d
         where a.r_owner = c.owner and a.r_constraint_name = c.constraint_name
         and c.constraint_name = d.constraint_name
         and c.owner = d.owner) else '' end))))
from dba_constraints a , dba_cons_columns b
where 1=1
and   a.constraint_type IN ('P', 'R') 
and  (a.owner, a.table_name) in (select t.owner, t.name from ai_profile a 
    CROSS JOIN JSON_TABLE(
        a.object_list, 
        '$.object_list[*]' COLUMNS (
            owner VARCHAR2(4000) PATH '$.owner',
            name VARCHAR2(4000) PATH '$.name'
        )
 ) t
 where profile_name = '고객')
and a.owner = b.owner and a.constraint_name = b.constraint_name
group by a.constraint_type;
```

테이블 관계와 관련된 데이터베이스입니다. 대표적으로 Primary Key와 Foreign key가 있습니다. 
대부분 논리적인 모델링에서 물리적 모델링으로 변화할때 성능 및 관리의 이유로 Foreign key부분이 제외됩니다. 
하지만 LLM에게는 테이블의 관계가 매우 중요하기 때문에, 테이블관계에 대한 정보를 제공하는것이 필요합니다. 
Foreign key로 테이블 관계가 없을 경우 수기로 텍스트로 작성해서 넣도록 합니다. (AI_PRFILE에 컬럼을 추가하여 테이블 관계에 대한 정보를 관리하면 됩니다. )

{% include codeHeader.html copyable="true" codetype="text"%}
```json
[{"key":"Primary keys : ","column_list":["VECTOR.PARTS.PART_ID","VECTOR.ITEMS_AS_GUIDE.ID","VECTOR.ITEM_PARTS.ID","VECTOR.ITEMS.ITEM_ID","VECTOR.ORDERS.ORDER_ID","VECTOR.CUSTOMERS.USER_ID"]},{"key":"Foreign keys : ","column_list":["VECTOR.ORDERS.USER_ID->VECTOR.CUSTOMERS.USER_ID","VECTOR.ITEMS_AS_GUIDE.ITEM_ID->VECTOR.ITEMS.ITEM_ID","VECTOR.ITEM_PARTS.PART_ID->VECTOR.PARTS.PART_ID","VECTOR.ITEM_PARTS.ITEM_ID->VECTOR.ITEMS.ITEM_ID","VECTOR.ORDERS.ITEM_ID->VECTOR.ITEMS.ITEM_ID"]}]
```
#### 3. 프롬프트 작성

LLM에 SQL 자동 작성 요청을 위하여 프롬프트를 작성합니다. 
앞서 조회한 메타데이터를 제공하고, 사용자 질문을 같이 전달하여 SQL 작성요청을 합니다. 
그리고 답변은 애플리케이션에서 쉽게 사용하도록 JSON형식으로 답변하도록 요청합니다. 

프롬프트 작성시 추가적으로 작성이 필요한 부분이 있습니다. SQL 사용방법입니다. 
23ai버전 부터 지원하는 벡터 검색기능은 아직 LLM모델에서 학습이 되어 있지 않습니다. One-Shot Learning을 위하여 프롬프트에 작성예시를 추가하였습니다. 

```sql
지침 : 당신은 오라클 SQL 전문가입니다. 주어진 입력 질문에 대해 먼저 실행할 구문적으로 올바른 오라클 SQL 쿼리를 작성하십시오. 질문에 답하는 데 필요한 컬럼만 질의해야합니다. 아래 테이블에서 볼 수 있는 열 이름만 사용하십시오. 존재하지 않는 열을 조회하지 않도록 주의하십시오. 또한 각 열이 어느 테이블에 있는지 주의하십시오. 

다음 형식(JSON)으로 답변하세요:
{"user_question": 질문 내용, "generated_sql": 생성된 SQL 쿼리}

Context: 다음 테이블과 열만 사용하십시오. 테이블과 관련없는 질문일경우 "N/A"로 표기합니다.

Tables information : 
[TABLE_INFO]

Primary Keys and Foreign Keys:
[KEY_INFO]
        
Conditions : 
[USER_ID]

참고사항 : 
1. VECTOR 데이터타입은 오라클 데이터베이스 최신버전에 추가된 데이터 타입입니다. 백터 검색을 활용하면 비정형데이터를 검색할수 있습니다. 지리적인 계산을 할수 없습니다. 벡터간 거리 계산을 위하여 vector_distance함수를 제공합니다. vector_distance은 2개의 인자를 받습니다. 첫번째 인자는 데이터벡터, 두번째 인자는 쿼리벡터입니다. 쿼리벡터는 사용자가 제공되는 벡터값으로 사용합니다. 만약 사용자 질문중에 메뉴얼이나 교체 방법에 대한 텍스트 검색을 할때 아래 예제를 참고하여 SQL을 작성하세요 

메뉴얼 검색 예시1
select PART_ID,CHUNK_ID, CHUNK_TEXT from  PARTS_GUIDE 
order by vector_distance(EMBEDDING, vector_embedding(doc_model_han using ''질문내용'' as data))
fetch first 5 rows only;

Question : [QUESTION]
```

오라클 데이터베이스는 벡터 임베딩을 위한 임베딩 모델을 DB내에서 저장하고 호출할수 있습니다. 쿼리 벡터 만드는 작업이 SQL내에서 처리되므로 벡터 검색 기술을 사용할수 있는 SQL구문 작성이 가능합니다. 

### 4. SQL 자동 생성 함수 

SQL 자동 생성을 자동하는 함수를 생성합니다. 역할과 사용자정보, 질문을 넣으면 자동으로 SQL을 생성합니다. 
p_user_id는 해당 업무에서는 이미 사용자 로그인되어 있다는 전제로 개인화된 SQL작성을 위하여 사용자ID를 추가하였습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION generate_sql(p_persona  varchar2,p_user_id number, p_chat_message varchar2) 
RETURN CLOB IS
     v_prompt clob;
     output clob;
     v_table_info clob;
     v_key_info clob;
BEGIN 
    
     select json_arrayagg(
            json_object(a.table_name, c.comments,
            'columns' is (
               select json_arrayagg(
                    json_object( a.owner, b.column_name, b.data_type, d.comments)
                    )
                from dba_tab_cols b, dba_col_comments d
                  where a.owner = b.owner
                    and  a.table_name = b.table_name 
                    and b.owner = d.owner
                    and b.table_name = d.table_name
                    and b.column_name = d.column_name
                    and b.hidden_column = 'NO'
                )
           ) returning CLOB) into v_table_info
     from dba_tables a, dba_tab_comments c 
     where (a.owner, a.table_name) in ( select t.owner, t.name from ai_profile a 
        CROSS JOIN JSON_TABLE(
            a.object_list, 
            '$.object_list[*]' COLUMNS (
                owner VARCHAR2(4000) PATH '$.owner',
                name VARCHAR2(4000) PATH '$.name'
            )
     ) t
     where profile_name = p_persona)
     and a.owner = c.owner
     and a.table_name = c.table_name;
     
    select json_arrayagg(
        json_object( 'key' is decode(a.constraint_type,'P','Primary keys : ','R','Foreign keys : '), 'column_list' is json_arrayagg(
        (b.owner||'.'||b.table_name||'.'||b.column_name)||
        (case when a.r_constraint_name is not null then '->'||(select d.owner||'.'||d.table_name||'.'||d.column_name from dba_constraints  c,  dba_cons_columns d
         where a.r_owner = c.owner and a.r_constraint_name = c.constraint_name
         and c.constraint_name = d.constraint_name
         and c.owner = d.owner) else '' end)))) into v_key_info
from dba_constraints a , dba_cons_columns b
where 1=1
and   a.constraint_type IN ('P', 'R') 
and  (a.owner, a.table_name) in (select t.owner, t.name from ai_profile a 
    CROSS JOIN JSON_TABLE(
        a.object_list, 
        '$.object_list[*]' COLUMNS (
            owner VARCHAR2(4000) PATH '$.owner',
            name VARCHAR2(4000) PATH '$.name'
        )
 ) t
 where profile_name = p_persona)
and a.owner = b.owner and a.constraint_name = b.constraint_name
group by a.constraint_type;

    v_prompt := '당신은 오라클 SQL 전문가입니다. 주어진 입력 질문에 대해 먼저 실행할 구문적으로 올바른 오라클 SQL 쿼리를 작성하십시오. 질문에 답하는 데 필요한 컬럼만 질의해야합니다. 아래 테이블에서 볼 수 있는 열 이름만 사용하십시오. 존재하지 않는 열을 조회하지 않도록 주의하십시오. 또한 각 열이 어느 테이블에 있는지 주의하십시오. 

다음 형식(JSON)으로 답변하세요:
{"user_question": 질문 내용, "generated_sql": 생성된 SQL 쿼리}

Context: 다음 테이블과 열만 사용하십시오. USER_ID=[USER_ID] 조건을 포함하여 SQL구문을 작성하세요. 테이블과 관련없는 질문일경우 "N/A"로 표기합니다.

Tables information : 
[TABLE_INFO]

Primary Keys and Foreign Keys:
[KEY_INFO]

참고사항 : 
1. VECTOR 데이터타입은 오라클 데이터베이스 최신버전에 추가된 데이터 타입입니다. 백터 검색을 비정형데이터를 검색할수 있습니다. 지리적인 계산을 할수 없습니다. 벡터간 거리 계산을 위하여 vector_distance함수를 제공합니다. vector_distance은 2개의 인자를 받습니다. 첫번째 인자는 데이터벡터, 두번째 인자는 쿼리벡터입니다. 쿼리벡터는 사용자가 제공되는 벡터값으로 사용합니다.
만약 사용자 질문중에 메뉴얼이나 교체 방법에 대한 텍스트 검색을 할때 아래 예제를 참고하여 SQL을 작성하세요 

메뉴얼 검색 예시1
select PART_ID,CHUNK_ID, CHUNK_TEXT from  PARTS_GUIDE 
order by vector_distance(EMBEDDING, vector_embedding(doc_model_han using ''질문내용'' as data))
fetch first 5 rows only; 
    
Question : [QUESTION]';

    v_prompt := replace(v_prompt,'[QUESTION]', p_chat_message);
    v_prompt := replace(v_prompt,'[TABLE_INFO]', v_table_info);
    v_prompt := replace(v_prompt,'[KEY_INFO]', v_key_info); 
    v_prompt := replace(v_prompt,'[USER_ID] ', p_user_id);
    output := generate_text('gpt-3.5-turbo', v_prompt);
    output := replace(output, CHR(10) || CHR(13) || CHR(9),'');
    RETURN output;
END;
/
```

**SQL 생성 테스트** 

사용자가 내가 구매한 상품이 무엇인지에 대해서 질의하였습니다.
해당 질의에 맞게 SQL구문을 작성합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select generate_sql('고객',1,'내가 구매한 상품이 무엇인가요');
```

SQL구문 생성 결과입니다. 테이블간 조인하여 데이터를 검색합니다. 

```json
{"user_question": "내가 구매한 상품이 무엇인가요", "generated_sql": "SELECT i.ITEM_NAME FROM ITEMS i JOIN ORDERS o ON i.ITEM_ID = o.ITEM_ID WHERE o.USER_ID = 1"}
```

사용자가 특정 푸품과 관련 메뉴얼 검색해달라고 질의하였습니다. 
해당 질의에 맞게 SQL구문을 작성합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select generate_sql('AS기사',1,'송풍팬 교체하는 방법을 무엇이죠? 부품 메뉴얼을 찾아서 알려주세요.');
```

SQL구문 생성결과입니다. 메뉴얼 검색을 위하여 벡터 검색을 사용하였습니다.

```json
{"user_question": "송풍팬 교체하는 방법을 무엇이죠? 부품 메뉴얼을 찾아서 알려주세요.", "generated_sql": "select PART_ID, CHUNK_ID, CHUNK_TEXT from PARTS_GUIDE order by vector_distance(EMBEDDING, vector_embedding(doc_model_han using '송풍팬 교체하는 방법' as data)) fetch first 5 rows only;"}
```

오라클 데이터베이스는 멀티 모델을 지원하고 있습니다. 정형데이터 뿐만 아니라 비정형 데이터를 위한 벡터 검색 기술을 제공하고 있습니다. 이외 JSON, XML, Spatial, Graph등 다양한 데이터 타입을 지원합니다. 

> 하나의 통합된 데이터베이스에 접속하여 SQL을 생성하고 실행하면 RAG에 필요한 데이터를 다양한 방법으로 다양한 형식의 데이터를 효율적으로 검색할수 있습니다. 

### 5. RAG 활용

SQL 자동 생성 기능을 이용하여 간단한 RAG 프로그램을 작성하도록 하겠습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION generate_text_for_demo(p_persona varchar2, p_user_id number,p_chat_message varchar2) 
RETURN CLOB IS
     v_prompt clob;
     output clob;
     v_return clob := '검색결과가 없습니다';
     v_gen_sql clob;
     p_sql clob;
BEGIN 
    v_prompt := '지침 : 당신은 친절하게 답변하는 챗봇서비스입니다. 질문한 사람의 역할은 [PERSONA] 입니다. 최대한 개인화된 답변으로 500자이내로 답변하세요 

Context: [CONTEXT]
Question : [QUESTION]    
    ';

   select generate_sql(p_persona,p_user_id,p_chat_message) into v_gen_sql;

   p_sql := JSON_OBJECT_T.PARSE(v_gen_sql).GET_STRING('generated_sql');

    if p_sql != 'N/A' then
         DBMS_SESSION.SET_IDENTIFIER(p_user_id);
        EXECUTE IMMEDIATE
             'select json_arrayagg(json_object(*)) from ('||replace(p_sql,';','')||')'
          INTO v_return;
    end if;
     v_prompt := replace(v_prompt,'[CONTEXT]', v_return);
     
    v_prompt := replace(v_prompt,'[PERSONA] ', p_persona);
    v_prompt := replace(v_prompt,'[QUESTION]', p_chat_message);
   
    
    output := generate_text('gpt-3.5-turbo', v_prompt);
    RETURN output;
END;
/ 
```

**RAG 테스트** 

SQL 생성 테스트와 동일한 질문을 하였습니다. 
내가 구매한 상품이 무엇인지를 검색하면 고객의 구매내역을 기반으로 답변을 합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select generate_text_for_demo('고객',1,'내가 구매한 상품이 무엇인가요');
```

답변내용입니다. 

```text
안녕하세요! 구매하신 상품은 "에어컨"입니다. 에어컨을 구매하셔서 시원한 공기를 즐기실 수 있을 거예요. 에어컨 사용에 관해 궁금한 점이 있거나 도움이 필요하신 경우 언제든지 물어봐 주세요. 쾌적한 환경에서 편안하게 시간을 보내시길 바랄게요. 이 외에도 궁금한 점이 있으면 말해주세요! 같이 해결해 나가요.
```

에어컨 부품중 하나인 송풍팬 교체작업에 대해서 질문을 하였습니다. 
벡터 검색을 통하여 메뉴얼 기반으로 답변을 수행합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select generate_text_for_demo('AS기사',1,'송풍팬 교체하는 방법을 무엇이죠? 부품 메뉴얼을 찾아서 알려주세요.');
```

답변내용입니다.

```text
"에어컨 송풍팬을 교체하는 과정은 다소 복잡할 수 있지만, 아래 단계를 따라 진행하면 도움이 될 것입니다. 

1. 전원 차단: 에어컨의 전원을 차단합니다.
2. 에어컨 커버 분해: 외부 커버를 나사를 푸는 드라이버로 제거합니다.
3. 송풍팬 고정 나사 제거: 송풍팬을 고정하는 나사를 드라이버로 풀어줍니다.
4. 송풍팬 분리: 모든 나사를 제거한 후 송풍팬을 분리합니다.
5. 새 송풍팬 설치: 새로운 송풍팬을 설치하고 나사로 고정합니다.
6. 커버 재조립 및 테스트: 에어컨 커버를 다시 조립하고, 전원을 켜서 송풍팬이 정상 작동하는지 확인합니다.
7. 청소 및 유지관리: 내부 청소 후 재조립하는 것이 좋습니다.

요청하신 부품 메뉴얼은 제공되지 않았지만, 이 단계를 따라하면 송풍팬 교체를 성공적으로 수행할 수 있습니다. 부품 메뉴얼을 찾는 데 도움이 필요하시면 추가 안내를 받아보세요."
```

## 마무리

지금까지 오라클 데이터베이스를 이용하여 RAG 구현 및 RAG에 필요한 데이터를 검색하는 SQL 자동 생성 기능에 대해서 알아보았습니다. 
SQL 작성 방법은 생각보다 간단합니다. 또한 SQL 생성 및 RAG 연결하는 절차도 생각보다 간단합니다. 

질문에 필요한 데이터를 스스로 검색하는 기술을 활용할 경우 CONTEXT의 크기를 줄일수 있고, 보다 정확한 답변을 위한 의미있는 데이터를 제공할수 있게 됩니다. 충분히 기업내에서도 활용할수 있을것으로 생각됩니다. 

데이터베이스의 영역이 이제 데이터 저장소에서 비정형 데이터를 생성하는 역할도 추가되고 있습니다. 기존에 정형화된 데이터간 연계, 정형화 데이터로 생성해야만 비즈니스에서 활용되었다면, 이제는 텍스트와 같은 비정형 데이터를 생성하거나, 비정형 데이터를 보다 쉽게 접근하여 분석할수 있는 기능들이 추가되고 있습니다. 

다음은 SQL자동 생성기능 구현시 오라클 데이터베이스의 특징 및 고려사항들을 정리한 내용입니다. 

- SQL 구문 생성시 이점
  - 오라클데이터베이스는 45년의 가장 많이 사용되는 데이터베이스로 메뉴얼과 관련지식들이 많이 있음. 
  - 따라서 LLM은 누구보다도 오라클 데이터베이스 SQL을 잘 알고 있음(이미 학습되어 있음)
  - 오라클 데이터베이스는 JSON처리를 잘하는 데이터베이스(API처리, LLM PARAMS관리, 메타데이터, 데이터 결과등)임, 또한 LLM에서 잘 이해할수 있는 JSON형식으로 데이터 제공할수 있으므로 금상첨화임.
- 데이터 조회의 단순화
  - 단일 오라클 데이터베이스에서 모든형식의 데이터 조회가 가능, Converged Database이기 때문에 가능함
  - 데이터 이해를 위한 풍부한 메타 데이터 제공(Comments, Annotations, SQL Domains)
  - 메뉴얼 검색의 경우 자동으로 텍스트 유사도 검색을 통해서 가능(이는 DB내에서 임베딩모델을 지원하기 때문에 가능한것임) (One(Two)-Shot Learning으로 신규 SQL 사용가능)
  - 애플리케이션 변경없이 DBMS엔진레벨에서 SQL 튜닝 가능(SPM, SQL Profile, Resource Manager)
- 엔진레벨의 데이터 보안
  - SQL이 자동생성되는 환경에서 데이터 조건만으로 보안을 유지하기 어려움. LLM모델에 의해서 SQL이 생성되므로 불순한 목적으로 프롬프트를 작성할경우 데이터 탈취가 가능
  - 오라클 데이터베이스는 보다 근본적으로 DBMS엔진레벨에서 데이터 보안 방법을 지원(VPD, Redaction(ASO필요), Read Only Schema, Fine-Grained Audit등)

다음에는 SQL 튜닝 및 다양한 관리 방법을 LLM과 연동하여 어떤 재미있는 일들을 데이터베이스를 통해서 해낼수 있는지 찾아보고 공유드리겠습니다.

## 참고문서

- Oracle AI Vector Search User's Guide
  - <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}