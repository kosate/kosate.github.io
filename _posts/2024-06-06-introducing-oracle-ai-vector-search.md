---
layout: single
title: "[오라클] 비정형 데이터를 검색하는 기술(Oracle AI Vector Search)"
date: 2024-06-06 15:00
categories: 
  - vector-search
books: 
 - oracleaivectorsearch
 - oracle23newfeature 
contents: PPT
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
excerpt : "✨ 오라클 데이터베이스 23ai에서 신규 추가된 Oracle AI Vector Search대해서 알아봅니다"
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

오라클 데이터베이스 23ai 버전에는 새로운 **Oracle AI Vector Search** 기능이 추가되었습니다.
이 기능은 비정형 데이터를 다루기 위한 다양한 기술을 제공합니다. 예를 들어, **벡터 임베딩(embedding) 작업**, 텍스트 **청킹(chunking)**, 유사도를 계산하는 **거리 함수**, 그리고 대용량 데이터를 빠르게 검색할 수 있는 **벡터 인덱스**를 제공합니다.

오라클 데이터베이스에서는 이러한 기능들을 **Oracle AI Vector Search**라고 부릅니다.

## 비정형 데이터를 검색하는 기술(Oracle AI Vector Search)

비정형 데이터를 검색하는 오라클의 새로운 기능에 대해 간단히 정리해보겠습니다.

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

- 요즘 데이터 환경은 빠르게 변하고 있으며, 기업 내부에서 비정형 데이터의 양도 엄청나게 늘어나고 있습니다.
- 비정형 데이터란, 텍스트, 이미지, 영상 등처럼 구조화되지 않은 데이터를 뜻합니다. 이런 데이터는 바로 비즈니스에 활용하기 어려운 경우가 많습니다.
- 이를 해결하려면:
	- 비정형 데이터를 저장하고 분석할 수 있는 전문 인력과 인프라가 필요합니다.
	- 데이터를 구조화하여 처리해야 하는 번거로움이 있습니다.

---
## 기존 관계형 저장소의 한계
### 관계형 DB는 엄격한 스키마와 SQL 쿼리의 한계로 인해 새로운 데이터 형식을 효과적으로 관리하는 데 제약이 있음

- 기존 데이터베이스 시스템(RDBMS)은 데이터를 처리하는 데 엄격한 규칙을 따릅니다.하지만 이러한 특징은 새로운 형식의 데이터를 다루는 데 한계로 작용합니다.
  -  RDBMS는 데이터를 스키마에 맞춰 저장하고, SQL로 처리합니다.
  - 이런 방식은 구조화된 데이터 처리에는 적합하지만, 비정형 데이터를 처리하기에는 부족합니다.
- 결과적으로, 비정형 데이터의 활용이 점점 중요해짐에 따라 기존 시스템을 개선할 필요성이 커지고 있습니다.

---
## 벡터 검색 기술이 필요한 이유
### 벡터 검색 기술은 데이터를 수치적 벡터로 변환하여 비정형 데이터에 대한 검색을 가능하게 함

- 벡터 검색 기술은 데이터를 수치적인 벡터로 변환하여, 비정형 데이터를 더 효과적으로 검색할 수 있게 합니다.
- 쉽게 말해, 텍스트나 이미지 같은 비정형 데이터를 숫자들의 모음인 벡터로 바꾸고, 이 벡터 사이의 거리를 계산해 유사도를 판단하는 기술입니다.
- 이 기술을 활용하면:
	-	텍스트, 이미지, 영상 등 다양한 데이터를 다룰 수 있습니다.
	-	비정형 데이터를 쉽게 검색하고 활용할 수 있는 도구를 제공받을 수 있습니다.

---
## 오라클 데이터베이스의 벡터 검색 기술
### 오라클은 AI Vector Search기능을 통해 비정형 데이터를 위한 백터 검색 기술을 제공하고 AI를 위한 지식베이스를 제공
- 오라클 23ai에 AI 벡터 검색 기능 추가되었습니다. 
- 동일한 데이터베이스에서 벡터 및 다른 업무 동시 처리가능합니다.
  - AI 벡터 검색과 함께 비즈니스 데이터를 같이 조회합니다.
- 사용하기 쉽고 이해하기 쉽도록 설계되었습니다.
  - 벡터 임베딩을 저장하기 위한 새로운 VECTOR 데이터 타입 추가되었습니다.
  - 유사성 검색은 새로운 SQL 구문 및 함수로 손쉽게 가능합니다.
  - 벡터 전용 고성능 인덱스 추가되었습니다.
---
## Oracle AI Vector Search의 주요기능
### 오라클은 벡터임베딩 및 유사도 검색가능한 벡터 스토어를 제공함

- 오라클의 Oracle AI Vector Search는 비정형 데이터를 검색하고 처리할 수 있는 강력한 도구를 제공합니다.
  - Generate : 비정형 데이터를 벡터로 변환(비정형 데이터를 벡터로 변환)
  - Store : 변환된 벡터 데이터를 데이터베이스에 저장(최대 64 차줜의 데이터를 지원)
  - index : 벡터 데이터를 빠르게 검색할 수 있도록 인덱스 제공 (HNSW 인덱스, IVF인덱스 지원, Accuracy기반의 손쉬운 튜닝)
  - Search : 벡터 데이터를 빠르게 검색할 수 있도록 인덱스 제공 (다양한 거리 함수 사용 가능)
---
## 벡터 검색과 오라클의 시너지 효과
### 오라클은 시맨틱 검색과 관계형 검색을 하나의 단일 시스템에서 결합할 수 있음
- 오라클은 벡터 검색과 기존 데이터 검색을 하나의 시스템에서 통합했습니다.
- 이로 인해 데이터베이스 안에서 비정형 데이터와 구조화된 데이터를 동시에 다룰 수 있게 되었습니다.
	-	데이터를 별도로 복사하거나 옮길 필요 없이, 엔터프라이즈급 데이터베이스에 벡터 검색 기능을 바로 추가할 수 있습니다.
	-	기존 RDBMS와 자연스럽게 결합하여 사용하기 쉽습니다.

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

- 벡터 검색 기술은 최신 AI 모델(LLM)과도 잘 어울립니다.
- 예를 들어, RAG(Retrieval-Augmented Generation) 방식에서는 검색을 통해 AI가 더 정확하고 의미 있는 답변을 제공합니다.
	-	LLM은 사용자 질문을 이해하고, 벡터 데이터베이스에 저장된 유사한 데이터를 검색하여 답변에 활용합니다.
	-	이러한 방식은 AI 모델의 성능을 극대화합니다.
	-	오라클은 LLM과 벡터 검색을 연결할 수 있는 인터페이스도 제공합니다.
---
## 더 자세한 내용은 메뉴얼을 참고하세요
- <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
- <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>
</textarea>
</section>
{% include pptend.html id="aivs" initialize="center: false,"%}

## 마무리

오라클의 AI Vector Search 기능은 비정형 데이터를 검색하고 활용할 수 있는 새로운 길을 열어줍니다.
기존의 단순 검색 방식보다 유사도 검색을 통해 더욱 정확하고 유용한 결과를 얻을 수 있습니다.

예를 들어, “서울”을 검색할 때, 단순히 “서울역”만 나오는 것이 아니라 “특별시”, “수도” 같은 연관된 데이터도 함께 검색할 수 있습니다.

## 참고문서

- Oracle AI Vector Search관련 오라클 사이트
  - <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
  - <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>