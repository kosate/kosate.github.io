---
layout: single
title: 클라우드 네트워크 다이어그램 작성 도구(drawio) 소개
date: 2024-02-11 21:00
categories: 
  - cloud
author: 
tags: 
   - cloud
   - draw.io
   - github blogs
excerpt : 클라우드 네트워크 아키텍쳐작성할때 도움이 되는 diagram 도구를 소개합니다.
header :
  teaser: /assets/images/blog/blog6.jpg
  overlay_image: /assets/images/blog/blog6.jpg
toc : true  
toc_sticky: true
---

## 개요

클라우드 네트워크 아키텍쳐 작성시 유용하게 사용할수 있는 Draw.io 도구에 대해서 설명합니다.
무료로 사용할수 있으니 다양한 아이콘을 사용하여 자신의 생각을 Diagram으로 표현해보세요.

## Draw.io 소개 

Draw.io는 오픈소스기반으로 무료로 사용할수 있는 Diagram 도구입니다. 웹 브라우저로 가입없이 Online 으로 사용하거나 데스크탑으로 다운로드 받아서 offline으로 사용할수 있습니다.  간단한 스케치 부터 복잡한 Diagram까지 그릴수 있습니다. 

- Drawio 홈페이지 :  <https://www.drawio.com>{:target="_blank"}


Draw.io의 특징은 아래와 같습니다. 
- 다양한 다이어그램 지원: 플로우 차트, UML 다이어그램, 네트워크 다이어그램, 기술적 구조도, 그리고 많은 다른 유형의 다이어그램을 그릴 수 있습니다.
- 저장 및 공유: Draw.io는 로컬 컴퓨터나 클라우드 서비스(예: Google Drive, Dropbox)에 다이어그램을 저장하고 공유할 수 있도록 지원합니다.
- 다양한 기능: 그림을 그리고 편집할 때 필요한 다양한 도구와 기능을 제공합니다. 이는 텍스트 추가, 색상 변경, 선 스타일 변경 등을 포함합니다.
- 직관적 사용자 인터페이스: 사용자 친화적인 인터페이스로, 새로운 사용자도 쉽게 익힐 수 있습니다.

저는 주로 클라우드 네트워크 구성도 그릴때 사용하고 있습니다.

## VSCode 플러그인 설치

Drawio는 위에서 언급하였듯이 online 혹은 offline으로 모두 사용이 가능합니다. 또한 다양한 plugin을 제공하여 vscode에서도 사용가능합니다. 

저는 Github blog작성 및 diagram작업을 같이 하기 위해서 vscode에서 `Draw.io Integration` plugin을 설치하였습니다. 

vscode-drawio Plugin 관련된 블로그
- Drawio에서 offical하게 언급하고 있습니다. 
  - <https://www.drawio.com/blog/embed-diagrams-vscode>{:target="_blank"}
- vs<https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio>{:target="_blank"}

vscode내에서 Extension화면에서 drawio로 검색하여 Draw.io Integration Plugin이 확인됩니다.

![](/assets/images/blog/vscode-drawio/vscode1.jpg)

`install` 버튼을 클릭하여 설치합니다. 

vscode에서는 Editor가 활성화되려면 아래와 같은 확장자를 사용해야합니다.

- .drawio .dio .dio.svg .drawio.svg .drawio.png .dio.png

저는 Github blogs내에서 네트워크 아키텍쳐를 작성하기 위해서, /assets/drawio 폴더를 만들고, 
cloudnetwork1.drawio 파일을 생성했습니다.

cloudnetwork1.drawio을 더블클릭을 하면 아래와 같이 Editor가 보여집니다.

![](/assets/images/blog/vscode-drawio/vscode2.jpg)


## OCI 아이콘 추가(library)

기본적으로 많은 라이브러리/이미지를 제공하고 있습니다.
화면 왼쪽에 있는 `More Shapes`버튼을 클릭하면 다양한 라이브러리를 추가할수 있습니다. 
클라우드 관련된 아이콘으로 AWS, GCP, Azure, IBM 등이 있습니다.  
아쉽게도 Draw.io도구에는 OCI 아이콘은 기본으로 내장되어 있지 않습니다. 

개별 사용자 이미지들은 Editor화면에 넣으면 붙여지게 됩니다.

**OCI 아이콘을 추가하는 작업에 대해서 알아보겠습니다.**

여러개의 이미지묶음을 라이브러리라고 하는데요, 사용자 정의 라이브러리를 추가하는 방법에 대해서 알아보겠습니다. 

이미지 묶음을 라이브러리파일로 export할수 있습니다. OCI에서는 export된 파일을 제공합니다. 

아래 사이트에는 OCI(Oracle Cloud) 아이콘이 있습니다. 
- <https://docs.oracle.com/en-us/iaas/Content/General/Reference/graphicsfordiagrams.htm>{:target="_blank"}

PowerPoint, draw.io, visio 파일중에 draw.io파일을 다운로드 받습니다.

- <https://docs.oracle.com/iaas/Content/Resources/Assets/OCI-Style-Guide-for-Drawio.zip>{:target="_blank"}

OCI-Style-Guide-for-Drawio.zip파일을 압축해제하면 OCI Library.xml 파일이 있습니다. 

OCI Library.xml파일을 VScode내 Drawio Editor 왼쪽으로 drag & drop 하면 됩니다.
이때 shift 키를 같이 눌러야 Editor 안으로 들어갑니다. (그냥 drag & drop하면 OCI Library.xml 파일 자체가 open됩니다.)

![](/assets/images/blog/vscode-drawio/vscode3.jpg)

왼쪽에 보면 OCI Library가 추가된것을 확인할수 있습니다. library의 아이콘을 클릭하면 가운데 diagram화면에 아이콘이 추가됩니다.

![](/assets/images/blog/vscode-drawio/vscode4.jpg)

> vscode plugin에는 매번 editor가 새로 오픈될때마다 추가한 library가 사라지는것 같습니다. 번거롭겠지만 반복적으로 설정해야될것같습니다. 

## 테마 변경하기 

vscode에서 `draw.io integration`을 사용하면 vscode theme가 적용됩니다. 저는 dark theme를 사용하다보니 diagram작성시 font color가 기본으로 black으로 표시되어 불편했습니다.
해당 plugin만 Theme를 변경할수 있습니다. 

Plugin의 환경 설정정보에서 변경할수 있는데요,  
왼쪽 plugin에서 톱니바퀴처럼 생긴 아이콘을 클릭하면 Setting 메뉴가 나옵니다. 
Setting에서 Theme를 변경할수 있습니다.

![](/assets/images/blog/vscode-drawio/theme1.jpg)

배경이 하얀색인 kennedy Theme을 선택했습니다. 선택하면 이미 오픈되어 있는 editor에도 곧바로 적용됩니다. 

![](/assets/images/blog/vscode-drawio/theme2.jpg)

## 네트워크 다이어그램 작성

Editor의 왼쪽에는 많은 아이콘이 있습니다. 
네트워크 다이어그램을 작성하기 위해서 네트워크대역 및 Compute 인스턴스를 이용하여 Diagram를 작성할수 있습니다. 

VCN (Virtual Cloud Network) 아이콘입니다. 클릭하거나 Drag & Drop을 하면 Diagram화면에 붙여지게됩니다.

![](/assets/images/blog/vscode-drawio/icon1.jpg)

Subnet 아이콘입니다. VCN안에 subnet 아이콘을 넣을수 있습니다. 아이콘을 Drag하여 크기와 위치를 조정합니다. 

![](/assets/images/blog/vscode-drawio/icon2.jpg)

Compute 아이콘입니다. subnet안에 VM아이콘을 넣을수 있습니다. 아이콘을 Drag하여 크기와 위치를 조정합니다. 

![](/assets/images/blog/vscode-drawio/icon3.jpg)


여러 아이콘들과 텍스트들을 조합하여 아래와 같이 다이어그램을 작성할수 있습니다. 

![](/assets/images/blog/vscode-drawio/diagram1.jpg)

## 이미지로 변환(저장)

cloudnetwork1.drawio 파일로 생성된 내용을 svg혹은 png파일로 저장할수 있습니다. 
메뉴에서 `Export`메뉴를 선택후에 svg형식으로 /assets/drawio/cloudnetwork1.svg에 저장했습니다. 

![](/assets/images/blog/vscode-drawio/export1.jpg)

GiHub Blogs에 넣을때는 아래와 같이 넣을수 있습니다. 
{% raw %}
```markdown
![](/assets/drawio/cloudnetwork1.svg)
```
{% endraw %}

실제 적용한 화면은 아래와 같습니다. 생각보다 깔끔하게 나왔네요~

![](/assets/drawio/cloudnetwork1.svg)

## 마무리

무료로 사용할수 있는 Diagram도구인 Draw.io 에 대해서 알아보았습니다. 블로그를 읽은 사람의 입장에서는 몇백줄의 글보다는 하나의 그림이 더 직관적으로 이해될것 같습니다. 저도 처음에는 글로 표현하려고 노력했지만, 너무 주저리 설명만 하는것 같아 지루하다는 생각이 저자신도 들었습니다. 
좀더 방문하는 사람의 입장에서 다양한 방법과 도구를 사용하여 짧은 시간안에 많은 정보를 얻어갈수 있는 방법에 대해서 고민해야될것 같습니다.

## 참고문서

- https://www.drawio.com/
- <https://docs.oracle.com/en-us/iaas/Content/General/Reference/graphicsfordiagrams.htm>{:target="_blank"}
