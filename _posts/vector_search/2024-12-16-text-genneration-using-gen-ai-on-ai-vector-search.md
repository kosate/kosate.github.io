---
layout: single
title: "[오라클] 생성형 AI와의 연동(1) - 텍스트 생성 요청"
date: 2024-12-16 21:00
categories: 
  - vector-search
books:
 - oracleaivectorsearch
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
excerpt : "🔍 데이터베이스에서 생성형 AI와 연동하는 방법을 알아봅니다."
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---
  
## 들어가며 

Oracle AI Vector Search는 텍스트나 이미지처럼 복잡한 데이터를 더욱 정확하고 효율적으로 검색할 수 있게 해 주는 Oracle 23ai의 핵심 기능입니다. 이 기술은 기업이 보유한 방대한 데이터를 더 똑똑하게 활용할 수 있도록 돕습니다.

예를 들어, RAG(정보 검색 및 생성) 같은 애플리케이션을 개발할 때, 데이터베이스를 중심 플랫폼으로 사용하면 기업 내부의 지식 정보나 데이터를 효율적으로 변환하거나 분석하는 데 큰 도움을 줄 수 있습니다.

특히, 데이터베이스와 **생성형 AI(Generative AI)**가 연동되면, 이전에는 어려웠던 데이터 활용 작업을 손쉽게 처리할 수 있습니다. 복잡한 데이터 분석부터 새로운 정보 생성까지, 이 기술을 통해 많은 새로운 가능성을 열 수 있습니다.

이번 글에서는 오라클 데이터베이스에서 생성형 AI를 연동하는 방법을 배워보겠습니다. LLM(대규모 언어 모델)을 사용해 정보를 입력하고, AI와 통신하여 답변을 생성하는 과정을 단계별로 알아보겠습니다

## 텍스트 생성 요청(작업)

오라클 데이터베이스에서 **생성형 AI(LLM)**을 연동하려면 DBMS_VECTOR_CHAIN.UTL_TO_GENERATE_TEXT 함수를 직접 호출할 수 있습니다. 하지만 여러 모델을 효율적으로 관리하기 위해 사용자 정의 코드를 추가하여 더 편리하게 사용할 수 있도록 구성했습니다.

- 모델 관리 테이블 : my_models
- 텍스트 요청 함수 : generate_text

### 1. ACL 권한 설정 : 외부 API 호출을 위한 네트워크 권한 구성

오라클 데이터베이스에서 외부 API나 웹 서비스와 통신하려면 특정 권한이 필요합니다. 이를 위해 네트워크 엑세스 제어(ACL) 권한을 설정합니다.

예제에서는 ADMIN 유저에게 모든 네트워크 호스트에 연결할 수 있는 권한을 부여했습니다. 실제 환경에서는 권한이 필요한 사용자로 변경하는 것이 중요합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
BEGIN
  DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
    host => '*',  -- 모든 호스트를 의미(모든 외부 네트워크에 연결하도록 허용)
    ace => xs$ace_type(privilege_list => xs$name_list('connect'), -- 허용되는 네트워크 작업 정의
        principal_name => 'ADMIN', -- 권한을 부여받는 사용또는 역할이름
        principal_type => xs_acl.ptype_db)); -- 권한 부여 대상(데이터베이스 사용자 유형으로 지정)
END;
/

-- ACL정보 확인
SELECT * FROM dba_network_acls;
```


### 2. 인증객체 생성 : LLM 제공자와 연동하기 위한 인증 설정

OpenAI와 같은 외부 서비스와 통신하려면 인증 정보가 필요합니다. 인증 객체를 생성하여 LLM 제공자와 연결합니다. 아래는 OpenAI와 연동하기 위한 인증 생성 예제입니다.

제공자별로 인증 방식이 다를 수 있으니, 오라클 메뉴얼 문서를 참고하세요.
- <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/create_credential-dbms_vector_chain.html>{:target="_blank"}

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
DECLARE
  v_params json_object_t;
  v_name varchar2(1000) :=  'OPENAI_CRED'; -- 인증 이름
  v_api_token varchar2(1000) := '{API 토큰정보}'; -- 토큰 정보
BEGIN
   v_params := json_object_t();
   v_params.put('access_token',v_api_token); 
   -- 인증정보 삭제
   BEGIN
       DBMS_VECTOR_CHAIN.DROP_CREDENTIAL ( CREDENTIAL_NAME  => v_name);
   EXCEPTION
     WHEN OTHERS THEN
        null;
   END;
   -- 인증정보 생성
   DBMS_VECTOR_CHAIN.CREATE_CREDENTIAL ( CREDENTIAL_NAME => v_name, PARAMS => json(v_params.to_string));
END;
/

-- 인증정보 확인
SELECT * FROM dba_credentials;
```

### 3. LLM 모델 관리 테이블 생성 : JSON 기반으로 다양한 모델 관리

오라클 데이터베이스에서 여러 LLM 모델을 사용할 수 있습니다. 이를 관리하기 위해 모델 관리 테이블을 생성하고, 모델 정보를 JSON 형식으로 저장합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 모델관리 테이블
CREATE TABLE IF NOT EXISTS my_models(
    model_id NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY PRIMARY KEY,
    model_params JSON)
```

### 4. LLM 모델 정보 저장 : OpenAI GPT-4를 예제로 활용

모델 관리 테이블에 OpenAI의 GPT-4 모델 정보를 저장합니다.

이때 다음과 같은 정보가 포함됩니다
- 인증객체 정보
- 앤드포인트(endpoint)
- 모델명
- max_tokens, temperature등의 파라미터

더 자세한 설정 방법은 아래 문서를 참고하세요
- 모델 정보 : <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/utl_to_generate_text-dbms_vector_chain.html>{:target="_blank"}
- endpoint 정보 : <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/supported-third-party-provider-operations-and-endpoints.html>{:target="_blank"}

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 모델 정보 저장
INSERT INTO my_models (model_params)
VALUES (json('{
  "provider": "openai",
  "credential_name": "OPENAI_CRED",
  "url": "https://api.openai.com/v1/chat/completions",
  "model": "gpt-4o-mini",
  "max_tokens":1000,
  "temperature": 0.5
}'));
```

### 5. LLM 모델 조회 View 생성

JSON으로 저장된 모델 정보를 보기 쉽게 관리하기 위해 View를 생성합니다. 이를 통해 모델 정보를 테이블 형식으로 확인할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 모델정보를 테이블형태로 보기
CREATE OR REPLACE VIEW vw_my_models 
AS
SELECT m.model_id, mt.*, m.model_params 
  FROM my_models m
   CROSS JOIN JSON_TABLE(
        m.model_params, 
        '$[*]' COLUMNS (
            provider VARCHAR2(4000) PATH '$.provider',
            credential_name VARCHAR2(4000) PATH '$.credential_name',
            model VARCHAR2(4000) PATH '$.model'
        )
) as mt;
```

### 6. LLM 모델과 통신 함수 생성 : REST API를 활용해 텍스트 생성

REST API를 사용하여 LLM 모델과 통신하는 함수를 생성합니다.
함수에서는 모델명과 **프롬프트(prompt)**를 인자로 전달해 답변을 생성합니다.

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

### 7. 텍스트 생성 요청 예시 : 프롬프트를 사용한 테스트

아래는 OpenAI의 ChatGPT 모델을 사용해 텍스트를 생성한 예제입니다.
프롬프트로 “Oracle AI Vector Search가 무엇인가요?“라는 질문을 입력하고, 생성된 답변을 확인했습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- PL/SQL 텍스트 생성요청
set serveroutput on
DECLARE
  v_model_name varchar2(100) := 'gpt-4o-mini'; -- 모델명지정
  v_prompt clob; 
BEGIN
  -- 프롬프트 작성(gpt모델예시 활용)
  v_prompt := '[
  {
      "role": "system",
      "content": "당신은 지식이 풍부하고 전문적인 어시스턴트입니다. 질문에 대해 정확하고 간결하며 이해하기 쉬운 방식으로 답변하세요. 필요한 경우 자세한 설명을 제공하고, 기술적인 개념은 간단한 언어로 풀어서 설명하세요."
  },
  {
      "role": "user",
      "content": "Oracle AI Vector Search가 무엇인가요?"
  }
  ]';
  -- 결과 출력
  DBMS_OUTPUT.PUT_LINE(generate_text(v_model_name, v_prompt));
END;
```

프롬프트를 더욱 구조화하면 필요한 데이터를 더 정확하게 생성할 수 있습니다.
사용 편의를 위해 PL/SQL로 작성했지만, SQL 구문으로도 실행할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- SQL로 텍스트 생성요청
SELECT generate_text('gpt-4o-mini', '[
  {
      "role": "system",
      "content": "당신은 지식이 풍부하고 전문적인 어시스턴트입니다. 질문에 대해 정확하고 간결하며 이해하기 쉬운 방식으로 답변하세요. 필요한 경우 자세한 설명을 제공하고, 기술적인 개념은 간단한 언어로 풀어서 설명하세요."
  },
  {
      "role": "user",
      "content": "Oracle AI Vector Search가 무엇인가요?"
  }
  ]') generated_text;
```

"Oracle AI Vecot Search가 무엇인가요"의 질문에 대한 텍스트 생성결과입니다. 
프롬프트를 좀 더 템플릿하여 구조화하면 원하는 데이터를 생성할수 있습니다.

```text
Oracle AI Vector Search는 Oracle 데이터베이스에서 제공하는 기능으로, 고차원 데이터의 유사성을 기반으로 한 검색을 지원합니다. 이 기술은 주로 머신러닝 및 인공지능(AI) 응용 프로그램에서 사용되며, 텍스트, 이미지, 비디오 등 다양한 형태의 데이터를 벡터로 변환하여 저장하고 검색할 수 있게 해줍니다.

주요 특징:

1. 벡터화: 데이터를 벡터로 변환하여 수치화합니다. 예를 들어, 텍스트는 단어 임베딩 기법을 통해 벡터로 변환될 수 있습니다.
2. 유사성 검색: 저장된 벡터 간의 유사성을 비교하여 가장 관련성이 높은 데이터를 찾습니다. 이는 최근접 이웃 검색(NN, Nearest Neighbor Search) 알고리즘을 통해 이루어집니다.
3. 고성능: 대량의 데이터에서도 빠른 검색 속도를 제공합니다. 이는 대규모 데이터베이스에서 효율적으로 작동하도록 최적화되어 있습니다.
4. 다양한 응용: 추천 시스템, 이미지 검색, 자연어 처리(NLP) 등 다양한 AI 기반 응용 프로그램에서 활용됩니다.

Oracle AI Vector Search는 데이터 분석과 AI 프로젝트에서 데이터 검색의 효율성을 크게 향상시키는 도구입니다.

``` 

## 마무리

지금까지 오라클데이터베이스에서 생성형 AI와 통신하여 답변생성하는 작업을 단계적으로 알아보았습니다. 
Oracle AI Vector Search와 생성형 AI 연동은 데이터베이스 활용도를 크게 높여줍니다. 단순한 데이터 저장소를 넘어, 데이터를 분석하고, 변환하며, 새로운 인사이트를 제공하는 강력한 플랫폼으로 바꿔줍니다.

**향후 활용 가능성**
- **맞춤형 추천 시스템**: 고객의 행동 데이터를 기반으로 한 개인화된 서비스 제공
- **문서 요약 및 분석**: 대규모 텍스트 데이터의 요약 및 통찰 제공
- **이미지 검색 및 태깅**: 벡터 기반 이미지 검색으로 고급 콘텐츠 관리 지원
- **실시간 사용자 응대**: 자연어 처리 기술과 결합하여 더 나은 고객 서비스 구현

Oracle AI Vector Search는 벡터 기반 검색과 생성형 AI 연동을 통해 비정형 데이터 분석 및 생성을 지원합니다. 
앞으로 이런 기술은 데이터 중심 서비스와 비즈니스에서 없어서는 안 될 중요한 도구가 될 것입니다

## 참고자료 

- <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/create_credential-dbms_vector_chain.html>{:target="_blank"}