---
layout: single
title: Container DB 구성시 고려사항
date: 2023-09-18 01:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - multitenant
   - container db
excerpt : Container DB 구성시 고려사항에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 개요

Container DB는 애플리케이션이 데이터에 접근할 수 있는 Pluggable DB를 관리합니다. Container DB를 구성할 때 고려해야 할 사항에 대해 알아보겠습니다.

## Container DB 운영방안

Container DB가 기동되면 오라클 인스턴스도 함께 기동됩니다. 이로 인해 오라클 백그라운드 프로세스가 시작되고 메모리가 할당됩니다. 여기까지는 Non-CDB 환경에서의 데이터베이스 기동 절차와 완전히 동일합니다. 그러나 큰 차이점이 한 가지 있습니다. Container DB에는 일반 사용자의 데이터를 저장할 수 없다는 점입니다.

Container DB는 Pluggable DB를 관리하는 역할을 수행할뿐, 사용자 데이터를 저장하고 서비스하는 것은 아닙니다.

그렇다면 Container DB가 수행하는 역할은 무엇일까요?

- Container DB의 역할
  - 데이터베이스의 버전을 관리합니다.
  - 데이터베이스 구성을 관리합니다 (Single 또는 RAC).
  - 데이터베이스의 백업과 복구를 관리합니다 (Control file, archived log).
  - Pluggable DB를 기동하기 위한 인프라 DB 역할을 합니다.

- Pluggable DB의 역할
  - 애플리케이션에서 데이터를 조작하는 DB로서 역할합니다.
  - 사용자와 테이블 등 오브젝트를 관리하며 업무 SQL을 실행합니다.

결론적으로, Container DB는 데이터베이스 버전과 인스턴스 구성을 관리하고, Pluggable DB는 애플리케이션과 관련된 데이터 작업을 수행합니다. 

Non-CDB 환경에서는 데이터베이스의 모든 작업이 sysdba 권한으로 하나의 DB에서 이루어졌지만, CDB 환경에서는 PDB로 이동하는 추가적인 절차가 필요합니다.

**CDB환경에서 PDB 작업하는 방법**
```sql
$> sqlplus "/as sysdba"
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
         5 PDB2                           READ WRITE NO
SQL> alter session set container=pdb1;
Session altered.
SQL> -- pdb1에서 작업수행 ? 
SQL> alter session set container=pdb2;
Session altered.
SQL> -- pdb2에서 작업수행 ? 
```

어떠신가요? 조금 익숙해지셨나요? 작업이 어려우시진 않으신가요?
CDB에서 sysdba 권한을 가진 사용자로 작업하실 때에는 하나의 세션에서 PDB를 스위칭하며 작업해야 합니다. CDB에 여러 개의 PDB가 존재할 경우, 작업 중에 실수가 발생할 수 있을 뿐만 아니라 보안상의 문제로 작용할 수도 있습니다.

- CDB 환경에서 sysdba 유저로 PDB 작업 시 주의사항
  - 보안 위반 가능성(필요 이상의 권한 사용)
  - 작업 중 실수 가능성이 높음

이러한 이유로 PDB를 생성할때 기본적으로 PDB관리자(예: salesadm)를 지정하도록 되어있습니다. 

```sql
SQL> CREATE PLUGGABLE DATABASE salespdb 
  ADMIN USER salesadm IDENTIFIED BY password;

SQL> connect salesadm/password@salespdb
SQL> -- salesadm에서 작업수행
```

작업이 진행되는 환경을 확인하고, 해당 작업에 필요한 권한을 가진 사용자로 직접 접속하시면 작업 중에 실수 없이 안정적으로 진행할 수 있습니다. PDB를 생성할 때 지정한 PDB 관리자는 다른 PDB로 이동할 수 없습니다.

## Container DB 구성시 고려사항

하나의 Container DB에 모든 업무를 올릴 수는 있지만, 운영 환경을 고려하여 적절한 그룹핑을 해주는 것이 중요합니다. Container DB에서는 데이터베이스 버전과 인스턴스 구성이 관리되며, 그 위에 올라가는 Pluggable DB는 Container DB의 속성을 그대로 따릅니다. Container DB가 RAC일 경우 Pluggable DB도 RAC가 되고, Single일 경우 Pluggable DB도 Single이 됩니다. 따라서 애플리케이션의 업무 수준을 고려하여 동일한 업무 수준의 경우 Container DB로 묶어 구성하는 것이 좋습니다.

- Container DB구성시 고려사항
  - 동일한 SLA(Single, RAC 구성) 요건은 동일한 Container DB로 구성합니다.
  - 동일한 Container DB에 있는 Pluggable DB는 동일한 운영 정책을 가지게 됩니다. (운영 정책: 업그레이드 및 패치, DR 환경 등)

Container DB를 인프라라고 표현을 많이 했습니다. CDB도 데이터베이스의 한 종류이지만 Pluggable DB 관리를 위해 존재하기 때문에 인프라라는 말로 설명을 했습니다. 

아래와 같은 업무 요건이 발생했을 때 Container DB를 통해 어떻게 운영할 수 있는지 알아보겠습니다.

- Container DB 운영 시 고려사항:
  - 특정 PDB에 패치 요건이 발생했을 경우: 데이터베이스 엔진에 적용되는 one-off 패치는 Container DB에 적용됩니다. 특정 PDB에만 적용하고 싶은 경우에는 새로운 Container DB를 만들고 패치를 적용한 후 PDB를 이동시켜 나머지 PDB에 영향을 주지 않고 작업할 수 있습니다.
  - 특정 PDB의 구성을 Single에서 RAC로 변경해야 할 경우: 기존에 Single로 구성된 Container DB에 있는 PDB를 RAC로 구성된 Container DB로 이동시키면 자동으로 PDB가 Single에서 RAC로 전환됩니다.
 
Container DB에 종속된 설정인 데이터베이스 버전과 인스턴스 구성을 피하려면 새로운 Container DB로 이동하는 작업을 통해 문제를 해결할 수 있습니다. 그렇기 때문에 Container DB를 Oracle Home과 같이 데이터베이스 운영을 위한 필수 인프라로 생각하는 것이 운영에 도움이 됩니다.

## 마무리

Container DB를 어떻게 구성하고 운영해야 하는지 알아보았습니다. 하나의 Pluggable DB를 운영할 경우에는 고려해야 할 사항이 많지 않겠지만, 여러 개의 Pluggable DB를 유연하게 운영하기 위해서는 Container DB에 대한 깊은 이해가 필요합니다.
전반적인 운영 효율성 관점에서 좀 더 넓은 시야로 접근하여 Container DB 구성에 대한 정책을 수립하고 운영하시면 좋겠습니다.