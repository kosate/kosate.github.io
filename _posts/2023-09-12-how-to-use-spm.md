---
layout: single
title: 오라클 SPM(SQL Plan Management) 기능소개
date: 2023-09-12 03:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - spm
   - sql plan
excerpt : 오라클에서 SPM기능에 대해서 알아봅니다.
header :
  overlay_image: /assets/images/blog/sql_plan.jpg
toc : true  
toc_sticky: true
---

## 개요

오라클 데이터베이스를 운영할 때 의도하지 않은 변화를 효과적으로 관리하는 것이 매우 중요합니다. 데이터베이스 안에는 지속적으로 데이터가 축적되며, 때로는 테이블의 구조가 변경되거나 외부에서 새로운 업무 요건이 발생할 때마다 SQL이 추가됩니다.

이러한 변화가 빈번한 운영 환경에서 시스템을 안정적으로 유지하기 위해서는 쿼리의 성능 관리가 필수적이며 SQL Plan 관리가 핵심입니다. 오라클 데이터베이스에서는 SPM(SQL Plan Management)이라는 기능을 통해 SQL Plan을 효과적으로 보장하고 관리할 수 있습니다. 

SPM에 대한 간략한 소개 및 기능에 대해서 설명하고자합니다.

## 통계정보 관리 필요성

SQL이 실행될 때 Parsing이 이루어지며, 오라클 옵티마이저(Optimizer)가 SQL Plan을 생성합니다. SQL Plan을 생성할 때 가장 중요한 데이터는 오브젝트 통계 정보입니다. 그러므로 SQL Plan이 변경되지 않도록 유지하려면 통계 정보를 새로 갱신하지 않고 유지하는 것이 중요합니다. 

그렇기 때문에 옵티마이저가 실행되는 동안 참조할 수 있는 데이터(Adaptive statistics 및 bind peeking)를 모두 끄고, 오로지 통계 정보만을 참조하여 SQL Plan을 생성하도록 관리했습니다.

- SQL Plan 생성시 참고되는 정보
  - 오브젝트 통계정보(테이블/컬럼/인덱스)
  - 시스템 통계정보 (CPU, I/O, single&multi read time...)
  - Bind Peaking
  - Dynamic Sample

### 통계정보 관리 방안

대다수의 시스템은 통계정보를 고정하여 SQL Plan의 변화를 방지하고 있습니다. 그러나 통계정보를 새로 갱신하지 않고 유지하는 것만으로는 시스템을 안정적으로 운영하기 어렵습니다. 데이터는 지속적으로 변하며, 이로 인해 실제 데이터와 통계정보 간의 차이로 인해 성능이 저하되는 SQL Plan이 계속 생성될 수 있습니다.

그럼에도 불구하고 선택을 해야합니다. 업무 우선순위로 봤을 때 현재 시스템의 안정성을 확보하는 것이 중요하므로, 비록 통계정보 불일치로 인한 부정적인 영향이 있더라도 운영해야 합니다.

만약 업무를 잘 알고 있고 데이터의 변화를 잘 이해한다면, 통계정보를 관리하는 방법을 통해 운영 리스크를 더 줄일 수 있습니다. 자동 통계정보 갱신 작업과 통계정보 잠금(lock) 작업을 병행하는 운영 방식을 사용하는 것입니다.

- 통계정보 관리 전략
  - 자동 통계정보 갱신 작업과 통계정보 잠금(lock) 작업을 병행하여 운영합니다.
  - 데이터 크기가 작고 통계정보가 없는 테이블들은 자동으로 통계정보를 수집합니다.
  - 데이터가 어느 정도 쌓인 테이블들은 통계정보 잠금(lock)을 적용하여 통계정보 변경을 방지합니다.
  - 파티션 테이블의 경우 이전 파티션의 통계정보를 복사하여 신규 파티션에 적용합니다.

위에 통계 정보 관리 방법은 옵티마이저가 참조하는 오브젝트의 통계 정보가 잘 관리되어야 한다는 전제를 가지고 있습니다. 그러나 운영 환경이 변경되어 옵티마이저환경이 변경 될경우, 이전에 적용하고 노력했던 관리 방법을 새로운 환경에서도 다시 적용하고 확인해야 합니다.

### 운영 환경 변화에 따른 대응방안

통계정보만을 관리하는 것으로는 다양한 환경 변화에 대응하기 어렵습니다. 특히 DB 업그레이드나 마이그레이션 시에 이러한 문제가 더 두드러집니다. 대부분의 환경에서는 테스트 환경을 구성하고 SQL 성능 및 업무 검증을 진행합니다. 이는 많은 시간과 노력이 필요한 작업입니다. 그 이유는 통계 정보 유지만으로는 SQL Plan의 안정성을 완전히 보장할 수 없기 때문입니다. 옵티마이저의 기능이 변경되거나 참조하는 시스템 통계 정보가 변경되면 새로운 Plan이 생성될수 있습니다.

- 운영 환경의 변화
  - DB 업그레이드가 될때 (예시 : 11g -> 19c) - 옵티마이저 기능 변경 
  - 신규 서버로 DB 마이그레이션 될때 (예시 : Unix to Linux) - 시스템 통계정보 변경

새로운 SQL Plan은 더 나은 성능을 제공할 수 있지만, 때로는 성능 저하를 가져올 수도 있습니다. 따라서 운영자는 리스크를 최소화하기 위해 SQL Plan을 고정하는 방법을 고려할 것입니다.

- SQL Plan을 고정하기 위한 노력
  - DB 업그레이드시 
    - 테이블 통계정보 유지 
  - DB 마이그레이션시
    - 테이블 통계정보 복사
    - 기존 SQL Plan을 그대로 유지하도록 튜닝(SQL Profile)

SQL Plan를 고정을 위한 노력을 한후에 최종적으로 애플리케이션 업무를 검증해야 합니다.

그렇다면 이러한 다양한 환경 변화에 어떻게 SQL Plan을 효과적으로 관리할 수 있을까요? 이를 위해 11g에 추가된 SPM(SQL Plan Management) 기능이 있습니다. SPM을 사용하면 주변의 어떠한 변화가 있더라도 동일한 SQL Plan으로 실행될 수 있습니다.

- SPM을 통한 실행계획 관리 이점
  - 새로운 통계정보가 수집해도 Plan 변경되지 않음.
  - 인덱스가 추가되어도 Plan변경되지 않음.
  - DB 업그레이드 되어도 Plan변경을 방지할수 있음(옵티마이저 버전이 올라가도 Plan 변경 방지)
  - DB 마이그레이션 되어도 Plan도 같이 옮길수 있으므로 변경을 방지할수 있음.

SQL Plan은 DB인스턴스의 메모리(library Cache)에 저장되지만 DB가 재기동되면 옵티마이저가 SQL Plan을 신규로 생성됩니다.(Plan 생성시점의 환경에 따라 새로운 Plan이 작성될 가능성이 높아집니다.) 

SPM은 SQL Plan정보를 물리적인 테이블에 저장해 놓고 있기 때문에 DB 재기동 혹은 환경변화가 발생되어도 재사용하여 SQL Plan변경을 방지합니다.

## SPM은 어떻게 동작할까요?

SPM을 사용하는 환경에서 SQL실행되는 관점에서 어떻게 동작하는지 확인해보겠습니다.

### SQL문장 실행될때 SPM동작방식
  1. SQL문장이 처음 실행될때
    - SQL 문장이 처음 실행되어 Hard Parsing이 되면 Plan이 만들어지게 됩니다. 생성된 Plan은 곧바로 사용됩니다.
    - 또한 SQL 문장은 SPM의 Statement log에 저장됩니다.
    
  2. 동일한 SQL문장이 두번째 실행될때
    - SQL 문장이 두번째 실행될때는 다시 Parsing이 되며 Plan이 만들어지게 됩니다. (Shared Pool에 존재하면 soft parsing이 되겠죠)
    - 먼저 SPM의 statement log에서 SQL문장이 존재하는지 확인하고, 존재하면 "repeatable SQL"이라고 간주하여 SPM의 Statement log에 해당 SQL의 Plan History를 만들고 현재 생성된 Plan을 SQL Plan baseline으로 등록됩니다. 생성된 Plan은 곧바로 사용됩니다.

  3. 환경 변화 이후에 새로운 Plan작성될때
    - SQL 문장을 parsing하고 New Plan이 작성되더라도, New Plan은 Plan History에 추가만 됩니다. 이미 SQL Plan baseline로 등록되어 있는 이전 Plan이 계속 사용합니다.
    - 다시 말해, 새로운 Plan이 생성되어도 사용되지 않으므로 운영환경 변화에도 SQL Plan이 변경되지 않습니다.

  4. 더 나은 실행계획이라고 판단될때
    - SQL Plan baseline에 등록된 Plan만 사용됩니다. 만약 새로 작성된 Plan이 더 나은 성능을 가지고 있는 Plan이라고 하면 현재 실행중인 Plan과 저장된 Plan들의 성능을 비교해볼수 있습니다. 
    - 운영자는 실행계획 변경해야 한다고 판단되면 더 나은 Plan을 SQL Plan baseline에 등록할수 있습니다. 

### SPM 실행 단계

SPM은 내부적으로 Capture 단계, Selection 단계, Evolution 단계로 구성되어 있습니다. 이를 앞서 설명한 SQL 실행 관점과 같이 살펴보면 더 쉽게 이해할 수 있습니다.

- SPM 내 동작하는 단계
  - Capture 단계 : 처음실행되는 SQL문장을 저장하고, 두번째 실행될때는 반복실행되는 SQL이라고 생각하고 SQL Plan을 저장되는 단계입니다. 환경변화에 따라 새로운 SQL Plan이 만들어지면 Plan History에 후보로 관리됩니다. 
  - Selection 단계 : 이미 만들어진 Plan들 중에서 Accept된 SQL Plan baseline을 선택하는 단계입니다. 
  - Evolution 단게 : 이미 만들어진 Plan들의 성능을 비교하여 새로운 후보를 확인하는 단계입니다. 

SPM의 Capture 단계와 Selection 단계를 위해 두 개의 DB 파라미터가 제공됩니다.

- SPM관련 파라미터
  - optimizer_capture_sql_plan_baselines : true로 설정하면 SPM의 Capture 단계가 수행됩니다
  - optimizer_use_sql_plan_baselines : true로 설정하면 SPM의 Selection 단계가 수행됩니다. 

※ 위의 두개 파라미터 alter system, alter session설정이 가능합니다.

optimizer_capture_sql_plan_baselines가 true로 설정되면 SQL Plan이 자동으로 Capture되며 "AUTO-CAPTURE"로 표시됩니다. 또한, False값으로 설정되어 있어도 이미 SQL Plan Baseline이 생성된 SQL에 대해서는 계속 Capture됩니다 (새로운 Plan이 생성되면 unaccepted plan으로 계속 추가됨).

optimizer_use_sql_plan_baselines를 설정하면 내부적으로 옵티마이저가 SPM을 인식하는 상태가 됩니다. 그래서 새로운 Plan이 만들어져도 SQL Plan Baseline이 선택되도록 되어 있습니다. SQL Plan을 Display하여 확인하면 사용된 SQL Plan Baseline의 이름을 함께 확인할 수 있습니다.

## 실제 운영환경에서 SPM을 어떻게 적용할까요?

SPM을 실제 운영환경에 어떻게 적용하는 것이 가장 좋을까요? 모든 것을 자동으로 Capture하고 Evolution을 자동으로 진행하는 것도 하나의 방법이겠지만, 운영자가 직접 제어할 수 있는 영역에서 예상된 운영환경으로 SPM을 관리하는 것이 중요합니다.

### 운영환경에서 SPM적용방안
  1. optimizer_capture_sql_plan_baselines와 optimizer_use_sql_plan_baselines을 모두 False로 설정해서 SPM를 사용하지 않도록 합니다.
  2. 현재 생성된 모든 SQL Plan을 SQL Plan baseline으로 로딩합니다. 이미 운영환경에는 메모리에 SQL Plan정보가 존재합니다. (사용되고 있는 SQL Plan정보를 SPM에 저장할수 있는 방법을 제공합니다.)
     - SQL Plan을 수동으로 Capture할수 있는 소스
       - SQL tuning Set
       - AWR(Automatic Workload Repository)
       - Cursor Cache
       - Stagine Table(다른 DB에 있던 SQL Plan baselines)
       - Store Outline
  3. 테스트 애플리케이션의 세션레벨에서 optimizer_use_sql_plan_baselines을 true로 설정하여 SPM이 영향을 미치지 않는지 확인합니다.
  4. optimizer_use_sql_plan_baselines을 시스템 레벨에서 true로 변경하여 모든 애플리케이션이 SPM을 사용할 수 있도록 합니다.
   

optimizer_capture_sql_plan_baselines를 true로 설정하면 모든 SQL이 저장되어 관리됩니다. 그러나 매번 SQL이 실행될 때마다 SPM 데이터를 확인해야 하므로 SPM으로 인한 시스템 오버헤드가 발생할 수 있습니다. 따라서 상시 Auto-Capture를 비활성화하고, 애플리케이션이나 워크로드가 변할 때 Bulk Capture를 수행하여 관리하는 것이 좋습니다. (예: Cursor Cache를 활용)

### SQL Plan 관리 방안

SPM적용후에 SQL Plan들은 어떻게 관리할수 있을까요? 평소에 SQL Plan을 관리할때는 Capture과 Evolution를 수동으로 관리합니다. 

  - 정기적으로 SQL을 관리대상으로 추가합니다. (Capture작업을 수동으로 수행합니다.)
    - SPM정보와 Cursor 정보를 비교하여 SPM에서 관리되지 않는 Cursor을 찾아 SPM에 저장합니다.
  - 더 나은 실행계획이 있는지 검토합니다. (Evolution 작업을 수동으로 수행합니다.)
    - SQL Plan history를 조회하여 새로운 Plan이 있는지 확인합니다.
    - SQL Plan baseline에 있는 Plan과 새로운 Plan의 성능을 비교합니다.
    - 성능이 개선될경우(예 - 최소 1.5배인경우) 해당 SQL Plan을 SQL Base lines에 추가합니다(이전 Plan을 unaccept상태로 변경)

## 마무리 

SPM에 대한 전반적인 기능과 사용 방법을 알아보았습니다. 실제 운영환경에 적용해 볼수 있나요?
현재 운영환경에 적용하기는 쉽지 않겠지만, 신규 프로젝트에 먼저 적용해볼 수 있습니다. SPM은 오라클에서 무료로 제공되는 기능입니다. 또한, 오라클 내에는 SQL Profile, SQL Patch 등 다양한 튜닝 기능을 제공하지만 SPM만이 SQL Plan을 보장하는 유일한 방법입니다. (SQL 튜닝은 사후 조치의 일환일뿐 사전 예방을 위한 방안은 아닙니다.)

통계정보를 관리하여 SQL Plan이 변경되지 않도록 하는 것보다, 원하는 Plan으로 실행되도록 SQL Plan을 관리하는 것은 어떨까요? 