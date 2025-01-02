---
layout: single
title: "[오라클] 벡터 검색 기술 활용(2) - 데이터분류"
date: 2024-06-18 15:00
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
   - image classificiation
excerpt : "🖼️ 벡터 검색을 통해 데이터 분류하는 방법에 대해서 알아봅니다. "
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며
벡터 검색 기술은 비정형 데이터를 효과적으로 분류하는 데 유용한 도구입니다.
예를 들어, 텍스트 유사도 검색을 통해 가장 유사한 텍스트 Top K를 쉽게 찾을 수 있습니다.

만약 이미지 분류 작업을 수행한다고 가정해 봅시다.
라벨링된 데이터와 해당 이미지의 특징 벡터를 데이터베이스에 저장해 두고, 분류하고자 하는 이미지의 특징 벡터를 생성하여 유사도 검색을 수행하면, 가장 유사한 이미지의 라벨링 데이터를 이용해 분류 작업을 간단히 수행할 수 있습니다.

이번 글에서는 오라클 데이터베이스 23ai에서 제공하는 AI Vector Search 기능을 활용하여 이미지 분류 작업을 어떻게 수행할 수 있는지 살펴보겠습니다.

## 이미지 분류 방안 비교
이미지 분류 작업에는 크게 두 가지 접근 방식이 있습니다.
1. **이미지 분류 모델 훈련(fine-tuning)**을 통해 분류 작업을 수행하는 방법
2. 벡터 검색 기능을 활용하여 이미지를 분류하는 방법

이 두 가지 방법의 차이를 비교하며 살펴보겠습니다.

### 1. 이미지 분류 모델 훈련(fine-tuning)

이미지 분류를 위해 딥러닝, 특히 **Convolutional Neural Network(CNN)**을 사용하는 일반적인 방법입니다.
다음과 같은 절차로 진행됩니다.

- 이미지 분류 모델 훈련 절차
  1. 데이터 수집 및 전처리 : 이미지 데이터를 수집한 후, 정규화, 크기 조정, 데이터 증강 등을 수행합니다.
  2. 모델 설계 : CNN 모델을 설계하고, 입력 레이어, Convolutional 레이어, Pooling 레이어, Fully Connected 레이어 등을 구성합니다
  3. 모델 훈련 : 데이터를 학습용과 검증용으로 나누고, 학습 데이터를 이용해 모델을 훈련합니다.
  4. 모델 평가 : 검증 데이터를 사용해 모델의 성능을 평가하고, 정확도, 정밀도, 재현율 등을 확인합니다.
  5. 모델 테스트 및 배포 : 테스트 데이터를 통해 최종 성능을 확인한 후, 실제 환경에 배포합니다.

사전 훈련된 모델을 사용할 경우 일부 단계를 간소화할 수 있지만, 여전히 모델 훈련과 성능 평가에는 많은 시간과 리소스가 필요합니다

### 2. 백터 검색을 활용한 이미지 분류

벡터 검색 기술은 사전 훈련된 모델을 사용하여 특징 벡터를 추출하고 이를 데이터베이스에 저장한 후, 유사도 검색으로 이미지를 분류하는 방식입니다.
다음은 주요 절차입니다.

- 백터 검색을 이용한 이미지 분류 절차
  1. 데이터 수집 및 전처리 : 일반적인 이미지 분류 모델과 동일하게 데이터를 수집하고 전처리합니다.
  2. 특징 추출 :  **사전 훈련된 CNN 모델**을 사용하여 이미지에서 특징 벡터를 추출합니다. 
  3. 벡터 데이터 저장 : 추출한 특징 벡터를 오라클 데이터베이스에 VECTOR 데이터 타입으로 저장합니다.
  4. 벡터 검색 및 유사도 계산 : 새로운 이미지가 주어지면 동일한 방식으로 특징 벡터를 추출하고, 데이터베이스의 VECTOR_DISTANCE 함수를 사용해 유사도를 계산합니다.
  5. 이미지 분류 : 유사도가 가장 높은 벡터의 클래스를 참조하여 이미지를 분류합니다. k-최근접 이웃 알고리즘(K-NN) 등을 사용할 수 있습니다.

### 두가지 이미지 분류 방안 비교

**작업 절차 비교**

벡터 검색을 이용한 이미지 분류는 사전 훈련된 모델을 사용하기 때문에, 일반적인 CNN 모델 설계 및 훈련 절차가 생략됩니다.
또한 모델 평가와 이미지 분류는 오라클 데이터베이스의 SQL로 간단히 처리할 수 있습니다.

| 항목                       | 이미지 분류 모델(fine tuning)                            | 벡터 검색을 이용한 이미지 분류                         |
|----------------------------|--------------------------------------------------|---------------------------------------------------|
| **데이터 수집 및 전처리**   | 정규화, 크기 조정, 데이터 증강  | 정규화, 크기 조정, 데이터 증강  |
| **특징 추출**              | CNN 모델을 통해 직접 특징 학습                     | 사전 훈련된 모델을 통해 특징 벡터 추출             |
| **모델 설계**              | CNN 레이어 구성       | 사전 훈련된 모델 사용                             |
| **모델 훈련**              | 훈련 데이터를 사용해 학습                   | 특징 벡터를 데이터베이스에 저장(INSERT)                   |
| **모델 평가**              | 검증 데이터를 사용해 평가                   | 벡터 검색을 통해 유사도 계산(SELECT)                     |
| **이미지 분류**            | 테스트 데이터를 사용해 성능 확인 및 배포       | 유사도 기반 K-NN 등으로 SQL로 분류    |

**장점과 단점 비교**

이미지 분류모델은 훈련된 이미지들에 최적화되어 높은 정확도로 이미지 분류작업이 가능합니다. 반면 모델을 튜닝하고 훈련하는 과정에서 하드웨어 자원을 사용하고 시간이 많이 소요되는 단점이 있습니다. 
벡터 검색을 이용한 이미지 분류작업은 사전 훈련 모델을 사용하여 곧바로 이미지의 특징을 벡터화하고 이를 검색함으로써 업무에 쉽게 적용이 가능합니다. 이미지 분류의 정확도는 사전훈련모델에 좌우되는 단점이 있습니다.

| 항목        | 일반적인 이미지 분류 모델                           | 벡터 검색을 이용한 이미지 분류                        |
|-------------|---------------------------------------------------|---------------------------------------------------|
| **장점**    | - 높은 정확도<br>- 엔드투엔드 학습<br>- 다양한 응용 가능  | - 빠른 검색 속도<br>- 효율적인 특징 저장<br>- 사전 훈련 모델 활용 |
| **단점**    | - 고성능 하드웨어 요구<br>- 데이터 요구량<br>- 시간 소모   | - 의존성 (사전 훈련 모델)<br>- 유사도 기반 오차<br>- 벡터스토어 관리 필요 |

> 벡터 검색은 사전 훈련된 모델의 성능에 의존하지만, 새로운 분류 클래스를 추가하거나 데이터 확장이 필요한 경우, 데이터베이스에 벡터를 저장하는 것만으로 간단히 적용 범위를 확장할 수 있습니다.

## 벡터 검색을 활용한 이미지 분류 작업


벡터 검색 기술을 사용해 이미지 분류 작업을 수행하려면 라벨링된 이미지 데이터가 필요합니다.
라벨링은 이미지 속 특정 객체를 정의하고, 그 위치와 형태를 구체적으로 표시하는 작업을 의미합니다.
하지만 고품질의 라벨링된 데이터를 구하기가 쉽지 않은 것이 현실입니다.

이를 해결하기 위해 AI Hub에서 제공하는 AI 학습용 데이터를 활용할 수 있습니다.
이 글에서는 AI Hub에 대해 소개하고, 이를 활용하여 벡터 검색 기반의 이미지 분류 작업을 수행하는 방법을 살펴보겠습니다.

### AI Hub 사이트(aihub.or.kr)

AI Hub는 **한국지능정보사회진흥원(NIA)**이 운영하는 인공지능 통합 플랫폼입니다.
<https://aihub.or.kr>{: target="_blank"}를 통해 다양한 AI 학습 데이터를 비롯해 AI 컴퓨팅 자원, 바우처 지원, API 서비스 등을 제공합니다.

**AI Hub의 주요 특징**

- 데이터 제공: 텍스트, 음성, 이미지, 비디오 등 14개 분야의 AI 학습 데이터를 공개.
- 학습용 제한: 제공된 데이터는 AI 학습용으로만 사용 가능하며, 데이터셋의 노출 및 재배포는 금지.
- 데이터 활용: 연구자, 개발자, 기업이 데이터 및 AI 솔루션 개발에 활용 가능.

**데이터 이용 정책 준수**
AI Hub의 데이터를 활용할 때는 데이터 이용 정책을 반드시 준수해야 합니다.

> AI학습용데이터에 대한 이용준수 공지
>  - 본 사이트에서는 AI 허브 개방 데이터의 이용정책을 준수합니다.
>  - 본 사이트에서는 AI데이터는 학습용으로만 사용되었으며, 데이터셋 원본을 노출하거나 재배포하지 않습니다.
>  - 한국지능정보사회진흥원에서 활용사례・성과 등에 관한 실태조사를 수행 할 경우 이에 성실하게 임하겠습니다.
>  - 데이터 이용정책 : <https://aihub.or.kr/intrcn/guid/usagepolicy.do?currMenu=151&topMenu=105>{:target="_blank"}

### 이미지 분류를 위한 데이터 선정

AI Hub의 상단 메뉴에서 “AI 데이터 찾기”를 클릭해 이미지 데이터를 검색할 수 있습니다.
데이터 유형을 **“이미지”**로 선택하면 다양한 학습 데이터를 확인할 수 있습니다.

**사용 데이터 예시**
- 선박도장 품질 데이터(제조,이미지) : <https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=71447>{:target="_blank"}

이 데이터는 선박의 품질 관리를 위해 제공된 이미지 데이터로, 여러 품질 유형(예: 양품, 불량품)과 불량 유형별로 상세히 라벨링되어 있습니다.

**데이터 활용 절차**

AI Hub의 데이터를 활용하려면 아래와 같은 과정을 거쳐야 합니다.

1. 데이터 이해 : AI Hub 사이트에서 “데이터 개요”와 “데이터 통계”를 확인해 데이터 구조와 분류 기준을 파악합니다.
2. 샘플데이터 다운로드 : 
  - AI Hub에서 제공하는 샘플 데이터를 다운로드합니다.
  - 샘플 데이터에는 라벨링 정보와 몇 개의 이미지 파일이 포함되어 있습니다.(전체 데이터는 훈련용과 검증용으로 구분되지만, 샘플 데이터는 이러한 구분 없이 제공됩니다.)
3. 라벨링 데이터 분석
  - 라벨링 데이터는 JSON 형식으로 제공되며, “어노테이션 포맷 및 데이터 구조”에서 상세 내용을 확인할 수 있습니다.
4. 학습 모델 확인
  - AI Hub는 각 데이터셋과 관련된 AI 모델 및 샘플 코드를 제공합니다.
  - 선박도장 품질 데이터에서는 DenseNet121 모델을 사용했으며, 분류 정확도(Top-1 Accuracy)는 **99.94%**로 보고되었습니다.

다운로드한 샘플 데이터(약 500MB)를 사용해 벡터 검색 기술을 적용한 이미지 분류 테스트를 진행했습니다.
이 과정에서 이미지 데이터를 벡터화하고 벡터 검색을 통해 유사도를 기반으로 분류 작업을 수행했습니다.

### 벡터 검색 기술 적용

샘플 데이터를 사용해 벡터 검색 기반의 이미지 분류 작업을 수행합니다.
훈련용 데이터와 검증용 데이터로 구분되지 않은 샘플 데이터를 모두 벡터화하여 저장한 후, 데이터베이스 내에서 정확도 테스트를 수행합니다.
DenseNet121 모델을 사전 훈련된 모델로 사용합니다.

#### 1. 벡터 테이블 생성

벡터 데이터를 저장하기 위해 오라클 데이터베이스 23ai에서 테이블을 생성합니다.
이 테이블은 메타데이터와 벡터 데이터를 저장하기 위한 구조를 가지고 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE TABLE IF NOT EXISTS image_demo1
(image_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 metadata JSON,
 embedding VECTOR)
 ```

#### 2. 라벨링/벡터 데이터 저장

샘플 데이터의 **라벨링 데이터(JSON)**와 이미지를 데이터베이스에 저장합니다.
Python 코드를 이용하여 데이터를 전처리하고 벡터화를 수행합니다.

**Python 코드 작업 절차**
1. **라벨링 데이터(JSON)**를 읽어와 **metadata 컬럼(JSON)**에 저장합니다.
2. metadata에 품질 유형 정보(categories)를 업데이트합니다.
3. metadata에 포함된 파일명 정보를 사용하여 이미지를 읽고, 이를 **벡터 데이터(embedding)**로 변환해 저장합니다.

이미지를 벡터화하는 함수 get_image_embedding은 사용자 정의 함수로 작성되었습니다.

{% include codeHeader.html copyable="true" codetype="python"%}
```python
import os
import json
import oracledb
import numpy as np
import tensorflow as tf
from tensorflow.keras.applications.densenet import DenseNet121, preprocess_input
from tensorflow.keras.preprocessing import image

# TensorFlow에서 GPU 사용을 비활성화하여 CPU만 사용하도록 설정
os.environ["CUDA_VISIBLE_DEVICES"] = "-1"

# DenseNet121 모델 로드 및 최종 분류 레이어 제거
model = DenseNet121(weights='imagenet', include_top=False, pooling='avg')

## 라벨링 데이터(json)파일 검색
def find_json_files(directory):
    json_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.json'):
                json_files.append(os.path.join(root, file))
    return json_files

# 디렉토리 경로를 배열로 변환
def path_to_array(path):
    directories, filename = os.path.split(path)
    directories_array = directories.split(os.sep)
    directories_array.append(filename)
    return directories_array

# 라벨데이터(json)를 데이터베이스에 저장
def insert_json_to_db(cursor, json_content):
    var_image_id =cursor.var(oracledb.DB_TYPE_NUMBER) 
    sql = "INSERT INTO image_demo1 (metadata) VALUES (:metadata) returning image_id into :image_id"
    cursor.execute(sql, {"metadata":json.dumps(json_content), "image_id":var_image_id})
    image_id = var_image_id.getvalue()[0]
    return image_id

# 파일경로에 있는 정보(양품, 탱크)를 메타데이터의 categories에 추가 
def update_json_from_db(cursor, file_path, image_id):
    path_array = path_to_array(file_path)
    categories =f"""["{path_array[3]}","{path_array[4]}"]"""
    sql = f"""UPDATE image_demo1 SET metadata=JSON_TRANSFORM(metadata,SET '$.annotations[*].attributes.categories' = JSON(:categories) ) WHERE image_id = :image_id"""
    cursor.execute(sql, {"categories":categories,"image_id":image_id})

# 파일명 가져오기
def get_image_file_name(cursor, image_id):
    sql="""SELECT file_name 
        FROM image_demo1 t,
            JSON_TABLE(
                t.metadata, 
                '$[*]' COLUMNS (
                    NESTED PATH '$.images[*]' COLUMNS (
                    file_name VARCHAR2(200) PATH '$.file_name'
            )
        )) a 
       WHERE image_id = :image_id"""
    cursor.execute(sql, {"image_id":image_id})
    result = cursor.fetchone()
    return result[0]

# 파일경로 가져오기
def get_image_path_by_file_name(root_dir, target_filename):
    matched_files = []
    for dirpath, dirnames, filenames in os.walk(root_dir):
        for filename in filenames:
            if filename == target_filename:
                matched_files.append(os.path.join(dirpath, filename))
    return matched_files[0]

## 백터로 변환하여 저장
def save_embedding_to_db(cursor, root_dir, image_id):
    print(f"image_id : {image_id}")
    file_name = get_image_file_name(cursor, image_id)
    print(f"file_name : {file_name}")
    img_path = get_image_path_by_file_name(root_dir, file_name)
    print(f"file_path : {img_path}")
    embedding_vector = get_image_embedding(img_path)
    print(f"embedding{embedding_vector}")
    # 벡터를 문자열로 변환
    vector_str = ",".join(map(str, embedding_vector))
    vector_str = "["+vector_str+"]"
    
    # PL/SQL 블록을 실행하여 벡터 저장
    sql = f"""UPDATE image_demo1 SET embedding=:vector_str WHERE image_id = :image_id"""
    cursor.execute(sql, {"vector_str":vector_str,"image_id":image_id})

def get_image_embedding(img_path):
    # 이미지를 로드하여 전처리
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = preprocess_input(img_array)
    
    # 모델을 사용하여 임베딩 벡터 생성
    embedding = model.predict(img_array)
    return embedding.flatten()

## 실행
def main(directory, dsn, user, password):
    # DB에 접속
    oracledb.init_oracle_client()
    connection = oracledb.connect(user=user, password=password, dsn=dsn)
    cursor = connection.cursor()

    # 파일 목록가져오기
    json_files = find_json_files(directory)
    for json_file in json_files:
        with open(json_file, 'r', encoding='utf-8') as file:
            json_content = json.load(file)
            file_path = json_file
            file_name = os.path.basename(json_file)
            image_id = insert_json_to_db(cursor, json_content)
            update_json_from_db(cursor,file_path, image_id)
            save_embedding_to_db(cursor, directory, image_id)
            connection.commit()    
    cursor.close()    
    connection.close()
    print("모든 이미지의 벡터 저장이 완료되었습니다.")

# 사용 예시
un = os.getenv("PYTHON_USERNAME")
pw = os.getenv("PYTHON_PASSWORD")
cs = os.getenv("PYTHON_CONNECTSTRING") 

 # 여기에 폴더 경로를 입력하세요 
directory_path = './Sample' 

main(directory_path, cs, un, pw)
```

**결과 확인**

샘플 데이터 전체를 벡터화하여 데이터베이스에 저장했습니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select count(*) from image_demo1;
select * from image_demo1 where rownum = 1;
```

샘플 데이터 전체를 벡터화하여 데이터베이스에 저장했습니다.
JSON 형식의 메타데이터는 가독성을 위해, 필요한 정보를 보여주는 VIEW를 생성해 확인할 수 있습니다.  

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
create or replace view vw_image_demo1
as
select image_id, a.part, a.quality, a.category1 ,a.category2, t.embedding
 from vector.image_demo1 t,JSON_TABLE(
    t.metadata, 
    '$[*]' COLUMNS (
            NESTED PATH '$.annotations[*]' COLUMNS (
                NESTED PATH '$.attributes' COLUMNS (
                    part VARCHAR2(100) PATH '$.part',
                    quality VARCHAR2(100) PATH '$.quality',
                    category1 VARCHAR2(100) PATH '$.categories[0]',
                    category2 VARCHAR2(100) PATH '$.categories[1]'
                )
            )
    )) a ;

select * from vw_image_demo1 where rownum = 1;
```

#### 3. 이미지 분류 작업 검증

이미지 분류 작업의 정확도를 테스트하기 위해 PL/SQL 코드를 작성하여 아래와 같은 절차를 수행합니다.

**검증작업**
1. 데이터 중 1건을 query vector로 설정합니다.
2. 나머지 218건을 data vector로 설정합니다.
3. VECTOR_DISTANCE 함수를 사용해 쿼리 벡터와 데이터 벡터 간의 유사도를 계산하고, 가장 유사한 데이터의 라벨을 비교합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
begin
    for rec in (select * from vw_image_demo1 order by image_id) loop
        for rec2 in (select *
                    from vw_image_demo1 mo
                    where image_id <> rec.image_id -- query vector는 검색대상에서 제외
                    and part = rec.part
                    order by vector_distance(mo.embedding, rec.embedding, COSINE)
                    fetch first 1 row only) -- KNN top 1 데이터만 조회
            loop 
            
            if rec.quality <> rec2.quality then -- 품질결과가 같은지 비교
                dbms_output.put_line('**'||rec.image_id || ' and '||rec2.image_id||' are different.');
            else 
                dbms_output.put_line(''||rec.image_id || ' and '||rec2.image_id||' are similar.');
            end if;
        end loop;
    end loop;
end;
/
```

**이미지 분류 결과**

총 218번의 테스트 중 217건이 정확하게 분류되었으며, 1건만 품질 결과가 달랐습니다.
산술로 계산하면 99.5412%의 정확도를 보여줍니다.

**추가 개선 사항**

1. 더 많은 데이터 추가 : 데이터 양이 늘어나면 모델이 더 많은 패턴을 학습하여 분류 정확도가 높아질 가능성이 있습니다.
2. 벡터 인덱스 생성 : 데이터가 많아질 경우 검색 성능에 영향을 받을 수 있으므로, 벡터 인덱스를 생성하여 성능을 개선할 수 있습니다.

## 마무리 

지금까지 벡터 검색을 활용해 Top 1 유사도 검색을 통해 이미지 분류를 수행했습니다.
벡터 검색의 가장 큰 장점은 사전 훈련된 모델을 사용함으로써 모델 설계와 훈련 과정을 간소화하고, 데이터셋을 벡터 스토어에 저장하는 것만으로 이미지 분류 작업을 바로 시작할 수 있다는 점입니다.

또한, 새로운 유형의 분류나 데이터셋 보강이 필요할 경우, 별도의 모델 재훈련 없이 벡터 스토어에 데이터를 추가 저장함으로써 기능을 쉽게 확장할 수 있습니다.
이러한 유연성과 확장성이 벡터 검색 기술의 가장 큰 이점이라 할 수 있습니다.

기업 환경에서는 직접 이미지 분류 모델을 설계하고 훈련하는 것이 가장 높은 정확도를 보장하지만, 인력, 하드웨어 등의 기반이 부족한 경우 벡터 검색 기술이 훌륭한 대안이 될 수 있습니다.

데이터베이스가 기존의 정형 데이터 관리에서 벗어나 비정형 데이터 관리 영역으로 확장되기 위해서는 이러한 유용한 도구가 필수적입니다.
오라클 데이터베이스 23ai버전의 벡터 검색 기능은 이러한 요구에 부응하며, 비정형 데이터를 실무에 활용할 수 있는 구체적인 방법을 제공합니다.

## 참고자료

- AI Hub : <https://aihub.or.kr>{:target="_blank"}
  - 데이터 이용정책 : <https://aihub.or.kr/intrcn/guid/usagepolicy.do?currMenu=151&topMenu=105>{:target="_blank"}
  - 선박도장 품질 데이터(제조,이미지) : <https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=71447>{:target="_blank"}

- Oracle AI Vector Search 사용자 가이드 : <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}
