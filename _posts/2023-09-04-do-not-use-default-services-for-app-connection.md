---
layout: single
title: 애플리케이션에서 오라클에 접속시 Default Service를 사용하면 안되는 이유
date: 2022-09-04 18:00
categories: 
  - oracle
author: 
tags: 
   - oracle
   - default service
   - user-defined service
   - sysdba
   - listener
summary: 
toc : true
---

오라클 데이터베이스에 접속할때 사용하는 서비스명(service name, 서비스이름)에 대한 사용방법에 대해서 정리하고자 합니다. 일반적으로 DB_NAME을 서비스명으로 사용하지만, 관리나 업무관점에서는 DB_NAME보다는 별도 서비스명(User-Defined Service)를 만들어서 접속하는것이 더 많은 운영 이점을 얻을수 있습니다.

### 오라클 데이터베이스 접속방법
오라클 데이터베이스에 어떻게 접속하고 있나요? 보통 애플리케이션에서 아래와 같이 Connection String을 지정하고 접속하고 있을것입니다. 

- 서비스명으로 접속 : "host:port/service_name"
- ORACLE_SID명으로 접속 : "host:port:ORACLE_SID" 
  
※ ORACLE_SID는 오라클데이터베이스를 서비스하는 인스턴스를 의미함.

### 서비스명 접속방법과 ORACLE_SID 접속방법의 차이점
단순히 접속해서 SQL조회하고, 데이터를 수정하는 maintainance 관점에서보면 서비스명과 ORACLE_SID접속하나 크게 차이는 없을수 있지만, 업무를 운영하는 애플리케이션 관점에서는 큰 차이점이 있습니다.

- 서비스명으로 접속한 경우 
  - 애플리케이션에서 접속한 DB세션의 load balancing, Failover를 지원합니다 : 만약 오라클 데이터베이스의 인스턴스가 이중화되어 서비스할경우(이런 방식의 인스턴스 구성방식을 RAC(Real Application cluster)라고 합니다). DB에 접속할때 load balancing이 가능하여 여러개의 인스턴스로 세션을 분산시킬수 있습니다. 한쪽 인스턴스가 장애가 발생되면 다른 가용한 인스턴스로 세션들이 모두 Failover가 되어 업무 영향도를 줄일수 있습니다.(이러한 세션 Failover기능을 TAF(Transparent Application Faliover)라고 합니다.)
  - 애플리케이션에서 접속한 DB세션들의 리소스를 관리합니다 :  오라클 데이터베이스에는 세션들의 리소스를 관리하는 Resource Manager라는 기능이 있습니다. Resource Manager는 접속한 세션들을 Grouping하여 리소스를 관리할수 있는데, 이때 Group의 기준이 서비스명이 될수 있습니다. (필요하면 프로그래명이나 모듈, 액션명으로 Grouping이 가능합니다.)    
  
- ORACLE_SID로 접속한 경우 
  - 특정 인스턴스로만 접속이 가능합니다 : 내가 접속한 인스턴스에서만 작업이 가능하므로 세션의 load balancing이나 Failover를 지원하지 않습니다.

서비스명으로 접속하는것이 운영관점 혹은 관리관점에서 더 많은 이점을 제공합니다.

### 서비스의 종류

오라클 데이터베이스에서 접속할수 있는 Service들은 아래와 같이 두가지로 나뉘게 됩니다. 

- Default Service : 오라클 데이터베이스가 생성되면 자동으로 DB_NAME, DB_UNIQUE_NAME, PDB_NAME(Multitenant환경인경우)으로 serivce가 생성되고 Mount단계에서 Active 상태가 되어 접속이 가능한 상태가됩니다. 대신 서비스의 중지 및 시작와 같은 제어작업이 불가능합니다.(이부분을 알고 계셨나요?)

- User-Defined Service : 사용자가 임의적으로 생성하는 서비스로 서비스를 분리하여 업무를 좀더 세분화하여 관리 운영할수 있습니다. 그리고 서비스 중지 및 시작, 이동작업이 가능합니다.

보통 데이터베이스 관리자 조차도 간과하는것이 서비스명입니다. 일반적으로 구성할경우 하나의 서비스명 그것도 DB_NAME으로만 사용합니다. 대부분의 환경들을 Single이거나 RAC 환경으로 구성되는데, 사실 이정도의 환경에서도 DB_NAME을 가지고 운영해도 크게 불편함을 못느기께 됩니다. 

### User-Defined Service의 필요성

오라클 데이터베이스에는 많은 기능과 옵션들이 존재합니다. 따라서 운영환경 업무요건을 고려했을때 다양한 환경들이 구성될수 있습니다. 
몇가지 상황에서 User-Defined Service가 필요한 이유에 대해서 설명하겠습니다.

- RAC환경에서 애플리케이션 분산을 하고 싶을때 - RAC환경에서는 서비스할수 있는 여러개의 인스턴스가 존재하게 되는데, A업무를 1번 인스턴스, B업무는 2번 인스턴스에서 접속해서 리소스를 잘 사용할수 있는 환경을 구성할수 있겠죠. DB_NAME는 모든 인스턴스에서 접속이 가능한 Default Service이므로 업무를 분리하기에는 적합하지 않는 서비스입니다.(DB_NAME으로 인스턴스를 분리한다면 TNS 정보에서 접속 아이피 순서를 조정해서 할수는 있습니다). User-Defined Service를 생성할때 A서비스를 1번 인스턴스에, B서비스는 2번 인스턴스에 띄우도록 생성할수 있습니다. 애플리케이션들은 생성된 서비스명(A, B)을 가지고 자동으로 인스턴스에 분산 시킬수 있습니다. 그리고 만약에 한쪽 인스턴스가 장애가 나거나, 혹은 한쪽 인스턴스에서 관리작업이 있어 재기동해야하는 일이 발생되면 애플리케이션 영향도를 최소화하기 위하여 작업하려는 인스턴스에 있는 서비스를 다른 인스턴스로 임의적으로 Failover시킬수 있습니다.   
  
- Active DataGuard 환경이 추가되었을때 - Priamry 운영환경에서 Active DataGuard구성을 통해서 Standby 환경이 구성될수 있습니다. 이럴때 어떻게 TNS정보를 관리할수 있을까요? DB_NAME을 서비스명으로 사용하는 애플리케이션인경우 Primary DB가 장애가 발생되어 Standby DB로 접속하기 위해서는 TNS정보를 수정해야합니다. 왜냐하면 DB_NAME은 Primary DB, Standby DB모두 접속이 가능한 서비스이기 때문입니다.(Standby DB는 Priamry DB와 동일한 DB_NAME을 가집니다.). 그게 무슨 의미이냐면, 평소에 Primary DB에 접속하기 위해서는 Primary DB 접속 아이피 + DB_NAME로 TNS정보를  설정하고 Standby DB 접속 아이피를 같이 넣을수가 없습니다. User-Defined Service를 생성할때 DB role(Primary Role, Standby Role)을 같이 지정할수 있습니다. DB Role에 따라서 서비스가 기동되므로 Primary DB에서만 서비스기동이 가능한 환경구성이 가능합니다 그렇기 때문에 TNS정보에 Primary DB, Stanby DB 접속아이피를 모두 설정하여도 상관없으며 결국 Primary DB가 장애가 발생되어 Standby DB로 운영이 될때 자동으로 Standby DB는 Primary Role을 가지게 되므로 TNS접속 정보없이 정상적으로 서비스가 가능합니다.
  
- Multitenant 환경으로 DB가 운영될때 - Multitenant 환경에서는 하나의 인스턴스에서 여러개의 PDB(Pluggable DB)를 관리하는 오라클 데이터베이스의 새로운 아키텍쳐입니다. 여러개의 PDB를 만들게 되면 자동으로 PDB_NAME으로 서비스명이 Default로 생성이 됩니다. 일반 DB보다 한계층 가상화된 개념으로 PDB의 이동 및 복제라는 기술이 추가되므로 Default Service보다는 새로운 User-Defined Service를 만들어서 사용하도록 메뉴얼에 가이드 되어 있습니다. 

### Default Service는 언제 사용할까요?

Default Service는 Mount만 되어도 접속이 가능한 서비스입니다. sysdba권한이 있으면 원격에서도 접속이 가능합니다.
그렇기 때문에, RMAN을 통해서 백업/복구작업을 할때, 혹은 Standby DB를 구성하거나 복구할때 사용됩니다. 작업대부분들은 일반적인 데이터 작업이 아니라 관리적인 작업임을 알수 있습니다. 데이터베이스 관리자가 특수한 상황에서 사용하는 용도로 이해하면 좋을것 같습니다. 


### 결론

사실 애플리케이션 담당자들에게는 크게 중요하지 않을수 있는 개념일수 있지만, 
데이터베이스 관리자가 애플리케이션 담당자에게 접속정보를 제공할때 고민해야되는 내용들입니다. 
데이터베이스를 어떻게 관리하고, 추후 애플리케이션 영향도를 줄일수 있는 방법을 고민한다면 당연히 User-Defined Service를 사용할수 밖에 없습니다. 
Default Service는 관리관점에서 사용하고 User-Defined Service는 애플리케이션 접속하는 서비스로 사용해야합니다.

