---
layout: single
title: 비정형 데이터를 검색하는 기술
date: 2024-06-06 15:00
categories: 
  - Oracle
books:
 - oracle23newfeature
author: 
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
excerpt : 오라클 데이터베이스에서 비정형 데이터를 검색하는 기술에 대해서 알아보겠습니다.
toc : true  
toc_sticky: true
---

## 들어가며

오라클 DB 23ai버전에 Oracle AI Vector Search기능이 추가되었습니다.

벡터 검색을 위한 임베딩 작업, 텍스트 청킹기능, 유사도 검색을 위한 거리함수들을 제공하며, 
대용량의 벡터데이터를 검색하기 위한 인덱스 기능이 있습니다. 
이러한 기능들을 Oracle AI Vector Search라고 불리웁니다. 

## 비정형 데이터를 검색하는 기술

비정형 데이터를 검색할수 있는 오라클의 기능 AI Vector Search기능에 대해서 간단하게 정리하였습니다.

{% include pptstart.html id="deck1" style="height:600px;" %}
<section data-markdown>
<textarea data-template>

# 비정형 데이터를 검색하는 기술
---
### 데이터 환경의 새로운 변화: 비정형 데이터의 관리
- 비정형 데이터는 빠르게 증가되고 있지만, 기업내 비즈니스에 활용하기는 어려웠습니다.
  - 데이터 환경은 빠르게 변화하며 비정형 데이터의 양이 급증하고 있습니다.
  - 비정형 데이터는 다양한 형태로 존재하며, 구조화되지 않은 상태로 비즈니스 활용이 어렵습니다
---
### RDBMS의 한계와 비정형 데이터의 도전
- RDBMS는 엄격한 스키마와 SQL 쿼리의 한계로 인해 새로운 데이터 형식을 효과적으로 관리하는 데 제약이 있습니다.
  - RDBMS는 데이터를 엄격한 스키마에 따라 저장하고 SQL을 통해 조작합니다.
  - RDBMS는 구조화된 데이터 처리에는 최적화되어 있지만 비정형 데이터 처리에는 제한적입니다. 
  - 비정형 데이터의 증가는 기업이 유연한 데이터 관리 방식을 모색하게 합니다.
---
### 벡터 검색 기술의 이해
- 벡터 검색 기술은 데이터를 수치적 벡터로 변환하여 비정형 데이터에 대한 검색을 가능하게 합니다.
  - 벡터 검색 기술은 데이터를 수치적인 벡터로 변환하고 이를 저장하여 검색합니다.
  - 비정형 데이터를 벡터로 매핑하고, 벡터 간 거리를 수학적 방법으로 측정하여 유사도를 검색합니다.
  - 이 기술은 텍스트, 이미지, 비디오 등 다양한 데이터 유형을 처리할 수 있습니다.
---
### 오라클 데이터베이스의 벡터 검색 기술(AI Vector Search)
- 오라클은 비정형 데이터를 위한 백터 검색 기술을 제공하고 AI를 위한 지식베이스를 제공합니다.
  - 사용하기 쉽고 이해하기 쉽도록 설계되었습니다.
    - 벡터 임베딩을 저장하기 위한 새로운 VECTOR 데이터 타입 추가되었습니다.
    - 유사성 검색은 새로운 SQL 구문 및 함수로 손쉽게 가능합니다.
    - 벡터 전용 고성능 인덱스 추가되었습니다.
---
### Oracle AI Vector Search기능의 특장점
- 오라클은 End-to-End 벡터 데이터베이스입니다.
  - Generate : 비정형 데이터에서 벡터 임베딩으로 변환합니다.
  - Store : 테이블의 벡터 컬럼에 벡터 데이터 저장합니다.
  - index : 저장 임베딩에 대한 벡터 인덱싱 지원합니다.
  - Search : 오라클 벡터 서치 쿼리로 유사성 높은 데이터 검색합니다.
---
### 오라클 데이터베이스와 벡터 검색 기술의 시너지 효과
- 오라클은 시맨틱 검색과 관계형 검색을 하나의 단일 시스템에서 결합할 수 있습니다.
  - 별도의 벡터 데이터베이스에 데이터를 복제하는 것이 아닌 엔터프라이즈 데이터에 벡터 임베딩과 벡터 서치 기능 추가되었습니다.
  - 통합된 엔터프라이즈급 데이터베이스에 벡터 검색 기능을 쉽게 추가할 수 있습니다.
---
## 참조문서 
  - <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
  - <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>
---
# End of Documents

</textarea>
</section>
{% include pptend.html id="deck1" initialize="center: false,"%}

## 마무리

오라클의 백터 검색기능은 무료로 사용할수 있는것으로 알고 있습니다. 
기존 비즈니스 데이터와 백터 검색기능을 이용할 경우 다양한 비즈니스에서 사용할수 있습니다.
게시판 데이터가 있더라고, 벡터 검색기능으로 텍스트 유사도 검색을 하면 기존 Exact 검색기법 대신 Similarity 검색기법을 사용하면 검색자의 입장에서는 더욱 정확한 데이터를 검색할수 있습니다. 

"서울" 데이터를 검색할때, "서울", "서울역"과 같은 Exact 검색기법이 아니라, "서울", "특별시", "수도" 등의 결과를 검색할수 있는 Similarity 검색기법이 검색결과의 정보를 보면 더욱 정확하게 느껴지지 않으신가요?

## 참고문서

- Oracle AI Vector Search관련 오라클 사이트
  - <a href="https://www.oracle.com/kr/database/ai-vector-search/" target="_blank">AI Vector Search</a>
  - <a href="https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/overview-ai-vector-search.html" target="_blank">Oracle AI Vector Search User's Guide</a>