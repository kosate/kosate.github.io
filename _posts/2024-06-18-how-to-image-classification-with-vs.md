---
layout: single
title: 벡터 검색 기술 활용(2) - 이미지분류
date: 2024-06-18 15:00
contents: PPT
categories: 
  - Oracle
books:
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
   - Similarity Search
   - image classificiation
excerpt : 오라클 데이터베이스 23ai에 벡터 검색을 위한 Oracle AI Vector Search기능을 제공합니다. 벡터 검색기능을 이용하여 이미지 분류하는 방법에 대해서 정리합니다.
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

벡터 검색기술을 사용하면 적은 데이터로 효과적으로 비정형 데이터의 분류 작업이 가능합니다. 
보통 텍스트 유사도 검색을 하면 가장 유사한 텍스트 Top K의 데이터를 조회할수 있습니다. 

비정형 데이터중 이미지분류(Classification)을 한다고 가정하면, 
라벨링된 데이터와 이미지의 임베딩데이터를 넣어놓고, 내가 분류하고자 하는 이미지를 이용하여 유사도 검색을 하고 그중 Top 1을 가져오면 해당 이미지의 라벨링데이터를 통해서 분류작업이 가능합니다.  

오라클 데이터베이스 23ai에서 제공하는 AI Vector Search기능을 이용하여 이미지 분류 작업을 해보겠습니다. 

## 이미지 분류 방안 비교

1) 이미지 분류 모델을 생성하여 이미지 분류를 수행하는 방법과 2) 백터 검색기능을 활용하여 이미지 분류 작업을 수행하는 방법에 대해서 비교하였습니다.

### 1. 이미지 분류 모델 훈련(fine-tuning)

일반적인 이미지 분류 모델은 딥러닝 기술, 특히 Convolutional Neural Network(CNN)을 사용하여 이미지를 특정 클래스로 분류합니다. 다음과 같은 과정으로 진행합니다. 

- 이미지 분류 모델 생성 및 훈련 절차
  1. 데이터 수집 및 전처리 : 이미지 데이터를 수집하고, 이를 정규화, 크기 조정, 데이터 증강 등을 통해 전처리합니다.
  2. 모델 설계 : CNN 모델을 설계하여 입력 레이어, 여러 개의 Convolutional 레이어, Pooling 레이어, Fully Connected 레이어, 출력 레이어 등을 구성합니다.
  3.  모델 훈련 : 수집한 데이터를 훈련 데이터와 검증 데이터로 분리하고, 훈련 데이터를 사용하여 모델을 학습시킵니다. 이 과정에서 손실 함수와 옵티마이저를 사용하여 모델의 성능을 개선합니다.
  4.  모델 평가 : 검증 데이터를 사용하여 모델의 성능을 평가합니다. 주로 정확도, 정밀도, 재현율, F1 점수 등의 지표를 사용합니다.
  5.  모델 테스트 및 배포 : 최종적으로 테스트 데이터를 사용하여 모델의 성능을 확인하고, 실제 환경에 배포합니다.

만약 모델 설계시 사전훈련된 모델을 사용할 경우 모델 설계 부분은 간소화될수 있습니다. 

### 2. 백터 검색을 활용한 이미지 분류 작업

벡터 검색 기술을 사용한 이미지 분류는 사전 훈련된 모델을 통해 특징 벡터를 추출하고, 이를 벡터 데이터베이스에 저장한 후 유사도 검색을 통해 이미지를 분류하는 방법입니다.

- 백터 검색을 이용한 이미지 분류 작업
  1. 데이터 수집 및 전처리 :  이미지 분류모델 생성 절차와 동일합니다. 
  2. 특징 추출 :  **사전 훈련된 CNN 모델**을 사용하여 이미지에서 특징 벡터를 추출합니다. 
  3. 벡터 데이터 저장 : 추출된 특징 벡터를 Oracle 데이터베이스에 VECTOR 데이터 타입으로 저장합니다.
  4. 벡터 검색을 통한 유사도 계산 : 새로운 이미지가 주어지면 동일한 방법으로 특징 벡터를 추출하고, VECTOR_DISTANCE 함수를 사용하여 유사도를 계산합니다.
  5. 이미지 분류 : 유사도가 높은 벡터의 클래스를 참조하여 새로운 이미지를 분류합니다. 이 과정에서 k-최근접 이웃 알고리즘(K-NN) 등을 사용할 수 있습니다.

### 두가지 이미지 분류 방안 비교

**작업 절차 비교**

이미지분류모델과 벡터 검색을 활용한 이미지 분류모델에 대해서 절차기반으로 비교하면 아래와 같습니다.  
백터 검색을 이용한 이미지 분류작업을 하면 사전훈련된 CNN모델을 사용하므로 이미지 분류모델을 생성할때 수행했던 모델설계 혹은 모델훈련절차가 매우 간소화됩니다. 또한 모델 평가 및 이미지 분류 작업은 오라클 데이터베이스에서 SQL로 쉽게 처리할수 있습니다. 

| 항목                       | 일반적인 이미지 분류 모델(fine tuning)                            | 벡터 검색을 이용한 이미지 분류                         |
|----------------------------|--------------------------------------------------|---------------------------------------------------|
| **데이터 수집 및 전처리**   | 이미지 데이터 수집 및 정규화, 크기 조정, 데이터 증강  | 이미지 데이터 수집 및 정규화, 크기 조정, 데이터 증강  |
| **특징 추출**              | CNN 모델을 통해 직접 특징 학습                     | 사전 훈련된 모델을 통해 특징 벡터 추출             |
| **모델 설계**              | CNN, Convolutional 레이어, Pooling 레이어 등        | 사전 훈련된 모델 사용                             |
| **모델 훈련**              | 훈련 데이터를 사용하여 모델 학습                   | 특징 벡터를 데이터베이스에 저장(INSERT)                   |
| **모델 평가**              | 검증 데이터를 사용하여 성능 평가                   | 벡터 검색을 통해 유사도 계산(SELECT)                     |
| **이미지 분류**            | 테스트 데이터를 사용하여 최종 성능 확인 및 배포       | 유사도 기반으로 K-NN 등을 사용하여 이미지 분류(SELECT)    |

**장점과 단점 비교**

이미지 분류모델은 훈련된 이미지들에 최적화되어 높은 정확도로 이미지 분류작업이 가능합니다. 반면 모델을 튜닝하고 훈련하는 과정에서 하드웨어 자원을 사용하고 시간이 많이 소요되는 단점이 있습니다. 
벡터 검색을 이용한 이미지 분류작업은 사전 훈련 모델을 사용하여 곧바로 이미지의 특징을 벡터화하고 이를 검색함으로써 업무에 쉽게 적용이 가능합니다. 이미지 분류의 정확도는 사전훈련모델에 좌우되는 단점이 있습니다.

| 항목        | 일반적인 이미지 분류 모델                           | 벡터 검색을 이용한 이미지 분류                        |
|-------------|---------------------------------------------------|---------------------------------------------------|
| **장점**    | - 높은 정확도<br>- 엔드투엔드 학습<br>- 다양한 응용 가능  | - 빠른 검색 속도<br>- 효율적인 특징 저장<br>- 사전 훈련 모델 활용 |
| **단점**    | - 고성능 하드웨어 요구<br>- 데이터 요구량<br>- 시간 소모   | - 의존성 (사전 훈련 모델)<br>- 유사도 기반 오차<br>- 벡터스토어 관리 필요 |

> 정확도는 이미지 분류모델이 높을수 있으나 벡터 검색을 이용한 분류작업의 정확도가 어느 오차내일경우 벡터검색을 이용한 이미지 분류작업이 실용성은 더 높을수 있습니다. 또한 새로운 분류 클래스트를 만들거나 훈련데이터를 추가할때 벡터스토어에 저장하는것으로만으로 기능을 확장할수 있습니다.

## 벡터 검색을 활용한 이미지 분류 작업

벡터 검색을 활용하여 이미지 분류 작업을 수행하기 위해서는 라벨링된 이미지 데이터가 필요합니다. 
데이터 라벨링은 해당 이미지 내의 특정 객체를 정의하고 그 위치와 형태를 구체적으로 표시하는 작업을 의미합니다. 
그런데 잘 라벨링된 이미지 데이터를 구하기 어렵습니다. 

한국지능정보사회진흥원에서 AI Hub사이트를 통해서 AI 학습용 데이터를 제공합니다. 이에 대한 소개 및 활용방법에 대해서 설명하겠습니다. 

### AI Hub 사이트(aihub.or.kr)
국내에 한국지능정보사회진흥원에서 관리하는 AI HUB 사이트가 있습니다. 
<https://aihub.or.kr>{:target="_blank"}

AI Hub는 한국지능정보사회진흥원(NIA)에서 운영하는 인공지능 통합 플랫폼으로, 다양한 AI 인프라와 서비스를 제공합니다. 이 플랫폼은 AI 기술 및 제품·서비스 개발에 필요한 데이터를 제공하여 연구자, 개발자, 기업 등이 활용할 수 있도록 지원합니다. 주요 서비스로는 AI 데이터, AI 컴퓨팅 자원, AI 바우처 지원, 그리고 AI 소프트웨어 API 제공 등이 있습니다.

총 14개 분야에서 텍스트,음성, 이미지, 비디오등 AI 학습용 데이터를 공개하고 있습니다. AI Hub에서 제공되는 데이터는 학습용으로 사용되어야하고 데이터셋의 노출 및 재 배포를 엄격하게 금지하고 있으므로 데이터이용 정책을 꼭 확인하고 사용하시기 바랍니다. 

본 블로그에서도 AI학습용 데이터에 대한 이용 규칙을 준수함을 고지합니다.
> AI학습용데이터에 대한 이용준수 공지
>  - 본 사이트에서는 AI 허브 개방 데이터의 이용정책을 준수합니다.
>  - 본 사이트에서는 AI데이터는 학습용으로만 사용되었으며, 데이터셋 원본을 노출하거나 재배포하지 않습니다.
>  - 한국지능정보사회진흥원에서 활용사례・성과 등에 관한 실태조사를 수행 할 경우 이에 성실하게 임하겠습니다.
>  - 데이터 이용정책 : <https://aihub.or.kr/intrcn/guid/usagepolicy.do?currMenu=151&topMenu=105>{:target="_blank"}

### 이미지 분류를 위한 데이터 선정

AI Hub에서 상단메뉴에서 "AI 데이터 찾기"에서 이미지 데이터를 검색할수 있습니다.
데이터 유형을 "이미지"로 선택하면 많은 데이터를 확인할수 있습니다.

저는 아래 데이터를 이용하여 테스트해 보았습니다. 

- 선박도장 품질 데이터(제조,이미지) : <https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=71447>{:target="_blank"}

해당 이미지 데이터는 품질관리를 위하여 이미지데이터로 여러개의 품질유형(양품, 불량등)과 각 불량품에 대한 세부적인 유형으로 분류되어 라벨링이 되어 있습니다. 

우선 데이터 이해가 필요합니다. 
AI Hub사이트에서 데이터정보를 확인합니다. 

- 데이터 이해 
  - AI Hub사이트의 "해당 데이터" 에서 "데이터 개요"와 "데이터 통계"를 확인하세요. 
- 샘플데이터 다운로드
  - AI Hub사이트의 "해당 데이터"에서 "샘플데이터"를 다운받으세요.
  - 전체 데이터는 훈련용데이터와 검증용 데이터로 구분되어 있으나 샘플데이터는 구분되어 있지 않고 몇개의 이미지와 라벨링 데이터만 제공합니다.
- 라벨링데이터 이해 
  - AI Hub사이트의 "해당 데이터" 에서 "어노테이이션 포멧 및 데이터 구조"를 확인하세요. 
  - 라벨링데이터의 json파일형식입니다. 
- 학습 모델 확인
  - AI Hub사이트의  "해당 데이터" 에서 "AI활용모델 및 코드"를 확인하세요 
  - "해당 데이터"에서 사용된 모델은 DenseNet121로, 분류 정확도(Top-1 Accuracy 99.94)를 확인할수 있습니다.

이 샘플데이터(약 500M)를 이용하여 백터 검색기술을 적용하여 이미지 분류테스트를 진행해보았습니다.

### 벡터 검색 기술 적용

샘플데이터는 훈련용데이터와 검증용 데이터로 구분되어 있지 않습니다. 일단 모든 이미지데이터를 백터화하여 저장하고 나서 DB내에서 샘플링하여 정확도 테스트를 수행하겠습니다. 사전훈련된 모델은 DenseNet121 모델를 사용합니다. 

#### 1. 벡터 테이블 생성
오라클 데이터베이스 23ai에 벡터 검색을 위한 테이블을 생성합니다. 

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE TABLE IF NOT EXISTS image_demo1
(image_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
 metadata JSON,
 embedding VECTOR)
 ```

#### 2. 라벨링/벡터 데이터 저장

샘플데이터의 라벨링 데이터를 DB에 저장하고 이미지를 읽어서 벡터 데이터로 저장합니다. 
샘플데이터압축을 풀고 아래 Python코드를 실행합니다.

Python코드의 작업 절차
1. 라벨링 데이터(json)를 읽어서 METADATA컬럼(json)에 저장
2. METADATA컬럼(json)에 품질 유형 정보(categories)를  업데이트
3. METADATA(json)에 있는 파일명을 이용하여 이미지파일(jpg)을 읽어서 벡터데이터(vector)를 업데이트

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

> 벡터화하기 위하여 이미지 전처리하는 코드(get_image_embedding)는 제가 임의적으로 작성하였습니다. 

샘플데이터를 모두 DB에 벡터화해서 저장하고 메타데이터로 같이 저장하였습니다.
데이터를 확인합니다.  

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
select count(*) from image_demo1;
select * from image_demo1 where rownum = 1;
```

총 219개의 데이터가 있습니다.
메타데이터가 JSON으로 저장되어 있어, 가독성을 위하여 메타데이터로부터 필요한 데이터를 보여주도록 VIEW를 생성합니다.  

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

이미지 분류 작업에 대한 검증 테스트를 수행합니다.  
219건중에 1건을 query vector로 사용하고 나머지 218건을 data vector로 사용합니다. 
PL/SQL 코드를 작성하면 검증 테스트를 수행할수 있습니다. 

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

결과는 아래와 같습니다. 
총 218번의 테스트 중에 217건는 정확했고, 1건만 품질결과가 달랐습니다. 산술로 계산하면 99.5412%의 정확도를 보여줍니다.
더 많은 데이터를 가지고 검색할경우 정확도가 더 개선될것으로 생각되고, 데이터가 많아질경우 검색 성능이 영향받을것을 고려하여 벡터 인덱스를 생성하여 개선시킬수 있습니다. 

## 마무리 

벡터 검색의 Top 1 유사도검색을 통해 이미지 분류 작업을 진행하였습니다.
벡터 검색을 통해서 사전 훈련된 모델을 사용하여 모델의 설계 부분을 간소하고, 훈련작업없이 곧바로 데이터셋을 벡터 스토어에 저장하고 유사도 검색을 통해서 이미지 분류작업이 가능합니다. 또한 새로운 유형의 분류 및 데이터 셋보강이 필요할 경우 벡터 스토어에 저장하는것만으로도 새로운 모델 훈련없이 기능을 확장할수 있습니다. 
이것이 벡터 검색의 이점인것 같습니다.

기업에서 이미지 분류모델에서 직접 훈련하여 사용하는 방법에 대해서 전혀 반론을 할수가 없습니다.
그러나 기업모두 인력, 하드웨어, 지식이 준비되어 있지 않다면 벡터 검색방법이 하나의 차선책이 될수 있지 않을까 싶습니다. 

저에게 기본적인 지식이 없는 상황에서 AI는 너무 어려운 도전과제입니다. 데이터베이스의 정형화된 데이터관리으로만 국한된 업무에서 비정형 데이터관리 영역까지 확장하기 위해서는 유용한 도구가 절대적으로 필요합니다. 오라클 데이터베이스 23버전 부터 백터 검색 기능을 지원하게 되었고 비정형 데이터를 업무에 적용할수 있는 좀 더 구체적인 활용 방법을 제공하는것 같습니다. 

## 요약(Generated By ChatGPT)

{% include pptstart.html id="aivs_img" style="" %}
<section data-markdown>
<textarea data-template>
## 들어가며
### 이미지 분류의 중요성과 벡터 검색 기술의 필요성
- **이미지 분류의 중요성**: 이미지 분류는 의료, 자율 주행, 보안 등 다양한 분야에서 필수적인 기술입니다.
- **벡터 검색 기술의 필요성**: 벡터 검색 기술을 통해 이미지를 더 효율적이고 정확하게 분류할 수 있습니다.
---
## 이미지 분류 방안 비교
### 전통적인 이미지 분류 방법과 벡터 검색 방법의 비교
- **전통적 방법**: 
  - **특징 추출**: 이미지를 픽셀, 모양, 색상 등으로 분석하여 주요 특징을 추출합니다.
  - **모델 학습**: 추출된 특징을 머신 러닝 모델에 학습시켜 이미지를 분류합니다.
  - **단점**: 시간이 많이 소요되고 복잡하며, 대량의 데이터가 필요합니다.
- **벡터 검색 방법**: 
  - **벡터 변환**: 이미지의 주요 특징을 벡터 형태로 변환합니다.
  - **유사도 검색**: 변환된 벡터를 이용해 유사한 이미지를 빠르게 찾습니다.
  - **장점**: 처리 속도가 빠르고, 대용량 데이터에도 효율적입니다.
---
## 벡터 검색을 활용한 이미지 분류 작업
### 벡터 검색의 원리와 이를 이미지 분류에 적용하는 방법
- **벡터 변환**: 이미지의 특징을 벡터로 변환하여 주요 속성을 수치화합니다.
- **유사도 검색 알고리즘**: 벡터화된 이미지를 데이터베이스에 저장하고, 새로운 이미지와의 유사도를 계산하여 분류합니다.
- **적용 예**: 특정 카테고리의 이미지가 주어졌을 때, 유사한 이미지를 검색하여 같은 카테고리로 분류합니다.
---
## 벡터 검색 기술 적용
### 벡터 검색 기술을 실제 이미지 분류에 적용하는 방법
- **벡터 검색 엔진 설정**: 벡터 검색 엔진을 설치하고, 이미지 데이터를 벡터로 변환하여 데이터베이스에 저장합니다.
- **검색 과정**: 새로운 이미지가 입력되면, 해당 이미지를 벡터로 변환하고, 데이터베이스에서 유사한 벡터를 검색합니다.
- **결과 분석**: 검색된 유사 이미지를 분석하여 원하는 이미지 분류 작업을 완료합니다.
- **예시**: 온라인 쇼핑몰에서 사용자가 업로드한 이미지와 유사한 상품을 검색하여 추천하는 시스템에 적용될 수 있습니다.
</textarea>
</section>
{% include pptend.html id="aivs_img" initialize="center: false,"%} 

## 참고자료

- AI Hub : <https://aihub.or.kr>{:target="_blank"}
  - 데이터 이용정책 : <https://aihub.or.kr/intrcn/guid/usagepolicy.do?currMenu=151&topMenu=105>{:target="_blank"}
  - 선박도장 품질 데이터(제조,이미지) : <https://aihub.or.kr/aihubdata/data/view.do?dataSetSn=71447>{:target="_blank"}

- Oracle AI Vector Search 사용자 가이드 : <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/>{:target="_blank"}
