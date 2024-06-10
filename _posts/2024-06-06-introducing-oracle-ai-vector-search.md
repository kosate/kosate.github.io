---
layout: single
title: 비정형 데이터를 검색하는 기술(Oracle AI Vector Search)
date: 2024-06-06 15:00
categories: 
  - Oracle
books:
 - oracle23newfeature
contents: PPT
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
excerpt : 오라클 데이터베이스에서 비정형 데이터를 검색하는 기술(Oracle AI Vector Search)에 대해서 알아보겠습니다.
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

오라클 DB 23ai버전에 Oracle AI Vector Search기능이 추가되었습니다.

벡터 검색을 위한 임베딩 작업, 텍스트 청킹기능, 유사도 검색을 위한 거리함수들을 제공하며, 
대용량의 벡터데이터를 검색하기 위한 인덱스 기능이 있습니다. 
이러한 기능들을 Oracle AI Vector Search라고 불리웁니다. 

## 비정형 데이터를 검색하는 기술(Oracle AI Vector Search)

비정형 데이터를 검색할수 있는 오라클의 기능 AI Vector Search기능에 대해서 간단하게 정리하였습니다.

{% include pptstart.html id="aivs" style="height:600px;" %}
<section data-markdown>
<textarea data-template>

## 비정형 데이터를 검색하는 기술 (Oracle AI Vector Search)
### 목차
  1. 기존 RDBMS의 한계  
  2. 벡터 검색 기술의 등장  
  3. Oracle AI Vector Search기능
---
## 데이터 환경의 새로운 변화 : 비정형 데이터의 관리
### 비정형 데이터는 빠르게 증가되고 있지만, 기업내 비즈니스에 활용하기는 어려움
  
- 데이터 환경은 빠르게 변화하며 비정형 데이터의 양이 급증하고 있음
- 비정형 데이터는 다양한 형태로 존재하며, 구조화되지 않은 상태로 비즈니스 활용이 어려움
- 비정형 데이터는 빅데이터 환경에 저장하고, 이를 위한 분석하기 위한 인력과 인프라가 필요함
- 비정형데이터는 결국 구조화된 데이터로 가공하여 분석하고 있음.
---
## RDBMS의 한계와 비정형 데이터의 도전
### RDBMS는 엄격한 스키마와 SQL 쿼리의 한계로 인해 새로운 데이터 형식을 효과적으로 관리하는 데 제약이 있음
- RDBMS는 데이터를 엄격한 스키마에 따라 저장하고 SQL을 통해 조작함
- RDBMS는 구조화된 데이터 처리에는 최적화되어 있지만 비정형 데이터 처리에는 제한적임
- 비정형 데이터의 증가는 기업이 유연한 데이터 관리 방식을 모색하게 함
---
## 벡터 검색 기술의 필요성
### 벡터 검색 기술은 데이터를 수치적 벡터로 변환하여 비정형 데이터에 대한 검색을 가능하게 함
- 벡터 검색 기술은 데이터를 수치적인 벡터로 변환하고 이를 저장하여 검색함
- 비정형 데이터를 벡터로 매핑하고, 벡터 간 거리를 수학적 방법으로 측정하여 유사도를 검색함
- 이 기술은 텍스트, 이미지, 비디오 등 다양한 데이터 유형을 처리할 수 있음
- 비정형 데이터를 쉽게 활용하고 접근할수 있는 도구로 확산되고 있음
---
## 오라클 데이터베이스의 벡터 검색 기술
### 오라클은 AI Vector Search기능을 통해 비정형 데이터를 위한 백터 검색 기술을 제공하고 AI를 위한 지식베이스를 제공
- 23ai에 AI 벡터 검색 기능 추가됨
- 동일한 데이터베이스에서 벡터 및 다른 업무 동시 처리가능
  - AI 벡터 검색과 함께 비즈니스 데이터 조회
- 사용하기 쉽고 이해하기 쉽도록 설계됨
  - 벡터 임베딩을 저장하기 위한 새로운 VECTOR 데이터 타입 추가
  - 유사성 검색은 새로운 SQL 구문 및 함수로 손쉽게 가능
  - 벡터 전용 고성능 인덱스 추가됨
---
## Oracle AI Vector Search기능의 특장점
### 오라클은 벡터임베딩 및 유사도 검색가능한 벡터 스토어를 제공함
- Generate : 비정형 데이터에서 벡터 임베딩으로 변환( In-DB에서 임베딩모델을 직접 호출할수 있으며, 텍스트의 데이터의 경우 직접 DB내에서 청킹 작업을 수행할수 있음)
- Store : 테이블의 벡터 컬럼에 벡터 데이터 저장( 최대 32K의 차원을 지원)
- index : 저장 임베딩에 대한 벡터 인덱싱 지원(HNSW 인덱스, IVF인덱스 지원, Accuracy기반의 손쉬운 튜닝)
- Search : 오라클 벡터 서치 쿼리로 유사성 높은 데이터 검색(다양한 거리함수지원)
---
## 오라클와 벡터 검색 기술의 시너지 효과
### 오라클은 시맨틱 검색과 관계형 검색을 하나의 단일 시스템에서 결합할 수 있음
- 별도의 벡터 데이터베이스에 데이터를 복제하는 것이 아닌 엔터프라이즈 데이터에 벡터 임베딩과 벡터 서치 기능 추가됨
- 통합된 엔터프라이즈급 데이터베이스에 벡터 검색 기능을 쉽게 추가할 수 있음
---
## Oracle AI Vector Search기능
### 벡터 스토어 생성 및 유사도 검색 예시
- 실행코드

<pre><code data-trim data-noescape>
-- 테이블 생성
SQL> CREATE TABLE docs (
  INT doc_id, 
  CLOB doc_text, 
  VECTOR doc_vector);

-- 유사도 검색
SQL> SELECT doc_text
      FROM docs
    ORDER BY vector_distance(doc_vector, :query_vector)
    FETCH FIRST 5 ROWS ONLY;
</code></pre>
---
## LLM과 벡터 검색 기술의 상호작용
### LLM과 벡터 검색 기술의 결합은 데이터 분석의 정확도와 효율을 극대화함
- RAG(Retrieval augmented generation)란 생성 AI 모델에 검색 메커니즘을 통합하여 보다 정확하고 의미 있는 콘텐츠를 생성하는 기술임
  - LLM에 컨텍스트를 제공하기 위해 최신 데이터를 사용함
  - 벡터 데이터베이스에 벡터로 저장되는 인코딩(임베딩)을 생성함
  - 사용자 쿼리가 인코딩되고 저장된 벡터와 유사성검색을 수행함
  - 상위 일치 항목(K-top)이 검색되어 프롬프트와 함께 제공됨
- RAG 프레임워크의 백터스토어로 사용가능하며 DB내에서 직접 LLM과 통신할수 있는 인터페이스를 같이 제공
---
## 더 자세한 내용은 메뉴얼을 참고하세요
- <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
- <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>
</textarea>
</section>
{% include pptend.html id="aivs" initialize="center: false,"%}

## 마무리

오라클의 백터 검색기능은 23ai에서 제공되는 기능입니다. 
기존 비즈니스 데이터와 백터 검색기능을 이용할 경우 다양한 비즈니스에서 사용할수 있습니다.
게시판 데이터가 있더라고, 벡터 검색기능으로 텍스트 유사도 검색을 하면 기존 Exact 검색기법 대신 Similarity 검색기법을 사용하면 검색자의 입장에서는 더욱 정확한 데이터를 검색할수 있습니다. 

"서울" 데이터를 검색할때, "서울", "서울역"과 같은 Exact 검색기법이 아니라, "서울", "특별시", "수도" 등의 결과를 검색할수 있는 Similarity 검색기법이 검색결과관점에서 보면 더욱 정확하게 느껴지지 않으신가요?

## 참고문서

- Oracle AI Vector Search관련 오라클 사이트
  - <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
  - <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>