---
layout: single
title: "[오라클] 벡터 검색 기술 고급 활용(3) - 그래프 검색 연계"
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
excerpt : "🌟 벡터 검색과 그래프 검색을 결합해 더 정밀하게 검색하는 방법에 대해서 알아봅니다."
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---
  
## 들어가며 

벡터 검색은 비슷한 콘텐츠를 찾아주는 기술입니다.
예를 들어, 벡터 검색으로 상위 3개의 콘텐츠를 검색했을 때, 각 결과의 거리 계산 값을 확인하면 거의 비슷한 경우가 있을수 있습니다..
이럴 때 아주 미세한 차이로 순위가 결정되었다면, 검색 결과 중 1위가 정말 내가 원하는 정답이라고 말할 수 있을까요?

때로는 이런 작은 차이를 극복하기 위해 더 구체적인 검색 기준이 필요할 수 있습니다.
구체적인 검색 기준이란, 검색된 데이터와 연관된 데이터를 조건으로 추가해 결과를 더 정밀하게 만드는 것을 의미합니다.

벡터 검색만으로도 많은 장점이 있지만, 결과 간 차이가 크지 않을 경우 다른 검색 기술을 결합해 순위를 조정하고, 검색 품질을 높일 수 있습니다.
이 글에서는 벡터 검색에 그래프 검색을 결합하여 검색 품질을 조정하는 예제를 살펴보겠습니다. 

## 검색 기술 연계의 필요성

특정한 목표를 달성하기 위해 검색 기술을 조합해야 하는 이유를 설명해 보겠습니다.
이 예제에서는 개인화된 서비스를 제공하는 OTT 플랫폼의 상황을 가정합니다.

**개인화 된서비스 예시**

대부분의 사람들이 OTT 서비스를 하나쯤 구독하고 있을 겁니다.
어떤 OTT 플랫폼에서 개인화된 영화 시청 파티를 제공하는 서비스를 준비 중이라고 해봅시다.
이 서비스는 기존의 영화 시청 파티 이벤트를 개선하여, 사용자가 직접 주최할 수 있도록 하고자 합니다.
OTT 플랫폼은 이미 고객들의 시청 정보를 보유하고 있습니다.

서비스를 어떻게 개인화할 수 있을까요?

1.	사용자가 시청 파티를 주최하기 위해 영화를 선정해야 합니다.
2.	영화를 선정하기 위해 줄거리나 장르를 기준으로 선택할 수 있습니다.
3.	과거 시청 이력을 바탕으로 선택한 영화와 비슷한 줄거리를 가진 영화를 검색합니다.
4.	비슷한 줄거리를 가진 영화를 같이 본 친구를 찾습니다.
5.	친구들에게 영화 시청 파티 초대장을 보냅니다.
 
**벡터 검색이 필요한 부분**

이 시나리오에서 벡터 검색이 필요한 단계는 무엇일까요?
“비슷한 줄거리를 가진 영화를 검색“할 때 벡터 검색을 활용할 수 있습니다.
그런데 여기에서 문제가 생길 수 있습니다.

예를 들어, 벡터 검색으로 여러 개의 영화가 검색되었다고 가정해 봅시다.
모든 영화의 줄거리가 비슷하다면, 어떤 영화를 기준으로 친구를 초대해야 할까요?

**관계 검색의 필요성**

1.	영화 기준 설정 예시
	-	Top 1 영화를 기준으로 함께 본 친구들에게 초대장을 보냅니다.
	-	Top 1 영화를 함께 본 친구는 2명이었습니다.
2.	질문: 친구 2명만 초대한다면, 시청 파티의 참여율은 높을까요?
	-	초대 인원이 적기 때문에, 참여율이 낮을 가능성이 큽니다.
3.	Top 3 영화로 확장
	-	Top 1, Top 2, Top 3 영화를 기준으로 함께 본 친구를 모두 확인합니다.
	-	Top 1 영화를 함께 본 친구는 2명, Top 2 영화를 함께 본 친구는 5명이었습니다.

**최적의 선택은?**

Top 1 영화와 Top 2 영화의 줄거리가 모두 시청 파티에서 볼 영화와 비슷하다면,어떤 친구들에게 초대장을 보내는 것이 참여율을 높일 수 있을까요?
-	Top 1 영화의 친구 2명을 초대하는 것보다,
-	Top 2 영화의 친구 5명을 초대하는 것이 더 나은 선택일 수 있습니다.

단순히 벡터 검색의 결과만으로 결정하지 말고,
추가적으로 관계 검색 결과를 조건으로 사용해 순위를 조정해야 합니다.
이를 통해 더 많은 사람을 초대하고, 참여율을 높이는 효율적인 검색 전략을 구현할 수 있습니다.

## 그래프 검색 연계 예제

앞서 설명한 개인화된 서비스를 위한 구현내용을 코드로 단계적으로 설명합니다. 

### 1. 데이터 준비 및 그래프 객체 생성

데이터 검색을 위하여 테이블을 생성합니다.

- movie 테이블 :  영화정보를 가지고 있습니다.
- cust 테이블 : 고객 정보를 가지고 있습니다. 
- watched 테이블 : 고객이 시청했던 영화 목록을 가지고 있습니다. 
- watched_with : 같이 시청했던 고객들에 대한 정보를 가지고 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- MOVIE 테이블 생성
CREATE TABLE IF NOT EXISTS movie (
   movie_id NUMBER PRIMARY KEY,  
   title VARCHAR2(1000), 
   year NUMBER, 
   genres JSON,
   summary VARCHAR2(4000)
);
```
{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- CUSTOMER 테이블 생성
CREATE TABLE IF NOT EXISTS cust (
    cust_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    email VARCHAR2(100)
);
```
{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- WATCHED 테이블 생성
CREATE TABLE IF NOT EXISTS watched (
    day_id NUMBER ,
    promo_cust_id NUMBER,
    movie_id NUMBER, 
	PRIMARY KEY ( day_id,promo_cust_id, movie_id)
);
```
{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- WATCHED_WITH 테이블 생성
CREATE TABLE IF NOT EXISTS watched_with (
    id NUMBER GENERATED AS IDENTITY PRIMARY KEY,
    watcher NUMBER,
    watched_with NUMBER
);
```

샘플 데이터를 생성합니다.
10명의 고객정보와 12개의 영화정보가 생성합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
BEGIN 
  INSERT INTO movie (movie_id, title, year, summary, genres) VALUES 
  (1, '듄', 2021, '사막 행성 아라키스를 배경으로 한 서사적인 이야기. 주요 가문의 권력 투쟁 속에서 주인공 폴 아트레이디스의 운명이 중심이 된다. 거대한 모래벌레와 귀중한 자원 스파이스를 둘러싼 갈등이 흥미를 더한다.', '["SF", "드라마"]'),
  (2, '스파이더맨: 노 웨이 홈', 2021, '멀티버스의 문이 열리며 다양한 차원의 스파이더맨과 악당들이 등장한다. 피터 파커는 자신의 정체성을 숨기기 위해 위험한 선택을 한다. 액션과 감동이 어우러진 이야기로 관객을 사로잡는다.', '["액션", "어드벤처"]'),
  (3, '탑건: 매버릭', 2022, '전설적인 파일럿 매버릭이 돌아와 새로운 세대의 조종사를 훈련시킨다. 과거의 기억과 현재의 책임이 충돌하며 감동적인 서사가 펼쳐진다. 고난을 극복하는 과정에서 진정한 리더십이 무엇인지 보여준다.', '["액션", "드라마"]'),
  (4, '아바타: 물의 길', 2022, '판도라 행성의 물과 자연 생태계를 탐험하는 새로운 모험이 시작된다. 제이크 설리와 네이티리 가족이 생존을 위해 새로운 위협에 맞선다. 자연과 조화로운 삶의 가치를 다시 한번 일깨워주는 감동적인 이야기.', '["SF", "어드벤처"]'),
  (5, '범죄도시 2', 2022, '마석도 형사가 해외에서 활동하는 강력 범죄 조직을 추적한다. 범죄와의 치열한 대결 속에서 정의감 넘치는 액션이 돋보인다. 긴장감과 유머가 어우러진 범죄 액션 영화.', '["액션", "범죄"]'),
  (6, '헤어질 결심', 2022, '형사와 용의자 사이에 형성되는 미묘한 감정선을 다룬다. 살인 사건의 진실을 파헤치면서 예상치 못한 갈등이 깊어진다. 사랑과 의심이 교차하는 독창적인 스릴러.', '["로맨스", "스릴러"]'),
  (7, '더 배트맨', 2022, '새로운 배트맨이 등장하여 고담시를 위협하는 범죄를 조사한다. 어둠 속에서 정의를 찾아가는 그의 여정은 흥미진진하다. 독특한 스타일과 강렬한 캐릭터가 돋보이는 작품.', '["액션", "범죄"]'),
  (8, '엘비스', 2022, '엘비스 프레슬리의 음악적 여정과 복잡한 삶을 그린 드라마. 그의 성공과 그 이면의 갈등을 심도 있게 다룬다. 음악과 감동이 어우러진 전기 영화.', '["드라마", "음악"]'),
  (9, '에브리씽 에브리웨어 올 앳 원스', 2022, '멀티버스를 배경으로 한 독특한 이야기로 한 여성의 특별한 여정을 다룬다. 평범한 삶에서 벗어나 우주적 존재와의 연결을 통해 변화를 경험한다. 유머와 철학이 결합된 신선한 SF 코미디.', '["SF", "코미디"]'),
  (10, '오펜하이머', 2023, '원자폭탄 개발의 중심에 있었던 과학자 오펜하이머의 이야기를 담았다. 과학적 혁신과 도덕적 갈등이 깊이 있게 그려진다. 역사적 순간을 생생하게 재현한 감동적인 드라마.', '["드라마", "역사"]'),
  (11, '데드풀과 울버린', 2024, '마블의 인기 캐릭터 데드풀과 울버린이 함께 펼치는 유쾌한 모험. 예상치 못한 상황과 유머로 가득 찬 액션이 돋보인다. 슈퍼히어로 팬들에게 큰 즐거움을 선사하는 작품.', '["슈퍼히어로", "액션", "코미디"]'),
  (12, '모아나 2', 2024, '모아나가 새로운 항해에 나서며 또 다른 모험을 경험한다. 가족과 동료들과의 유대가 더욱 깊어진다. 감동과 음악이 어우러진 애니메이션 후속편.', '["애니메이션", "어드벤처", "뮤지컬"]');

  INSERT INTO cust (cust_id, name, email) VALUES 
  (1, '김철수', 'cheolsu.kim@example.com'),
  (2, '이영희', 'younghee.lee@example.com'),
  (3, '박민준', 'minjun.park@example.com'),
  (4, '최수정', 'soojung.choi@example.com'),
  (5, '정다은', 'daeun.jung@example.com'),
  (6, '한지우', 'jiwoo.han@example.com'),
  (7, '윤서현', 'seohyun.yoon@example.com'),
  (8, '임현수', 'hyunsoo.lim@example.com'),
  (9, '오민서', 'minseo.oh@example.com'),
  (10, '강하윤', 'hayoon.kang@example.com');


  -- 김철수, 이영희, 박민준이 4번영화 관람함
  INSERT INTO watched (day_id, promo_cust_id, movie_id) VALUES 
  (1, 1, 4),(1, 2, 4),(1, 3, 4);

  --김철수가 이영희,박민준 과 같이 관람함
  INSERT INTO watched_with ( watcher, watched_with) VALUES 
  (1, 2), (1, 3);

  -- 김철수,박민순, 정다은, 한지우, 윤서현, 임현수이 2번영화 관람함
  INSERT INTO watched (day_id, promo_cust_id, movie_id) VALUES 
  (2, 1, 2),(2, 3, 2),(2, 5, 2),(2, 6, 2), (2, 7, 2), (2, 8, 2);

  -- 김철수가 이영희, 박민준, 최수정, 정다은과 같이 관람함
  INSERT INTO watched_with ( watcher, watched_with) VALUES 
  (1, 2), (1, 3),(1, 5),(1, 6),(1, 7),(1, 8);

  COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

관계 분석을 위하여 그래프(Property Graph)를 생성합니다.
Oracle의 Property Graph는 노드와 엣지에 속성을 부여하여 복잡한 관계 데이터를 분석할수 있는 기능으로 제공합니다. 
이를 통해 대규모 데이터에서 패턴을 탐색하고 고급 네트워크 분석을 수행할 수 있습니다.

- Property Graph : <https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/graph_table-operator.html>{:target="_blank"}


고객정보와 영화정보간의 관계를 정의합니다
고객은 영화를 시청(watched)하고, 고객들간의 같이 시청(watched_with)했던 정보를 객체로 표현할수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE PROPERTY GRAPH IF NOT EXISTS movie_recommendations
VERTEX TABLES (
    CUST
        KEY ( CUST_ID ),
    MOVIE
        KEY ( MOVIE_ID )
)
EDGE TABLES (
    WATCHED
        KEY ( DAY_ID, PROMO_CUST_ID, MOVIE_ID )
        SOURCE KEY ( PROMO_CUST_ID ) REFERENCES CUST ( CUST_ID )
        DESTINATION KEY ( MOVIE_ID ) REFERENCES MOVIE ( MOVIE_ID ),
    WATCHED_WITH
        KEY(ID)
        SOURCE KEY ( WATCHER ) REFERENCES CUST( CUST_ID )
        DESTINATION KEY ( WATCHED_WITH ) REFERENCES CUST ( CUST_ID )
);
```

### 2. 벡터 검색과 그래프 검색 활용

"김철수"고객이 영화시청파티를 주최하고자 합니다. 
일단 2024년 개봉작 중에 '어드벤처'장르를 검색합니다. (결과 가독성을 위하여 `SELECT json_arrayagg(json_object(*)) FROM (<쿼리>)`를 이용하여 JSON으로 출력했습니다. )

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT m.TITLE, m.MOVIE_ID, m.YEAR, m.SUMMARY 
  FROM MOVIE m 
 WHERE m.YEAR = 2024 
   AND JSON_EXISTS(genres, '$[*]?(@ == "어드벤처")');
```

2024년 개봉작중에 '어드벤처'장르로 '모아나 2'가 검색되었습니다. 
'모아나 2' 영화 시청파티를 주최하는것으로 결정했습니다.

```json
[
  {"TITLE":"모아나 2","MOVIE_ID":12,"YEAR":2024,"SUMMARY":"모아나가 새로운 항해에 나서며 또 다른 모험을 경험한다. 가족과 동료들과의 유대가 더욱 깊어진다. 감동과 음악이 어우러진 애니메이션 후속편."}
]
```

'모아나 2'영화과 비슷한 줄거리를 가진 영화 목록을 벡터 검색합니다. 
벡터 검색시 임베딩 모델은 오라클 데이터베이스내에 로딩된 모델을 사용합니다.

오라클 데이터베이스에 택스트 임베딩 모델을 로딩할수 있습니다. 텍스트 임베딩 및 유사도 검색은 아래 블로그를 참조하시기 바랍니다. 
- [벡터 검색 기술 활용 - 텍스트유사도검색](/blog/vector-search/how-to-use-oracle-ai-vector-search/#업데이트){:target="_blank"}

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT mo.MOVIE_ID, mo.TITLE, mo.YEAR, mo.SUMMARY,
       VECTOR_DISTANCE(
         VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using mo.summary as data ),
         VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using m.summary as data ), COSINE) as vec_dist
FROM MOVIE m, MOVIE mo
WHERE m.TITLE = '모아나 2'
  AND JSON_EXISTS(mo.genres, '$[*]?(@ == "어드벤처")')
  AND mo.YEAR between 2021 and 2023
ORDER BY vec_dist;
```

줄거리가 비슷한 영화는 "아바타: 물의 길"와 "스파이더맨: 노 웨이 홈" 영화입니다
벡터 유사도(VEC_DIST)를 기준으로 '모아나 2'와 가장 비슷한 영화는 "아바타: 물의 길" 입니다.

```json
[
  {"MOVIE_ID":4,"TITLE":"아바타: 물의 길","YEAR":2022,"SUMMARY":"판도라 행성의 물과 자연 생태계를 탐험하는 새로운 모험이 시작된다. 제이크 설리와 네이티리 가족이 생존을 위해 새로운 위협에 맞선다. 자연과 조화로운 삶의 가치를 다시 한번 일깨워주는 감동적인 이야기.","VEC_DIST":0.127494215965271},
  {"MOVIE_ID":2,"TITLE":"스파이더맨: 노 웨이 홈","YEAR":2021,"SUMMARY":"멀티버스의 문이 열리며 다양한 차원의 스파이더맨과 악당들이 등장한다. 피터 파커는 자신의 정체성을 숨기기 위해 위험한 선택을 한다. 액션과 감동이 어우러진 이야기로 관객을 사로잡는다.","VEC_DIST":0.14889639616012573}
]
```

'김철수' 고객이 과거에 시청한 영화목록을 확인합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT C1NAME WATCHER, MOVIE_TITLE
  FROM GRAPH_TABLE( MOVIE_RECOMMENDATIONS
             MATCH (c1 IS CUST)-[e1 IS WATCHED]->(m IS MOVIE)
             WHERE c1.NAME  ='김철수'
           COLUMNS (c1.NAME as C1NAME, m.title as MOVIE_TITLE) );
```

다행이도 벡터 검색에서 검색된 영화 모두 이전에 시청했던 영화로 확인되었습니다.

```json
[
  {"WATCHER":"김철수","MOVIE_TITLE":"아바타: 물의 길"},
  {"WATCHER":"김철수","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"}
]

```

'김철수' 고객이 과거에 같이 시청한 친구들을 확인합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT distinct C1NAME WATCHER, C2NAME WATCHED_WITH, MOVIE_TITLE
 FROM GRAPH_TABLE(MOVIE_RECOMMENDATIONS 
      MATCH (c1 is CUST) -[e is WATCHED_WITH]-> (c2 is CUST)-[w is WATCHED]-> (m is MOVIE)
      WHERE c1.NAME ='김철수'
    COLUMNS (c1.NAME as C1NAME, C2.NAME as C2NAME, m.TITLE as MOVIE_TITLE));
```

김철수 고객은 과거 "아바타: 물의 길" 영화를 2명의 친구와 시청했고, "스파이더맨: 노 웨이 홈" 영화를 5명의 친구와 시청했습니다. 
( 그래프 검색의 경우 시각화를 할경우 기존에 파악하기 힘들었던 관계를 좀더 쉽게 확인할수 있습니다.)

```json
[
  {"WATCHER":"김철수","WATCHED_WITH":"이영희","MOVIE_TITLE":"아바타: 물의 길"},
  {"WATCHER":"김철수","WATCHED_WITH":"박민준","MOVIE_TITLE":"아바타: 물의 길"},
  {"WATCHER":"김철수","WATCHED_WITH":"박민준","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"},
  {"WATCHER":"김철수","WATCHED_WITH":"정다은","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"},
  {"WATCHER":"김철수","WATCHED_WITH":"한지우","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"},
  {"WATCHER":"김철수","WATCHED_WITH":"윤서현","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"},
  {"WATCHER":"김철수","WATCHED_WITH":"임현수","MOVIE_TITLE":"스파이더맨: 노 웨이 홈"}
]
```

**통합조회**

'김철수' 고객이 '모아나 2' 영화 시청 파티에 초대하기 위하여 과거에 같이 시청했던 친구 수를 확인합니다.
벡터 검색과 그래프 검색을 조합하여 검색합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT WATCHER, MOVIE_TITLE, VEC_DIST, LISTAGG(DISTINCT WATCHED_WITH ,',') WATCHED_WITH 
  FROM (SELECT C1NAME WATCHER, C2NAME WATCHED_WITH, MOVIE_TITLE, 
            VECTOR_DISTANCE(svec, 
                (SELECT VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using summary as data ) 
                   FROM movie 
                  WHERE title = '모아나 2'), COSINE) as vec_dist 
        FROM (
            SELECT C1NAME, C2NAME, MOVIE_TITLE, VECTOR_EMBEDDING(MULTILINGUAL_E5_SMALL using summary as data ) svec
            FROM GRAPH_TABLE(MOVIE_RECOMMENDATIONS 
                MATCH (c1 is CUST) -[e is WATCHED_WITH]-> (c2 is CUST)-[w is WATCHED]-> (m is MOVIE)
                WHERE c1.NAME ='김철수'  
                COLUMNS (c1.NAME as C1NAME, C2.NAME as C2NAME, m.TITLE as MOVIE_TITLE, m.SUMMARY)
            )
        ))
 GROUP BY WATCHER, MOVIE_TITLE, VEC_DIST;
 ```


영화 내용은 '아바타' 영화가 더 유사하지만, 시청을 많이 한 영화는 '스파이더맨' 이었습니다.
'모아나 2' 시청파티에 '스파이더 맨'을 시청한 친구들을 초대하면 참여율이 높아질것입니다.

```json
[
  {"WATCHER":"김철수","MOVIE_TITLE":"스파이더맨: 노 웨이 홈","VEC_DIST":0.14889639616012573,"WATCHED_WITH":"박민준,윤서현,임현수,정다은,한지우"},
  {"WATCHER":"김철수","MOVIE_TITLE":"아바타: 물의 길","VEC_DIST":0.127494215965271,"WATCHED_WITH":"박민준,이영희"}
]
```

## 마무리
 
지금까지 벡터 검색과 그래프 검색을 연계하여, 벡터 검색 결과에 조건을 추가하고 결과 순위를 조정하는 방법을 알아보았습니다.

도메인 지식이 있다면 다양한 검색 방법을 더욱 효과적으로 활용할 수 있지만, 벡터 검색과 다른 검색 기술을 조합하면 정형 데이터와 비정형 데이터를 연결해 실질적인 비즈니스 가치를 창출할 수 있습니다.

처음에는 다소 생소하게 느껴질 수 있는 예제일지라도, 단순한 비정형 데이터 검색을 넘어 다양한 검색 기술을 조합해 더 정교한 검색 결과를 얻을 수 있다는 점은 이해하셨을 것이라 생각합니다.

검색 기술의 발전은 단순한 데이터 검색을 넘어 더 나은 의사결정과 개인화된 경험을 제공할 수 있는 중요한 도구로 활용될것입니다. 

여러분도 이번 글을 바탕으로 다양한 검색 기술을 조합해 창의적인 비즈니스 아이디어를 만들어 보시기 바랍니다! 

## 참고자료

- Oracle Property Graph : <https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/graph_table-operator.html>{:target="_blank"}
- Title Use of Graph RAG and Vector Search for Enhanced User Prompt to LLM : <https://apexapps.oracle.com/pls/apex/r/dbpm/livelabs/view-workshop?wid=3953>{:target="_blank"}