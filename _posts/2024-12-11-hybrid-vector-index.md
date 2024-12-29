---
layout: single
title: "[오라클] 벡터 검색 기술 고급 활용(2) - 하이브리드 백터 검색"
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
excerpt : "🔍 벡터 검색과 키워드 검색을 결합한 하이브리드 검색 기술을 알아봅니다."
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---
  
## 들어가며 

벡터 검색을 사용하다 보면, 종종 원치 않는 데이터가 검색 결과에 포함되는 경우가 있습니다.
이는 임베딩 모델의 성능 문제일 수도 있지만, 기존 벡터 검색 기술의 한계에서 비롯되기도 합니다.

벡터 검색은 벡터 간의 거리를 계산해 가장 가까운 값들을 정렬하는 방식입니다.
그러나 이 방식만으로는 검색 키워드나 질문 내용과 큰 관련이 없는 데이터가 결과에 포함될 가능성이 있습니다.

비즈니스에서 벡터 검색을 효과적으로 활용하려면 정확도를 높이기 위한 다양한 보완 작업이 필요합니다.
이번 글에서는 벡터 검색에 키워드 검색 기능을 결합한 하이브리드 검색 기술에 대해 알아보겠습니다.

## 하이브리드 검색방법

하이브리드 검색 방법은 서로 다른 두 가지 검색 방식을 결합하여 더 넓고 중요한 정보를 검색할 수 있는 기술입니다.
주로 **벡터 검색(Dense Search)**과 **키워드 검색(Sparse Search)**를 조합해 사용하며, 이를 효과적으로 결합하려면 순위 기반(RRF - Reciprocal Rank Fusion) 또는 점수 기반(RSF - Relative Score Fusion) 통합 방법이 필요합니다.

**검색 방식 비교**

| 항목 | Sparse Retriever(회소 검색) - 단어빈도/일치         | Dense Retriever (밀집 검색) - 백터검색 | Hybrid Retriever 
|-------------|--------------------------------------------------|---------------------------------------------------|--|
| **설명**   | 문서와 질의를 단어 빈도(TF-IDF BM25와 같은 방식) 기반의 희소 벡터로 표현<br>이 벡터는 수천 또는 수백만 개의 차원을 가질 수 있지만, 대부분의 값은 0으로 채워져 있음. <br>질의와 문서 간의 단어 일치에 기반해 작동함 | BERT, SBERT 같은 사전 학습된 Transformer 모델을 기반으로 질의와 문서를 벡터로 인코딩하여 벡터 간 코사인 유사도를 사용해 유사 문서를 검색<br>질의와 문서 간 의미적 유사성을 기반으로 검색  |Sparse와 Dense Retriever를 조합하여, 단어 일치 기반 검색과 의미 기반 검색의 장점을 모두 활용하는 방법<br>각 기법에서 얻은 검색 결과를 결합하거나 가중 평균을 적용해 최종 결과를 산출 |
| **장점**              | 간단하고 빠르며, 짧은 텍스트나 구체적인 단어 기반 질의에서 성능이 우수함.   | 문맥을 고려한 의미 기반 검색이 가능하여 복잡하고 긴 질의에 적합함.   | 정확도와 다양성을 모두 향상시킬 수 있음.|
| **단점**              | 문맥을 고려하지 못하므로, 복잡한 질의나 긴 문장에 대해 성능이 떨어질 수 있음   | 모델의 크기 때문에 리소스를 많이 사용하며, 실시간 검색에서 상대적으로 속도가 느릴 수 있음.  |구현 복잡성이 높고, 두 가지 방법을 병행하는 만큼 속도 저하가 있을 수 있음.|
| **사용예**              | 뉴스검색, 법률 문서 검색등 | 추천시스템, 챗봇등 |고정밀 검색이 필요한 복합 검색 |


**여러 검색결과를 결합하는 방법(Scoring)**

하이브리드 검색에서는 여러 검색 결과를 결합해 최종 결과를 도출해야 합니다.
이를 위해 순위 기반과 점수 기반 두 가지 방식이 주로 사용됩니다.

- RRF(Reciprocal Rank Fusion) - 순위기반
  - 검색 결과의 순위를 기반으로 점수를 계산합니다. 순위에 따라 점수를 역수로 부여하며, 상위 순위일수록 높은 점수를 받습니다. 모든 점수를 합산해 최종 순위를 결정합니다.
  - 패널티 변수 : Text Penalty(1), Vector Penalty(1)

- RSF(Relative Score Fusion) - 점수기반
  - 검색 엔진별로 점수를 정규화한 뒤 이를 합산하여 최종 점수를 계산합니다. 점수를 상대적 비율로 변환하므로, 서로 다른 점수 체계를 가진 검색 결과를 결합하는 데 유리합니다.
  - 가중치 변수 : Text Weight(5), Vector Weight(10)

**하이브리드 검색 구현**

하이브리드 검색은 서로 다른 두 검색 방식을 결합하여 검색 결과를 통합하는 방법입니다.
예를 들어, LangChain 같은 AI 앱 개발 도구는 EnsembleRetriever를 제공해 Sparse(키워드 기반 검색)와 Dense(벡터 기반 검색)를 함께 사용할 수 있게 해줍니다.

오라클 데이터베이스는 하이브리드 검색을 Hybrid Vector Index 기능을 통해 지원합니다.
이 기능은 데이터베이스 내부에서 하이브리드 검색을 실행할 수 있도록 설계되어, 간단한 SQL 문법만으로 사용할 수 있으며, 성능 향상 효과도 기대할 수 있습니다.

- 키워드 검색과 벡터 검색의 결합
  - 키워드 검색 (Sparse):  Oracle Text 기능을 사용하여 텍스트 데이터를 처리합니다. 	텍스트를 분석(토큰화)하고 이를 기반으로 Text Index를 생성합니다.
  - 벡터 검색 (Dense) :  텍스트 데이터를 크기에 따라 나누는 청크 작업을 자동으로 수행합니다. 나누어진 텍스트를 임베딩 모델을 통해 벡터로 변환한 후, Vector Index를 생성합니다.

두 가지 검색 방식을 조합할 때는 RRF(순위 기반) 또는 RSF(점수 기반) 방법 중 하나를 선택할 수 있습니다.
또한, 필요에 따라 패널티 변수를 조정하여 원하는 검색 결과에 더 가까운 데이터를 얻을 수 있습니다.

## 하이브리드 검색 인덱스 예제 

이번에는 우리가 익히 알고 있는 토끼와 거북이 이솝우화를 활용하여 하이브리드 검색을 실행해 보겠습니다.
데이터를 저장하고 하이브리드 인덱스를 생성한 후, 벡터 검색과 하이브리드 검색 결과를 비교해 보겠습니다.

### 1. 데이터 준비 및 인덱스 생성
텍스트 검색을 위하여 테이블을 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE TABLE IF NOT EXISTS my_doc( 
   id NUMBER, 
   text VARCHAR2(1000)
);
```

샘플 데이터를 생성합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
INSERT INTO MY_DOC (id, text) VALUES
(1,'옛날 옛적에 토끼와 거북이가 살고 있었습니다.'),
(2,'토끼는 자신의 빠른 다리를 자랑하며 친구들에게 늘 과시하곤 했습니다.'),
(3,'어느 날 거북이가 조용히 다가와 토끼에게 경주를 제안했습니다.'),
(4,'토끼는 웃으며 제안을 받아들였고, 경주가 시작되었습니다.'),
(5,'토끼는 출발하자마자 빠르게 앞서갔고, 거북이는 천천히 걸어갔습니다.'),
(6,'한참 앞서간 토끼는 거북이가 자신을 따라잡지 못할 것이라 생각하고 길가에 누워 잠을 잤습니다.'),
(7,'그 사이, 거북이는 느리지만 꾸준히 앞으로 나아갔습니다. 결국 토끼가 잠에서 깨어났을 때, 거북이는 결승선을 눈앞에 두고 있었습니다.'),
(8,'토끼는 급히 뛰어갔지만 이미 늦었고, 거북이가 승리했습니다.') ,
(9,'이 경주를 통해 토끼는 지나친 자신감과 자만이 위험하다는 것을 배웠습니다.');
```

오라클 데이터베이스에 택스트 임베딩 모델을 로딩할수 있습니다. 텍스트 임베딩 및 유사도 검색은 아래 블로그를 참조하시기 바랍니다. 
- [벡터 검색 기술 활용 - 텍스트유사도검색](/blog/vector-search/how-to-use-oracle-ai-vector-search/#업데이트){:target="_blank"}

텍스트 임베딩 모델을 DB에 로딩합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
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

하이브리드 인덱스를 생성하려면 벡터 인덱스가 필요하며, 이를 위해 오라클 데이터베이스에 등록된 임베딩 모델을 설정해야 합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE HYBRID VECTOR INDEX my_hybrid_idx ON MY_DOC(text) PARAMETERS('MODEL MULTILINGUAL_E5_SMALL');
```


### 2. 데이터 검색결과 비교

하이브리드 검색에서는 DBMS_HYBRID_VECTOR.SEARCH 함수를 사용합니다.
이 함수는 기존 벡터 검색과 달리, 벡터 검색과 키워드 검색을 동시에 실행할 수 있는 기능을 제공합니다.

- 하이브리드 검색 인덱스는 다음 옵션을 제공합니다
	-	벡터 검색만 수행
	-	키워드 검색만 수행
	-	벡터 검색과 키워드 검색을 결합

또한, 각 검색 방식에 대한 패널티를 설정하여 결과의 가중치를 조정할 수 있습니다.
검색 결과는 JSON 형식으로 출력되며, 이를 통해 벡터 검색과 하이브리드 검색의 차이를 비교할 수 있습니다
 
**벡터 검색**

벡터 검색에서는 search_fusion을 VECTOR_ONLY로 지정하여 벡터 기반의 검색만 수행합니다.
이 방식은 내부적으로 벡터 점수와 순위를 계산하지만, 출력에는 벡터 검색 결과만 포함됩니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT JSON_SERIALIZE(
       DBMS_HYBRID_VECTOR.SEARCH(
       json('{
        "hybrid_index_name": "my_hybrid_idx",
        "search_text": "토끼가 잠을 잔 이유",
        "search_fusion": "VECTOR_ONLY",
        "return": {
            "topN": 5
        }
    }')) ) txt 
    FROM dual;
```

벡터 검색 결과는 의미적으로 유사한 콘텐츠를 반환하지만, 질문과 직접적인 연관이 없는 문장도 포함될 수 있습니다.
예를 들어, “옛날 옛적에 토끼와 거북이가 살고 있었습니다.” 같은 문장은 질문과 직접적으로 관련이 적습니다.
이러한 결과는 불필요한 데이터로 인해 검색의 품질을 낮출 수 있습니다.

```json
[
  {"rowid":"AAAY/CAAAAAAMcnAAF","score":82.55,"vector_score":90.7,"text_score":1,"vector_rank":1,"text_rank":1,"chunk_text":"한참 앞서간 토끼는 거북이가 자신을 따라잡지 못할 것이라 생각하고 길가에 누워 잠을 잤습니다.","chunk_id":"1"},
  {"rowid":"AAAY/CAAAAAAMcnAAA","score":81.23,"vector_score":89.35,"text_score":0,"vector_rank":2,"text_rank":1000,"chunk_text":"옛날 옛적에 토끼와 거북이가 살고 있었습니다.","chunk_id":"1"},
  {"rowid":"AAAY/CAAAAAAMcnAAD","score":81.05,"vector_score":89.16,"text_score":0,"vector_rank":3,"text_rank":1000,"chunk_text":"토끼는 웃으며 제안을 받아들였고, 경주가 시작되었습니다.","chunk_id":"1"},
  {"rowid":"AAAY/CAAAAAAMcnAAB","score":80.83,"vector_score":88.91,"text_score":0,"vector_rank":4,"text_rank":1000,"chunk_text":"토끼는 자신의 빠른 다리를 자랑하며 친구들에게 늘 과시하곤 했습니다.","chunk_id":"1"},
  {"rowid":"AAAY/CAAAAAAMcnAAC","score":80.42,"vector_score":88.46,"text_score":0,"vector_rank":5,"text_rank":1000,"chunk_text":"어느 날 거북이가 조용히 다가와 토끼에게 경주를 제안했습니다.","chunk_id":"1"}
]
```

**하이브리드 검색**

하이브리드 검색에서는 search_fusion을 INTERSECT로 지정하여 벡터 검색과 키워드 검색을 결합합니다.
내부적으로 두 검색 결과의 점수와 순위를 계산한 뒤, RRF(Reciprocal Rank Fusion) 방식을 사용하여 최종 결과를 도출합니다.(RSF 변경도 가능합니다.)

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT JSON_SERIALIZE(
       DBMS_HYBRID_VECTOR.SEARCH(
       json('{
        "hybrid_index_name": "my_hybrid_idx",
        "search_text": "토끼가 잠을 잔 이유",
        "search_fusion": "INTERSECT",
        "return": {
            "topN": 5
        }
    }')) ) txt 
    FROM dual;
```

하이브리드 검색 결과는 벡터 검색에 비해 검색 결과가 더 적지만, 관련성이 높은 문장만 포함되어 있습니다.
키워드 검색이 추가되어, 질문에 포함된 단어를 기반으로 결과가 필터링되기 때문입니다.

```json
[
  {"rowid":"AAAY/CAAAAAAMcnAAF","score":82.55,"vector_score":90.7,"text_score":1,"vector_rank":1,"text_rank":1,"chunk_text":"한참 앞서간 토끼는 거북이가 자신을 따라잡지 못할 것이라 생각하고 길가에 누워 잠을 잤습니다.","chunk_id":"1"},
  {"rowid":"AAAY/CAAAAAAMcnAAG","score":80.35,"vector_score":88.29,"text_score":1,"vector_rank":7,"text_rank":1,"chunk_text":"그 사이, 거북이는 느리지만 꾸준히 앞으로 나아갔습니다. 결국 토끼가 잠에서 깨어났을 때, 거북이는 결승선을 눈앞에 두고 있었습니다.","chunk_id":"1"}
]
```

## 마무리

지금까지 벡터 검색과 하이브리드 검색을 비교하고, 하이브리드 검색이 제공하는 높은 품질의 결과에 대해 살펴보았습니다.
- 벡터 검색은 질문과 의미적으로 유사한 문장을 찾아주지만, 관련성이 낮은 불필요한 결과가 포함될 수 있습니다.
- 하이브리드 검색은 키워드 검색을 결합하여, 질문과 더 밀접하게 관련된 데이터를 반환함으로써 검색 품질을 크게 개선합니다.

오라클 데이터베이스는 단순한 데이터 저장소의 역할을 넘어, 검색 품질을 높이기 위한 다양한 검색 방법을 지원합니다.
하이브리드 검색은 기존의 검색 기술에 벡터 검색을 결합한 강력한 도구로, 비즈니스에서 요구하는 정밀한 검색 결과를 제공합니다.

또한, 키워드 검색뿐만 아니라 그래프 검색과 같은 관계 분석 도구와 결합해 검색 품질을 더욱 향상시킬 수 있습니다.
비즈니스 환경에서는 원하는 성능을 달성하기 위해 여러 검색 기술을 조합하여 최적의 솔루션을 구현하는 것이 중요합니다.

## 참고문서

-  Hybrid Vector Index : <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/understand-hybrid-vector-indexes.html>{:target="_blank"}