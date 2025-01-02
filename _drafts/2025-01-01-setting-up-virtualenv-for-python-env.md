---
layout: single
title: "[Python] virtualenv를 실행환경 관리하기"
date: 2025-01-01 21:00
categories: 
  - python
author: 
tags: 
  - Python
excerpt : virtualenv를 이용하여 Python 실행환경을 관리하는 절차에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 들어가며  

Python 프로젝트를 진행하다 보면, 각 프로젝트마다 다른 패키지 버전을 사용해야 할 때가 많습니다. 이럴 때 유용한 도구가 바로 `virtualenv`입니다. 이번 글에서는 `virtualenv`를 이용해 Python 실행환경을 설정하는 방법을 알아보겠습니다. `virtualenv`를 사용하면 각 프로젝트마다 독립적인 환경을 유지할 수 있어 패키지 충돌을 방지할 수 있습니다.

- 다른 블로그 참조하기
  - [Miniconda와 Jupyter설정하기](/blog/python/install-miniconda-for-python-env/){:target="_blank"}

virtualenv의 특징
 - Python의 다양한 버전을 사용가능(Python2, Python3 모두 지원)
 - 별도 설치 필요

##  virtualenv 설정

`virtualenv`를 사용하면 Python 프로젝트마다 독립적인 가상환경을 만들 수 있습니다. 이렇게 하면 프로젝트 간의 패키지 충돌을 방지할 수 있습니다. 다음은 `virtualenv`를 설정하는 방법입니다.

{% include codeHeader.html copyable="true" codetype="shell"  %}
```bash
## Python 가상화 도구 설치
pip3 install --user virtualenv
```

먼저, `virtualenv`를 설치합니다.

{% include codeHeader.html copyable="true" codetype="shell"  %}
```bash
## 가상환경 생성
virtualenv --python=3.12 aivs_demo
```

그 다음, 가상환경을 생성합니다. 여기서는 `aivs_demo`라는 이름의 가상환경을 생성합니다.

{% include codeHeader.html copyable="true" codetype="shell"  %}
```bash
## 가상환경 활성화
source aivs_demo/bin/activate
```

마지막으로, 가상환경을 활성화합니다. 이제 이 가상환경 내에서 Python 패키지를 설치하고 사용할 수 있습니다.


## 마무리

이제 `virtualenv`를 사용하여 Python 실행환경을 설정하는 방법을 배웠습니다. 각 프로젝트마다 독립적인 환경을 유지할 수 있어 충돌을 방지할 수 있습니다. 다음 프로젝트에서도 이 방법을 활용해 보세요. 가상환경을 사용하면 프로젝트 간의 패키지 충돌을 방지하고, 더 효율적으로 개발할 수 있습니다. 앞으로도 Python 프로젝트를 진행할 때 `virtualenv`를 적극 활용해 보세요.
 