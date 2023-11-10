---
layout: single
title: SELECT AI기능 소개
date: 2023-11-08 02:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - Autonomous Database
   - SELECT AI
excerpt : 자연어로 SQL질의할수 있는 SELECT AI기능이 Autonomous Database에 추가되었습니다.
header :
  teaser: /assets/images/blog/oracle23c.jpg
  overlay_image: /assets/images/blog/oracle23c.jpg
toc : true  
toc_sticky: true
---

**참고사항** <br>본문은 [Use Select AI to Generate SQL from Natural Language Prompts](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/sql-generation-ai-autonomous.html){: target="_blank"} 메뉴얼을 참고하여 작성된 글입니다. 
{: .notice} 

## 개요

오라클 클라우드에서는 Exadata인프라 기반위에서 동작하는 Autonomous Database 서비스를 제공합니다.
최근에 Autonomous Database에서 SELECT AI기능이 추가되어, 자연어로 데이터베이스에 질의할수 있게 되었습니다.

SELECT AI의 기능 및 사용방법에 대해서 알아보겠습니다.

## SELECT AI기능이란?

SELECT AI는 Autonomous Database에서 사용자가 제공한 자연어를 SQL 쿼리로 생성하고 실행할수 있는 기능입니다.
사용자가 선택한 LLM(대형언어모델)과 함께 스키마 메타데이터를 기반으로 사용자가 수동으로 수행할수 있는 작업을 자동화합니다.
SQL쿼리 결과 생성과 관련없는 프롬프트를 작성할수도 있지만, SELECT AI의 주요 기능은 SQL 쿼리생성에 중점을 두고 있습니다. 
SELECT AI를 사용하면 채팅작업을 통해 일반적인 질의도 가능합니다.

데이터베이스는 LLM의 할루시네이션을 완화하기 위하여 메타데이터로 사용자 지정 프롬프트를 강화하며 사용자가 지정한 LLM으로 전송하여 쿼리를 생성합니다.
데이터베이스는 스키마 메타데이터(스키마정의 테이블 및 열 설명, Dictionary 및 catalog)만으로 프롬프트를 강화하며 실제 행이나 열값은 사용하지 않습니다.
그러나 narrate 작업은 쿼리 결과를 자연어 텍스트로 생성시키기 위하여 데이터베이스 데이터를 사용자 지정 LLM에 제공할수 있습니다.

※ 주의사항 : 사용자 지정하는 LLM의 결과가 부정확한 결과를 생성하거나 보안을 손상시키는 SQL쿼리를 포함될수 있으므로 이 기능을 사용하는 위험에 대한 책임은 전적으로 사용자에게 있습니다.

## 내부적으로 동작하는 메커니즘은?
Autonomous Database에서 DBMS_CLOUD_AI패키지를 제공합니다.
DBMS_CLOUD_AI패키지는 자연어 프롬프트를 사용하여 SQL코드를 생성하기 위하여 사용자 지정 LLM과 연결합니다
그리고 이 패키지는 LLM에 데이터베이스 스키마에 대한 지식을 제공하고 해당 스키마와 일치하는 SQL 쿼리를 작성하도록 지시합니다.
DBMS_CLOUD_AI패키지는 OpenAI와 Cohere와 같은 AI Provider와 함께 동작합니다.

## SELECT AI 설정 및 사용절차

DBMS_CLOUD_AI패키지를 통해서 외부 AI Provider 를 등록합니다.
자연어로 질의하기 위한 테이블의 메타데이터를 포함한 AI Profile를 생성합니다. 
세션에 AI Profile을 설정하고 SELECT AI 구문으로 자연어로 질의하면 SQL이 실행되어 결과가 리턴됩니다.

### 1. 외부 AI Provider 접속정보를 설정

연동가능한 외부 AI Privider(LLM제공)은 OpenAI, Cohere, Azure AI Service가 있습니다. 
1. SELECT AI를 수행할 DB User에 DBMS_CLOUD_AI패키지 실행권한을 부여합니다.
2. AI Provider에 접근할수 있도록 네트워크 ACL에 추가합니다. 
3. AI Provider의 API key를 이용하여 Credential정보를 생성합니다.
   (생성된 Credential로 AI Profile를 생성할수 있습니다.)

```sql
-- DB User에게 권한부여 , ADMIN유저는 이미권한이 있음
GRANT EXECUTE ON DBMS_CLOUD_AI TO <DB User>;

-- DB User에게 Network ACL권한부여(OpenAI 예시)
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
  HOST => 'api.openai.com',
  ACE  => xs$ace_type(PRIVILEGE_LIST => xs$name_list('http'),
                      PRINCIPAL_NAME => '<DB User>',
                      PRINCIPAL_TYPE => xs_acl.ptype_db));
END;
/
-- Credential 생성(API key필요)(OpenAI 예시)
-- API Key생성하는것은 그냥 되지만 API 사용하려면 최소 5$를 결제해야 동작하는것 같습니다.
BEGIN
    dbms_cloud.create_credential (
        credential_name  => 'OPENAI_CRED',
        username => '<User Name>',
        password => '<API Key>'
    );
END;
/
```

### 2. AI Profile 생성

앞서 생성한 Credential정보를 이용하여 AI Profile를 생성합니다.
AI Profile에는 할루네이션를 완화하기 위하여 메타데이터를 설정할수 있습니다.
자연어로 질의에 참고되는 정보를 Object_list에 나열하여 테이블목록으로 설정합니다. 

SELECT AI이용한 자연어 질의시 테이블명과 컬럼명, 컬럼의 Comments정보가 추가된 메타데이터가 LLM에 전달합니다.

```sql
-- AI Profile 생성(Sales Hisitory 스키마구조)(OpenAI 예시)
-- 테이블목록은 오라클 데이터베이스 샘플 스키마인 SE(Sales History)입니다
BEGIN
  DBMS_CLOUD_AI.CREATE_PROFILE(
     profile_name => 'openai_gpt4',
     attributes =>
      '{"provider": "openai",
        "credential_name": "OPENAI_CRED",
        "object_list": [
            {"owner": "SH","name":"TIMES"},
            {"owner": "SH","name":"PRODUCTS"},
            {"owner": "SH","name":"COUNTRIES"},
            {"owner": "SH","name":"COSTS"},
            {"owner": "SH","name":"PROMOTIONS"},
            {"owner": "SH","name":"SALES"},
            {"owner": "SH","name":"CHANNELS"},
            {"owner": "SH","name":"CUSTOMERS"} ],
        "max_tokens":512,
        "stop_tokens": [";"],
        "model": "gpt-3.5-turbo",
        "temperature": 0.5,
        "comments": true
       }');
END;
/
```

### 3. SELECT AI 수행

자연어프롬프트를 사용하여 데이터베이스와 상호작용하기 위해 SELECT문에 AI 키워드를 사용합니다.
SELECT문의 AI키워드는 활성화된 AI Profile에서 식별된 LLM을 사용하여 자연어를 처리하고 SQL을 생성하도록 SQL 실행엔진에 지시합니다.
SQL Developer, OML notebooks과 3rd party Tools와 같은 Oracle 클라이언트에서 쿼리에서 AI키워드를 사용하여 자연어로 사용할수 있습니다.

```sql
SELECT AI action natural_language_prompt
```
- SELECT AI에 4가지 Action을 제공합니다.
  - runsql : 자연어 프롬프트를 이용하여 SQL실행한 결과를 보여줍니다. 
  - showsql : 자연어 프롬프트에 대한 SQL 구문 표시합니다. 
  - Narrate : 자연어를 이용하여 프롬프트 결과를 설명합니다. 
  - chat : AI와 대화할수 있습니다. 


#### 자연어 질의예시(영어)
```sql 
-- AI Profile 설정
SQL> exec DBMS_CLOUD_AI.SET_PROFILE(profile_name => 'openai_gpt35');

-- 자연어로 질의
SQL> SELECT AI How many customers;
   CUSTOMER_COUNT
_________________
            55500

SQL> SELECT AI RUNSQL how many customers;
   TOTAL_CUSTOMERS
__________________
             55500

SQL> SELECT AI SHOWSQL how many customers;
RESPONSE
______________________________________________________
SELECT COUNT(*) AS total_customers
FROM SH.CUSTOMERS

SQL> SELECT AI NARRATE how many customers;
RESPONSE
______________________________________________________
The total number of customers is 55,500.

SQL> SELECT AI CHAT What is Oracle Database''s market share;
RESPONSE
____________________________________________________________________________________________________________________________________
As of 2021, Oracle Database has a market share of approximately 32.7% in the relational database management system (RDBMS) market.
SQL>
```

#### 자연어 질의예시(한국어)
```sql 
-- AI Profile 설정
SQL> exec DBMS_CLOUD_AI.SET_PROFILE(profile_name => 'openai_gpt35');

-- 한국어로 질의
SQL> SELECT AI 얼마나 많은 고객이 있나요;
   TOTAL_CUSTOMERS
__________________
             55500

SQL> SELECT AI RUNSQL 얼마나 많은 고객이 있나요;
   TOTAL_CUSTOMERS
__________________
             55500

SQL> SELECT AI SHOWSQL 얼마나 많은 고객이 있나요;
RESPONSE
__________________________________________________________
SELECT COUNT(*) AS customer_count
FROM "SH"."CUSTOMERS"

SQL> SELECT AI NARRATE 얼마나 많은 고객이 있나요;
RESPONSE
_________________________________________
There are a total of 55,500 customers.

-- 한국어로 질의하였지만 영어로 답변하여 프롬프트에 한국어로 작성해줘라는 문장을 명시적으로 적었습니다.
SQL> SELECT AI NARRATE 얼마나 많은 고객이 있나요(한국어로 작성해줘);

RESPONSE
______________________________________________________
한국어로 작성한 쿼리에 대한 답변은 다음과 같습니다:
[
  {"고객 수": 55500}
]

SQL> SELECT AI CHAT 오라클 데이터베이스의 시장 점유율은 어떤가요;
RESPONSE
________________________________________________________________________________________________________________________________________________________
오라클은 전세계적으로 가장 많이 사용되는 데이터베이스 관리 시스템 중 하나입니다. 현재 시장 점유율은 약 40% 정도로 추정되고 있습니다. 다른 주요 데이터베이스 관리 시스템으로는 MySQL, Microsoft SQL Server, PostgreSQL 등이 있습니다.

SQL>
```
## 마무리 

SELECT AI기능에 대해서 간략하게 알아보았습니다. 오라클 데이터베이스에서 생성형 AI와 연결하여 자연어로 데이터를 질의할수 있습니다.
SELECT AI는 SQL사용자와 개발자를 위한 생산성 도구역할을 하며 비전문가의 SQL사용자가 데이터 구조나 기술 언어를 이해하지 않고도 데이터에 대한 유용한 통찰력을 얻도록 도와줍니다.

생성형 AI가 가져온 기술혁신이 벌써 우리 주변까지 온것 같습니다. 실 업무에서 사용될수 있을지 좀더 테스트 해봐야하겠지만 분명 데이터 관리나 활용관점에서는 큰 변화로 받아들이게 될것입니다.

## 참조자료 
- Blogs
  - [Introducing Select AI - Natural Language to SQL Generation on Autonomous Database](https://blogs.oracle.com/machinelearning/post/introducing-natural-language-to-sql-generation-on-autonomous-database){: target="_blank"}
  - [Autonomous Database speaks “human”](https://blogs.oracle.com/datawarehousing/post/autonomous-database-speaks-human){: target="_blank"}
- Documents
  - [Use Select AI to Generate SQL from Natural Language Prompts](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/sql-generation-ai-autonomous.html){: target="_blank"}
  - [DBMS_CLOUD_AI Package](https://docs.oracle.com/en/cloud/paas/autonomous-database/serverless/adbsb/dbms-cloud-ai-package.html){: target="_blank"}
  - [DBMS_CLOUD Subprograms and REST APIs](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/dbms-cloud-subprograms.html){: target="_blank"}
  - [DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE procedure](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html){: target="_blank"}
- LiveLabs
  - [Chat with Your Data in Autonomous Database Using Generative AI](https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=3831){: target="_blank"}