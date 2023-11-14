---
layout: single
title: 23c신기능 - Automatic Transaction Rollback 
date: 2023-10-26 02:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - 23c
   - Automatic Transaction Rollback
excerpt : 오라클데이터베이스의 신기능인 Automatic Transaction Rollback기능에 대해서 정리하였습니다.
header :
  teaser: /assets/images/blog/oracle23c.jpg
  overlay_image: /assets/images/blog/oracle23c.jpg
toc : true  
toc_sticky: true
---

## 개요

업무를 처리할때 데이터베이스 Lock때문에 고생한적이 있었습니다.
Lock이 왜 발생했고, 동일한 row에 왜 변경요청을 했는지 분석하는 작업을 하는데요.
결국 애플리케이션 로직상에서 해결방법을 찾아야했습니다.

중요 업무를 우선 처리할수 있도록 트랜잭션 우선순위를 설정하는 기능이 오라클 23c에 추가되었습니다.
(23c FREE버전에서는 기능 제약으로 테스트가 되지 않습니다.)

## Automatic Transaction Rollback(이하 ATR) 이란?

Lock이 발생했을때 회피할수 있는 방법은 Lock을 선점한 세션의 트랜잭션이 끝나기를 바랄수 밖에 없습니다. 혹은 Lock Holder세션을 찾아서 kill을 해서 트랜잭션을 강제 rollback시켜 조치할수 있습니다.

사실 ATR 기능도 여기서 크게 벗어 나지 않습니다.
ATR은 트랜잭션의 우선순위를 설정해서, 만약 Lock Holder가 Waiter 세션보다 하위 순위 트랜잭션일경우 Lock holder를 강제 세션종료시켜 rollback하는 기능입니다.

### 동작 방식

트랜잭션 우선순위를 비교후에 하위 트랜잭션이 Lock을 선점하고 있으면 하위 트랜잭션의 세션을 강제 종료시켜 rollback시키고 자신의 트랜잭션을 처리합니다.

### 관련 DB 파라미터

ATR관련 DB 파라미터를 보시면 기능에 대해서 쉽게 이해할수 있습니다.
세션레벨과 시스템레벨에서 설정할수 있는 DB파라미터가 있습니다.

- 세션레벨(session level) 
  - txn_priority : 세션레벨에서 트랜잭션의 우선순위를 지정합니다. 기본 HIGH이며, HIGH/MEDIUM/LOW로 설정할수 있습니다.
- 시스템레벨(system level)
  - txn_auto_rollback_mode : ROLLBACK/TRACK으로 설정할수 있습니다. ROLLBACK는 ATR기능이 사용되는것이고, TRACK은 ATR사용전에 어느 세션에 영향이 가는지 분석하기 위한 설정입니다.
  - txn_auto_rollback_high_priority_wait_target : 트랜잭션 우선순위가 HIGH인 세션이 하위 순위(MEDIUM or LOW)를 만났을때 얼마나 대기할지 시간(sec)을 설정합니다.
  - txn_auto_rollback_medium_priority_wait_target : 트랜잭션 우선순위가 MEDIUM인 세션이 하위 순위(LOW)를 만났을때 얼마나 대기할지 시간(sec)을 설정합니다.
  
오라클 23c에 접속해서 DB 파라미터를 조회하면 다음과 같습니다.
```sql
SQL>  show parameter txn
NAME                                          TYPE        VALUE
--------------------------------------------- ----------- ------------------------------
txn_auto_rollback_high_priority_wait_target   integer     2147483647
txn_auto_rollback_medium_priority_wait_target integer     2147483647
txn_auto_rollback_mode                        string      ROLLBACK
txn_priority                                  string      HIGH
```

기본값을 설정된 DB에서는 모든 세션의 트랜잭션 우선순위가 HIGH로 설정되어 있으므로 Rollback이 되지 않습니다.
즉 기존 운영하던 방식대로 Lock이 발생되면 Waite세션은 대기하게 됩니다.

## 테스트 예시

23c FREE에서는 ATR 기능 테스트를 할수 없어 블로그 내용을 인용하였습니다.(23c 공식버전이 나오면 테스트후에 업데이트하겠습니다.)
- 참고 문서 : <https://blogs.oracle.com/coretec/post/automatic-transaction-rollback-in-23c>

```sql
-- 시스템레벨로 Lock대기시간을 20초로 설정
SQL> alter system set txn_auto_rollback_high_priority_wait_target = 20;

-- 세션1(low)에서 업데이트 수행
SQL#1>alter session set txn_priority = low;
SQL#1>select sys_context('userenv','SID');
-----------------------------
43

SQL#1>update scott.mycheck set value=0; 
1 rows updated.

-- 세션2(high)에서 업데이트 수행시 20초대기후 완료
SQL#2>alter session set txn_priority = high;
SQL#2>select SYS_CONTEXT('USERENV','SID')
----------------------------
32

SQL#2>update scott.mycheck set value=1000;
-- maximum wait time 20 seconds
1 rows updated.

-- 세션1(low) 종료되어 rollback됨
SQL#1> select sysdate;
select sysdate
*
ERROR at line 1:
ORA-03113: end-of-file on communication channel
Process ID: 33042
Session ID: 43 Serial number: 59494
```

동일한 row에 대해서 Lock경합이 발생될경우 하위 순위 트랜잭션은 rollback되고 상위 순위 트랜잭션은 wait time후에 처리되는것을 확인할수 있습니다. 

## 적용절차 및 고려사항

23c FREE에서는 ATR 기능 테스트를 할수 없어 예상되는 적용절차에 대해서 정리해보았습니다. (23c 공식버전이 나오면 테스트후에 업데이트하겠습니다.)

1. 트랜잭션 우선순위 설정
   - 업무별로 우선순위를 지정해야합니다. 물론 모든 업무가 중요하겠지만 내부 업무 중요도를 고려하여 트랜잭션 우선순위를 지정해야합니다. 우선순위는 HIGH, MEDIUM, LOW가 있습니다.
     ```sql
    alter session set txn_priority = high|medium|low;
      ```
   - MEDIUM, LOW 트랜잭션의 경우 ROLLBACK이 되었을 경우 재처리를 위한 로직을 구현해야합니다.
2. 영향도 평가 
   - txn_auto_rollback_mode를 track으로 설정하여 트랜잭션 영향도를 확인합니다. system 통계값을 통해 적정 waite시간을 구할수 있습니다.
    ```sql
    select name from V$SYSSTAT where  name like '%txns track mode%';
    txns track mode txn_auto_rollback_high_priority_wait_target
    txns track mode txn_auto_rollback_medium_priority_wait_target
    ```
3. ATR기능 설정(파라미터설정)
   - txn_auto_rollback_mode를 rollback를 설정후에 wait target시간을 설정합니다.
    ```sql
    alter system set txn_auto_rollback_high_priority_wait_target = 20;
    alter system set txn_auto_rollback_mode = rollback;
    ```
4. 모니터링 
   - system 통계값을 조회하면 ATR이 얼만큼 적용되었는지 확인할수 있습니다. 
   ```sql
   select name from  V$SYSSTAT where  name like '%txns rollback%';
   txns rollback txn_auto_rollback_high_priority_wait_target
   txns rollback txn_auto_rollback_medium_priority_wait_target 
   ```
   - ATR이 적용되어 세션이 rollback된 정보는 alert.log에서 확인할수 있습니다.
   - ATR이 적용되어 wait하는 세션의 wait event는 아래와 같습니다.
     - HIGH우선순위 세션 - enq:TX - row lock contention (HIGH pri)
     - MEDIUM우순선위 세션 - enq: TX - row lock contention (MEDIUM pri)
     - LOW우선순위 세션 - enq: TX - row lock contention (LOW pri)

## 마무리

트랜잭션 우선순위를 지정하여 처리할수 있는 방법에 대해서 정리하였습니다.
가장 고민이 많은 부분은 하위순위 트랜잭션이 rollback(세션이 중지되었을때)이 되었을때의 재처리 방안이 될것 같은데요, 애플리케이션에서 자동으로 트랜잭션를 replay해줄수 있는 Application Continuity라는 기능을 검토해보시면 좋을것 같습니다. (JDBC Driver, .NET Managed Driver 모두 지원합니다.)

## 참조문서

- Documents
  - [Database Reference - 2.401 TXN_AUTO_ROLLBACK_MODE](https://docs.oracle.com/en/database/oracle/oracle-database/23/refrn/TXN_AUTO_ROLLBACK_MODE.html)
- Blogs
  - [Automatic transaction rollback in 23c with high, medium and low priority transactions](https://blogs.oracle.com/coretec/post/automatic-transaction-rollback-in-23c) 
