---
layout: single
title: Ollama로 Local LLM구축하기
date: 2024-07-10 21:00
categories: 
  - llm 
tags: 
   - ollama
   - LLM
excerpt : olllma을 이용하여 Local LLM구축하는 방법에 대해서 알아봅니다. 명령어 2개로 설치, 그리고 질문
header : 
  teaser: /assets/images/blog/vector_search1.jpg
  overlay_image: /assets/images/blog/vector_search1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

Local LLM 구축을 해보고 싶다는 생각에 사이트를 검색하던중 ollama에 대해서 알게되었습니다. 
자세한 내용은 추가적으로 공부해야겠지만 먼저 설치 절차와 질의방법에 대해서 알아보겠습니다.

## Ollama 란?

Ollama는 Open LLM(Llama3, Phi3, Mistral, Gemma 2등)을 쉽게 설치하고 관리하기 위하여 CLI를 제공하고  REST API를 위한 end point를 제공합니다. 
한마디로 LLM을 쉽게 사용할수 있는 플랫폼입니다. MacOS, Linux, Window를 지원하기 때문에 PC에서 쉽게 설치해서 사용할수 있습니다. 

제가 테스트한 환경은 GPU없는 Linux환경이었습니다. 나중에 GPU나 Mac Notebook이 생기면 꼭 테스트해보고 싶습니다. 

Ollama에서 지원되는 모델은 상당히 많습니다. 자세한 모델들은 아래 사이트에서 확인가능합니다. 
- <https://github.com/ollama/ollama/blob/main/README.md#quickstart>{:target="_blank"}
- <https://ollama.com/library>{:target="_blank"}

## LLM 설치 절차

Linux/MasOS/Window 환경별로 설치 절차가 틀립니다. 
- Download Ollama : <https://ollama.com/download>{:target="_blank"}
  
저는 Linux환경에서 설치해보았습니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
curl -fsSL https://ollama.com/install.sh | sh
```

설치 화면입니다. http://localhost:11434로 REST API 서비스가 가능합니다. 

```shell
$> curl -fsSL https://ollama.com/install.sh | sh
>>> Downloading ollama...
######################################################################## 100.0%
>>> Installing ollama to /usr/local/bin...
>>> Creating ollama user...
>>> Adding ollama user to render group...
>>> Adding ollama user to video group...
>>> Adding current user to ollama group...
>>> Creating ollama systemd service...
>>> Enabling and starting ollama service...
Created symlink /etc/systemd/system/default.target.wants/ollama.service → /etc/systemd/system/ollama.service.
>>> The Ollama API is now available at 127.0.0.1:11434.
>>> Install complete. Run "ollama" from the command line.
WARNING: No NVIDIA/AMD GPU detected. Ollama will run in CPU-only mode.
$> ollama
Usage:
  ollama [flags]
  ollama [command]

Available Commands:
  serve       Start ollama
  create      Create a model from a Modelfile
  show        Show information for a model
  run         Run a model
  pull        Pull a model from a registry
  push        Push a model to a registry
  list        List models
  ps          List running models
  cp          Copy a model
  rm          Remove a model
  help        Help about any command

Flags:
  -h, --help      help for ollama
  -v, --version   Show version information
```

mistral LLM모델을 설치합니다. 참쉽네요.
저는 Mistral을 설치해보았습니다.

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
ollama run mistral
```

설치 화면입니다. 모델 사이즈는 4.1GB입니다. 
처음에 run명령어로 모델을 실행하면 다운로드를 수행하고 이미 다운로드된 모델로 run하면 CLI기반으로 질의를 수행할수 있습니다. 

```shell
## 처음실행하면 모델을 다운로드함 
$> ollama run mistral  
pulling manifest
pulling ff82381e2bea... 100% ▕███████████████████████████████████▏ 4.1 GB
pulling 43070e2d4e53... 100% ▕███████████████████████████████████▏  11 KB
pulling c43332387573... 100% ▕███████████████████████████████████▏   67 B
pulling ed11eda7790d... 100% ▕███████████████████████████████████▏   30 B
pulling 42347cd80dc8... 100% ▕███████████████████████████████████▏  485 B
verifying sha256 digest
writing manifest
removing any unused layers
success
## 다운로드후 질의수행
>>> hello
 Hello! How can I assist you today? If you have any questions or need help with something,
feel free to ask. Im here to help!

>>> 안녕하세요
 안녕하세요! 어떤 도움이 필요합니까? 항상 돕기로운 마음가짐으로 대답할게요.

(Hello, How can I assist you today?)

>>> /bye

## 두번째 실행하면 질의를 위한 CLI화면이 나옴
$> ollama run mistral
>>> Send a message (/? for help)
```

현재 실행하고 있는 목록을 확인할수 있습니다. 

```shell
ollama list
```

실행결과입니다. 

```shell
$> ollama list
NAME            ID              SIZE    MODIFIED
mistral:latest  2ae6f6dd7a3d    4.1 GB  8 hours ago
```
 

처음에 run 으로 실행하여 CLI기반으로 질의를 수행할수도 있지만, REST API로 답변을 요청할수 있습니다. 

{% include codeHeader.html copyable="true" codetype="shell"%}
```shell
curl -X POST http://localhost:11434/api/generate -d '{
   "model": "mistral",
   "prompt":"Here is a story about llamas eating grass"
  }'
```

실행결과입니다. stream방식으로 token단위로 초단위로 생성됩니다. 저는 CPU기반이라 엄청 느리긴했습니다. 

```shell
$> curl -X POST http://localhost:11434/api/generate -d '{
>   "model": "mistral",
>   "prompt":"Here is a story about llamas eating grass"
>  }'
{"model":"mistral","created_at":"2024-07-12T00:30:25.652704101Z","response":" Title","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:26.134395969Z","response":":","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:26.614596208Z","response":" The","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:27.096715876Z","response":" L","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:27.579239169Z","response":"lam","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:28.060137413Z","response":"as","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:28.540455184Z","response":"'","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:29.020465113Z","response":" Green","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:29.507430027Z","response":" Fe","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:29.990720774Z","response":"ast","done":false}
{"model":"mistral","created_at":"2024-07-12T00:30:30.474961933Z","response":"\n","done":false}
```

추가적으로 아래와 같은 기능들을 지원합니다. 
 - python, js 지원 
 - OpenAI 호환 API를 제공함.
 - GGUF형식의 모델파일을 import할수 있음
 - 관련 Community가 엄청 많음(대박!!)
   - <https://github.com/ollama/ollama/blob/main/README.md#quickstart>{:target="_blank"}


## 마무리

외부 상용 LLM에서 API로 요청할수는 있지만 Token의 갯수가 비용이고 인터넷에 항상 연결되어야하는 부담이 있습니다. 기업내에서는 데이터 보안 및 비용을 고려하면 Local LLM구축을 고민할수도 있습니다 

Ollama을 사용하면 동일한 API로 다양한 모델을 테스트해볼수 있을것 같습니다. 

## 참고문서

- Ollama 홈페이지
  - <https://ollama.com/>{:target="blank"}
- Ollama Github
  - <https://github.com/ollama/ollama>{:target="blank"}