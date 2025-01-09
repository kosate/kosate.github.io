---
layout: single
title: "[LLM활용] PDF문서(논문) 번역하기"
date: 2025-01-02 21:00
categories: 
  - llm 
tags: 
   - pdfmathtranslate
   - ollama
   - exaone
excerpt : 로컬 LLM모델을 활용하여 PDF문서 번역하는 절차에 대해서 알아봅니다.
header : 
  teaser: /assets/images/blog/ai1.jpg
  overlay_image: /assets/images/blog/ai1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

생성형 AI를 어떻게 활용할 수 있을지 궁금해서 종종 논문을 찾아보곤 합니다.  
논문에는 보통 요약, 서론, 관련 연구, 실험, 결과, 결론 같은 중요한 내용이 포함되어 있습니다. 직접 테스트해보진 않았지만, 논문에 나오는 내용은 신뢰할 수 있는 근거 자료로 활용하기 좋습니다.  

예를 들어, 소프트웨어 엔지니어링 관련 논문은 아래 링크에서 확인할 수 있습니다.  
- <https://arxiv.org/list/cs.SE/recent?skip=0&show=25>

하지만, 논문이 보통 영어로 작성되어 있어서 이해하기 어렵고 시간도 많이 걸립니다.  
그래서 영어를 한국어로 쉽게 번역해주는 도구를 찾아보았습니다.  

이 과정에서 **PDFMathTranslate**라는 라이브러리를 알게 되었는데, 이 도구는 PDF 포맷을 그대로 유지하면서 텍스트만 번역할 수 있습니다.  
또한 번역 작업에는 로컬에서 실행 가능한 **LLM(Local Large Language Model)**을 사용했습니다. 

## ollama

로컬 LLM 모델을 실행하려면 **ollama**라는 도구를 사용하면 됩니다. Ollama는 로컬 환경에서 LLM 모델을 쉽게 실행할 수 있도록 도와줍니다.

- [Ollama로 Local LLM 구축하기](/blog/llm/how-to-install-local-llms-using-ollama/){:target="_blank"}

설치도 간단하고, 명령어 하나만 실행하면 모델을 바로 사용할 수 있습니다. 한국어 번역을 위해 LG AI Research에서 제공하는 생성형 AI 모델(exaone3.5)을 사용하였습니다.
{% include codeHeader.html copyable="true"%}
```bash
ollama run exaone3.5:2.4b
```

EXAONE3.5 모델 정보는 아래 링크에서 확인할 수 있습니다.
- <https://github.com/LG-AI-EXAONE/EXAONE-3.5>{:target="blank"}

## PDFMathTranslate

PDFMathTranslate는 바이두에서 개발한 PDF 번역 라이브러리입니다. 이 라이브러리는 PDF 문서를 번역하면서 원본의 레이아웃과 형식을 최대한 보존합니다. 특히 수식, 차트, 목차, 주석 등의 구조를 유지하며 번역을 수행하여, 학술 논문이나 기술 문서와 같은 전문 자료의 번역에 유용합니다.
- <https://github.com/Byaidu/PDFMathTranslate>{:target="_blank"}

- 주요 기능
   - 구조 보존 번역: 수식, 차트, 목차, 주석 등 원본 문서의 레이아웃과 형식을 유지하면서 번역을 수행합니다.
   - 다양한 번역 서비스 지원: Google Translate, DeepL, OpenAI GPT 등 여러 번역 서비스를 지원하며, 사용자가 원하는 번역 엔진을 선택할 수 있습니다.
   - 다양한 사용 방식: 명령줄 도구(CLI), 그래픽 사용자 인터페이스(GUI), Docker 환경 등 다양한 방식으로 활용할 수 있습니다.
   - 부분 번역 기능: 전체 문서뿐만 아니라 특정 페이지를 지정하여 번역할 수 있어 필요에 따라 유연하게 사용할 수 있습니다.

### 1. 설치 방법

Python 버전이 3.8 이상 3.12 이하이어야 합니다. 설치는 아래 명령어로 가능합니다.

{% include codeHeader.html copyable="true"%}
```bash 
## 라이브러리 설치
pip install pdf2zh
```

### 2. 실행 방법

#### 1. 그래픽 모드로 실행
{% include codeHeader.html copyable="true"%}
```bash 
## 웹서비스 실행
pdf2zh -i
```
웹 브라우저에서 http://localhost:7860/ 으로 접속하면 됩니다. 아래와 같이 PDF 문서를 지정하고, 번역 서비스를 선택하여 번역 작업을 수행할 수 있습니다. 
![](/assets/images/blog/llm/pdfmathtranslate.png)

#### 2. 커맨드 모드로 실행

여러 개의 파일을 번역할 때는 커맨드 모드가 그래픽 모드에 비해 편리합니다. 로컬 LLM 모델을 호출하려면 환경 변수를 설정해야 합니다. 이번 글에서는 ollama에서 제공하는 exaone 모델을 사용합니다.

{% include codeHeader.html copyable="true"%}
```bash 
## 번역문서 저장 폴더 생성
mkdir result
## LLM모델 지정
export OLLAMA_HOST=http://127.0.0.1:11434
export OLLAMA_MODEL=exaone3.5:2.4b
## 번역 작업 수행
pdf2zh 2410.06011v1.pdf -li en -lo ko -o result -s ollama
```

**명령어 옵션 설명**

- `-li` : 원본 PDF의 언어를 지정합니다. 대부분 논문은 영어(en)로 작성됩니다.
- `-lo` : 번역할 언어를 지정합니다. 여기서는 한국어(ko)로 설정했습니다.
- `-o` : 번역된 파일이 저장될 폴더를 지정합니다. 위에서는 result 폴더를 사용했습니다.
- `-s` : 번역을 요청할 서비스명을 지정합니다. 이번에는 ollama를 사용했습니다.

추가 정보는 GitHub 문서를 참고하세요.
- <https://github.com/Byaidu/PDFMathTranslate/blob/main/docs/ADVANCED.md>{:target="_blank"}

**생성된 파일 확인**

번역이 완료되면 결과 파일은 지정한 폴더에 저장됩니다. 저장된 파일 목록을 확인하면 두 개의 파일이 확인됩니다. 

- 원본파일명-mono.pdf : 한국어로 번역된 문서입니다.
- 원본파일명-dual.pdf : 원본 내용과 번역된 내용이 같이 있는 문서입니다. (예로 1페이지는 원본, 2페이지는 1페이지의 번역본, 3페이지는 원본 2페이지의 내용, 4페이지는 3페이지의 번역본) 원본 한 페이지와 번역본 한 페이지가 번갈아가며 나오기 때문에 원본 내용을 참고할 때 유용합니다.

{% include codeHeader.html copyable="true"%}
```bash
## 번역된 문서 확인
ls -al result  
## 번역된 문서 
-rw-r--r--@ 1 kosate  staff   704833 Jan  7 12:42 result/2410.06011v1-mono.pdf
-rw-r--r--@ 1 kosate  staff  1207711 Jan  7 12:42 result/2410.06011v1-dual.pdf
```

LLM 모델에 따라 번역 품질이 좌우됩니다. 한국어 번역 시에는 한국어용 모델이 품질이 좋은 것 같습니다. 로컬 PC(Mac Air M3)에 ollama의 exaone3.5-2.4B 모델을 이용하여 15페이지 문서를 번역할 경우 약 10분 정도 소요되었습니다. 약간의 시간을 가지면 외부 서비스를 호출하지 않고도 충분히 좋은 품질의 번역 문서를 생성할 수 있습니다.

## 마무리

이 글에서는 PDFMathTranslate와 ollama를 활용해 PDF 논문을 쉽게 번역하는 방법을 소개했습니다. 이 도구들을 사용하면 영어 논문을 읽는 데 걸리는 시간이 줄어들고, 더 효율적으로 정보를 활용할 수 있습니다. 앞으로도 이러한 도구들을 활용하여 더 많은 정보를 쉽게 접근하고 이해할 수 있기를 바랍니다!