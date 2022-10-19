---
layout: single
title: 가상자산의 변동성은?
date: 2022-05-02 16:46
category: 
  - bitcoin
author: 
tags: ['비트코인', '가상자산', '트레이딩','변동성','업비트']
summary: 변동성을 이용한 트레이딩 전략
toc: true
---


가상자산의 변동성은?
----

※ 저는 가상자산 전문가도, 금융전문가도 아닙니다. 단지 궁금한 부분에 대해서 데이터 기반으로 테스트해보고 그 내용을 공유하고자 합니다. 

가상자산의 1세대코인는 비트코인입니다. 그뒤로 이더리움을 비롯하여 2세대코인이 나오고, 알트코인들이 우우죽순 나오고 있습니다. 
업비트 거래소기준 원화마켓에서는 금일(5월 13일) 114개의 코인이 있으며, 빗썸 거래소기준 원화마켓에는 개의 코인이 있습니다.

비트코인이 대장주이기 때문에 하루의 변동성이 5%넘기기 힘듦니다. 그러나 알트코인들은 변동성이 10%이상 넘을 때가 많습니다. 
하나의 코인에 잘못들어가면 어마한 손실이 발생될수 있지만, 이익실현을 할수 있겠죠.손실 방지를 위한 최선의 방법은 분산투자입니다.

여기서 먼저 개별 코인의 변동성에 대해서 확인해보겠습니다. 

> 개별 코인의 변동성은 어느정도 될것인가??

아래 그래프를 보셨듯이 최소는 OO,최대 OO 그리고 평균 OOOO 의 변동성을 보이고 있습니다.

개별의 코인의 변동성은 크지만 현물주식의 테마처럼 비트코인이라는 가상자산 대장주와 같은 추이로 수렴합니다.

> 코인들의 추이는 어떠한가?

그래서 아이디어로 **가상자산의 변동성을 이용한다면 수익이 나는 매매가 가능하지 않을가?** 라는 생각입니다. 최대 손실폭(MDD)는 모르겠지만요..

> 비트코인의 변동성보다 알트 코인의 변동성이 더 크다.
> 가상자산의 시장은 추세를 가지고 있다. 
> ㅇㅇ  


그럼 트레이딩 전략은?
---

> 매수 금액 : 코인별 10만원
> 부하 분산 : 모든 코인
> 전체 투자 비용 : 1140만원 (114개종목 * 10만원)

시물레이션 결과는?
---


<div id="chart_div"></div>
<script defer type="text/javascript">
    console.log("start load");
    // Load the Visualization API and the corechart package.
    google.charts.load('current', {'packages':['corechart']});
    // Set a callback to run when the Google Visualization API is loaded.
    google.charts.setOnLoadCallback(drawChart);
    // Callback that creates and populates a data table,
    // instantiates the pie chart, passes in the data and
    // draws it.
    function drawChart() {
    console.log("loaded");
    // Create the data table.
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Topping');
    data.addColumn('number', 'Slices');
    data.addRows([
        ['Mushrooms', 3],
        ['Onions', 1],
        ['Olives', 1],
        ['Zucchini', 1],
        ['Pepperoni', 2]
    ]);
    // Set chart options
    var options = {'title':'How Much Pizza I Ate Last Night',
                    'width':400,
                    'height':300};
    // Instantiate and draw our chart, passing in some options.
    var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
    chart.draw(data, options);
    }
</script>