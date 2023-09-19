---
layout: single
title: Container DB 생성 및 기동
date: 2023-09-17 11:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - multitenant
   - container db
   - pluggable db
   - 19c
   - 21c
   - 23c
excerpt : Multitenat 아키텍쳐에서 Container DB의 생성 및 기동 방법에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 개요
오라클의 Multitenant 아키텍처는 기존의 오라클 운영 환경과 크게 다르지 않습니다. 이미 오라클 데이터베이스를 운영하고 계신 분이라면 추가적인 개념과 제어를 위한 명령어를 익히는 것만으로도 큰 어려움 없이 적용할 수 있을 것입니다. Container DB를 생성하고 기동하는 방법에 대해 알아보겠습니다.


## DBMS 아키텍쳐의 비교

현재 운영 중인 방식은 Non-CDB(Non Container DB) 구성이라고 합니다. Multitenant 아키텍처에서 운영하는 DB 환경은 CDB(Container DB) 구성이라고 합니다.

- DBMS 아키텍처 비교
  - Non-CDB 운영 환경 : 하나의 오라클 인스턴스에서 하나의 데이터베이스를 호스팅합니다.
  - CDB 운영 환경 : 하나의 오라클 인스턴스가 여러 개의 데이터베이스를 호스팅합니다.

오라클 인스턴스는 오라클 백그라운드 프로세스와 메모리를 포함합니다. CDB 환경처럼 하나의 오라클 인스턴스에서 여러 개의 데이터베이스를 운영하면 백그라운드 프로세스와 메모리를 공유하여 사용합니다. 이로 인해 자원을 효율적으로 활용할 수 있는 특징을 가집니다.

데이터베이스 운영환경에서는 메모리 리소스를 많이 사용할수 밖에 없습니다. 데이터베이스의 성능 향상을 위해 데이터를 메모리에 캐시하기 때문에 일반적인 애플리케이션보다 많은 메모리를 할당하여 사용합니다. CDB 환경처럼 어떤 효과가 있을까요?

각 애플리케이션에서 필요한 데이터는 캐시(Buffer cache)되는 것이 좋기 때문에 메모리 공유로 인한 효과는 크지 않지만, 오라클 내부적인 딕셔너리 관련 공통 데이터(libarary cache, row cache)에 대해서는 메모리를 공유하기 때문에 여러 개의 데이터베이스를 동시에 운영할 때 메모리 절감 효과를 볼 수 있습니다. 또한 백그라운드 프로세스도 모두 공유되므로 DB별로 실행되었던 백그라운드 수 만큼 메모리 절감효과와 더불어 CPU 자원을 확보할 수 있습니다.

- Multitenant의 구성요소
  - Container DB : Pluggable DB을 관리하는 인프라 DB입니다. Container DB에서 백그라운드 프로세스가 실행되고 Pluggable DB의 리소스를 관리합니다. Single, RAC의 구성들은 Container DB에서 설정됩니다.
  - Pluggable DB : Pluggable DB는 애플리케이션이 접근하는 DB입니다.

## CDB 운영환경은 어떻게 바뀌는가?

현재 운영 중인 Non-CDB 환경을 CDB 환경으로 전환하면 어떤 변화가 있을까요?
애플리케이션 입장에서는 접속한 환경이 CDB인지 Non-CDB인지 구별이 되지 않습니다. 따라서 DB 아키텍처의 변화가 애플리케이션 환경에는 영향을 미치지 않습니다.
CDB를 관리해야 하는 데이터베이스 관리자의 입장에서 정리해보겠습니다.

### Container DB 설치 방법
데이터베이스를 설치하는 방법은 기존과 동일합니다. 19c에서 DBCA를 통해 설치할 때 Container DB를 선택할 수 있는 옵션이 제공됩니다. 그러나 21c부터는 해당 옵션이 제외되어 설치 시 자동으로 Container DB가 생성됩니다.

Container DB로 생성할 때는 기본적으로 Container DB의 이름을 지정해야 하며, 그 위에 올라가는 Pluggable DB를 만들지 않거나(Empty PDB), Pluggable DB의 이름을 지정하여 함께 생성할 수 있습니다.

- 설치시 고려사항
  - 어떤 캐릭터셋을 선택할 것인가?
    - Container DB는 여러 개의 Pluggable DB를 관리할 수 있도록 설계되었습니다. 각 Pluggable DB마다 다른 캐릭터셋을 설정할 수 있으므로, Container DB의 캐릭터셋은 주로 AL32UTF8로 설정하는 것이 권장됩니다.
    - Container DB와 Pluggable DB을 특정 캐릭터셋으로 함께 설정할 수 있지만, Pluggable DB가 다른 Container DB로 이동할 경우 해당 Container DB의 캐릭터셋은 Pluggable DB의 Superset이어야 합니다.
  - Compatiable 파라미터관리
    - Pluggable DB는 Container DB 간에 이동이 가능합니다. 이때 Compatible가 동일하거나 상위 버전으로 이동할 수 있습니다. 그러나 Container DB의 Compatible를 너무 높게 설정하면 하위 버전의 Container DB로 이동할 수 없습니다. 따라서 Container DB의 Compatible는 주로 베이스 버전까지만 지정하는 것이 좋습니다. (예: 19.0.0) 

### 데이터베이스 기동 절차
Non-CDB 환경에서는 일반적으로 "startup" 명령어를 사용하여 데이터베이스를 시작했을 것입니다. (또는 svrctl)

```sql
$> export ORACLE_SID=NONCDB
$> sqlplus "/as sysdba"
Connected to an idle instance.
SQL> startup
Database mounted.
Database opened.
```
CDB 환경에서 Non-CDB 환경과 동일하게 데이터베이스를 시작하면 어떤 일이 벌어질까요?
```sql
$> export ORACLE_SID=CDB
$> sqlplus "/as sysdba"
Connected to an idle instance.
SQL> startup
Database mounted.
Database opened.
```
CDB만 시작된 상태이기 때문에 애플리케이션에서 접속 가능한 PDB는 아직 시작되지 않았습니다. PDB 목록을 확인하고 기동하는 절차가 추가됩니다.

```sql
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           MOUNTED    NO
SQL> alter pluggable database pdb1 open;
Pluggable database altered.
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
```
Non-CDB 환경과 CDB 환경 간의 큰 차이점은 PDB를 기동하는 절차가 추가된다는 점입니다. PDB를 기동하는 절차에서 보았듯이 PDB를 제어하는 명령어는 "alter pluggable database" 입니다.

CDB 환경에서 PDB를 관리하기 위해서는 "alter pluggable database" 또는 "create pluggable database" 명령어를 친숙하게 다뤄야 할 필요가 있습니다. 그리고 이 명령어만 알아도 모든 PDB를 관리할 수 있다는 의미이기도 합니다.

```sql
create pluggable database ..
alter pluggable database ..
```

## 마무리

Container DB는 여러 개의 Pluggable DB를 관리하는 기반, 즉 인프라 환경입니다. 기존에 알던 데이터베이스 관리 방법에서 PDB를 제어하는 명령어를 추가로 습득하면 CDB 환경도 쉽게 관리할 수 있습니다.

데이터베이스 생성 작업은 평소에 자주 수행하지 않았습니다. 개발 환경을 만들 때도 주로 기존 운영 DB의 백업을 내려받아 개발 환경에서 복구하여 사용하게 됩니다. 이는 백업과 복구의 작업이며 데이터베이스 생성 작업은 아닙니다.

CDB 환경에서는 PDB를 복제하는 다양한 기술을 제공하고 있습니다. "create pluggable database 개발DB from 운영DB@dblink"를 통해 운영 환경을 참조하여 개발 및 테스트 환경을 만들 수 있습니다.

"create/alter pluggable database " 명령어에 더 익숙해지면 다양한 업무에 더 유용하게 활용할 수 있습니다.