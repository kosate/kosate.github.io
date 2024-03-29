---
layout: single
title: 시스템 트레이딩을 위한 데이터 수집방안
date: 2023-09-15 08:00
categories: 
  - system-trading
books:
 - system-trading
author: 
tags: 
   - bitcoin
   - system trading
excerpt : 시스템 트레이딩 기능중 가장 기본이 되는 데이터 수집방안에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/trading-logic.jpg
  overlay_image: /assets/images/blog/trading-logic.jpg
toc : true  
toc_sticky: true 
---

**참고사항** 시스템 트레이딩 관련 블로그들은 개인 경험을 바탕으로 작성되었습니다. 각자 자신만의 투자방식과 매매전략을 만들어 가시기 바랍니다.
{: .notice} 

## 개요

시스템 트레이딩을 시작할 때 가장 먼저 해야 할 일은 데이터를 수집하는 것입니다. 당장 매매 방법을 찾는 사람들도 있겠지만, 검증되지 않은 매매 전략은 결코 살아남을 수 없습니다. 항상 나보다 뛰어난 사람이나 나보다 운이 더 좋은 사람이 있다는 것을 명심하고 모든 것을 철저히 확인하는 자세가 필요합니다.

## 데이터 수집을 시작합니다.

먼저 데이터를 수집하는 방법을 찾아보겠습니다. 가산자산 거래소의 경우 홈페이지에서 API를 제공하고 있습니다. 업비트(Upbit)를 예시로 설명하겠습니다. (가장 오래된 데이터를 제공하는 것으로 알려져 있습니다.)

업비트에서는 캔들 데이터를 인증 없이 조회할 수 있습니다. 먼저 업비트 개발자 센터(<https://docs.upbit.com/>)로 이동합니다. 상단 메뉴에서 "API Reference"를 클릭합니다.

왼쪽메뉴를 보면 Exchange API, Quotation API, Websocket 로 구분되어 있습니다. 

- Exchange API(Private 데이터)
  - 자산 조회 및 주문, 출금, 입금 작업이 가능합니다.
  - 이러한 정보들은 개인 정보이므로 인증이 필요합니다. 로그인 후 Open API 관리 화면에서 개인 Key(Access Key, Secret Key)를 받아야 합니다.
  - Rest API 조회 시 JWT 인증 토큰을 사용하여 데이터를 요청해야 합니다.
- Quotation API (Public 데이터)
  - 시세종목, 캔들(봉), 체결, 현재가 ,호가 정보를 제공합니다.  
  - 별도의 인증없이 데이터를 조회할 수 있습니다.
- Websocket (Private,Public 데이터 )
  - 현재가, 체결, 호가, 내 체결정보등을 제공합니다. 
  - 데이터를 실시간으로 받을수 있습니다.  
  - 내체결에 대한 데이터를 실시간으로 받기 위해서는 인증정보가 필요합니다.

캔들 데이터를 수집하기 위해 Quotation API를 이용하겠습니다. 다음은 4시간 간격의 캔들(봉) 데이터를 조회하는 예시입니다. 현재 시간을 기준으로 200개의 캔들 데이터(비트코인)를 요청하는 URL입니다. 브라우저에서 주소를 입력하면 데이터를 확인할 수 있습니다.

```
https://api.upbit.com/v1/candles/minutes/240?market=KRW-BTC&count=200
```
※ 가산자산 거래소에는 마켓이란 개념이 있습니다. KRW는 원화 마켓, BTC는 비트코인 마켓, USDT는 USDT스테이블 코인 마켓입니다. 앞에 마켓명이 붙고 뒤에 각 코인의 코드가 붙게 됩니다. KRW-BTC는 원화 마켓의 비트코인을 의미합니다.

API 문서를 참고하면 더 자세한 정보를 확인할 수 있습니다. Shell, Node, Ruby, PHP, Python 예제도 제공하고 있습니다.

API 참고 문서 : <https://docs.upbit.com/reference/분minute-캔들-1>

## 데이터 수집 방법

캔들 데이터를 조회하기 위해서는 먼저 종목 코드(마켓)가 필요합니다. 종목 목록을 가져온 다음, 각 종목별로 캔들 데이터를 조회하여 데이터를 수집할 수 있습니다.

- 데이터 수집 대상 
  - 종목리스트 (예시 https://api.upbit.com/v1/market/all)
  - 종목별 캔들데이터 (예시 https://api.upbit.com/v1/candles/minutes/240?market=KRW-BTC)

다음은 Pseudo 코드입니다.
```java
var 종목리스트 =  종목리스트조회(https://api.upbit.com/v1/market/all)
for 종목 in 종목리스트 loop
  var 캔들데이터 = 캔들데이터조회(https://api.upbit.com/v1/candles/minutes/240?market=종목.종목코드&count=200)
  캔들데이터를 저장소에 저장   
end loop
```
각자 자신에게 맞게 프로그래밍을 하시면 됩니다.

데이터를 수집하다가 에러가 발생할 수 있는데, 그 중 하나는 Rest API 요청에 대한 제한입니다. 증권사와 가산 자산 거래소는 무분별한 요청으로부터 시스템을 보호하기 위해 요청에 대한 제한을 관리하고 있습니다.

업비트의 경우 QUOTATION API 중 Rest API 요청 수 제한은 초당 10회, 분당 600회로 되어 있습니다.
참고문서 - <https://docs.upbit.com/docs/user-request-guide>

위의 Pseudo 코드에서 보신 것처럼 종목 목록으로 Loop가 돌게 된다면 제한 요청 건수를 초과할 수 있습니다. 그렇기 때문에 중간에 sleep을 주는 코드가 추가되어야 합니다. 몇 번의 요청마다 한 번씩 sleep을 주거나, HTTP Header 부분에 "Remaining-Req" 값을 확인해서 sleep을 줄 수 있습니다.

Rest API로부터 받은 데이터는 JSON 형식입니다. JSON을 Parsing해서 원하는 데이터를 저장할 수 있습니다. 

- 데이터별 상세정보 
  - 종목리스트  (마켓, 자산한글명, 자산영문명, 유의종목여부)
  - 캔들데이터  (마켓, 캔들기준시각, 시가, 고가, 저가, 종가, 누적거래량, 누적거래금액)

이러한 데이터는 추후에 백테스트에서 다시 읽어야 하므로 관리하기 쉬운 방식으로 데이터를 관리해야 합니다. 파일로 저장하거나 데이터베이스로 관리하면 편리할 것 같습니다.

## 과거 데이터 수집 방안

시스템 트레이딩을 위해 데이터를 수집할 때, 처음에는 가능한 모든 과거 데이터를 수집하는 것이 좋습니다. 이후 일주일에 한 번씩 수집하면서 일주일 동안 발생한 데이터를 추가로 관리할 수 있습니다.

- 과거 데이터 수집방법
  - 종목 데이터의 과거 데이터는 가상 자산 거래소에서 제공하지 않습니다. 따라서 가능하면 가산 자산 거래소의 공지사항을 확인하여 종목이 상장 폐지되기 전에 종목 코드와 캔들 데이터를 미리 수집하는 것이 좋습니다.
  - 캔들 데이터는 현재 종목을 기준으로 과거 데이터를 제공합니다. 과거 데이터를 조회하는 방법은 현재 기준에서 200개를 수집하고, 수집된 데이터 중 가장 오래된 캔들의 캔들 기준 시각을 가져와서 다시 캔들 데이터를 조회할 때 변수로 사용하면 과거 데이터를 계속 수집할 수 있습니다.

다음은 캔들 데이터를 수집하는 Pseudo 코드입니다.
```java
var 종목코드 =  KRW-BTC
var 마지막캔들기준시각 = 현재시각
loop
  var 캔들데이터 = 캔들데이터조회(https://api.upbit.com/v1/candles/minutes/240?market=종목코드&count=200&to=마지막캔들기준시각)
  캔들데이터를 저장소에 저장()
  마지막캔들기준시각 = 캔들데이터에서 가장 오래된 캔들에서 기준시각을구함
end loop
```

업비트 가상 자산 거래소는 서비스를 시작한 2017년까지의 데이터를 수집할 수 있습니다.

유동성이 높은 가상 자산 시장에서는 유의종목에 대해서는 거래하지 않도록 매매 로직에 변수로 포함시킬수 있습니다. 그러나 유의종목에 대해서는 API로 제공되지 않기 때문에 데이터를 미리 수집해서 백테스트 시에 검증할 수 있도록 관리해야 합니다. 유의종목의 이력은 업비트의 공지사항에서 확인할 수 있습니다. 필요하다면 이러한 방식으로 데이터를 수집할 수 있으니 참고하시면 좋을 것 같습니다.

## 마무리

 종목 리스트를 활용하여 캔들 데이터를 수집하는 방법에 대해 설명했습니다. 몇몇 부분은 개념적으로 설명되어 있어 처음에는 이해하기 어려울 수 있습니다. 그러나 데이터를 수집하는 과정과 중요성에 대한 기본적인 이해는 얻으셨을 것으로 기대됩니다.

한번 데이터를 수집하고 나면, 이후에는 원하는 로직을 테스트할 수 있게 됩니다.

시스템 트레이딩을 시작하면 계속해서 질문을 하게 될것입니다. "어떤 데이터를 기반으로 매매 신호를 판단해야 할까요?" 그런 기준에서 시장에서 찾아볼 수 있는 로직들을 보면 모호하게 느껴질 수 있습니다.

트레이딩은 컴퓨터가 자동으로 수행하겠지만, 그 기준은 우리가 정합니다. 그리고 그 기준은 데이터에서 출발하니 데이터를 수집할수 있는 시스템을 만들어 보셨으면 좋겠습니다.