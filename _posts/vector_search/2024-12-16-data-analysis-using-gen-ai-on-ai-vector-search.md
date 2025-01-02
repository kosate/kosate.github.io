---
layout: single
title: "[오라클] 생성형 AI와의 연동(2) - 데이터 분석 및 변환"
date: 2024-12-16 22:00
categories: 
  - vector-search
books:
 - oracleaivectorsearch
 - oracle23newfeature 
tags: 
   - Oracle
   - 23ai
   - Vector Search
excerpt : "📊 데이터베이스에서 생성형 AI를 활용해 감정 분석부터 이미지 분류하는 방법에 대해서 알아봅니다."
header :
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---
  
## 들어가며 

생성형 AI는 데이터베이스 내부에서 고급 데이터 분석 작업을 쉽게 실행할 수 있도록 지원하는 강력한 도구로 활용할수 있습니다.. 이를 통해 감정 분석, 카테고리 분류, 텍스트 변환 등 다양한 작업을 효율적으로 처리할 수 있습니다. 특히, 데이터베이스에서 AI를 활용하면 복잡한 데이터 변환 과정이 간단해지고, 분석 작업을 실시간으로 수행하여 업무를 자동화할 수 있습니다.

이번 글에서는 사전에 정의된 프롬프트를 사용하여 Oracle AI Vector Search로 데이터를 분석하고 변환하는 과정을 알아봅니다. 
이를 통해 다양한 비즈니스 사례에 적용할 가능성을 살펴보고, 오라클 데이터베이스가 제공하는 강력한 데이터 처리 능력을 직접 확인해 보겠습니다.

## 프롬프트 작성 예시

생성형 AI에게 데이터 분석 작업을 요청할 때는 프롬프트의 구조와 형식이 매우 중요합니다. 적절한 형식을 사용하면 AI가 요청을 더 정확히 이해하고, 원하는 결과를 도출할 가능성이 높아집니다.

1. markdown형식
  - Markdown 형식은 텍스트를 시각적으로 구분하고 구조를 파악하기 쉽게 만들어줍니다. 주로 간단한 데이터 요청이나 사람이 읽기 쉬운 형식의 데이터를 입력할 때 적합합니다.
  - 하지만 Markdown 형식은 중첩된 데이터나 복잡한 계층 구조를 표현하기 어렵습니다. 데이터 처리가 복잡해질수록 비효율적일 수 있습니다.
2. JSON 형식
  - JSON은 표준화된 데이터 형식으로, 중첩된 데이터와 계층 구조를 명확하게 표현할 수 있습니다. 또한, 다양한 프로그래밍 언어와 도구에서 쉽게 처리할 수 있어 데이터 분석 작업에서 매우 유용합니다.
  - JSON 형식은 프로그래밍과 데이터 처리에서 직접 활용하기 좋고, 일관된 입력과 결과를 제공할 수 있어 복잡한 작업에 적합합니다.

이 글에서는 JSON 형식을 사용해 생성형 AI의 프롬프트를 관리하고, 데이터 분석 작업의 효율성을 극대화하였습니다.
- 프롬프트 관리 테이블 : my_task
- 데이터 출력 형식 테이블 : my_task_output


**1. 프롬프트 관리 테이블 생성**

프롬프트 관리 테이블은 각 작업에 필요한 프롬프트를 저장하고 관리하기 위한 구조입니다.
이를 통해 텍스트 분석, 이미지 분석 등 다양한 데이터 작업에 대해 반복적으로 사용할 수 있는 프롬프트를 체계적으로 관리할 수 있습니다.
이 테이블은 마치 AI 에이전트처럼 특정 작업에 대해 지속적으로 활용될 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 프롬프트 관리 테이블
CREATE TABLE IF NOT EXISTS my_task (  
   task_name VARCHAR2(4000) PRIMARY KEY,  -- 감정분석, 카테고리분류, 텍스트요약, 텍스트증강
   category_name VARCHAR2(1000), --이미지 , 텍스트
   task_rules VARCHAR2(4000);
);
```


**2. 프롬프트 저장**

각 작업의 특성에 맞는 프롬프트를 저장하여, 데이터 분석 요청 시 일관된 결과를 얻을 수 있도록 합니다.
이 글에서는 프롬프트의 구조에 중점을 두었으며, 작업별 프롬프트 작성 방법은 구체적으로 다루지 않았습니다.
추후 프롬프트를 더욱 상세화하고 구조화하여, AI가 정확하고 일관된 답변을 제공할 수 있도록 개선하는 것이 중요합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 데이터 분석을 위한 프롬프트 예시 작성
INSERT INTO my_task(task_name, category_name,task_rules)  VALUES
  ('감정분석','텍스트','주어진 문장의 감정을 분석하세요. 감정은 "긍정", "부정", "중립" 중 하나로 판단하고, 이유를 간단히 설명해주세요.'),
  ('카테고리분류','텍스트', '주어진 문장을 아래 카테고리 중 하나로 분류하세요. 카테고리는 "제품 리뷰", "서비스 피드백", "일반 문의"입니다. 그리고 선택 이유를 간단히 설명하세요.'),
  ('텍스트요약','텍스트','주어진 문장을 한 문장으로 간단히 요약하세요. 주요 내용을 유지하면서 요약해주세요.'),
  ('텍스트증강','텍스트','주어진 문장을 다양한 표현으로 변형해주세요. 어휘를 변경하거나 문장 구조를 다양하게 만들어 3개의 결과를 생성하세요.'),
  ('텍스트변환','텍스트','주어진 문장의 형식을 JSON으로 변환해주세요.'),
  ('이미지설명','이미지','주어진 이미지에 대해서 설명해주세요'),
  ('이미지분류','이미지','주어진 이미지에서 "배경"는 [자연,도시,실내]로, "피상"는 [인물,동물,사물,건물]로, "피상특징"을 3개추가하여 카테고리를 지정하세요');
```

**3. 데이터 결과 형식 관리 테이블 생성**

데이터 분석 결과를 일관된 형식으로 관리하기 위해 결과 형식 관리 테이블을 생성합니다.
이 테이블은 데이터 분석 작업에서 생성된 결과를 체계적으로 정리하고 활용할 수 있는 기반을 제공합니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
-- 데이터 형식 관리 테이블
CREATE TABLE IF NOT EXISTS my_task_output(
    output_id NUMBER,  -- 번호
    output_name VARCHAR2(4000), -- 데이터 형식
    output_text VARCHAR2(4000), -- 데이터 형식을 위한 프롬프트 내용
    output_sample VARCHAR2(4000)     -- 데이터 출력 형식 예제
);
```

**4. 데이터 결과 형식 저장**

분석 결과는 JSON 형식으로 요청하며, 프롬프트에 출력 형식에 대한 지침을 포함합니다.
JSON 형식은 구조화된 데이터 표현 방식으로, AI 생성 결과를 다양한 환경에서 쉽게 처리할 수 있도록 해줍니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
INSERT INTO my_task_output(output_id, output_name, output_text, output_sample) VALUES 
(1,'JSON', '답변은 JSON형식으로만 생성합니다. JSON은 명확히 구조화되어야 하며, Markdown 형식으로 표시하지 마세요.',
'{"reason":"<답변이유>","generated_text":"<생성된답변>"}'); -- 데이터 분석 및 변환시 사용
```


**5. 프롬프트 생성 예시**

작업 요청을 위한 프롬프트와 데이터 출력 형식을 위한 프롬프트를 조합하여, JSON 형식으로 작성합니다.
오라클 데이터베이스는 관계형 데이터에서 JSON 형식으로 쉽게 변환할 수 있는 JSON_OBJECT와 같은 SQL 연산자를 제공합니다.
아래는 ‘감정 분석’ 작업을 위한 프롬프트 작성 예시입니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT JSON_SERIALIZE(JSON_OBJECT(instruction, output_format  FORMAT JSON,input_data)) prompt
  FROM (SELECT t.task_rules instruction, 
               o.output_name,
               JSON_OBJECT('format' value o.output_text, 'example' value o.output_sample ) output_format,
               '<제공된데이터>' input_data 
          FROM my_task t, my_task_output o
         WHERE t.task_name = '감정분석'
           AND o.output_id = 1);
```
 
다음은 구조화된 JSON 형식으로 작성된 프롬프트 예제입니다.
이 프롬프트는 AI가 제공된 데이터를 분석하고, 그 결과를 지정된 형식으로 반환하도록 요청합니다.

```json
{
  "instruction":"주어진 문장의 감정을 분석하세요. 감정은 \"긍정\", \"부정\", \"중립\" 중 하나로 판단하고, 이유를 간단히 설명해주세요.",
  "output_format":
    {
      "format":"답변은 JSON형식으로만 생성합니다. JSON은 명확히 구조화되어야 하며, Markdown 형식으로 표시하지 마세요.",
      "example":"{\"reason\":\"<답변이유>\",\"generated_text\":\"<생성된답변>\"}"
    },
  "input_data":"<제공된데이터>"
}
```

## 텍스트 분석 및 변환

생성형 AI 중 **언어 모델(LLM)**은 텍스트를 생성하거나 분석하는 작업을 수행할 수 있습니다. 이를 활용하면 제공된 데이터에 대해 다양한 분석 작업을 요청할 수 있습니다.
오라클 데이터베이스는 생성형 AI와의 연동을 지원하며, 이를 통해 텍스트 분석과 생성 요청을 쉽게 처리할 수 있는 전용 함수를 제공합니다.

좀더 자세한 내용은 텍스트 생성 요청 블로그 글을 참조하시기 바랍니다. vm_my_models등을 포함하여 모델정보를 관리하는 방법에 대해서 작성되어 있습니다. 
- [생성형 AI와의 연동 - 텍스트 생성 요청](/blog/vector-search/text-genneration-using-gen-ai-on-ai-vector-search/){:target="_blank"}

사용자 정의 함수로 모델명과 프롬프트 내용을 입력받아, 결과를 CLOB 형식으로 반환합니다.
이 함수를 사용하면 단순한 SQL 실행만으로 텍스트 데이터를 분석하거나 변환할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION generate_text(p_model_name varchar2, p_prompt CLOB) RETURN CLOB 
IS 
   output CLOB;
   v_model_params json;
BEGIN 
    --모델 정보가져오기
   select model_params into v_model_params from vw_my_models where model = p_model_name;
   -- REST API 통신할때 문자 인코딩 설정
   utl_http.set_body_charset('UTF-8'); 
   -- 결과요청
   output := dbms_vector_chain.utl_to_generate_text(p_prompt, v_model_params);
   return output;
END;
/
```

작업명(task_name)과 분석 데이터(input_data)를 넣고 SQL을 실행하면, 데이터 분석 결과를 반환받을 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT instruction,output_name, output_format, input_data, 
       JSON(generate_text('gpt-4o-mini', JSON_SERIALIZE(JSON_OBJECT(instruction, output_format,input_data )))) generated_text
  FROM (SELECT t.task_rules instruction, 
               o.output_name,
               o.output_text||chr(10)||o.output_sample output_format,
               '제품이 정말 훌륭하고 배송도 빨라서 만족합니다!' input_data
          FROM my_task t, my_task_output o
         WHERE t.task_name = '감정분석'
           AND o.output_id = 1);
```

**1. 감정분석**

- 작업 내용(입력) : 감정분석
- 프롬프트 : 주어진 문장의 감정을 분석하세요. 감정은 "긍정", "부정", "중립" 중 하나로 판단하고, 이유를 간단히 설명해주세요
- 분석 데이터(입력) : 제품이 정말 훌륭하고 배송도 빨라서 만족합니다
- 분석 결과(출력) : 
```json
{
  "reason":"문장에서 제품에 대한 긍정적인 평가와 빠른 배송에 대한 만족감이 표현되어 있어 긍정적인 감정으로 판단됩니다.",
  "generated_text":"긍정"
}
```

**2. 카테고리분류**

- 작업 내용(입력) : 카테고리분류
- 프롬프트 : 주어진 문장을 아래 카테고리 중 하나로 분류하세요. 카테고리는 "제품 리뷰", "서비스 피드백", "일반 문의"입니다. 그리고 선택 이유를 간단히 설명하세요
- 분석 데이터(입력) : 이번에 주문한 세탁기가 생각보다 빨리 도착했어요
- 분석 결과(출력) : 
```json
{
  "reason":"주문한 세탁기의 배송에 대한 언급이 있으며, 이는 제품에 대한 피드백으로 볼 수 있습니다.",
  "generated_text":"제품 리뷰"
}
```

**3. 텍스트 요약**

- 작업 내용(입력) : 텍스트요약
- 프롬프트 : 주어진 문장을 한 문장으로 간단히 요약하세요. 주요 내용을 유지하면서 요약해주세요
- 분석 데이터(입력) : 어제 회사에서 새로운 프로젝트에 대해 논의했는데, 많은 사람들이 이 프로젝트가 성공할 가능성이 높다고 생각했습니다. 특히 시장 조사 결과가 긍정적이라 더 확신을 가졌습니다
- 분석 결과(출력) : 
```json
{
  "reason":"프로젝트에 대한 긍정적인 논의와 시장 조사 결과의 중요성을 강조하기 위해 요약했습니다.",
  "generated_text":"어제 회사에서 논의된 새로운 프로젝트는 긍정적인 시장 조사 결과로 인해 성공 가능성이 높다고 평가받았다."
}
```

**4. 텍스트 증강**

- 작업 내용(입력) : 텍스트증강
- 프롬프트 : 주어진 문장을 다양한 표현으로 변형해주세요. 어휘를 변경하거나 문장 구조를 다양하게 만들어 3개의 결과를 생성하세요
- 분석 데이터(입력) : 이 제품은 품질이 매우 좋습니다
- 분석 결과(출력) : 
```json
[
  {
    "reason":"어휘를 변경하여 표현을 다양화했습니다.",
    "generated_text":"이 상품은 뛰어난 품질을 자랑합니다."
  },
  {
    "reason":"문장 구조를 변경하여 새로운 표현을 만들었습니다.",
    "generated_text":"이 제품의 품질은 매우 우수합니다."
  },
  {
    "reason":"비슷한 의미의 다른 어휘를 사용하여 변형했습니다.",
    "generated_text":"이 아이템은 품질이 상당히 뛰어납니다."
  }
]
```

**5. 텍스트 변환**

- 작업 내용(입력) : 텍스트변환
- 프롬프트 : 주어진 문장의 형식을 JSON으로 변환해주세요
- 분석 데이터(입력) : `<users><user><username>Gildong-Hong</username></user></users>`
- 분석 결과(출력) : 
```json
{
  "reason":"주어진 문장을 JSON 형식으로 변환하였습니다.",
  "generated_text":"{\"users\":{\"user\":{\"username\":\"Gildong-Hong\"}}}"
}
```

## 이미지 분석

생성형 AI는 텍스트뿐만 아니라 이미지 데이터를 분석하는 작업도 수행할 수 있습니다.
이미지를 통해 다음과 같은 작업이 가능합니다:
- 캡션 생성: 이미지의 내용을 요약하여 텍스트로 표현
- 객체 식별(Object Detection): 이미지 안에 있는 특정 객체를 찾아냄
- 텍스트 인식(OCR): 이미지 안의 텍스트를 추출
- 그래프 패턴 분석: 시각적 데이터를 텍스트 형태로 변환

오라클 데이터베이스는 텍스트 데이터와 유사하게 바이너리 이미지 또는 PDF와 같은 문서 데이터를 생성형 AI로 전송하여 분석 작업을 수행할 수 있습니다.
- 지원가능 미디어 타입 : image/png, image/jpeg, application/pdf
- 지원 가능한 이미지 형식 및 처리 방법은 사용 중인 3rd Party Provider 문서를 확인해야 합니다.

사용자 정의 함수로 모델명, 이미지 데이터(BLOB), 그리고 프롬프트 내용을 입력받아, 결과를 CLOB 형식으로 반환합니다.
이를 통해 이미지 데이터를 텍스트로 변환하거나 추가적인 분석 작업을 수행할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
CREATE OR REPLACE FUNCTION generate_text_from_image(p_model_name varchar2, p_prompt CLOB, p_media_data BLOB, p_media_type VARCHAR2 default 'image/jpeg') RETURN CLOB 
IS 
   output CLOB;
   v_model_params json;
BEGIN 
    --모델 정보가져오기
   select model_params into v_model_params from vw_my_models where model = p_model_name;
   -- REST API 통신할때 문자 인코딩 설정
   utl_http.set_body_charset('UTF-8'); 
   -- 결과요청
   output := dbms_vector_chain.utl_to_generate_text(p_prompt, p_media_data, p_media_type, v_model_params);
   return output;a
END;
/
```
 
사용자 정의 함수로 모델명, 이미지 데이터(BLOB), 그리고 프롬프트 내용을 입력받아, 결과를 CLOB 형식으로 반환합니다.
이를 통해 이미지 데이터를 텍스트로 변환하거나 추가적인 분석 작업을 수행할 수 있습니다.

{% include codeHeader.html copyable="true" codetype="sql"%}
```sql
SELECT instruction, output_format, 
       JSON(generate_text_from_image('gpt-4o-mini', JSON_SERIALIZE(JSON_OBJECT(instruction, output_format )), input_data, 'image/jpeg')) generated_text
  FROM (SELECT g.id image_id ,
               t.task_rules instruction, 
               o.output_name,
               o.output_text||chr(10)||o.output_sample output_format,
               to_blob(bfile('DATA_PUMP_DIR','Jeep_Wranger.jpg')) input_data
          FROM my_task t, my_task_output o
         WHERE t.task_name = '이미지설명'
           AND o.output_name = 1);
```

**1. 이미지 설명**

- 작업 내용(입력) : 이미지설명
- 프롬프트 : 주어진 이미지에 대해서 설명해주세요
- 분석 데이터(입력) : Jeep_Wranger.jpg(BLOB) 
  - ![](/assets/images/blog/aivectorsearch/Jeep_Wranger.jpg)
- 분석 결과(출력) : 
```json
{
  "reason":"주어진 이미지는 차량의 모습으로, 특정 모델과 색상을 식별할 수 있습니다.",
  "generated_text":"이미지에는 올리브 그린 색상의 지프 차량이 보입니다. 이 차량은 오프로드 주행에 적합한 디자인을 가지고 있으며, 넓은 타이어와 강력한 차체 구조가 특징입니다. 배경에는 자연 경관이 펼쳐져 있어 차량의 외관과 잘 어우러집니다."
}
```

**2. 이미지 분류**

- 작업 내용(입력) : 이미지분류
- 프롬프트 : 주어진 이미지에서 "배경"는 [자연,도시,실내]로, "피상"는 [인물,동물,사물,건물]로, "피상특징"을 3개추가하여 카테고리를 지정하세요
- 분석 데이터(입력) : Jeep_Wranger.jpg(BLOB) 
  - ![](/assets/images/blog/aivectorsearch/Jeep_Wranger.jpg)
- 분석 결과(출력) : 
```json
{
  "reason":"이미지는 자연 배경에 있는 자동차를 보여주고 있으며, 자동차에 대한 세부 특성을 추가했습니다.",
  "generated_text":"{\"배경\":\"자연\",\"피상\":\"사물\",\"피상특징\":[\"SUV\",\"녹색 색상\",\"오프로드 타이어\"]}"
}
```
 
## 마무리

지금까지 Oracle AI Vector Search와 생성형 AI를 활용해 데이터를 분석하고 변환하는 효율적인 방법을 살펴보았습니다. 이를 통해 오라클 데이터베이스 내부에서 AI 기반 작업을 간소화하고, 데이터를 실시간으로 분석하거나 자동화하는 과정을 배웠습니다.

오라클의 강력한 데이터 처리 기능과 AI 연동은 복잡한 데이터 작업을 손쉽게 수행할 수 있도록 도와주며, 이를 업무에 적용하면 생산성 향상과 비즈니스 가치 증대를 기대할 수 있습니다.

앞으로 이러한 기술을 활용하여 데이터 기반 의사결정을 더욱 빠르고 정확하게 내릴 수 있을 것입니다. 나아가, AI 기술과 데이터베이스의 결합은 새로운 비즈니스 기회를 창출하는 데도 중요한 역할을 할 것입니다.

## 참고자료 

- <https://docs.oracle.com/en/database/oracle/oracle-database/23/vecse/utl_to_generate_text-dbms_vector_chain.html>{:target="_blank"}