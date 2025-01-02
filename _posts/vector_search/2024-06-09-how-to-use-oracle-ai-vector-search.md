---
layout: single
title: "[오라클] 벡터 검색 기술 활용(1) - 텍스트유사도검색"
date: 2024-06-09 15:00
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
excerpt : "🔍 텍스트에서 유사도 검색하는 방법에 대해서 알아봅니다. "
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

AI 기술이 발전하면서 데이터베이스 분야에도 많은 변화가 생기고 있습니다.
특히, **시멘틱 검색(semantic search)**이라는 새로운 방식이 주목받고 있습니다. 시멘틱 검색은 단순히 키워드로 데이터를 찾는 것이 아니라, 데이터의 의미를 기반으로 검색하는 기술입니다.
이 기술과 함께 등장한 것이 바로 벡터 데이터베이스인데요, 오라클 데이터베이스는 최신 버전인 23ai부터 벡터 검색을 지원하기 시작했습니다.

오라클은 텍스트, 이미지 같은 비정형 데이터를 **벡터(숫자로 표현된 데이터)**로 변환하고, 이 벡터들 간의 유사성을 계산해 검색하는 기술을 **Oracle AI Vector Search**라고 부릅니다.
이번 글에서는 복잡한 AI 모델보다는 데이터베이스 사용자 관점에서 벡터 검색 기술을 쉽게 이해할 수 있도록 설명하겠습니다.

## 백터 검색 기술 활용

벡터 검색은 데이터를 검색하기 전에 먼저 임베딩 모델을 통해 데이터를 벡터화하는 작업이 필요합니다.
이 과정을 **벡터 임베딩(Vector Embedding)**이라고 합니다.
단순히 데이터를 저장하는 것이 아니라, 숫자로 된 벡터 형태로 변환하여 데이터를 표현하는 방식입니다.

검색을 할 때는 내가 조회하고자 하는 조건(예: 텍스트)을 **쿼리 벡터(Query Vector)**로 변환해야 합니다.
그 후, 데이터에 저장된 데이터 벡터와 쿼리 벡터 간의 거리 계산을 통해 가장 가까운 벡터들을 찾습니다.
이렇게 가장 가까운 데이터를 찾는 과정을 **유사도 검색(Similarity Search)**이라고 합니다.

유사도 검색을 사용하면 내가 입력한 조건과 의미적으로 가장 가까운 데이터를 효과적으로 검색할 수 있습니다.

이제, 벡터 검색의 주요 단계를 자세히 알아보겠습니다.

### 1. 벡터 임베딩 (Vector Embedding)

**벡터 임베딩(Vector Embedding)**이란 텍스트, 이미지 같은 비정형 데이터를 벡터 공간에 표현하는 방법입니다. 영어로는 Embedding Vector라고도 합니다.
벡터는 “크기”와 “방향”을 가진 데이터로, 비슷한 의미를 가진 데이터는 벡터 공간에서 가까운 위치에 배치됩니다.
예를 들어, “고양이”와 “강아지”처럼 비슷한 의미를 가진 데이터는 벡터 공간에서도 서로 가깝게 배치됩니다.

이 과정을 통해 비정형 데이터를 벡터로 변환하면, 변환된 벡터 간의 수학적 거리 계산을 통해 유사한 데이터를 찾아낼 수 있습니다.

**벡터 데이터의 저장 방식**

벡터 데이터는 **차원(dimension)**과 **데이터 형식(number format)**으로 표현됩니다.
오라클 데이터베이스에서는 벡터 데이터를 저장하기 위해 VECTOR 데이터 타입을 제공합니다.
아래는 벡터 데이터를 저장하는 예제입니다.

{% include codeHeader.html copyable="true" codetype="SQL"%}
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
위 코드에서 EMBED_VECTOR 컬럼은 VECTOR 타입으로 선언되었으며, 예제로 “[1,3,4]“라는 3차원의 벡터 데이터를 입력했습니다.
일반적으로 임베딩된 벡터는 300차원 이상의 고차원 데이터로, 주로 FLOAT나 INT 타입으로 구성됩니다.

> 오라클 23ai부터 VECTOR 데이터 타입을 지원하며, 최대 64K 차원과 FLOAT32, FLOAT64, INT8 데이터 타입을 제공합니다.

**벡터 데이터의 생성 과정**

벡터 데이터는 보통 **임베딩 모델(ML 모델)**을 통해 생성됩니다.
이 모델들은 비정형 데이터를 분석하고, 이를 벡터로 변환해 주는 역할을 합니다.
임베딩 모델을 사용하는 방법은 이후 단계에서 더 자세히 알아보겠습니다.

### 2. 임베딩 모델 (Embedding Model)

임베딩 모델은 데이터를 벡터로 변환하는 데 사용됩니다.
이 모델은 훈련된 데이터에 따라 처리 가능한 데이터 유형(모달리티)이 정해지며, 대표적으로 아래와 같은 유형이 있습니다.
-	텍스트 임베딩 모델: 텍스트 데이터를 벡터로 변환합니다.
-	이미지 임베딩 모델: 이미지 데이터를 벡터로 변환합니다.
-	멀티모달 임베딩 모델: 텍스트와 이미지 등 여러 데이터를 동시에 처리할 수 있습니다.

이러한 모델은 직접 훈련하여 개발할 수도 있지만, 오픈소스의 사전 훈련된(pretrained) 모델을 활용하거나, 외부 임베딩 모델 API를 사용하여 간편하게 처리할 수도 있습니다.

**텍스트 임베딩 모델의 예시**

1. 사전 훈련된(pretrained) 텍스트 임베딩 모델
  - Sentence Transformers(SBERT.net)
    - <https://www.sbert.net/>{:target="_blank"})에서 다양한 pretrained 모델을 확인할 수 있습니다.
    - 이 모델들은 로컬에서 다운로드받아 벡터화 작업에 사용할 수 있습니다.
  - Hugging Face
    - 머신러닝 모델을 공유하는 플랫폼으로, <https://huggingface.co/models>{:target="_blank"})에서 다양한 모델을 검색하고 사용할 수 있습니다.
2. LLM(대형언어모델)기반 임베딩 모델 
  - OpenAI(GPT), Cohere(Command) 등 LLM을 제공하는 벤더들은 임베딩 모델 API를 함께 제공합니다.
  - 이 API를 호출하면 텍스트 데이터를 벡터로 변환할 수 있습니다.

> 임베딩 모델은 사전 훈련된 모델을 다운로드하거나, 외부의 API를 호출해 데이터를 벡터로 변환할 수 있습니다.

그럼 임베딩 모델들은 어떻게 사용할수 있을까요?

**임베딩 모델 사용 방법**

방법1) 애플리케이션 레이어에서 호출
- 사전 훈련된 모델 활용
  - Python의 SentenceTransformer 모듀을 사용해 로컬에서 데이터를 백터화합니다.
- LLM 기반 모델 활용
  - REST API를 호출해 데이터를 백터화합니다.

방법2) 데이터베이스 레이어에서 호출
- 사전 훈련된 모델 활용
  - 오라클 데이터베이스는 외부의 많은 ML모델들을 사용할수 있도록 모델을 DB내에 저장하는 기능을 제공하고 있습니다. 
  - 오라클 데이터베이스는 ONNX 표준 형식을 이용하여 데이터베이스내에서 임베딩 모델을 저장할수 있습니다. SQL(PL/SQL)로 임베딩 모델을 호출할수 있습니다. 
  - 데이터베이스 내에서 벡터 임베딩 될경우 데이터를 데이터베이스 외부로 이동하지 않고, 대량의 데이터를 빠르게 벡터 임베딩 처리할수 있습니다. 또한 대규모 데이터 이동을 회피할수 있고, 민감한 데이터에 보안을 강화할수 있는 이점이 있습니다. 
- LLM모델을 제공하는 벤더의 임베딩 모델 활용
  - 오라클 데이터베이스에서 직접 REST API로 임베딩 모델 API를 이용하여 벡터 수행할수 있습니다.

> 오라클 데이터베이스내에서 사전 훈련된(pretrained) 임베딩모델을 저장하고 임베딩을 수행 할수 있습니다. 또한 직접 외부의 임베딩 모델 API를 호출할수 있습니다.

**임베딩 모델 로딩과정**
오라클 데이터베이스에 임베딩 모델을 로딩하는 절차를 알아보겠습니다. 

오라클 데이터베이스는 OML4Py(Oracle Machine Learning for Python) 기능을 제공합니다. 
OML4Py에는 Pretrainded Model를 ONNX파일로 생성하는 기능을 제공합니다.

- OML4Py 2.0
  - 지원환경 : Python 3.12
  - 설치절차 : <https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2/mlugp/install-oml4py-premises-database.html>{:target="_blank"}

오픈소스의 Pretrained Model을 가져와서 오라클 데이터베이스에 호환되는 ONNX파일로 생성합니다.
예시로, multi-qa-MiniLM-L6-cos-v1 모델을 변환하는 과정은 아래와 같습니다.

- 모델 정보(multi-qa-MiniLM-L6-cos-v1)
  - 내용 : Dimension - 384, Pooling-method - mean Pooling, Susitable Score Functions - dot-product (util.dot_score), cosine-similarity (util.cos_sim), or euclidean distance
  - 훈련된 데이터 : 215M개의 질문과 답변으로 훈련됨
  - 설명 : <https://huggingface.co/sentence-transformers/multi-qa-MiniLM-L6-cos-v1>{:target="_blank"}


{% include codeHeader.html copyable="true" codetype="Python"%}
```python
$ cd /home/oracle/onnx
$ python3
from oml.utils import EmbeddingModel, EmbeddingModelConfig
## 오라클 테스트한 모델목록확인
EmbeddingModelConfig.show_preconfigured()
## 현재 지원되는 모달정보
EmbeddingModelConfig.show_templates()
## 오라클이 테스트한 모델 목록이 아닐경우 설정작업을 할수 있음.
config = EmbeddingModelConfig.from_template("text",max_seq_length=512)
embedding_model = "sentence-transformers/multi-qa-MiniLM-L6-cos-v1"
em = EmbeddingModel(model_name=embedding_model, config=config)
## ONNX 파일 생성
em.export2file("multi-qa-MiniLM-L6-cos-v1",output_dir="./")
```

ONNX파일로 생성하는 작업을 하는 실행 화면입니다.

```python
oracle$> python
Python 3.12.3 | packaged by Anaconda, Inc. | (main, May  6 2024, 19:46:43) [GCC 11.2.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> from oml.utils import EmbeddingModel, EmbeddingModelConfig
>>> EmbeddingModelConfig.show_preconfigured();
['sentence-transformers/all-mpnet-base-v2', 'sentence-transformers/all-MiniLM-L6-v2', 'sentence-transformers/multi-qa-MiniLM-L6-cos-v1', 'ProsusAI/finbert', 'medicalai/ClinicalBERT', 'sentence-transformers/distiluse-base-multilingual-cased-v2', 'sentence-transformers/all-MiniLM-L12-v2', 'BAAI/bge-small-en-v1.5', 'BAAI/bge-base-en-v1.5', 'taylorAI/bge-micro-v2', 'intfloat/e5-small-v2', 'intfloat/e5-base-v2', 'prajjwal1/bert-tiny', 'thenlper/gte-base', 'thenlper/gte-small', 'TaylorAI/gte-tiny', 'infgrad/stella-base-en-v2', 'sentence-transformers/paraphrase-multilingual-mpnet-base-v2', 'intfloat/multilingual-e5-base', 'intfloat/multilingual-e5-small', 'sentence-transformers/stsb-xlm-r-multilingual']
>>> EmbeddingModelConfig.show_templates()
['text']
>>> embedding_model = "sentence-transformers/multi-qa-MiniLM-L6-cos-v1"
>>> config = EmbeddingModelConfig.from_template("text",max_seq_length=512)
>>> em = EmbeddingModel(model_name=embedding_model, config=config)
>>> em.export2file("multi-qa-MiniLM-L6-cos-v1",output_dir="./")
>>> quit()

## ONNX파일 생성 확인
oracle$> ls -al *.onnx
-rw-r--r--. 1 oracle oinstall 90621438 Jun 12 00:20 multi-qa-MiniLM-L6-cos-v1.onnx
```

**데이터베이스에 ONNX 파일 로딩** 

생성한 ONNX 파일을 오라클 데이터베이스에 저장하고, 임베딩 작업에 사용할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="SQL"%}
```sql
-- 디렉토리 생성(해당 디렉토리에 onnx파일이 있어야함)
CREATE OR REPLACE DIRECTORY CTX_WORK_DIR AS '/home/oracle/onnx';
-- 이미 모델이 있는경우 삭제 
begin DBMS_VECTOR.drop_onnx_model(model_name => 'doc_model_han', force => true); end;
-- onnx파일을 가져와서 로딩 작업수행
begin
  DBMS_VECTOR.LOAD_ONNX_MODEL('CTX_WORK_DIR','multi-qa-MiniLM-L6-cos-v1.onnx','doc_model_han',
  JSON('{"function" : "embedding", "embeddingOutput" : "embedding", "input":{"input": ["DATA"]}}'));
end;
/

-- 임베딩 모델를 이용하여 'hello'문자를 임베딩하는 예제
SELECT TO_VECTOR(VECTOR_EMBEDDING(doc_model_han USING 'hello' as data)) AS embedding;
```

위의 쿼리를 실행하면 "hello"라는 텍스트가 384차원의 벡터로 변환됩니다.

```sql
SQL> SELECT TO_VECTOR(VECTOR_EMBEDDING(doc_model_han USING 'hello' as data)) AS embedding;
EMBEDDING
------------------------------------------------------------------------------------------------------------------------------------
[-1.84456294E-003,4.6881251E-002,5.60026839E-002,2.94819362E-002,-4.99280356E-002,-5.25398068E-002,9.09654573E-002,-7.13755935E-002,
-7.11104795E-002,3.83346304E-002,4.16246057E-002,-8.75969231E-002,9.75992996E-003,-4.2328421E-002,5.8659073E-002,4.72318754E-002,3.2
288637E-002,-4.8622869E-002,-7.69898817E-002,2.10542604E-003,-6.60614073E-002,-2.03449018E-002,3.47332954E-002,1.9247124E-002,-3.419
60415E-002,-6.37527695E-003,-8.05879943E-004,6.11303821E-002,5.32540567E-002,-5.08440323E-002,-5.46900295E-002,-2.08270513E-002,1.06
616482E-001,-1.19611446E-003,-2.35890094E-002,4.07438762E-002,1.60605256E-002,-7.81672597E-002,-4.02841419E-002,9.34662949E-003,-2.7
3767691E-002,-3.7499398E-002,2.2549089E-003,(중략).20833308E-001,-9.52617906E-004,-1.92611255E-002,2.078
65909E-002,-3.66526619E-002,-1.55179901E-003,6.10501543E-002,4.66698781E-002,-1.13457903E-001,-4.52607647E-002,-2.59705577E-002,-2.4
1795443E-002,7.98424985E-003,2.37004794E-002,3.34092081E-002,-3.43932845E-002,3.56714725E-002,3.02354619E-002,2.17860304E-002,1.6272
4443E-002,2.28671189E-002,1.05159163E-001,1.31758135E-002,5.26017696E-002,-8.4661236E-003]
```

임베딩(Embedding) 모델은 우리가 많이 사용하고 있는 대형 언어 모델(LLM)과는 어떤 차이점은 무엇일까요?

|종류|LLM모델|임베딩모델|
|---|---|---|
|기능|많은 양의 텍스트 데이터로 훈련된 모델로, 자연어 이해와 생성에 능숙합니다. <br>텍스트를 입력받아 문맥에 맞는 출력을 생성합니다. |단어나 문장을 벡터 공간에 매핑하는 모델로 텍스트의 의미를 수치로 표현합니다. |
|크기| 모델사이즈가 매우 큽니다.(10G이상) | 모델사이즈가 상대적으로 작습니다.(1G이내)| 
|활용| 주로 번역, 요약, 질문응답등 다양한 작업에 사용됩니다. | 주로 문서 분류, 유사도 계산, 정보 검색등에 사용됩니다. |

 > LLM은 텍스트 생성과 문맥을 이해하는데 초점, 임베딩 모델은 데이터 의미를 벡터로 표현하는데 효과적입니다

### 3. 텍스트 데이터의 청킹 작업(Chunking)

**청킹(Chunking)**은 긴 텍스트 데이터를 의미 있는 작은 조각(청크)으로 나누는 작업입니다.
이 작업은 텍스트를 더 효과적으로 검색하거나 분석할 수 있도록 도와줍니다.

오라클 데이터베이스는 텍스트 데이터를 청크로 분할하고, 이를 요약하거나 벡터화할 수 있도록 DBMS_VECTOR_CHAIN 패키지를 제공합니다.
이 패키지는 데이터베이스 내에서 모든 작업을 처리하므로, 데이터를 외부로 이동할 필요가 없어 처리 속도가 빠르고 보안도 강화됩니다.

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
( oracle-ai-vector-search-users-guide.pdf파일은 약 2.5M입니다. )

{% include codeHeader.html copyable="true" codetype="SQL"%}
```sql
-- PDF문서를  텍스트로 변환하고 이를 청킹(작은 조각)으로 분리함
select chunk_id, chunk_offset, chunk_length, chunk_data
  from TABLE(
  dbms_vector_chain.utl_to_chunks(
        dbms_vector_chain.utl_to_text(to_blob(bfilename('CTX_WORK_DIR','oracle-ai-vector-search-users-guide.pdf'))), 
     json('{"by":"words","max":"300","split":"sentence","normalize":"all"}')
 )) t, JSON_TABLE(
    t.column_value, 
    '$[*]' COLUMNS (
        chunk_id NUMBER PATH '$.chunk_id',
        chunk_offset NUMBER PATH '$.chunk_offset',
        chunk_length NUMBER PATH '$.chunk_length',
        chunk_data VARCHAR2(4000) PATH '$.chunk_data'
    )
) AS et;

-- PDF문서를  텍스트로 변환하고 이를 청킹(작은 조각)으로 분리함 + 벡터화하여 저장합니다.
INSERT INTO VECTOR_STORE
SELECT dt.id as doc_id, 
      et.embed_id, 
      et.embed_data, 
      to_vector(et.embed_vector) AS embed_vector
FROM (select a.id, 
             to_blob(bfilename('CTX_WORK_DIR',a.file_name)) file_content 
             from (values(1, 'oracle-ai-vector-search-users-guide.pdf')) a (id, file_name) )dt
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
```

위 코드는 PDF 파일에서 텍스트를 읽은 뒤, 300단어씩 청크로 나눕니다. 나눠진 텍스트 조각은 이후 벡터화하거나 요약 작업에 사용할 수 있습니다.

실행 결과입니다. 데이터 건수가 많아서 1건씩만 표시하였습니다. 

```sql
  CHUNK_ID CHUNK_OFFSET CHUNK_LENGTH  CHUNK_DATA
---------- ------------ ------------   ------------------------------------------------------------------------------------------------------------------------------------
         1            4         1626   Oracle AI Vector Search User's Guide
                                       
                                       Oracle? Database
                                       Oracle AI Vector Search User's Guide
                                       
                                       23ai
                                       F87786-02
                                       May 2024
                                       
                                       Oracle Database Oracle AI Vector Search User's Guide, 23ai
                                       
                                       F87786-02
                                       
                                       Copyright ? 2023, 2024, Oracle and/or its affiliates.
                                       
                                       Primary Author: Jean-Francois Verrier
                                       
                                       Contributing Authors: Binika Kumar, Douglas Williams, Frederick Kush, Gunjan Jain, Maitreyee Chaliha, Mamata
                                       Basapur, Jessica True, Jody Glover, Prakash Jashnani, Sarah Hirschfeld, Sarika Surampudi, Suresh Rajan, Tulika Das,
                                       Usha Krishnamurthy, Ramya P
                                       
                                       Contributors: Aleksandra Czarlinska, Agnivo Saha, Angela Amor, Aurosish Mishra, Bonnie Xia, Boriana Milenova, David
                                       Jiang, Dinesh Das, Doug Hood, George Krupka, Harichandan Roy, Malavika S P, Mark Hornick, Rohan Aggarwal,
                                       Roger Ford, Sebastian DeLaHoz, Shasank Chavan, Tirthankar Lahiri, Teck Hua Lee, Vinita Subramanian, Weiwei
                                       Gong, Yuan Zhou
                                       
                                       This software and related documentation are provided under a license agreement containing restrictions on use and
                                       disclosure and are protected by intellectual property laws. Except as expressly permitted in your license agreement or
                                       allowed by law, you may not use, copy, reproduce, translate, broadcast, modify, license, transmit, distribute, exhibit,
                                       perform, publish, or display any part, in any form, or by any means. Reverse engineering, disassembly, or decompilation
                                       of this software, unless required by law for interoperability, is prohibited.
                                       
                                       The information contained herein is subject to change without notice and is not warranted to be error-free.
```

기본 옵션으로 텍스트를 데이터를 청킹작업을 수행했습니다. 다양한 옵션이 있으니 좀더 관심이 있으면 아래 메뉴얼을 참고하시기 바랍니다. 

- Explore Chunking Techniques and Examples
  - <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/explore-chunking-techniques-and-examples.html>{:target="_blank"}

> 청킹 작업은 텍스트 데이터를 효율적으로 분할하고 활용하기 위해 중요한 단계입니다. 데이터를 잘게 나누는 방식과 크기는 검색 결과의 품질에 큰 영향을 미치므로, 작업에 따라 적절한 청킹 전략을 사용하는 것이 중요합니다

### 4. 유사도 검색(Similarity Search)

**유사도 검색(Similarity Search)**은 벡터 간의 유사성을 계산하여 데이터의 의미를 기반으로 검색하는 기술입니다.
이 검색 방식은 단순히 키워드가 일치하는 데이터를 반환하는 대신, 의미가 유사한 콘텐츠를 찾아냅니다.
예를 들어, “강아지”를 검색하면 “반려견”이나 “포메라니안”과 같은 의미적으로 가까운 데이터를 반환할 수 있습니다.

**백터 검색의 원리**

유사도 검색에서는 임베딩된 데이터 벡터와 쿼리 벡터(Query Vector) 간의 거리를 계산합니다.
두 벡터 간의 거리가 가까울수록 두 데이터가 의미적으로 더 유사하다고 판단합니다.
검색의 정확성을 위해 거리의 크기보다 **상대적인 순서(Relative Order of Distances)**가 더 중요합니다.
 
**거리 함수**

유사도 검색에서 벡터 간의 거리를 계산하기 위해 다양한 거리 측정 함수가 사용됩니다.
두 벡터간 거리를 계산하는 거리 측정 함수 목록들 입니다. 
- Euclidean and Euclidean Squared Distances : 유사도 검색에서 벡터 간의 거리를 계산하기 위해 다양한 거리 측정 함수가 사용됩니다.(유사한 이미지, 관심사나 선호도 분류)
- Cosine Similarity : 두 벡터 간의 코사인 값을 계산해 유사도를 판단합니다.(자연어 처리, 영상 검색)
- Dot Product Similarity : 두 벡터의 코사인 값에 벡터 크기를 곱하여 내적을 계산합니다.(단어 유사도, 벡터간 유사성)
- Manhattan Distance : 각 축을 따라 이동한 거리를 계산합니다. (GPS기반 경로 탐색, 문서 분류)
- Hamming Similarity : 두 벡터에서 서로 다른 차원의 개수를 계산합니다.(디지털 통신 오류, 유전자분석)

> 데이터 벡터와 쿼리 벡터는 동일한 임베딩 모델을 사용해야합니다.
> 적합한 거리 측정법은 사용하는 임베딩 모델에 따라 결정됩니다.

**SQL을 활용한 유사도 검색 예제**

다음은 SQL을 사용해 특정 질의에 대해 의미적으로 유사한 데이터를 검색하는 예제입니다.

{% include codeHeader.html copyable="true" codetype="SQL"%}
```sql
-- 임베딩 모델로 쿼리 벡터를 생성
-- 쿼리 벡터로 벡터 거리 계산(VECTOR_DISTANCE)후 ORDER BY로 정렬
-- 가장 가까운 거리의 벡터를 가지는 데이터가 5개가 출력됨
SELECT EMBED_DATA 
  FROM VECTOR_STORE 
ORDER BY vector_distance(EMBED_VECTOR, vector_embedding(doc_model_han USING 'What is the Oracle AI Vector Search?' as data), COSINE)
FETCH FIRST 5 ROWS ONLY ;
```

"What is the Oracle AI Vector Search?" 질문을 기반으로 유사한 텍스트를 검색한 결과입니다. (1건만 표시하였습니다.)

```sql
EMBED_DATA
------------------------------------------------------------------------------------------------------------------------------------
109 30 About Oracle AI Vector Search

143 148 Vector Indexes are a new classification of
specialized indexes that are designed for Artificial Intelligence (AI)
workloads that allow you to query

291 48 data based on semantics, rather than keywords.

343 33 Why Use Oracle AI Vector Search?

377 162 The biggest benefit of Oracle AI Vector Search is
that semantic search on unstructured data can be combined with relational
Chapter 3

Vector Generation Examples

3-82

D:20240514080434-08'00'
Example 3-6

search on business data in one single

539 8 system.

Example 3-10 BY words MAX 40 OVERLAP 5 SPLIT BY none

This example is the similar to
Example 3-4

, except an overlap of
5

is used.
The first chunk ends at the maximum 40 words (after
workloads

). The second chunk overlaps
with the last 5 words including parentheses of the first chunk, and ends after
unstructured

.
The overlapping words are underlined below. The third chunk overlaps with the last 5 words,
which are also underlined.
```

유사도 검색은 SQL의 **ORDER BY**와 거리 계산 함수를 결합한 단순한 방식으로 구현됩니다.
벡터 간 거리를 정렬해 상위 K개의 데이터를 선택하므로, 원하는 의미와 가장 가까운 데이터를 효과적으로 검색할 수 있습니다.

이처럼 벡터 검색 기술은 데이터를 의미 기반으로 탐색할 수 있는 강력한 도구를 제공합니다.
특히, 텍스트, 이미지 등 비정형 데이터를 다루는 현대 애플리케이션에서 그 활용도가 높습니다.

## 마치며

지금까지 오라클 데이터베이스를 활용한 **유사도 검색(벡터 검색)**의 기본 과정을 알아보았습니다.
먼저 텍스트 데이터를 **청킹(Chunking)**하여 작은 조각으로 나누고, 이를 임베딩 모델을 사용해 벡터화하는 작업을 수행했습니다.
이후 벡터화된 데이터와 쿼리 벡터 간의 거리를 계산해 가장 유사한 데이터를 검색하는 방법을 살펴보았습니다.

**벡터 검색의 핵심**

벡터 검색은 단순한 키워드 검색과 달리, 데이터의 의미를 기반으로 검색을 수행할 수 있는 강력한 기술입니다.
이번 글에서는 벡터 검색의 기초를 다루었지만, 실제 활용에서는 다음과 같은 중요한 고려 사항이 있습니다
-	임베딩 모델의 선택: 어떤 임베딩 모델을 사용하느냐에 따라 검색의 정확도가 크게 달라집니다.
- 데이터 양 : 저장된 벡터 데이터의 양이 검색 결과에 영향을 줄수 있습니다. 검색되는 데이터가 많을 수록 조건과 유사한 데이터가 검색될 확률이 높습니다. 
-	텍스트 청킹 전략: 텍스트를 의미를 보존하면서 적절히 분할하는 방법은 검색 품질에 중요한 영향을 미칩니다. 

**실무 적용을 위한 제언**

오라클 데이터베이스는 SQL만으로 임베딩과 유사도 검색 작업을 간단히 수행할 수 있도록 설계되었습니다.
이 기본 원리를 이해하고 나면, 실제 업무에 이 기술을 적용할 때 어떤 방식이 가장 적합한지 고민해볼 필요가 있습니다.
특히, 비정형 데이터가 많아지고 AI 기술이 필수적인 시대에서, 벡터 검색은 매우 유용한 도구가 될 것입니다.

이제 기본 개념을 바탕으로, 여러분의 데이터와 업무 환경에 맞는 활용 방안을 찾아보시기 바랍니다. 작은 시작이 큰 혁신으로 이어질 수 있습니다!

## 업데이트

오라클 데이터베이스에 곧바로 로딩할수 있는 agument된 임베딩 모델을 블로그에서 제공하고 있습니다. 2개의 텍스트 임베딩 모델을 제공하고 있습니다. 

- All-MiniLM-L12-v2(2024년 9월)(영어) : <https://blogs.oracle.com/machinelearning/post/use-our-prebuilt-onnx-model-now-available-for-embedding-generation-in-oracle-database-23ai>{:target="_blank"}
- Multilingual-e5-small(2024년 9월)(다국어) : <https://blogs.oracle.com/machinelearning/post/enhance-your-semantic-similarity-search-with-multilingual-support>{:target="_blank"}

{% include codeHeader.html copyable="true" codetype="SQL"%}
```sql
DECLARE
  ONNX_MOD_FILE VARCHAR2(100) := 'multilingual_e5_small.onnx';
  MODNAME VARCHAR2(500) := 'MULTILINGUAL_E5_SMALL';
  LOCATION_URI VARCHAR2(200) := 'https://adwc4pm.objectstorage.us-ashburn-1.oci.customer-oci.com/p/mbFT6Y4-cDFZr86_BlvZJA8CUiIzFmOCxN7m627gr3DWbksfgTzxf9HBREVgTvn1/n/adwc4pm/b/OML-Resources/o/';

BEGIN
 -- Object Storage접근을 위하여 Credential 생성
 BEGIN 
	DBMS_CLOUD.DROP_CREDENTIAL( credential_name => 'MY_CLOUD_CRED');
	EXCEPTION WHEN OTHERS THEN NULL; 
  END;
  DBMS_CLOUD.CREATE_CREDENTIAL( credential_name => 'MY_CLOUD_CRED', username => 'OMLUSER', password => 'Welcome12345');

 -- Object Storage에 있는 모델을 DB에 로딩
  BEGIN 
	DBMS_DATA_MINING.DROP_MODEL(model_name => MODNAME);
	EXCEPTION WHEN OTHERS THEN NULL; 
  END;
    DBMS_CLOUD.GET_OBJECT( credential_name => 'MY_CLOUD_CRED', directory_name => 'DATA_PUMP_DIR', object_uri => LOCATION_URI||ONNX_MOD_FILE);
    DBMS_VECTOR.LOAD_ONNX_MODEL(directory => 'DATA_PUMP_DIR', file_name => ONNX_MOD_FILE, model_name => MODNAME);
END;
/
```

## 참고문서 

Oracle AI Vector Search 사용자 가이드
- <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}

OML4Py 설치 절차
- <https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2/mlugp/install-oml4py-premises-database.html>{:target="_blank"}

SBERT.net사이트(텍스트 임베딩 모델)
- <https://www.sbert.net/>{:target="_blank"}
  
Hugging Face(기계 학습에 특화된 GitHub/GitLab과 같은 플랫폼)
- <https://huggingface.co/models>{:target="_blank"}

