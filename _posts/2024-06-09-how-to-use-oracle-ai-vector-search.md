---
layout: single
title: 벡터 검색 기술 활용(1/2)
date: 2024-06-09 15:00
categories: 
  - Oracle
books:
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
excerpt : 오라클 데이터베이스 23ai에 벡터 검색을 위한 Oracle AI Vector Search기능을 제공합니다. DB안에서 텍스트를 청킹하고 벡터로 임베딩하여 유사도 검색을 하는 절차들을 정리하였습니다.
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

LLM모델을 나오면서 데이터베이스 시장에도 많은 변화가 있습니다. 
의미론적인 검색의 필요성이 대두되면서 벡터 데이터베이스(스토어)가 관심을 받기 시작했습니다.
오라클 데이터베이스도 23ai버전부터 벡터 검색을 위한 벡터 데이터타입, 벡터 인덱스, 유사도 검색을 위한 SQL 연산자들 지원합니다.
이러한 여러기능들을 묶어서 Oracle AI Vector Search라고 불리웁니다

좀더 구체적으로 어떻게 사용할수 있는지 기능에 대해서 알아볼텐데요, 주로 텍스트 유사도 검색관점으로 정리하였습니다. 

## 백터 검색 기술 활용

벡터 검색을 위해서는 임베딩 모델을 통해서 데이터를 벡터화 하는 작업이 필요합니다. 이를 벡터 임베딩(Vector Embedding)이라고 합니다. 
데이터 검색을 할때 내가 조회할려는 조건(텍스트)도 백터로 변환해야하는데 이를 쿼리 벡터(Query Vector)라고 합니다. 데이터벡터들과 쿼리 벡터간간 거리 계산을 통해서 가장 가까운 벡터들을 찾는것이 유사도 검색(Similarity Search)입니다. 
유사도 검색하면 내가 검색한 조건에 의미가 가장가까운 데이터를 검색할수 있게 됩니다. 

각 단계별로 좀더 자세하게 알아보겠습니다.

### 1. 벡터 임베딩 (Vector Embedding)

비정형데이터(텍스트, 이미지등)을 의미 벡터 공간에 표현하는 방법이 벡터 임베딩(Vector Embedding)이라고 합니다. (영어은 Embedding Vector로 표현하는것 같습니다.)
벡터는 "크기"와 "방향"을 가진 데이터로 유사한 의미를 가진 데이터는 벡터 공간내에서 가까운 위치에 배치됩니다. 
그래서 비정형 데이터를 벡터로 임베딩하면 임베딩된 벡터(데이터 포인터)간의 수학적 계산법으로 거리측정을 하여 가장 가까운 데이터를 계산해 낼수 있습니다. 

그럼 벡터 데이터는 어떻게 저장될까요?
벡터 데이터는 차원(dimension)과 데이터 형식(number format)으로 표현됩니다. 

오라클 데이터베이스에서는 아래와 같이 벡터 데이터 형식을 정의하여 저장할수 있습니다.
```sql
-- VECTOR_STORE 테이블을 생성(EMBED_VECTOR 컬럼은 VECTOR 데이터타입임)
CREATE TABLE IF NOT EXISTS VECTOR_STORE( 
    DOC_ID NUMBER NOT NULL, 
    EMBED_ID NUMBER, 
    EMBED_DATA VARCHAR2(4000), 
    EMBED_VECTOR VECTOR
  );

-- 벡터 데이터를 입력
INSERT INTO VECTOR_STORE VALUES(1, 1, "나는 벡터다", "[1,3,4]");
COMMIT;
```
오라클 23ai부터 VECTOR 데이터타입이 추가되었습니다. 
EMBED_VECTOR 컬럼은 VECTOR 타입으로 선언했고, 임의 벡터값을 "[1,3,4]" 넣었습니다. 
단순히 3차원의 int타입으로 데이터를 넣지만, 일반적으로 임베딩되는 벡터는 300개이상의 차원으로 float, int타입으로 벡터가 생성됩니다

> 오라클 23ai부터 VECTOR 데이터타입을 지원합니다, 32K 차원과 FLOAT32, FLOAT64, INT8 차원 타입을 지원합니다. 

그럼 벡터 데이터는 어떻게 생성될까요? 임베딩을 위한 ML모델을 통해서 생성됩니다

### 2. 임베딩 모델 (Embedding Model)

임베딩 모델들은 훈련된 데이터에 따라서 지원되는 모달이 정해집니다.
대표적으로 텍스트 임베딩 모델, 이미지 임베딩 모델이 있고, 텍스트와 이미지를 모두지원하는 멀티 모달의 임베딩 모델이 있습니다. 
이러한 임베딩 모델들은 직접 훈련하여 개발할수 있지만, 오픈소스를 이용하여 사전 훈련된(pretrained) 임베딩 모델들 쉽게 사용할수 있습니다. 

- 사전 훈련된(pretrained) 텍스트 임베딩 모델들 
  - SBERT.net사이트(<https://www.sbert.net/>{:target="_blank"})에서 Sentence Transformers(Python 모듈)의 Pretrained Model목록들을 확인할수 있습니다. 
  - 여러개 모델들에 대해서 평가한 결과를 확인할수 있습니다. 
  - 모든 임베딩 모델은 Hugging Face에서 제공됩니다. (기계 학습에 특화된 GitHub/GitLab과 같은 플랫폼 : <https://huggingface.co/models>{:target="_blank"})

그럼 임베딩 모델들은 어떻게 사용할수 있을까요?

- 임베딩 모델사용방법
  1. 애플리케이션 레이어에서 임베딩 모델을 호출하여 데이터를 벡터화 작업을 수행합니다.
    - Python의 SentenceTransformer모듈을 호출하여 임베딩 모델을 이용하여 encode작업을 수행하여 벡터 수행함
  2. 데이터베이스 레이어에서 임베딩 모델을 호출하여 데이터를 벡터화 작업을 수행합니다. 
    - 오라클 데이터베이스는 외부의 많은 ML모델들을 사용할수 있도록 모델을 DB내에 저장하는 기능을 제공하고 있습니다. 
    - 오라클 데이터베이스는 ONNX 표준 형식을 이용하여 데이터베이스내에서 임베딩 모델을 저장할수 있습니다. SQL(PL/SQL)로 임베딩 모델을 호출할수 있습니다. 
    - 데이터베이스 내에서 벡터 임베딩 될경우 데이터를 데이터베이스 외부로 이동하지 않고, 대량의 데이터를 빠르게 벡터 임베딩 처리할수 있습니다. 또한 대규모 데이터 이동을 회피할수 있고, 민감한 데이터에 보안을 강화할수 있는 이점이 있습니다. 

> 오라클 데이터베이스내에서 임베딩모델을 저장하고 호출할수 있습니다. 

오라클 데이터베이스에 임베딩 모델을 로딩하는 절차를 알아보겠습니다. 

오라클 데이터베이스는 OML4Py(Oracle Machine Learning for Python) 기능을 제공합니다. 
OML4Py에는 Pretrainded Model를 ONNX파일로 생성하는 기능을 제공합니다.

```python
$ python3
Python 3.12.0 (main, May 13 2024, 06:13:22) [GCC 8.5.0 20210514 (Red Hat 8.5.0-20.0.3)] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from oml.utils import EmbeddingModel, EmbeddingModelConfig
>>> EmbeddingModelConfig.show_preconfigured()
['sentence-transformers/all-mpnet-base-v2', 'sentence-transformers/all-MiniLM-L6-v2', 'sentence-transformers/multi-qa-MiniLM-L6-cos-v1', 'ProsusAI/finbert’, …]
>>> EmbeddingModelConfig.show_templates()
['text']
>>> quit()
```

임베딩(Embedding) 모델은 우리가 많이 사용하고 있는 대형 언어 모델(LLM)과는 어떤 차이점은 무엇일까요?

|종류|LLM모델|임베딩모델|
|---|---|---|
|기능|많은 양의 텍스트 데이터로 훈련된 모델로, 자연어 이해와 생성에 능숙합니다. 텍스트를 입력받아 문맥에 맞는 출력을 생성합니다. |단어나 문장을 벡터 공간에 매핑하는 모델로 텍스트의 의미를 수치로 표현합니다. |
|크기| 모델사이즈가 매우 큽니다.(10G이상) | 모델사이즈가 상대적으로 작습니다.(1G이내)| 
|활용| 주로 번역, 요약, 질문응답등 다양한 작업에 사용됩니다. | 주로 문서 분류, 유사도 계산, 정보 검색등에 사용됩니다. |

 > LLM은 텍스트 생성과 문맥을 이해하는데 초점, 임베딩 모델은 텍스트의미를 벡터로 표현하는데 효과적입니다

### 2. 텍스트 데이터의 청킹 작업(Chunking)

오라클 데이터베이스는 텍스트를 분할을 위한 유틸리티 패키지인 DBMS_VECTOR_CHAIN 패키지를 제공합니다. 
문서용 텍스트 데이터, 텍스트 데이터의 청크 분할, 콘텐츠 요약 및 임베딩을 모두 데이터베이스내에서 처리할수 있습니다.
데이터베이스에 벡터화하려는 데이터가 있는 경우 데이터 이동을 최소화하므로 효율적으로 처리를 할수 있습니다.

DBMS_VECTOR_CHAIN 패키지의 프로시저/함수목록

|함수명|내용|
|---|---|
|UTL_TO_TEXT|PDF, DOC, JSON, XML 및 HTML과 같은 문서에서 텍스트를 추출|
|UTL_TO_CHUNKS|텍스트 데이터를 청크로 분할하는 함수|
|UTL_TO_SUMMARY|텍스트와 청크데이터를 요약|
|UTL_TO_EMBEDDING(S)|텍스트 및 청크 배열을 벡터 형식으로 임베딩|
|CREATE_VOCABULARY|토큰별로 텍스트를 분할하기 위한 어휘 파일 생성|
|CREATE_LANG_DATA|특정 언어별 약어 토큰을 등록|
|UTL_TO_GENERATE_TEXT|LLM과 연동하여 답변을 생성|

패키지명에 CHAIN이 있는것처럼 함수들간 연결하여 사용할수 있습니다. 
직접 파일을 읽고, 텍스트로 변환하고 청킹하는 작업까지 보여주는 SQL입니다. 

```sql
-- PDF문서를  텍스트로 변환하고 이를 청킹(작은 조각)으로 분리함
SELECT dt.id doc,
    JSON_VALUE(C.column_value, '$.chunk_id' RETURNING NUMBER) AS id,
    JSON_VALUE(C.column_value, '$.chunk_offset' RETURNING NUMBER) AS pos,
    JSON_VALUE(C.column_value, '$.chunk_length' RETURNING NUMBER) AS siz,
    JSON_VALUE(C.column_value, '$.chunk_data') AS chunk
FROM documentation_tab dt, dbms_vector_chain.utl_to_chunks(dbms_vector_chain.utl_to_text(dt.data),
JSON('{ "by":"CHARACTERS","max":"50","overlap":"0",
      "split":"recursively","language":"american", "normalize":"all"}')) C;


-- PDF문서를  텍스트로 변환하고 이를 청킹(작은 조각)으로 분리함 + 벡터화하여 저장합니다.
 INSERT INTO vector_store (doc_id, embed_id, embed_data, embed_vector)
    SELECT dt.id AS doc_id, 
            et.embed_id, 
            et.embed_data, 
            to_vector(et.embed_vector) AS embed_vector
    FROM my_books dt
    CROSS JOIN TABLE(
        dbms_vector_chain.utl_to_embeddings(
            dbms_vector_chain.utl_to_chunks(
                dbms_vector_chain.utl_to_text(dt.file_content), 
                json('{"by":"words","max":"300","split":"sentence","normalize":"all"}')
            ),
            json('{"provider":"database", "model":"doc_model_han"}')
        )
    )  t
    CROSS JOIN JSON_TABLE(
        t.column_value, 
        '$[*]' COLUMNS (
            embed_id NUMBER PATH '$.embed_id',
            embed_data VARCHAR2(4000) PATH '$.embed_data',
            embed_vector CLOB PATH '$.embed_vector'
        )
    ) AS et
    WHERE dt.id = v_ids(i);
```

### 3. 유사도 검색(Smilarity Search)

벡터 검색 (유사성 검색 - smilarity search) 는 임베딩된 벡터간의 유사성 검색을 통해 데이터의 의미 검색을 가능하게 합니다. 
단어의 의미를 해석하는 검색 엔진 기술로 검색어와 일치하는 결과 대신 쿼리의 “의미 일치“ 콘텐츠를 반환합니다. 
그렇기 때문에 벡터 검색을 사용하여 의미가 유사한 데이터를 찾을수 있습니다. 
벡터간의 거리는 거리함수를 통해 계산하고, 쿼리 벡터로 부터 가장 가까운 데이터를 찾습니다.
두개의 벡터간의 실제 거리보다 결과 집합의 상대적 거리 순서(RELATIVE ORDER OF DISTANCES )가 더 중요합니다.

두 벡터간 거리를 계산하는 거리 측정 함수 목록들 입니다. 
- Euclidean and Euclidean Squared Distances : 파타고라스 정리를 이용하여 두 지점간의 직선 거리를 계산(유사한 이미지, 관심사나 선호도 분류)
- Cosine Similarity : 두 Vector의 Cosine을 계산(자연어 처리, 영상 검색)
- Dot Product Similarity : 두 Vector의 Cosine에 Vector크기를 곱하여 내적 계산 (단어 유사도, Vector간 유사성)
- Manhattan Distance : 두 지점간의 각축에 따른 차이 합을 계산 (GPS기반 경로 탐색, 문서 분류)
- Hamming Similarity : 각 dimension별로 다른갯수를 찾아 계산 (디지털 통신 오류, 유전자분석)

> 데이터 벡터와 쿼리 벡터는 동일한 임베딩 모델을 사용해야합니다.
> 거리 측정법은 임베딩 모델에 의해서 결정됩니다. 

```sql
-- 쿼리 벡터 생성
select to_vector(vector_embedding(doc_model_han USING user_question as data)) as embedding  into  user_question_vec ;

-- 쿼리 벡터로 벡터 거리 계산(VECTOR_DISTANCE)후 ORDER BY로 정렬
-- 가장 가까운 거리의 벡터를 가지는 데이터가 5개가 출력됨
SELECT EMBED_DATA 
  FROM VECTOR_STORE 
 WHERE doc_id = :doc_id
ORDER BY vector_distance(EMBED_VECTOR, :user_question_vec, COSINE)
FETCH  FIRST 5 ROWS ONLY ;
```

## 샘플코드 

1. 임베딩 모델을 로딩합니다. 
2. 문서를 넣으면 자동으로 청킹합니다.(문서를 넣을때 자동으로 청킹되도록 트리거를 추가합니다.)
3. 유사도 검색을 수행합니다. (문서 번호를 조건으로 유사도 검색을 수행합니다. )

```sql
CREATE TABLE IF NOT EXISTS VECTOR.MY_BOOKS
    ( 
    ID  INTEGER GENERATED BY DEFAULT ON NULL AS IDENTITY 
        ( START WITH 1 CACHE 20 ) PRIMARY KEY, 
    file_name      VARCHAR2 (900) , 
    file_size      INTEGER , 
    file_type       VARCHAR2 (100) , 
    file_content    BLOB
    ) ;
```

## 마치며

## 참고문서 