---
layout: single
title: "[오라클] 생성형 AI와의 연동(3) - SQL 생성 및 검색"
date: 2024-12-17 21:00
categories: 
  - vector-search
books:
 - oracleaivectorsearch
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
   - RAG
excerpt : "생성형 AI를 활용하여 SQL을 자연어로 작성하는 방법에 대해서 알아봅니다."
header : 
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

최근 기업에서는 생성형 AI를 활용해 자연어로 SQL을 생성하고 이를 업무에 활용하려는 노력이 활발히 진행되고 있습니다. 이는 데이터 처리와 검색 측면에서 매우 큰 변화를 가져올 수 있습니다.

모든 데이터를 정확히 알지 못하더라도, AI가 자동으로 SQL을 생성하고 실행하여 원하는 데이터를 검색해 준다면, 데이터 분석가뿐만 아니라 SQL 비전문가도 데이터에 쉽게 접근할 수 있습니다. 이는 데이터 활용의 문턱을 크게 낮추는 혁신적인 변화입니다.

이 글에서는 SQL 생성을 위해 필요한 단계를 살펴보고, 더 나아가 SQL 관리 업무로 확장하여 실제로 어떻게 활용할 수 있는지 다양한 사례를 통해 알아보겠습니다.

## SQL 생성을 위한 프롬프트 예시

**LLM(대규모 언어 모델)**은 인터넷 상의 방대한 데이터를 기반으로 학습되었기 때문에, 오라클 데이터베이스와 관련된 메뉴얼 및 지식 또한 잘 알고 있을 가능성이 높습니다. 특히 오라클 데이터베이스는 45년 이상 전 세계적으로 널리 사용되어 왔기 때문에, LLM은 SQL 작성에 있어 상당히 높은 수준의 이해도를 가지고 있다고 기대할 수 있습니다.

아래와 같은 프롬프트를 작성하여 LLM에게 SQL 작성을 요청할 수 있습니다.
이 프롬프트는 LLM이 구문적으로 올바른 SQL을 생성하도록 돕고, 특정 테이블과 열만 사용할 수 있도록 제약 조건을 설정합니다.

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

위 프롬프트를 사용해 LLM에게 질문하면, 다음과 같은 SQL 쿼리를 생성할 수 있습니다.

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

위와 같이, LLM은 질문에 맞는 SQL을 작성하고, 테이블과 열 이름, 관계를 고려해 정확한 결과를 반환할 수 있습니다.

이런 접근 방식은 다음과 같은 장점을 제공합니다
- SQL 비전문가도 쉽게 활용 가능: 자연어 질문만으로 SQL 작성 가능합니다.
- 구문 오류 방지: LLM이 자동으로 구문과 테이블 관계를 검증하여 오류를 방지합니다.
- 효율적인 데이터 분석: 올바른 SQL을 빠르게 생성해 데이터 검색 및 처리 시간 단축할수 있습니다.

LLM에서 SQL생성 요청을 하면 데이터 분석 및 검색 작업이 더 쉽고 효율적이 될 수 있습니다.

## SQL 생성 및 검색을 위한 구성 요소

 SQL 자동 생성을 구현하려면 아래와 같은 주요 구성 요소들을 고려해야 합니다. Oracle 데이터베이스는 DBMS_VECTOR_CHAIN 패키지를 통해 **LLM(대규모 언어 모델)**과 통신할 수 있는 기능을 제공하므로, 데이터베이스에서 직접 통신하는 방식을 활용했습니다.

**구성요소 및 지원 방법**

|구분|구성요소|지원방법|비고|
|---|---|---|---|
|LLM연동|LLM모델|외부 모델 활용(OpenAI, Google AI,OCI Gen AI, Cohere등)|Multilingual 지원|
||LLM통신인증|DBMS_VECTOR_CHAIN.CREATE_CREDENTIAL 사용|API Key등록|
||LLM통신방법|DBMS_VECTOR_CHAIN.UTL_TO_GENERATE_TEXT 사용|LLM에게 답변 요청|
||네트워크 권한|권한부여(DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE)||
|프롬프트작성|테이블 범위 지정|특정 사용자와 테이블 접근 목록 지정 (예: sql_gen_profile 테이블 생성)||
||테이블 메타데이터|테이블명, 컬럼명, 데이터형식, Comments, Annotations, SQL Domain, Primary Key, Foreign Key|메타데이터를 기반으로 SQL생성가능|
|검색|데이터 스토어|Multi-Model지원(JSON, XML, Spatial, Graph, Vector Search, CLOB, BLOB)|최신 SQL은 One-shot learning|
|보안|데이터 보안|SQL변경없이 DBMS엔진레벨에서 보안적용|접근 행 제어(Virtual Private Database)<br> 동적 마스킹 ( Data Redaction(ASO필요) )|
 
오라클 데이터베이스는 데이터 이해와 관리를 위한 풍부한 메타데이터를 제공합니다.

예를 들어:
- Comments: 테이블 및 컬럼에 대한 설명 추가 가능
- Annotations: 테이블과 컬럼의 의미를 설명
- SQL Domain: 데이터의 사용 목적과 타입을 정의

이 글에서는 테이블의 Comments 정보만 사용했지만, 더 정확한 SQL 생성을 위해 추가적인 메타데이터를 활용할 수 있습니다.

**SQL자동 생성과 보안문제**

LLM을 이용한 SQL 자동 생성은 매우 유용하지만, 보안적 측면에서 주의가 필요합니다.
예를 들어, 의도적으로 민감한 데이터를 탈취하려는 질문이 들어올 경우 데이터 노출 위험이 발생할 수 있습니다.

특히 SQL 자동작성에서는 엄격한 보안적용이 필요합니다. 오라클 데이터베이스는 DBMS엔진레벨에서 적용할수 있는 많은 보안 방법들이 있습니다. 

예로, DB 세션 컨텍스트 기반으로 조건을 강제 추가하는 VPD기능, 접속한 유저에 따라서 특정 정보를 조회할때 마스킹할수 있는 동적 마스킹(Redaction)기능들을 제공하고 또한 Audit기능도 제공하고 있습니다. 

## 프롬프트 작성
 
### 1. 테이블 범위 지정

LLM이 SQL을 생성하려면 테이블 구조 정보가 필요합니다. 이때, 업무나 역할별로 접근 가능한 테이블을 명확히 지정하여 프롬프트 작성에 활용할 수 있습니다. 테이블 목록과 관계 정보를 기반으로 메타데이터를 생성하고, 테이블 접근 범위를 제한함으로써 1차 보안 역할을 수행할 수 있습니다.

- 테이블 범위 지정의 중요성
  - 메타데이터 생성 : 테이블 목록을 기반으로 SQL 생성을 위한 메타데이터 제공
  - 업무/역할별 접근 제한 : 역할에 따라 접근 가능한 테이블을 제한해 보안 강화

**프로파일 관리 테이블 생성**

테이블 목록과 관계 정보를 관리하기 위해 프로파일 관리 테이블을 생성합니다.
이 테이블은 JSON 형식으로 테이블 목록과 테이블 간 관계 정보를 관리합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 프로파일 관리 테이블
CREATE TABLE IF NOT EXISTS sql_gen_profile(
    profile_name VARCHAR2(1000) PRIMARY KEY, --프로파일 명
    object_list JSON, -- 테이블 목록
    object_relationals JSON -- 테이블관계정보
);
```

**테이블 관계 정보**

대부분의 기업은 성능 및 관리상의 이유로 물리적 테이블 관계를 설정하지 않는 경우가 많습니다. SQL 생성 작업을 수행하려면 테이블 간 관계 정보가 매우 중요하므로, 별도의 컬럼을 추가해 관계 정보를 관리해야 합니다.

이 예제에서는 SH 스키마를 사용하며, 테이블 관계 정보를 수동으로 작성하지 않았습니다. 실제 기업 환경에서는 테이블 관계 정보를 작성하여 프롬프트 생성 시 활용해야 합니다.

**프로파일 데이터 삽입**

아래는 SH 스키마와 ADMIN 스키마의 테이블 목록 정보를 삽입한 예제입니다.
- SH_SCHEMA: SH 스키마([Sample Schema](blog/oracle/how-to-install-sample-schema/){:target="_blank"})의 실제 테이블 정보
- ADMIN_SCHEMA: SH 스키마의 복제본으로, 테이블명과 컬럼명을 임의의 텍스트로 변경하여 의미를 알기 어렵게 만듦(고객 환경과 유사한 상황으로 가정)

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
INSERT INTO sql_gen_profile(profile_name, object_list) 
VALUES
   ('ADMIN_SCHEMA','
            { object_list : [{"owner": "ADMIN","name":"TABLE01"},
                {"owner": "ADMIN","name":"TABLE02"},
                {"owner": "ADMIN","name":"TABLE03"},
                {"owner": "ADMIN","name":"TABLE04"},
                {"owner": "ADMIN","name":"TABLE05"}, 
                {"owner": "ADMIN","name":"TABLE06"},
                {"owner": "ADMIN","name":"TABLE07"},
                {"owner": "ADMIN","name":"TABLE08"},
                {"owner": "ADMIN","name":"TABLE09"},
            ]}
    '),
    ('SH_SCHEMA','
            { object_list : [{"owner": "SH","name":"COUNTRIES"},
                {"owner": "SH","name":"CUSTOMERS"},
                {"owner": "SH","name":"PROMOTIONS"},
                {"owner": "SH","name":"PRODUCTS"},
                {"owner": "SH","name":"TIMES"}, 
                {"owner": "SH","name":"CHANNELS"},
                {"owner": "SH","name":"SALES"},
                {"owner": "SH","name":"COSTS"},
                {"owner": "SH","name":"SUPPLEMENTARY_DEMOGRAPHICS"},
            ]}
    ');

COMMIT;
```

삽입된 테이블 목록 정보를 테이블 형식으로 조회할 수 있도록 VIEW를 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 프로파일별 테이블 목록 확인
CREATE OR REPLACE VIEW vw_sql_profile AS
SELECT a.profile_name, t.owner, t.name 
  FROM sql_gen_profile a 
    CROSS JOIN JSON_TABLE(
        a.object_list, 
        '$.object_list[*]' COLUMNS (
            owner VARCHAR2(4000) PATH '$.owner',
            name VARCHAR2(4000) PATH '$.name'
        ) 
    ) t;
```
 
### 2. 테이블 메타데이터 생성

테이블 메타데이터는 SQL 작성에 필요한 정보를 제공합니다.
메타데이터는 크게 테이블 구조와 테이블 관계로 구분되며, LLM에게 프롬프트로 제공할 때 JSON 형식으로 제공하면 더 효과적으로 이해할 수 있습니다.

오라클 데이터베이스의 ALL_TABLES, ALL_TAB_COLS, ALL_CONSTRAINTS 등의 JSON 뷰를 활용하여 테이블 구조 정보를 조회합니다.
조회 결과는 JSON 형식으로 출력하며, 테이블 이름, 컬럼 정보, 그리고 주석(Comments) 정보를 포함합니다.

- [Read-Only Views Based On JSON Generation](https://docs.oracle.com/en/database/oracle/oracle-database/23/adjsn/read-only-views-based-json-generation.html){:target="_blank"}

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 테이블 정보 조회 VIEW생성( comment정보 , contraints 정보 활용)
CREATE OR REPLACE VIEW vw_object_info AS 
  SELECT  at.owner owner,
          at.table_name table_name,
          JSON {
            'owner' : at.owner,'table_name': at.table_name,'comments': atcmt.comments,
            'columns' :[ 
				SELECT JSON {'column_name' : atcol.column_name,
				             'data_type' : atcol.data_type,
							 'comments': accmt.comments }
					  FROM all_tab_cols atcol, all_col_comments accmt
					WHERE atcol.owner = accmt.owner
					AND atcol.table_name = accmt.table_name
                    AND atcol.column_name = accmt.column_name
					AND atcol.owner = at.owner
					AND atcol.table_name = at.table_name
					AND atcol.hidden_column = 'NO'
			],
			'constraints' : [
				SELECT JSON {
                           --'constraint_name'  : ac.constraint_name,
							'constraint_type'  : decode(ac.constraint_type,'P','Primary key','R','Foreign key'), 
							'columns':[
							        SELECT JSON {'owner' : acc.owner,'table_name':acc.table_name,'column_name' : acc.column_name }
									FROM all_cons_columns  acc
									WHERE ac.owner = acc.owner 
									AND ac.constraint_name = acc.constraint_name
								],
							'refereced_column':[
								SELECT JSON {'owner' : acc.owner,'table_name':acc.table_name,'column_name' : acc.column_name }
								FROM all_constraints acs, all_cons_columns  acc
								WHERE acs.owner = acc.owner 
								 AND acs.constraint_name = acc.constraint_name
								 AND ac.r_owner = acs.owner 
								AND ac.r_constraint_name = acs.constraint_name
							]
							}
					  FROM all_constraints ac
					WHERE ac.owner = at.owner
					  AND ac.table_name = at.table_name
					  AND ac.constraint_type IN ('P', 'R')
			]
			} data
    FROM all_tables at, all_tab_comments atcmt
    WHERE at.owner = atcmt.owner
	  AND at.table_name = atcmt.table_name;
 ```

뷰에서 특정 테이블의 메타데이터를 조회하면 다음과 같이 JSON 형식으로 출력됩니다.
예를 들어, ADMIN 스키마의 TABLE06에 대해 조회하면 다음과 같은 SQL을 사용할 수 있습니다:

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select json_serialize(json_arrayagg(data)) from vw_object_info where owner = 'ADMIN' and table_name = 'TABLE06';
```

조회된 메타데이터는 JSON 형식으로 출력됩니다. 

```json
[
  {
    "owner":"ADMIN","table_name":"TABLE06","comments":"dimension table",
    "columns":
    [
      {"column_name":"COL01","data_type":"NUMBER","comments":"primary key"},
      {"column_name":"COL02","data_type":"VARCHAR2","comments":"product name"},
      {"column_name":"COL03","data_type":"VARCHAR2","comments":"product description"},
      {"column_name":"COL04","data_type":"VARCHAR2","comments":"product subcategory"},
      {"column_name":"COL05","data_type":"NUMBER","comments":null},
      {"column_name":"COL06","data_type":"VARCHAR2","comments":"product subcategory description"},
      {"column_name":"COL07","data_type":"VARCHAR2","comments":"product category"},
      {"column_name":"COL08","data_type":"NUMBER","comments":null},
      {"column_name":"COL09","data_type":"VARCHAR2","comments":"product category description"},
      {"column_name":"COL10","data_type":"NUMBER","comments":"product weight class"},
      {"column_name":"COL11","data_type":"VARCHAR2","comments":"product unit of measure"},
      {"column_name":"COL12","data_type":"VARCHAR2","comments":"product package size"},
      {"column_name":"COL13","data_type":"NUMBER","comments":"this column"},
      {"column_name":"COL14","data_type":"VARCHAR2","comments":"product status"},
      {"column_name":"COL15","data_type":"NUMBER","comments":"product list price"},
      {"column_name":"COL16","data_type":"NUMBER","comments":"product minimum price"},
      {"column_name":"COL17","data_type":"VARCHAR2","comments":null},
      {"column_name":"COL18","data_type":"NUMBER","comments":null},
      {"column_name":"COL19","data_type":"NUMBER","comments":null},
      {"column_name":"COL20","data_type":"DATE","comments":null},
      {"column_name":"COL21","data_type":"DATE","comments":null},
      {"column_name":"COL22","data_type":"VARCHAR2","comments":null}
    ],
    "constraints":
    [
      {
        "constraint_type":"Primary key",
        "columns":[
          {"owner":"ADMIN","table_name":"TABLE06","column_name":"COL01"}
        ],
        "refereced_column":[]
      }
    ]
  }
]
```
 
대부분의 물리적 모델링에서 Foreign Key를 생략하는 경우가 많습니다.
LLM은 테이블 관계 정보를 필요로 하기 때문에, 관계 정보를 수동으로 작성하여 sql_gen_profile의 object_relationals 컬럼에 추가할 수 있습니다.

**3. 프롬프트 작성**

SQL생성을 위한 프롬프트 텍스트는 테이블에 저장하여 반복적으로 사용할수 있습니다. 

좀더 자세한 내용은 텍스트 분석 및 변환 블로그 글을 참조하시기 바랍니다. my_task테이블 및 my_task_output테이블에 대한 정보를 확인합니다. 
- [생성형 AI와의 연동 - 데이터 분석 및 변환](/blog/vector-search/data-analysis-using-gen-ai-on-ai-vector-search/){:target="_blank"}

SQL 생성 및 SQL 설명 요청을 위한 프롬프트를 작성하고 저장합니다. 

```sql
INSERT INTO my_task(task_name, category_name,task_rules)  VALUES 
  ('SQL생성','SQL','당신은 오라클 SQL 전문가입니다. 주어진 입력 질문에 대해 먼저 실행할 구문적으로 올바른 오라클 SQL 쿼리를 작성하십시오. 질문에 답하는 데 필요한 컬럼만 질의해야합니다. 주어진 정보에 있는 테이블에서 볼 수 있는 열 이름만 사용하십시오. 존재하지 않는 열을 조회하지 않도록 주의하십시오. 또한 각 열이 어느 테이블에 있는지 주의하십시오. 테이블을 사용할때는 앞에 사용자명을 추가합니다. 테이블과 관련없는 질문일경우 "N/A"로 표기합니다.'),
  ('SQL설명','SQL','당신은 오라클 SQL 전문가입니다. 주어진 SQL문장에 대해서 제공되는 테이블정보를 이용하여 사용자가 이해하기 쉬운 내용으로 설명합니다. ');
```

각 작업별로 답변결과 형식을 지정합니다. 

```sql
INSERT INTO my_task_output(output_id, output_name, output_text, output_sample) VALUES 
(2,'JSON', '답변은 JSON형식으로만 생성합니다. JSON은 명확히 구조화되어야 하며, Markdown 형식으로 표시하지 마세요.','{"user_question":<사용자질문>,"reason":"<답변이유>","generated_sql":"<생성된 SQL>"}'), -- SQL 생성시 사용
(3,'JSON', '답변은 JSON형식으로만 생성합니다. JSON은 명확히 구조화되어야 하며, Markdown 형식으로 표시하지 마세요.','{"sql_text":<SQL구문>,"title":"<SQL작성목적>","description":"<SQL에 대한 설명>"}');  -- SQL 설명시 사용
```

SQL 생성 요청에 대한 프롬프트를 SQL로 생성할수 있습니다.

```sql
SELECT JSON_SERIALIZE(JSON_OBJECT(instruction, output_format  FORMAT JSON,input_data)) prompt
  FROM (SELECT t.task_rules instruction, 
               o.output_name,
               JSON_OBJECT('format' value o.output_text, 'example' value o.output_sample ) output_format,
	           '<제공된데이터>' input_data 
          FROM my_task t, my_task_output o
         WHERE t.task_name = 'SQL생성'
           AND o.output_id = 1);
```

프롬르트 생성 예시입니다. 

```json
{
  "instruction":"당신은 오라클 SQL 전문가입니다. 주어진 입력 질문에 대해 먼저 실행할 구문적으로 올바른 오라클 SQL 쿼리를 작성하십시오. 질문에 답하는 데 필요한 컬럼만 질의해야합니다. 주어진 정보에 있는 테이블에서 볼 수 있는 열 이름만 사용하십시오. 존재하지 않는 열을 조회하지 않도록 주의하십시오. 또한 각 열이 어느 테이블에 있는지 주의하십시오. 테이블을 사용할때는 앞에 사용자명을 추가합니다. 테이블과 관련없는 질문일경우 \"N/A\"로 표기합니다.",
  "output_format":
  {
    "format":"답변은 JSON형식으로만 생성합니다. JSON은 명확히 구조화되어야 하며, Markdown 형식으로 표시하지 마세요.",
    "example":"{\"reason\":\"<답변이유>\",\"generated_text\":\"<생성된답변>\"}"
  },
  "input_data":"<제공된데이터>"
}
```

## SQL 생성 및 검색

### 1. 텍스트 생성 요청

생성형 AI의 **언어 모델(LLM)**은 텍스트 생성 작업을 수행할 수 있으며, 이를 활용하면 메타데이터와 사용자 질문을 기반으로 SQL 생성 작업을 요청할 수 있습니다.
오라클 데이터베이스는 이를 지원하기 위해 DBMS_VECTOR_CHAIN 패키지를 사용한 텍스트 요청 작업을 제공합니다.

좀더 자세한 내용은 텍스트 생성 요청 블로그 글을 참조하시기 바랍니다. vm_my_models등을 포함하여 모델정보를 관리하는 방법이 작성되어 있습니다. 
- [생성형 AI와의 연동 - 텍스트 생성 요청](/blog/vector-search/text-genneration-using-gen-ai-on-ai-vector-search/){:target="_blank"}

아래는 텍스트 생성 요청을 처리하기 위한 사용자 정의 함수 예제입니다.
이 함수는 모델명과 프롬프트 내용을 입력받아 CLOB 형식의 데이터를 반환합니다.

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

### 2. SQL 생성 및 실행 

LLM을 활용하여 SQL을 자동으로 생성하고 실행하는 전체 흐름을 다음과 같이 구성할 수 있습니다.
SQL 생성을 자동화하기 위한 사용자 정의 함수를 작성합니다. 이 함수는 프로파일명과 사용자 질문을 입력받아, 테이블 메타데이터와 질문을 조합해 SQL을 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION generate_sql(p_model varchar2, p_prfile_name varchar2, p_question varchar2) 
RETURN CLOB IS
     v_prompt clob; 
     v_table_info clob; 
     output clob;
BEGIN 

-- 테이블 정보 가져오기
    SELECT  json_serialize(json_arrayagg(oi.data) returning CLOB)  into v_table_info
     FROM vw_object_info oi, vw_sql_profile sp
     WHERE oi.owner = sp.owner
       AND oi.table_name = sp.name
       AND sp.profile_name = p_prfile_name; 

-- 프롬프트 작성
  SELECT JSON_OBJECT(instruction, output_format,input_data, user_question returning CLOB ) into v_prompt
  FROM (SELECT t.task_rules instruction, 
               o.output_name,
               o.output_text||chr(10)||o.output_sample output_format,
	           v_table_info input_data,
               p_question user_question
          FROM my_task t, my_task_output o
         WHERE t.task_name = 'SQL생성'
           AND o.output_id = 2);

    output := generate_text(p_model, v_prompt); 
    RETURN output;
END;
/
```

**SQL 생성 예시**

질문: “상품 카테고리별 판매량은 얼마인가요?”

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select generate_sql('gpt-4o-mini','ADMIN_SCHEMA','상품 카테고리별 판매량은 얼마인가요?');
```

생성된 JSON 결과입니다. 

```json
{
  "user_question": "상품 카테고리별 판매량은 얼마인가요?",
  "reason": "판매량은 'TABLE01'의 'COL06'에서 확인할 수 있으며, 상품 카테고리는 'TABLE06'의 'COL07'에서 확인할 수 있습니다. 두 테이블을 조인하여 상품 카테고리별 판매량을 집계할 수 있습니다.",
  "generated_sql": "SELECT T6.COL07 AS 상품_카테고리, SUM(T1.COL06) AS 판매량 FROM ADMIN.TABLE01 T1 JOIN ADMIN.TABLE06 T6 ON T1.COL01 = T6.COL01 GROUP BY T6.COL07"
}
```

**SQL 실행 예시**

성된 SQL을 실행합니다. 실행 전에 애플리케이션 구분을 위해 모듈 정보와 액션 정보를 세션에 추가합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
exec DBMS_APPLICATION_INFO.SET_MODULE('SQLGEN', 'ADMIN_SCHEMA');
SELECT T6.COL07 AS 상품_카테고리, SUM(T1.COL06) AS 판매량 FROM ADMIN.TABLE01 T1 JOIN ADMIN.TABLE06 T6 ON T1.COL01 = T6.COL01 GROUP BY T6.COL07;
```

SQL 실행 결과입니다. 

![](/assets/images/blog/aivectorsearch/query_result1.png)

### 3. SQL 저장 및 검색

**SQL 저장 예시**

애플리케이션 세션 정보를 기반으로 생성된 SQL을 저장하고 검색할 수 있도록 SQL 저장 테이블을 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- SQL 검색 테이블
CREATE TABLE IF NOT EXISTS my_sql(
    sql_id VARCHAR2(1000) PRIMARY KEY, -- v$SQL 의 SQL_ID 
    sql_text CLOB,   -- V$SQL의 SQL_TEXT
    sql_desc JSON,   -- LLM에 의해서 생성된 설명내용
    sql_vector VECTOR  -- 설명내용에 대한 벡터값
);
```

SQL구문에 대한 설명정보를 추가하기 위하여 사용자 정의함수를 생성합니다.
LLM을 활용해 SQL 구문에 대한 설명을 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION describe_sql(p_model varchar2, p_prfile_name varchar2, p_sql_text varchar2) 
RETURN CLOB IS
     v_prompt clob; 
     v_table_info clob; 
     output clob;
BEGIN 

-- 테이블 정보 가져오기
    SELECT  json_serialize(json_arrayagg(oi.data) returning CLOB)  into v_table_info
     FROM vw_object_info oi, vw_sql_profile sp
     WHERE oi.owner = sp.owner
       AND oi.table_name = sp.name
       AND sp.profile_name = p_prfile_name; 

-- 프롬프트 작성
  SELECT JSON_OBJECT(instruction, output_format,input_data, sql_text returning CLOB ) into v_prompt
  FROM (SELECT t.task_rules instruction, 
               o.output_name,
               o.output_text||chr(10)||o.output_sample output_format,
	           v_table_info input_data,
               p_sql_text sql_text
          FROM my_task t, my_task_output o
         WHERE t.task_name = 'SQL설명'
           AND o.output_id = 3);

    output := generate_text(p_model, v_prompt); 
    RETURN output;
END;
/
```

자동 생성된 SQL과 관련 메타데이터 정보를 데이터베이스 테이블에 저장하기 위해 PL/SQL 구문을 작성합니다. 저장 시 벡터 검색을 지원하기 위해 SQL 설명 정보를 벡터화하며, 이를 위해 데이터베이스 내에 로드된 임베딩 모델을 활용합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
DECLARE 
  v_model_name varchar2(100) := 'gpt-4o-mini';
  v_response JSON;
  v_sql_title VARCHAR2(1000);
  CURSOR sql_cursor IS
     SELECT sql_id, sql_text, action profile_name 
       FROM v$sql 
      WHERE module = 'SQLGEN'  
        AND action in ('ADMIN_SCHEMA','SH_SCHEMA')
     ORDER BY sql_id
     FETCH FIRST 5 ROWS ONLY;

BEGIN
   FOR s_rec IN sql_cursor LOOP
       v_response := json(describe_sql(v_model_name, s_rec.profile_name, s_rec.sql_text));
       v_sql_title := JSON_VALUE(v_response, '$.title');
       INSERT INTO my_sql(sql_id, sql_text, sql_desc, sql_vector ) VALUES (s_rec.sql_id, s_rec.sql_text, v_response, 
           VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using v_sql_title as data )
       );
   END LOOP;
   COMMIT;
END;
/
```

**SQL 검색**

질문 : 최고 많이 판매한 제품
벡터 검색을 활용해 관련성이 높은 SQL을 검색합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT sql_id, to_char(sql_text) sql_text, JSON_SERIALIZE(sql_desc returning VARCHAR2(1000)) sql_desc, 
       VECTOR_DISTANCE(sql_vector, VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using '최고 많이 판매한 제품' as data ), COSINE) AS distance
  FROM my_sql
 ORDER BY distance 
 FETCH FIRST 1 ROWS ONLY;
```

SQL 검색결과입니다. 가독성을 위하여 JSON형식으로 출력하였습니다. 

```json
[
  {
    "SQL_ID":"9uybvbp3htm0b",
    "SQL_TEXT":"SELECT T6.COL07 AS 상품_카테고리, SUM(T1.COL06) AS 판매량 FROM ADMIN.TABLE01 T1 JOIN ADMIN.TABLE06 T6 ON T1.COL01 = T6.COL01 GROUP BY T6.COL07",
    "SQL_DESC": {
      "sql_text":"SELECT T6.COL07 AS 상품_카테고리, SUM(T1.COL06) AS 판매량 FROM ADMIN.TABLE01 T1 JOIN ADMIN.TABLE06 T6 ON T1.COL01 = T6.COL01 GROUP BY T6.COL07",
      "title":"상품 카테고리별 판매량 집계",
      "description":"이 SQL 쿼리는 ADMIN.TABLE01 (사실 테이블)과 ADMIN.TABLE06 (상품 차원 테이블)을 조인하여 각 상품 카테고리별로 판매량을 집계하는 것입니다. T1.COL01은 TABLE01의 외래 키로, T6.COL01은 TABLE06의 기본 키로 설정되어 있습니다. 쿼리는 각 상품 카테고리(T6.COL07)에 대한 판매량(SUM(T1.COL06))을 계산하고, 결과는 상품 카테고리별로 그룹화되어 반환됩니다."
    },
    "DISTANCE":0.09250301122665405
  }
]
```

## 마무리

지금까지 오라클 데이터베이스에서 LLM을 활용해 SQL을 생성하고 활용하는 방법에 대해 살펴보았습니다.
SQL 작성 과정은 생각보다 간단하며, 이러한 자동 생성 기능은 RAG(정보 검색 및 생성) 구현에서도 중요한 역할을 할 수 있습니다.

SQL 자동 생성 기술은 데이터를 보다 효율적으로 분석하고 검색할 수 있도록 지원하며, 데이터 활용의 새로운 가능성을 열어줍니다.
특히, SQL 비전문가도 쉽게 데이터를 활용할 수 있게 되어 조직 내 데이터 활용 범위를 확장할 수 있습니다.

나아가, 이러한 기술은 AI와 데이터베이스의 결합을 통해 더 높은 수준의 자동화와 혁신을 가능하게 할 것입니다. 

## 참고문서

- Oracle AI Vector Search User's Guide
  - <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}