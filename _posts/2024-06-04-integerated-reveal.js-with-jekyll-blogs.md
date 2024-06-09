--- 
layout: single
title: Github 블로그에 프레젠테이션 화면 만들기
date: 2024-06-04 21:00
categories: 
  - blogs
author: 
tags: 
  - github
  - blogs
  - reveal.js
excerpt : Github 블로그에서 reveal.js를 이용하여 블로그 내용을 프레젠테이션 처럼 꾸미는 방법에 대해서 알아보겠습니다.
header :
  teaser: /assets/images/blog/blog1.jpg
  overlay_image: /assets/images/blog/blog1.jpg
toc : true  
toc_sticky: true
---

## 들어가며

블로그 글을 작성하다보면 주저리 주저리 글을 길게 작성하는것보다 몇단어로 요약된 정보로 보는것이 지식을 습득하는 관점에서는 효과적일수 있습니다.

저는 관심된 내용을 정리하기 위해서 주로 블로그를 작성하지만, 때로는 꼭 이것만큼은 정보로 전달하고 싶다는 생각으로 작성할때도 있지만, 전달을 잘 못하는것 같습니다. 

그럼 좀더 효과적으로 정보를 전달하기 위한 방법은 무엇이 있을까요?
시각적인 요소가 중요한것 같습니다.
대표적으로 시각적인 요소를 효과적으로 표현한 방법은 프레젠테이션(대표적인 도구 : Power Point)인것 같습니다. 

블로그에서 프레젠테이션형식으로 설정하고 작성하는 방법에 대해서 알아보겠습니다. 

## 프레젠테이션 작성 예시 

어떠신가요? 하나의 md파일에서 각 챕터내용을 ppt처럼 보여지도록 설정되었습니다.
전체화면도 가능하고, 전체 슬라이드를 보고 특정 슬라이드로 이동도 가능합니다. 

{% include pptstart.html id="deck1" %}
<section data-markdown>
<textarea data-template>

# 이것은 프레젠테이션 장표입니다.

---

# 타이틀 #1
## 커버닝 메시지


내용1

---
# 타이틀 #2
## 커버닝 메시지 2

내용 2
---

# 슬라이드에서 f를 누르면 전체화면으로 전환됩니다

---

# 슬라이드에서 o를 누르면 슬라이드를 선택할수 있습니다.

---

# 슬라이드에서 s를 누르면 발표자 모드로 변경됩니다. popup을 허용하세요
(embedd모드에서는 적합하지 않네요)

Note:
이 내용은 발표자 노트에만 보입니다.
---

# 슬라이드에서 esc를 누르면 전체화면이 최소됩니다.

---
# End of Documents

</textarea>
</section>
{% include pptend.html id="deck1"%}


## 프레젠테이션 설정 절차 

구글 검색을 하다가 reveal.js를 알게 되었습니다. 
reveal.js 홈페이지에서 가져온(번역) 기능소개 내용입니다.

> reveal.js는 오픈 소스 HTML 프레젠테이션 프레임워크입니다. 웹 브라우저만 있으면 누구나 무료로 완전한 기능을 갖춘 아름다운 프레젠테이션을 만들 수 있는 도구입니다.
> reveal.js로 만든 프레젠테이션은 오픈 웹 기술을 기반으로 구축됩니다. 즉, 웹에서 할 수 있는 모든 것을 프레젠테이션에서도 할 수 있다는 뜻입니다. CSS로 스타일을 변경하고, <iframe>을 사용해 외부 웹 페이지를 포함하거나 JavaScript API를 사용해 사용자 정의 동작을 추가할 수 있습니다.
> 이 프레임워크는 중첩 슬라이드, Markdown 지원, 자동 애니메이트, PDF 내보내기, 발표자 노트, LaTeX 지원 및 구문 강조 코드 등 다양한 기능을 제공합니다.


jekyll기반 블로그에서 reveal.js을 설정하는 방법은 아래 블로그에서 잘 정리되어 있습니다.

- <https://raaaimund.github.io/posts/integrate-reavealjs-in-jekyll-on-github-pages/>{:target="_blank"}

### 프레젠테이션 소스 코드

제 블로그에서는 전체화면으로 보여줄것이 아니고 블로그의 내용중간에 embedded된 형식으로 보여줄것이므로 앞서 블로그 내용에서 설명된 스크립트에서 일부 수정하였습니다. 

{% include codeHeader.html name="_post/2024-06-04-first-ppt.html"%} 
{% raw %}
```html
(생략)

<link rel="stylesheet" href="{{ "/assets/reveal.js/dist/reveal.css" | prepend: site.baseurl }}"/>
<link rel="stylesheet" href="{{ "/assets/reveal.js/dist/theme/black.css" | prepend: site.baseurl }}"/>
<link rel="stylesheet" href="{{ "/assets/reveal.js/plugin/highlight/monokai.css" | prepend: site.baseurl }}"/>

<script src="{{ "/assets/reveal.js/dist/reveal.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/notes/notes.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/markdown/markdown.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/highlight/highlight.js" | prepend: site.baseurl }}"></script>

<div class="reveal deck1 " style="height:300px">
    <div class="slides">
      <section data-markdown>
        <textarea data-template>
          # 이것은 프레젠테이션 장표입니다.
          ---
          # 타이틀 #1
          ## 커버닝 메시지

          내용1

          ---
          # 타이틀 #2
          ## 커버닝 메시지 2

          내용 2
          ---

          # 슬라이드에서 f를 누르면 전체화면으로 전환됩니다

          ---

          # 슬라이드에서 o를 누르면 슬라이드를 선택할수 있습니다.

          ---

          # 슬라이드에서 s를 누르면 발표자 모드로 변경됩니다. popup을 허용하세요
          (embedd모드에서는 적합하지 않네요)

          Note:
          이 내용은 발표자 노트에만 보입니다.
          ---

          # 슬라이드에서 esc를 누르면 전체화면이 최소됩니다.

          ---
          # End of Documents
        </textarea>
      </section>
    </div>
</div>
 
<script>
  let deck1 = new Reveal(document.querySelector('.deck1'), {
    embedded:true,
    hash:true,
    disableLayout: false,
    slideNumber: 'c/t',
    plugins: [RevealMarkdown, RevealHighlight, RevealNotes],
  });

  deck1.initialize(); 
</script>
```
{% endraw %}

프레젠테이션에 필요한 css와 js파일은 reveal.js의 github에서 다운 받습니다. 다운 파일에 있는 dist, plugin폴더를 jekyll blogs의 assets폴더밑에 reveal.js폴더를 새로 만들고, 복사해서 넣습니다.

- <https://github.com/hakimel/reveal.js>{:target="_blank"}


블로그에서 프레젠테이션을 반복적으로 작성할텐데, 너무 부가적인 설정들이 많습니다. 

코드를 반복적으로 사용할수 있도록 템플릿으로 분리해놓으면 좀더 적은 코드로 프레젠테이션 설정작업이 가능할것입니다. 

### 프레젠테이션 코드 템플릿화

앞서 작성된 코드를 jeykll에서 템플릿화하여 분리작업을 합니다. 

1. css와 js호출코드를 header폴더의 custom.html에 넣습니다.
2. pptstart.html를 만들어서 ppt시작을 위한 div 태그를 숨깁니다.
3. pptend.html를 만들어서 나머지 코드(ppt초기화 작업등)를 넣습니다.  

jekyll blogs에서는 ```<head>``` element에 사용자 추가적으로 정의하고 싶은 내용을 넣을때  _includes/header폴더에는 custom.html을 사용합니다. 
custom.html에 css와js 호출코드를 넣습니다. 

프레젠테이션 처음과 끝을 pptstart.html과 pptend.html로 분리하고 md파일에서는 프레젠테이션 장표만 작성하도록 수정합니다. 

#### 1. header/custom.html 수정

_includes/header/custom.html 파일에 css와 js호출 코드를 추가 합니다. 

{% include codeHeader.html name="_includes/header/custom.html"%} 
{% raw %}
```html
<link rel="stylesheet" href="{{ "/assets/reveal.js/dist/reveal.css" | prepend: site.baseurl }}"/>
<link rel="stylesheet" href="{{ "/assets/reveal.js/dist/theme/black.css" | prepend: site.baseurl }}"/>
<link rel="stylesheet" href="{{ "/assets/reveal.js/plugin/highlight/monokai.css" | prepend: site.baseurl }}"/>

<script src="{{ "/assets/reveal.js/dist/reveal.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/notes/notes.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/markdown/markdown.js" | prepend: site.baseurl }}"></script>
<script src="{{ "/assets/reveal.js/plugin/highlight/highlight.js" | prepend: site.baseurl }}"></script>
```
{% endraw %}

#### 2. pptstart.html 추가

_includes폴더 밑에 pptstart.html을 새로 생성합니다. 

여러개의 ppt가 하나의 블로그에 있을수 있으므로 html호출할때 id값을 받아서 처리하도록 include.id를 추가합니다. 해당 id를 이용하여 pptend.html에서 초기화 작업을 수행합니다. 

{% include codeHeader.html name="_includes/pptstart.html"%} 
{% raw %}
```html
<div class="reveal  {{ include.id  }} " style="height:300px">
    <div class="slides">
```
{% endraw %}

#### 3. pptend.html 추가

_includes폴더 밑에 pptend.html을 새로 생성합니다. 

pptstart.html에서 추가한 div태그가 완료되도록 div태그를 닫아줍니다.
초기화 작업을 위하여 pptstart.html에서 설정한 id값을 사용할수 있도록 설정합니다. 

{% include codeHeader.html name="_includes/pptend.html"%} 
{% raw %}
```html
    </div>
</div> 
  
<script>
  let {{ include.id  }} = new Reveal(document.querySelector('.{{ include.id  }}'), {
    embedded:true,
    hash:true,
    disableLayout: false,
    slideNumber: 'c/t',
    plugins: [RevealMarkdown, RevealHighlight, RevealNotes],
  });

  {{ include.id  }}.initialize(); 
</script> 
```
{% endraw %}


#### 4. 블로그 작성 방법

jekyll blogs에서 블로그를 작성할때 아래와 같이 사용합니다. 

내가 프레젠테이션을 넣고 싶은 영역에 pptstart.html과 pptend.html를 include하고 그 사이에 프레젠테이션 장표를 작성합니다. 각 html을 include할때는 동일한 id값을 추가합니다. id의 시작과 끝을 기준으로 프레젠테이션 모드로 작성됩니다. 

{% include codeHeader.html name="_post/2024-06-04-first-ppt.html"%} 
{% raw %}
```html
{% include pptstart.html id="deck1" %}
<section data-markdown>
<textarea data-template>

# 이것은 프레젠테이션 장표입니다.

---

# 타이틀 #1
## 커버닝 메시지


내용1

---
# 타이틀 #2
## 커버닝 메시지 2

내용 2
---

# 슬라이드에서 f를 누르면 전체화면으로 전환됩니다

---

# 슬라이드에서 o를 누르면 슬라이드를 선택할수 있습니다.

---

# 슬라이드에서 s를 누르면 발표자 모드로 변경됩니다. popup을 허용하세요
(embedd모드에서는 적합하지 않네요)

Note:
이 내용은 발표자 노트에만 보입니다.
---

# 슬라이드에서 esc를 누르면 전체화면이 최소됩니다.

---
# End of Documents

</textarea>
</section>
{% include pptend.html id="deck1"%}
```
{% endraw %}


## 마무리

프레젠테이션 모드를 blog에 추가하고 보니 다양한 글들을 작성하고 싶은 동기부여가 되는것 같습니다. 
오픈소스의 js들을 사용하여 나의 blog에 풍부한 사용자 경험을 제공할수 있도록 수정해보니 너무 재미있는것 같습니다. 또한 순전히 자기만족이긴 하지만 변화하고 있다는 생각에 앞으로 더 기대되고 애정을 갖게되는것 같습니다. 

앞으로 더 자주 블로그 작성을 할수 있도록 노력해야겠습니다.

## 참고문서

- <https://revealjs.com>{:target="_blank"}
- <https://raaaimund.github.io/posts/integrate-reavealjs-in-jekyll-on-github-pages/>{:target="_blank"}
- <https://github.com/hakimel/reveal.js>{:target="_blank"}
