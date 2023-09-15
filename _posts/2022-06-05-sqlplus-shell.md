---
layout: single
title: 다양한 sqlplus 실행 방안
date: 2022-06-05 21:58
categories: 
  - Oracle
author: 
tags: 
   - shell
   - sqlplus
excerpt : sqlplus을 호출하는 여러가지 방법에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/sqlplus.jpg
  overlay_image: /assets/images/blog/sqlplus.jpg
toc : true
toc_sticky: true
---

## 개요

Shell스크립트에서 sqlplus을 호출하는 여러가지 방법에 대해서 정리했습니다. 
예를 들어 부하테스트를 할경우 여러개의 세션에서 동시에 SQL을 실행하거나, 루프를 돌면서 반복으로 실행될수 있습니다.
그러한 요건에서 Shell 스크립트를 통해서 sqlplus를 호출하여 실행할수 있습니다.

## CASE #1)  SQL파일을 sqlplus 인자로 넣어서 실행

- 장점 : SQL파일과 Shell구문 분리되어있어서 SQL구문 변경시 sql파일만 수정하면 됨.
- 단점 : while 구문으로 반복적으로 수행시 세션이 반복적으로 접속되므로 logon에 대한 overhead가 존재함.

```sql
$> cat sysdate.sql
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select sysdate from dual;
exit; 
$> while true
do 
sqlplus -s scott/tiger @sysdate.sql
sleep 1
done
```


## CASE #2) Shell에서 SQL구문을 지정해서 sqlplus를 실행 

- 장점 : shell 스크립트내에서 SQL구문을 만들게 되므로 SQL구문사이로 shell 변수를 사용하기 편리함.
- 단점 : while 구문으로 반복적으로 수행시 세션이 반복적으로 접속되므로 logon에 대한 overhead가 존재함. SQL구문변경을 위해서는 shell스크립트를 직접 수정해야하고 재 실행해야함.
 
```sql
$> while true 
do
sqlplus -s scott/tiger << EOF
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select sysdate from dual;
exit;
EOF
sleep 1
done
```
 
## CASE #3) Shell에서 SQL구문을 만들어서 sqlplus에게로 전달 
- 장점 : while 구문으로 반복적으로 수행시 "접속된 하나의 세션"에서 SQL구문이 반복실행되므로 logon에 대한 overhead가 없음.
- 단점 : Failover 테스트등으로 세션이 끊겼을경우 신규접속을 하지 않으므로 계속 에러가 발생됨. SQL구문변경시 shell스크립트 변경후 재 실행해야함.

```sql
$> cat runsql.sh
while true 
do
echo "alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';";
echo "select sysdate from dual;";
sleep 1
done
$> sh runsql.sh | sqlplus -s scott/tiger 
```
