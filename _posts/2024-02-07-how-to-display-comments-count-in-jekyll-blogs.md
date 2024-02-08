---
layout: single
title: Github 블로그에 Comment 개수 표시하기
date: 2024-02-07 21:00
categories: 
  - blogs
author: 
tags: 
  - github
  - blogs
excerpt : Github 블로그에서 댓글 개수를 표시하는 방법에 대해서 정리했습니다.
header :
  teaser: /assets/images/blog/blog1.jpg
  overlay_image: /assets/images/blog/blog1.jpg
toc : true  
toc_sticky: true
---

## 개요

제가 운영하고 있는 블로그는 Jekyll기반의 github blogs입니다. (테마는 [minimal-mistakes](https://mademistakes.com/work/jekyll-themes/minimal-mistakes/){:target="_blank"}를 사용합니다. )

댓글 작성기능은 utterances를 이용하여 GitHub의 issue기능으로 작성되도록 설정하였습니다. 

utterances를 이용한 댓글 설정방법은 다른 블로그를 참고하였습니다. 
- [[Github 블로그] utterances 으로 댓글 기능 만들기](https://ansohxxn.github.io/blog/utterances/){:target="_blank"}

각 블로그글들은 GitHub의 Issue와 연결되고 블로그에 있는 댓글들은 Issue에 있는 Comments로 저장됩니다.
GitHub blogs에서 GitHub api를 호출하면 댓글 개수를 가져올수 있겠죠.

## 댓글 개수 표시 절차 

댓글 표시 되는 영역을 추가하고, 댓글 개수 표시를 위하여 JQuery로 GitHub api를 호출했습니다. 

댓글 개수 표시하는 절차는 아래와 같습니다. 

1. 댓글 개수 표시하는 영역을 만듭니다.
2. JQuery로 데이터 가져와서 댓글 태그에 표시하는 javascript를 추가합니다.

생각보다 간단합니다. 

### 1. 댓글 개수 표시하는 영역을 만듭니다.

보통 블로그 글에는 메타정보로 read time, created date 정보가 같이 표시됩니다. 
메타 정보에 댓글 개수 표시 영역(class="page__meta-comments")을 추가합니다. 

_include 폴더에 메타정보만 표시하는 page_meta.html파일이 있습니다. 
맨밑에 아래 내용을 추가합니다. 

{% include codeHeader.html name="/_include/page_meta.html"%} 
{% raw %}
```html
<!--- 댓글 개수 표시 -->
{% if document.comments  %}<span class="page__meta-sep"></span>{% endif %}
{% if document.comments %}
    <span class="page__meta-comments">
      <i class="far fa-fw fa-comment-dots" aria-hidden="true"></i>
      <span class="comment_count" pathname="{{ document.id }}">0</span> Comments
    </span>
{% endif %}
```
{% endraw %}

### 2. JQuery로 데이터 가져와서 댓글 태그에 표시하는 javascript를 추가합니다.

JQuery를 사용하면 쉽게 Github API를 호출할수 있고, HTML내 태그들을 쉽게 찾을수 있습니다. 
Github API호출할때 GitHub Repository를 지정해야합니다. 이 repository는 댓글 작성을 위한 github repository를 의미합니다.
_config.yml 파일에 있는 repository 정보와 동일합니다. 

아래 스크립트에서 Repository를 수정한다음
assets/js 폴더에 getComments.js 파일을 새로 생성합니다. (assets/js/getComments.js)

{% include codeHeader.html name="/assets/js/getComments.js"%} 
```js
// 화면이 다 표시되고나서 API호출함
$(document).ready(function() {

    var repository = "댓글용 repository";
    $.ajax({
    url: "https://api.github.com/repos/" + repository+"/issues",
    type: 'GET', 
    dataType: "json",
    success: function(data) {

        var issueDataMap = new Map();
        // 조회 건수가 있으면
        if (data.length > 0) {
            // 각 이슈의 제목과 댓글 수 출력
            for (var i = 0; i < data.length; i++) {
                var issueTitle = data[i].title;
                var commentsCount = data[i].comments;

                // Map에 저장
                issueDataMap.set("/"+issueTitle, commentsCount);
            }
          
            // comment_count 클래스 내의 모든 객체 가져오기. 
            var countTags = $('.comment_count');  
            
            for (var i = 0; i < countTags.length; i++) {
                var key = countTags.eq(i).attr('pathname')+"/";
 
                var value = issueDataMap.get(key); 
                // value가 undefined인 경우 0으로 대체
                if (value === undefined) {
                    value = 0;
                }
 
                // 해당 이슈의 댓글 수를 표시
                countTags.eq(i).text(value); 
            }
        }
    },
    error: function(error) {
        console.error('이슈 검색 실패:', error);
    }
    });

});
```

생성한 javascript을 호출될수 있도록 footer에 넣습니다. 

footer로 _include/footer/custom.html  파일을 사용했습니다. 
해당 파일에 JQuery와 getComments.js 스크립트를 추가합니다.

{% include codeHeader.html name="/_include/footer/custom.html "%} 
```html
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
<script src="/assets/js/getComments.js"></script>
```

자~ 모두 완료가 되었습니다. 

모든 페이지를 호출할때마다 GitHub API를 호출합니다. 
그리고 페이지내에 meta정보를 보여주는 영역이 있으면 댓글 개수도 같이 표기 됩니다. 
제 블로그에서 확인해보세요.

## 마무리

javascript를 공부해보지 않았지만, ChatGPT를 통해서 물어서 작성하였습니다. 
각 화면의 영역들은 firefox와 같은 브라우저내 개발자도구를 이용하여 어떻게 보이는지, Javascript가 어떻게 호출되고, 어떤 에러가 나는지도 확인했습니다. 

생각보다 단순하게 많은 노력없이도 쉽게 구현했던것 같습니다. 

GitHub Blogs는 stateless(상태값이 없음)로 구현되죠. 데이터저장소에 질의를 통해서 화면을 만드는것이 아니라, 이미 만들어진 데이터만을 가지고 화면에 보여집니다. 만약 외부 서비스(데이터제공하는)와 연계시킨다면 GitHub Blog내 생각보다 더 다양한 페이지들을 만들수 있다는 생각이 들었습니다. 

## 참고자료

- GitHub REST API 문서 - <https://docs.github.com/en/rest>{:target="_blank"}
- Comments 아이콘으로 사용했던 폰트입니다 - <https://fontawesome.com/v5/search?o=r&m=free>{:target="_blank"}

