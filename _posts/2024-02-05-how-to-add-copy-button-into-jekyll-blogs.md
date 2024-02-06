---
layout: single
title: Github 블로그에 copy-to-clipboard 버튼 추가하기
date: 2024-02-05 21:00
categories: 
  - blogs
author: 
tags: 
  - github
  - blogs
excerpt : Github 블로그에서 copy button 추가하는 방법에 대해서 정리하였습니다.
header :
  teaser: /assets/images/blog/blog1.jpg
  overlay_image: /assets/images/blog/blog1.jpg
toc : true  
toc_sticky: true
---

## 개요

제가 운영하고 있는 블로그는 Jekyll기반의 github blogs입니다. (테마는 [minimal-mistakes](https://mademistakes.com/work/jekyll-themes/minimal-mistakes/){:target="_blank"}를 사용합니다. )

블로그 내용에 코드 작성을 하다보면 누구나도 쉽게 코드 복사를 할수 있도록 copy button이 있으면 좋겠다는 생각을 했습니다. 

Copy Button이용하면 간단하게 마우스 클릭만으로 실습 할수 있는 유형의 글을 작성하고 싶었습니다.(실제해보는것이 중요하죠)

## Copy button 추가 절차

Copy-to-Clipboard 버튼 추가작업은 아래 블로그 내용을 참고해서 스타일은 수정하고 파일명이 나오도록 기능 개선했습니다.

- 원문(How to Add a Copy-to-Clipboard Button to Jekyll) - <https://www.aleksandrhovhannisyan.com/blog/how-to-add-a-copy-to-clipboard-button-to-your-jekyll-blog/>{:target="_blank"}

Copy button을 추가하는 절차는 아래와 같습니다. 

1. 자주 사용하는 Copy Button을 템플릿으로 저장합니다.
2. Copy Button에 Stlye을 적용합니다.
3. Copy Button을 클릭하면 copy되도록 Javascript을 추가합니다.
4. 코드 복사 필요한 영역위에 생성한 템플릿을 include합니다.

### 1. 자주 사용하는 Copy Button을 템플릿으로 저장합니다.

_includes 폴더에 codeHeader.html 파일을 새로 생성하고 아래 내용을 입력합니다.
( _incldes/codeHeader.html )

{% include codeHeader.html name="/_incldes/codeHeader.html"%} 
{% raw %}
```html
<div class="code-header">  
    {% if include.name %}
        <div class="copy-code-name">📂 {{ include.name  }}</div>
    {% endif %}
    <button class="copy-code-button" title="Copy text to clipboard">Copy</button>
</div>
```
{% endraw %}

### 2. Copy Button에 Stlye을 적용합니다. 

_sass 폴더밑에  _page.scss 파일에 스타일을 추가합니다.
저는 minimal-mistakes 테마를 적용하여 _sass/minimal-mistakes/_page.scss 파일에 추가했습니다.

{% include codeHeader.html name="/_sass/minimal-mistakes/_page.scss" %} 
```css
.copy-code-button {
  float: right;
  cursor: pointer;
  font-size: 14px;
  font-weight: 50;
  text-align: center;
  padding: 5px 5px;
  background-color: #fff;
  color: #100f0e;
  border: 2px solid #dedad6;
  min-width: 60px;
  margin-top: -40px;
}

.copy-code-button:hover
{
  color: #fcfbfa;
  background-color: #45413e;
}

.copy-code-name{
  font-size: 14px;
  padding: 5px 5px;
}
```

### 3. Copy Button을 클릭하면 copy되도록 Javascript을 추가합니다. 

assets/js 폴더에 copyCode.js 파일을 새로 생성합니다. (assets/js/copyCode.js)

{% include codeHeader.html name="/assets/js/copyCode.js"%} 
```js
// This assumes that you're using Rouge; if not, update the selector
const codeBlocks = document.querySelectorAll('.code-header + .highlighter-rouge');
const copyCodeButtons = document.querySelectorAll('.copy-code-button');

copyCodeButtons.forEach((copyCodeButton, index) => {
  const code = codeBlocks[index].innerText;

  copyCodeButton.addEventListener('click', () => {
    // Copy the code to the user's clipboard
    window.navigator.clipboard.writeText(code);

    // Update the button text visually
    const { innerText: originalText } = copyCodeButton;
    copyCodeButton.innerText = 'Copied!';

    // (Optional) Toggle a class for styling the button
    copyCodeButton.classList.add('copied');

    // After 2 seconds, reset the button to its initial UI
    setTimeout(() => {
      copyCodeButton.innerText = originalText;
      copyCodeButton.classList.remove('copied');
    }, 2000);
  });
});
```

생성한 javascript을 호출될수 있도록 footer에 넣습니다. 

footer로 _include/footer/cutstom.html 파일을 사용했습니다.
마지막에 javascript가 호출되어야 앞단에 어떤 class가 사용되었는지 javasript에서 인식됩니다.

{% include codeHeader.html  name="/_include/footer/cutstom.html"%} 
```html
<script src="/assets/js/copyCode.js"></script>
```

### 4. 코드 복사 필요한 영역위에 생성한 템플릿을 include합니다. 
 
Code block을 copy하기 위해서 button을 아래와 같이 추가합니다.

{% raw %}
````markdown
{% include codeHeader.html name="file-name" %}
```someLanguage
code goes in here!
```
````
{% endraw %}

위 코드를 그대로 사용하면 아래와 같이 화면에 렌더링 됩니다. 

{% include codeHeader.html name="file-name" %}
```markdown
code goes in here!
```

## 마무리

Github 블로그에서 Copy button추가하는 방법에 대해서 알아보았습니다.

본 글에도 Copy Button 추가하여 작성되었습니다.

Code block을 쉽게 Copy할수 있는 버튼을 제공하면 
사용자 관점, 활용 관점에서 좀더 유용한 블로그가 되지 않을까 싶습니다. 


## 참고자료

- How to Add a Copy-to-Clipboard Button to Jekyll - <https://www.aleksandrhovhannisyan.com/blog/how-to-add-a-copy-to-clipboard-button-to-your-jekyll-blog/>{:target="_blink"}
- markdown_supported_languages - <https://github.com/jincheng9/markdown_supported_languages>{:target="_blink"}