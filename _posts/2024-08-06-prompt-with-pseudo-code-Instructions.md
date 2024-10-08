---
layout: single
title: (논문요약)의사 코드(Pseudo Code)를 이용한 프롬프팅
date: 2024-08-06 21:00
categories: 
  - thesis 
tags: 
   - LLM
   - Pseudo-Code
   - Pythonic
excerpt : 자연어 대신 코드로 LLM에게 명령을? 의사 코드를 사용한 프롬프트 작성 기법이 LLM의 잠재력을 최대한 끌어낼 수 있는 방법으로 주목받고 있습니다!
header : 
  teaser: /assets/images/blog/prompt1.jpg
  overlay_image: /assets/images/blog/prompt1.jpg
toc : true  
toc_sticky: true
---

**참고사항** 논문이나 기술문서를 요약하여 정보를 전달드리는 목적으로 작성되었습니다. 
{: .notice} 

## 들어가며

본 블로그는 Google의 Notebook LM 도구를 사용하여 의사코드를 이용한 프롬프트 작성관련한 기술 논문을 요약한 내용입니다. 
 
- 논문 제목 : Prompting with Pseudo-Code Instructions
- 파일 원본 : <https://aclanthology.org/2023.emnlp-main.939.pdf>{:_target="_blank"}

> 논문 원본과 다르게 설명을 위하여 부가적인 내용이 포함되어 있을수 있습니다. 상세한 내용은 논문 원본을 참고하시기 바랍니다.

## 자연어 대신 코드로? 😮 LLM 프롬프트 작성의 새로운 트렌드!

최근 대규모 언어 모델(LLM) 분야에서는 **자연어 대신 의사 코드(pseudo-code)를 사용하여 프롬프트를 작성하는 기법**이 주목받고 있습니다. 마치 개발자처럼 LLM에게 코드로 명령을 내리는 방식인데요, 이는 자연어의 모호성을 줄이고 LLM이 명령을 더 잘 이해하도록 돕기 위함입니다. 

"Prompting with Pseudo-Code Instructions" 논문에서는 BLOOM 및 CodeGen 모델을 사용한 실험을 통해 **의사 코드 기반 프롬프트가 LLM의 성능 향상에 상당한 효과가 있음을 보여줍니다.**

### 💡 왜 의사 코드를 사용할까요?

* **자연어는 모호할 수 있습니다.** 여러 의미로 해석될 여지가 많아 LLM이 혼란을 일으킬 수 있습니다.
* **의사 코드는 명확하고 구조적입니다.** 컴퓨터 과학 분야에서 사용되는 형식으로, LLM이 명령을 쉽게 이해하고 처리할 수 있도록 돕습니다.

### 🚀 실험 결과: 의사 코드가 더 효과적입니다!

132개의 다양한 NLP 작업(분류, QA, 텍스트 생성 등)에 대한 의사 코드 프롬프트 데이터 세트를 사용한 실험 결과:

* **분류 작업의 경우 F1 점수가 평균 7~16점 증가했습니다.**
* **전체 작업에서 ROUGE-L 점수가 12~38% 향상되었습니다.**

특히 코드 관련 모델인 CodeGen은 의사 코드 프롬프트를 사용했을 때 성능 향상이 두드러졌습니다. 

### 💪 의사 코드가 LLM에 효과적인 이유

1. **명확한 구조**: 함수, 변수, 제어 흐름 등을 사용하여 작업을 단계별로 명확하게 정의하여 LLM의 이해를 돕습니다.
2. **풍부한 정보**: 함수 이름, 매개변수, 반환 값 등 자연어 프롬프트보다 풍부한 정보를 제공하여 작업의 정확도를 높입니다.
3. **코드 모델의 장점**: CodeGen과 같은 코드 모델은 의사 코드의 구조와 정보를 효과적으로 활용할 수 있습니다.

### 🤔 그렇다면 모든 작업에서 의사 코드가 항상 더 나은 성능을 보일까요?

흥미롭게도, 단순 질의응답(QA) 작업에서는 CodeGen 모델에서만 의사 코드 프롬프트가 더 나은 성능을 보였고, BLOOM 모델에서는 오히려 자연어 프롬프트보다 성능이 떨어지는 것을 확인했습니다. 연구팀은 이러한 현상이 QA 작업의 특성과 의사 코드 프롬프트의 복잡성 때문이라고 분석했습니다.

반면 객관식 문제(MCQ)와 같이 답변 형식이 정해져 있고, 좀 더 복잡한 추론이 필요한 QA 작업에서는 의사 코드 프롬프트가 두 모델 모두에서 효과적이었습니다.

### 🧐 의사 코드 프롬프트, 예시와 함께 알아보기

다음은 주어진 문장의 감정을 분석하는 작업에 대한 의사 코드 프롬프트 예시입니다. (출처에서 발췌)

```python
내가 작성한 의사코드를 기반으로 감정 예측합니다. 
결과만 출력합니다.

def generate_sentiment(sentence: str) -> str:
  """ 주어진 문장에 대한 감정을 예측합니다. 긍정적인 감정이면 "positive"를, 그렇지 않으면 "negative"를 반환합니다.

  Parameters:
    sentence (str): 입력 문장

  Returns:
    str: 입력 문장의 감정
  """

  # 감정 예측
  if sentiment_is_positive(sentence):
    return "positive"
  else:
    return "negative"

>>> generate_sentiment("오늘 기분 최고야!") 
```

ChatGPT 요청 결과입니다. 

```text
"positive"
```

> 위에 작성된 의사 코드 프롬프트예시는 논문에 있는 내용을 한국어로 번역하고 내용을 일부 수정하였습니다. 

### 🚧 의사 코드 프롬프트, 앞으로의 과제

* **더 큰 모델 및 다양한 작업에 대한 추가 연구**:  더 큰 모델과 다양한 작업 유형에서 의사 코드 프롬프트의 효과를 검증해야 합니다.
* **의사 코드 작성의 어려움 해결**: 누구나 쉽게 의사 코드 프롬프트를 작성할 수 있도록 간편화된 작성 방법이나 도구 개발이 필요합니다.
* **다른 프롬프트 기법과의 비교 분석**: 의사 코드 프롬프트가 다른 프롬프트 기법들과 비교하여 어떤 강점과 약점을 가지고 있는지 분석하는 연구가 필요합니다.

### ✨ 결론: LLM과의 소통 방식을 바꿀 가능성

의사 코드 프롬프트는 LLM, 특히 코드 모델의 잠재력을 최대한 이끌어낼 수 있는 유망한 방법입니다. 앞으로 의사 코드 프롬프트를 이용한 LLM 활용 연구가 더욱 활발하게 이루어져, LLM의 능력을 최대한 발휘하고 다양한 분야에 기여할 수 있기를 기대합니다. 

## 참고문서

- 논문 : <https://aclanthology.org/2023.emnlp-main.939.pdf>{:_target="_blank"}