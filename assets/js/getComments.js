// 함수를 정의하여 인자로 받은 값으로 처리
$(document).ready(function() {

    var repository = "kosate/comments";
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