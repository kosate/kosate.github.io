---
layout: single
title: 벡터 검색 기술 활용(1) 
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
오라클 23ai부터 VECTOR 데이터타입이 추가되었습니다. 
EMBED_VECTOR 컬럼은 VECTOR 타입으로 선언했고, 임의 벡터값을 "[1,3,4]" 넣었습니다. 
단순히 3차원의 int타입으로 데이터를 넣지만, 일반적으로 임베딩되는 벡터는 300개이상의 차원으로 float, int타입으로 벡터가 생성됩니다

> 오라클 23ai부터 VECTOR 데이터타입을 지원합니다, 64K 차원과 FLOAT32, FLOAT64, INT8 차원 타입을 지원합니다. 

그럼 벡터 데이터는 어떻게 생성될까요? 임베딩을 위한 ML모델을 통해서 생성됩니다

### 2. 임베딩 모델 (Embedding Model)

임베딩 모델들은 훈련된 데이터에 따라서 지원되는 모달이 정해집니다.
대표적으로 텍스트 임베딩 모델, 이미지 임베딩 모델이 있고, 텍스트와 이미지를 모두지원하는 멀티 모달의 임베딩 모델이 있습니다. 
이러한 임베딩 모델들은 직접 훈련하여 개발할수 있지만, 오픈소스를 이용하여 사전 훈련된(pretrained) 임베딩 모델들을 사용하여 외부의 임베딩 모델 API를 사용할수 있습니다. 

**텍스트 임베딩 모델 유형**

- 사전 훈련된(pretrained) 텍스트 임베딩 모델들 
  - SBERT.net사이트(<https://www.sbert.net/>{:target="_blank"})에서 Sentence Transformers(Python 모듈)의 Pretrained Model목록들을 확인할수 있습니다. 
  - 이러한 모델들은 로컬에 다운받아 임베딩을 처리할수 있습니다.
  - 여러개 모델들에 대해서 평가한 결과도 확인할수 있습니다. 
  - 모든 임베딩 모델은 Hugging Face에서 제공됩니다. (기계 학습에 특화된 GitHub/GitLab과 같은 플랫폼 : <https://huggingface.co/models>{:target="_blank"})
- LLM모델을 제공하는 벤더의 임베딩 모델들
  - 대부분 LLM모델(OpenAI의 ChatGPT, Cohere의 Command등)등은 임베딩 모델 API을 같이 제공합니다. 
  - 임베딩 모델 API를 호출하여 사용할수 있습니다. 

> 임베딩 모델은 사전 훈련된(pretrained) Model을 다운받거나, 외부 임베딩 모델 API를 호출하여 임베딩 처리할수 있습니다.

그럼 임베딩 모델들은 어떻게 사용할수 있을까요?

**임베딩 모델 사용 방법**

방법1) 애플리케이션 레이어에서 임베딩 모델을 호출하여 데이터를 벡터화 작업을 수행합니다.
- 사전 훈련된(pretrained) 임베딩 모델 활용
  - Python의 SentenceTransformer모듈을 호출하여 사전 훈련된(pretrained) 임베딩 모델을 이용하여 encode작업을 수행하여 벡터 수행합니다.
- LLM모델을 제공하는 벤더의 임베딩 모델 활용
  - REST API로 임베딩 모델 API를 이용하여 벡터 수행함

방법2) 데이터베이스 레이어에서 임베딩 모델을 호출하여 데이터를 벡터화 작업을 수행합니다. 
- 사전 훈련된(pretrained) 임베딩 모델 활용
  - 오라클 데이터베이스는 외부의 많은 ML모델들을 사용할수 있도록 모델을 DB내에 저장하는 기능을 제공하고 있습니다. 
  - 오라클 데이터베이스는 ONNX 표준 형식을 이용하여 데이터베이스내에서 임베딩 모델을 저장할수 있습니다. SQL(PL/SQL)로 임베딩 모델을 호출할수 있습니다. 
  - 데이터베이스 내에서 벡터 임베딩 될경우 데이터를 데이터베이스 외부로 이동하지 않고, 대량의 데이터를 빠르게 벡터 임베딩 처리할수 있습니다. 또한 대규모 데이터 이동을 회피할수 있고, 민감한 데이터에 보안을 강화할수 있는 이점이 있습니다. 
- LLM모델을 제공하는 벤더의 임베딩 모델 활용
  - 오라클 데이터베이스에서 직접 REST API로 임베딩 모델 API를 이용하여 벡터 수행할수 있습니다.

> 오라클 데이터베이스내에서 사전 훈련된(pretrained) 임베딩모델을 저장하고 임베딩을 수행 할수 있습니다. 또한 직접 외부의 임베딩 모델 API를 호출할수 있습니다.

오라클 데이터베이스에 임베딩 모델을 로딩하는 절차를 알아보겠습니다. 

오라클 데이터베이스는 OML4Py(Oracle Machine Learning for Python) 기능을 제공합니다. 
OML4Py에는 Pretrainded Model를 ONNX파일로 생성하는 기능을 제공합니다.

- OML4Py 2.0
  - 지원환경 : Python 3.12
  - 설치절차 : <https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2/mlugp/install-oml4py-premises-database.html>{:target="_blank"}

오픈소스의 Pretrained Model을 가져와서 오라클 데이터베이스에 호환되는 ONNX파일로 생성합니다.
예제에서는 multi-qa-MiniLM-L6-cos-v1 모델을 사용하겠습니다.

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

onnx파일을 데이터베이스에 저장(로드)합니다.

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

Hello 문자를 임베딩한 결과입니다. 384개의 차원으로 생성되었습니다

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

 > LLM은 텍스트 생성과 문맥을 이해하는데 초점, 임베딩 모델은 텍스트의미를 벡터로 표현하는데 효과적입니다

### 3. 텍스트 데이터의 청킹 작업(Chunking)

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

> 데이터 검색 결과의 품질은 청킹에서 많이 좌우됩니다. 청킹을 얼만큼 의미론적으로 단락으로 잘 분리하는지에 따라서 검색 결과의 품질이 결정됩니다. 청킹의 방법론과 노하우가 임베딩 모델만큼 중요하게 됩니다.

### 4. 유사도 검색(Similarity Search)

벡터 검색 (유사성 검색 - Similarity search) 는 임베딩된 벡터간의 유사성 검색을 통해 데이터의 의미 검색을 가능하게 합니다. 
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


특정 질의에 대해서 유사한 데이터를 검색하겠습니다.

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

사실 SQL구문에서보면 유사도 검색이라는 기술이 특별한것이 아닙니다.거리측정함수에 의해서 계산된 벡터간 거리 계산을 정렬한것입니다. 
SQL의 ORDER BY 구문에 VECTOR_DISTANCE를 사용하여 정렬하게 되고 상위 Top K건만 추출하기 위하여 FETCH 절을 사용하였습니다. 

## 마치며

지금까지 오라클 데이터베이스를 통해서 유사도 검색(벡터 검색)을 위한 과정에 대해서 알아보았습니다. 
문자 데이터를 청킹작업을 통해 작은 텍스트로 쪼개고 각 텍스트는 임베딩 모델을 통해서 벡터화합니다. 
벡터화된 데이터는 내가 질의하는 쿼리 벡터와 거리계산을 통하여 가장 유사한 데이터를 검색합니다. 

여기까지가 기본 적인 내용이고, 좀더 중요한 요소들이 많습니다. 
임베딩모델을 어떤것을 사용하고, 청킹할때 의미를 보존하면서 텍스트를 쪼갤는 방법이 무엇인지는 또 다른 영역입니다. 

오라클 데이터베이스는 기본적으로 SQL작업만으로 간단하게 임베딩 작업 및 유사도 검색작업을 쉽게 할수 있습니다.
일단 기본적인 내용을 이해하고 나서 우리업무에 적용했을때를 고려하여 좀 더 깊이 있는 고민을 해보는것이 좋을것 같습니다. 

## 참고문서 

Oracle AI Vector Search 사용자 가이드
- <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}

OML4Py 설치 절차
- <https://docs.oracle.com/en/database/oracle/machine-learning/oml4py/2/mlugp/install-oml4py-premises-database.html>{:target="_blank"}

SBERT.net사이트(텍스트 임베딩 모델)
- <https://www.sbert.net/>{:target="_blank"}
  
Hugging Face(기계 학습에 특화된 GitHub/GitLab과 같은 플랫폼)
- <https://huggingface.co/models>{:target="_blank"}

