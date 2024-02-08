---
layout: single
title: 시스템트레이딩 개발하기 
book: system-trading
date: 2023-09-17 11:00
categories: 
  - bitcoin
author: 
tags: 
   - bitcoin
   - system trading
excerpt : 시스템트레이딩 구축시 고려사항에 정리하였습니다.
header :
  teaser: /assets/images/blog/system-trading.jpg
  overlay_image: /assets/images/blog/system-trading.jpg
comments: true
---

**참고사항** 시스템 트레이딩 관련 블로그들은 개인 경험을 바탕으로 작성되었습니다. 각자 자신만의 투자방식과 매매전략을 만들어 가시기 바랍니다.
{: .notice} 

## 개요 

시스템 트레이딩(자동 거래) 개발을 위한 고려사항 및 구성방안에 대해서 정리하고 있습니다.
로직의 의미을 담고 있는 의미(Pseudo) 코드을 제공하여 좀더 쉽게 시스템 트레이딩에 접근할수 있도록 작성하고 있습니다. 

용어나 문맥상 이상한 부분이 있겠지만 추후에 내용이 통일되도록 업데이트할 예정입니다.

## 거래 환경 
 
 - 가상자산거래소 : 업비트(<https://www.upbit.com>{: target="_blank"}), 현물거래(원화마켓), 24시간 거래지원
 - 트레이딩 방식 : 스윙 트레이딩 

## 목차

- [시스템 트레이딩 구축시 고려사항](/blog/system-trading/how-to-begin-system-trading/){: target="_blank"}
- 시스템 트레이딩 구성방안
  - [데이터 수집방안](/blog/system-trading/how-to-collect-candle-data/){: target="_blank"}
    - (작성예정)데이터 저장 형식(json) 
  - [백테스트 방안](/blog/system-trading/first-backtest-for-systemtrading/){: target="_blank"}
    - [구성요소(종목객체과 종목그룹객체)](/blog/system-trading/how-create-stock-obj/){: target="_blank"} 
      - [지표관리방안](/blog/system-trading/how-to-deal-with-indicator/){: target="_blank"} 
      - [매매관리방안](/blog/system-trading/how-to-manage-trade/){: target="_blank"} 
    - [구성요소(자금관리자객체)](/blog/system-trading/how-to-manage-your-invest/){: target="_blank"} 
  - [매매처리 방안](/blog/system-trading/how-to-make-trading-logic/){: target="_blank"}
  - (작성예정)실전거래 방안
- 시스템 트레이딩 매매방안
  - (작성예정)추세추종 매매전략 적용예시 및 결과

## 마무리 
계속 업데이트 됩니다.