---
layout: single
title: Redo 전송 서비스를 활용한 오라클 기술소개
date: 2022-10-18 22:01
categories: 
    - oracle
tags: 
    - oracle
    - Redo Transport Service
    - DataGuard
    - Oracle GoldenGate
    - zdlra
summary: '오라클 DB에서 발생되는 트랜잭션로그를 이용하여 실시간 데이터 복제/추출/백업이 가능합니다.'
toc: true
comments: true
---

오라클 데이터베이스의 Redo Transport Service에 대해서 알아보고, 
다양한 활용방법과 고려사항들을 살펴보고자합니다.


Redo Transport Service 소개
-

Oracle Database에서 제공하는 Redo transport Service는 Data Guard설정이 되어 있는 구성원들간 Redo Data를 자동으로 전송하는 기능입니다. (Redo Transport Service는 Data Guard의 설정절차을 따를뿐 Data Guard를 구성한다는것만을 의미하지 않습니다. 전송받은 Redo를 어떻게 활용되는지가 더 중요합니다. )

> Oracle Database에서는 발생되는 Redo data는 데이터 변경시 발생되는 트랜잭션 발생 로그를 의미하며, 장애시 인스턴스 복구를 위해서 사용됩니다. 

이러한 Redo Data는 Oracle Database의 Online Redo log파일에 저장이 되고, 아카이브 로그 모드로 운영시 Online Redo log파일의 복사본인 Archive log파일로 생성이 됩니다.

트랜잭션로그인 Redo Data를 이용하면 인스턴스 복구작업이외 데이터 복제, 데이터 추출, 데이터 백업업무에 활용될수 있습니다. 

- 제공되는 기능
  - Archive Gap Resolution   
  소스 DB의 현재 발생 redo데이터와 타켓 DB에서 받은 Redo 데이터의 차이를 Archive Gap이라고 합니다. 보통 네트워크 순단, 타켓 DB 장애시 정상적으로 Redo 데이터 전송 및 수신이 안될경우 발생됩니다. 이는 타켓DB에서 맨마지막 받은 Redo데이터와 현재까지 받았던 Redo데이터를 비교하여 missmath가 될경우 Archive gap있다고 판단하게 되며 소스DB에게 gap발생되는 redo데이터를 요청하여 해결하게 됩니다. 이러한 내부작업들은 자동으로 수행되므로 특별하게 모니터링이나 설정작업이 필요없습니다.


### 고려사항

Redo Transport Service구성을 위해서는 오라클 데이터베이스는 Archive Mode로 운영해야하며, 활용하려는 데이터가 Nologging Operation이 있는지 확인해야합니다.

#### Archive log Mode로 운영되고 있는가?   
  Redo 전송을 위해서 Oracle Database가 Archive log mode여야 합니다. Archive log Mode는 online Redolog의 복제본인 archived log를 생성하여 별도로 저장한다는것을 의미합니다. Database 백업 및 복구할때 최신 데이터까지 복구하기 위해서는 데이터 파일 백업본 이외 archived log가 필요하며, 그외적으로 데이터 추출시에도 필요합니다.

#### Nologging Operation 작업이 수행되고 있는가?

  데이터 복구이외 다양한 업무에 활용되기 위해서는 데이터 변경사항이 Redo Log에 기록이 되어야합니다. Oracle Database에서는 복구가 필요없는 초기 데이터 적재작업 혹은 배치 작업과 같은 대량의 데이터 변경시 성능개선을 위해서 Nologging Operation작업을 수행하기도합니다.(다시 수행가능한 업무에 적용가능).  

  > Nologging Operation으로 수행된 데이터 변경(DML)작은 Redo Log에 기록되지 않으므로 데이터 복구대상에서 제외됩니다. Redo Data를 활용하기 이전에 현재 업무에 Nologging Operation을 사용하고 있는지 확인해야합니다. 

  - **Nologging Operation의 조건** 
    - 세그먼트가 Nologging 속성 적용되고, 
        ```sql
        alter table emp nologging;
        alter index ix_emp nologging;
        ```

    - 아래와 같은 작업 수행되어야 Nologging Operation이 수행됩니다.
        DML : Direct-path insert, Direct Loader(SQL*Loader)
        DDL : CREATE TALBE/INDEX시 nologging 속성사용 
        ```sql
        insert /*+ APPEND */ into scott.emp select * from sys.emp2;
        create table emp nologging as select * from sys.emp;
        create index emp_i on emp(empno) nologging;
        SQL Loader operation with unrecoverable option
        ```    
  > 데이터를 복제하거나 추출 하려는 대상이 되는 세그먼트에 대해서  Nologging속성이 있는지 확인합니다.

  - **Nologging Operation 확인 방법**
     - 세그먼트에 대해서  Nologging속성이 있는지 확인합니다.
        ```sql
        select * from ...
        ```

  - force logging설정
    - 일일이 모든 Nologging Operation이 확인이 어려울 경우 데이터베이스 레벨에서 Force Logging을 설정할수 있습니다. 
      ```sql
      alter database force logging;
      ```

  > Nologging Operattion 작업을 Logging작업으로 변경시 redo log 발생량이 증가되고 App성능(DML)에 영향을 줄수 있습니다. 그리므로 필히 업무테스트를 통하여 영향도 검증이 필요합니다.

### 구성방안

Redo Transport Service 소개부분에서 DataGuard 설정작업을 한다고 설명드렸습니다. DataGuard설정은 DB parameter로 구성이 됩니다. 

- DB 파라미터 구성예시
    - 소스 DB (Redo를 전송하는 DB)   
        ```sql
        DB_UNIQUE_NAME=BOSTON
        LOG_ARCHIVE_CONFIG='DG_CONFIG=(BOSTON,CHICAGO)' 
        LOG_ARCHIVE_DEST_2='SERVICE=CHICAGO_TNS ASYNC NOAFFIRM VALID_FOR=(ONLINE_LOGFILE, PRIMARY_ROLE) DB_UNIQUE_NAME=CHICAGO'
        ```
        LOG_ARCHIVE_DEST_2의 세부 정보는 대해서는 "관련 기술"에 따라 다르게 설정될수 있습니다. (위예제는 Oracle DataGuard 시 설정기준으로 작성되었습니다. )
        소스 DB와 타켓 DB는 DG_CONFIG설정을 통하여 서로 신뢰되는 관계가 설정됩니다.   LOG_ARCHIVE_DEST_2 파라미터를 통해서 Redo를 보내는 타켓DB의 정보(TNS, UNIQUE_NAME)와 동기화모드(sync or async) 가 설정됩니다. 

    - 타켓 DB (Redo를 받은 DB)
        ```sql
        DB_UNIQUE_NAME=CHICAGO
        LOG_ARCHIVE_CONFIG='DG_CONFIG=(BOSTON,CHICAGO)' 
        ```

- Redo 전송시 인증방법   
    Redo전송시 인증방법은 2가지가 있습니다. SSL과 remote password file 인증방식이 있습니다. 

    - SSL인증  
      SSL인증방식으로 설정한 사례를 아직까지 본적이 없는것 같습니다. 데이터베이스가 Oracle Internet Directory (OID)와 같은 Domain의 구성원으로 구성되어야하며 wallet이나 HSM에 저장된 사용자 인증서을 통해서 Redo전송시 인증할수 있습니다.

    - Password File 인증 (대부분 사용)   
      Oracle Database에는 remote환경에서 sys권한으로 접근할수 있도록 password file인증 방식을 제공합니다. Redo전송시에 소스DB에서는 sys유저로 타켓DB에 인증 요청을 하게 되며, 소스DB의 sys유저 password hash와 타켓 DB에 있는 password file의 sys유저 password hash값을 비교하여 인증이 수행됩니다. 
      그러므로 소스DB의 password file을 타켓 DB에 password file로 동기하는 작업(복사)이 필요합니다.
      이러한 관리적인 이슈가 발생되어서 DataGuard에 한정하여 12.2부터는 소스DB의 sys패스워드를 변경하면 자동으로 타켓DB의 password file에 동기화하는 기능이 추가되었습니다.


관련 기술들
- 

데이터변경정보를 담고 있는 트랜잭션 로그(Redo)를 전송하면 데이터 복제, 추출, 백업업무에 활용할수 있습니다. 소스DB는 Redo전송만 수행하게 되며, 타켓서버에서 데이터동기화 및 추출, 백업이 수행된다고 이해하시면 될것 같습니다.
그렇기 때문에 소스DB애 부하를 발생시키지 않고도 다양한 데이터 관리 업무를 수행(offload) 할수 있습니다. 

### 실시간 데이터 복제 - Oracle Data Guard

Oracle Data Guard는 소스DB와 물리적으로 동일한 데이터 크기를 가지고 있는 Standby DB로 보통 재해 복구(Disaster Recovery) 용도로 사용됩니다. 소스DB에서 데이터의 Read/write가 발생되면 DataGuard에서는 소스DB의 Redo를 받아서 동기화하게 됩니다. 내부적으로 Redo를 받는 Receive절차와 받은 Redo를 Apply하는 절차로 구분되는데 DataGuard로 구성을 하면 Mount단계에서 Redo를 Apply작업이 수행되므로 업무에 활용할수 없습니다. 
그러나 Active DataGuard 구성을 하게되면 Open단계로 유지하고 Redo apply작업중에 데이터를 조회할수 있습니다. 즉 Active Data Guard를 사용하면 Standby DB에서 업무에 활용이 되며, Active DR로 운영이 가능합니다.

> Data Guard :  Database가 Mount단계에서 Redo apply가 수행됨.
> Acitve DataGuard :  Database가 Open(read only)단계에서 Redo apply가 수행됨.

구성방법은 동일하나 어느단계에서 Redo apply가 수행되는지에 따라서 구분됩니다.

> Oracle Database(Primary) -> Oracle (Active) DataGuard(Standby)

### 실시간 데이터 추출 - Oracle GoldenGate Downstream Capture Database

Oracle product중에는 CDC솔루션으로 Oracle GoldeGate가 있습니다. Oracle GoldenGate는 여러개의 데이터 캡쳐 모델을 제공하고 있으며 그중 하나의 방식이 Downstream Caputre방식입니다. 이는 Source Database에서 데이터 추출하는것이아니라 Downstream Mining Database라는 별도의 Oracle database에서 데이터 추출 작업이 수행됩니다. 보통 CDC솔루션을 고려할때 제일 먼저 Source Database의 업무 영향도에 대해서 고민을 하게 됩니다. Downstream Capture방식으로 데이터를 추출할 경우는 데이터 추출와 솔루션 자체의 부하가 Source Database에서 발생되지 않고, Downstream Mining Database에서 발생되므로 Source Database에 발생되는 CDC솔루션 부하를 원천적으로 방지 할수 있습니다. 
Downstream Mining Database는 Redo Transporrt Service를 이용하여 Source Database에서 real-time으로 redo data를 받도록 설정된 Database로 이해하시면 됩니다.

> Oracle Database(Source) -> Downstream Mining Database(Redo Data 받는 Database서버) -> Oracle GoldenGate(데이터 추출)

### 실시간 데이터 백업 - ZDLRA(Zero Data Loss Recovery Appliance)

Oracle Product중에는 데이터 보호를 위한 백업 솔루션으로 ZDLRA(Zero Data Loss Recovery Appliance) 가 있습니다. 데이터 보호를 위해서 백업해야하는 대상 파일은 두가지가 있습니다. Data file, archive log입니다. 반대로 데이터 복구 방법도 두단계로 구분됩니다. 먼저 데이터파일을 복구하고(restore) archive log로 최신 데이터까지 Recovery합니다. Data Loss를 줄이기 위해서는 online redolog의 백업본(archive log)이 아니라 현재 마지막 데이터변경분까지 지정되어 있는 online redo가 필요합니다. ZDLRA는 online Redo를 real-time으로 전송받기 때문에, 현재 운영중인 마지막 트랜잭션데이터까지 복구할수 있습니다. 그래서 제품명에서 나왔듯이 Zero Data Loss 가 가능합니다.

> Oracle Database(Source)  -> ZDLRA(Redo Data받는 백업전용서버)

기술 자료
- 

- Redo Transport Services : https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/oracle-data-guard-redo-transport-services.html

- SQL Language Reference - logging_clause: https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/logging_clause.html#GUID-C4212274-5595-4045-A599-F033772C496E
