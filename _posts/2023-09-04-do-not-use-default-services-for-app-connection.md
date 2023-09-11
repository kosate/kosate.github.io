---
layout: single
title: 애플리케이션에서 오라클에 접속시 Default Service를 사용하면 안되는 이유
date: 2023-09-04 18:00
categories: 
  - oracle
author: 
tags: 
   - oracle
   - default service
   - user-defined service
   - sysdba
   - listener
summary: 오라클 데이터베이스로 접속할수 있는 두가지 서비스유형에 대해서 설명합니다.
toc : true
toc_sticky: true
---

## 목적

오라클 데이터베이스에 접속하는 방법과 서비스명(Service Name) 사용방법에 대해 간단히 정리해보겠습니다. 일반적으로 DB_NAME을 서비스명으로 활용하지만, 관리나 업무 관점에서는 DB_NAME보다는 별도의 서비스명(User-Defined Service)을 만들어 사용하는 것이 더 많은 운영의 이점을 얻을수 있습니다.

## 오라클 데이터베이스 접속방법

오라클 데이터베이스에 어떻게 접속하고 있나요? 대부분의 경우, 애플리케이션에서 다음과 같이 Connection String을 이용하여 접속합니다.

- 서비스명으로 접속 : "host:port/service_name"
- ORACLE_SID명으로 접속 : "host:port:ORACLE_SID" 
  
※ ORACLE_SID는 오라클데이터베이스를 서비스하는 인스턴스를 가르킵니다.

## 서비스명 접속방법과 ORACLE_SID 접속방법의 차이점

일반적으로 SQL을 조회하거나 데이터를 수정하는 관리 차원에서는 서비스명과 ORACLE_SID로 접속하는 것 사이에 큰 차이가 없을 수 있습니다. 그러나 업무를 운영하는 애플리케이션의 관점에서는 두 가지 간에 중요한 차이가 있습니다.

- 서비스명으로 접속한 경우 
  - 애플리케이션에서 접속한 DB세션의 부하 분산(load balancing) 및 장애 극복(Failover)를 지원합니다. 예를 들어, 오라클 데이터베이스의 인스턴스가 이중화되어 서비스할 경우(이러한 구성을 RAC(Real Application Cluster)라고 합니다), DB에 접속할 때 세션을 여러 인스턴스로 분산시켜 부하를 분산시킬 수 있습니다. 한 인스턴스에서 장애가 발생하면 나머지 가용한 인스턴스로 세션들이 모두 자동으로 이전되어 업무 영향을 최소화할 수 있습니다. (이를 TAF(Transparent Application Failover)라고 합니다.)
  - 애플리케이션에서 접속한 DB 세션들의 리소스를 관리합니다. 오라클 데이터베이스에는 세션 리소스를 관리하는 Resource Manager 기능이 있습니다. Resource Manager는 접속한 세션들을 그룹화하여 리소스를 관리할 수 있는데, 이때 그룹의 기준이 서비스명이 될 수 있습니다. (필요에 따라 Program, Module, Action Name등으로 그룹화할 수 있습니다.)
  
- ORACLE_SID로 접속한 경우 
  - 특정 인스턴스에만 접속할 수 있습니다. 내가 접속한 인스턴스에서만 작업이 가능하므로 세션의 부하 분산(load balancing) 이나 장애 극복(Failover)을 지원하지 않습니다.

운영 관점이나 관리 관점에서는 서비스명으로 접속하는 것이 더 많은 이점을 제공합니다.

## 서비스의 종류

오라클 데이터베이스에는 다음과 같이 두 가지 유형의 접속 서비스가 있습니다.

- 기본 서비스(Default Service) : 오라클 데이터베이스가 생성되면 자동으로 DB_NAME, DB_UNIQUE_NAME, PDB_NAME(Multitenant환경인경우)으로 serivce가 생성되고 Mount단계에서 활성 상태가 되어 접속이 가능해 집니다. 그러나 이 서비스는 중지 및 시작와 같은 제어작업이 불가능합니다.(이부분을 알고 있었나요?)

- 사용자 정의 서비스(User-Defined Service) : 사용자가 직접 생성하는 서비스로 업무를 더 세분화하여 관리 및 운영할수 있도록 서비스를 분리할수 있습니다. 또한 서비스를 서비스 중지하거나 시작하고 이동하는 작업이 가능합니다.

보통 데이터베이스 관리자조차 간과하는 부분 중 하나가 서비스명입니다. 일반적으로 구성할 때 하나의 서비스명, 그것도 DB_NAME만 사용합니다. 대부분의 환경은 싱글 또는 RAC 환경으로 구성되는데, 사실 이정도 환경에서도 DB_NAME만 가지고 운영해도 큰 불편함을 느끼지 못할 수 있습니다.

## User-Defined Service의 필요성

오라클 데이터베이스는 다양한 기능과 옵션을 제공합니다. 이에 따라 운영 환경과 업무 요건에 따라 다양한 환경이 구성될 수 있습니다. 몇 가지 상황에서 사용자 정의 서비스(User-Defined Service)가 필요한 이유를 설명하겠습니다.

- RAC환경에서 애플리케이션 분산 
  - RAC 환경에서는 여러 인스턴스가 서비스할 수 있습니다. A 업무는 1번 인스턴스, B 업무는 2번 인스턴스에서 처리하는 등 리소스를 효율적으로 활용할 수 있는 환경을 구성할 수 있습니다. DB_NAME은 모든 인스턴스에서 사용 가능한 Default Service이므로 업무를 분리하기에는 적합하지 않습니다. User-Defined Service를 생성하여 A 서비스를 1번 인스턴스에, B 서비스는 2번 인스턴스에 할당할 수 있습니다. 애플리케이션들은 생성된 서비스명(A, B)을 사용하여 자동으로 인스턴스에 분산됩니다. 
  - 또한 한쪽 인스턴스에 장애가 발생하거나 관리 작업이 필요한 경우 해당 인스턴스의 서비스를 다른 인스턴스로 Failover시킬 수 있어 애플리케이션 영향도를 최소화할 수 있습니다.
  
- Active DataGuard 환경 추가
  - Primary 운영환경에서 Active DataGuard 구성을 통해 Standby 환경을 구성할 수 있습니다. 이때 TNS 정보를 어떻게 관리해야 할까요? DB_NAME을 서비스명으로 사용하는 애플리케이션의 경우 Primary DB에서 Standby DB로 접속하기 위해서는 TNS 정보를 수정해야 합니다. 왜냐하면 DB_NAME은 Primary DB와 Standby DB 둘 다 접속 가능한 서비스이기 때문입니다. 이런 경우, User-Defined Service를 생성할 때 DB Role(Primary Role, Standby Role)을 함께 지정할 수 있습니다. DB Role에 따라 서비스가 기동되므로 Primary DB에서만 서비스 기동이 가능한 환경을 구성할 수 있습니다. 그렇기 때문에 TNS 정보에 Primary DB와 Stanby DB의 접속 아이피를 모두 설정해도 되며, 결국 Primary DB에서 장애가 발생하여 Standby DB로 운영될 때 자동으로 Standby DB는 Primary Role을 가지게 되어 TNS 접속 정보 없이 정상적으로 서비스가 가능합니다.
  
- Multitenant 환경으로 DB운영
  - Multitenant 환경에서는 하나의 인스턴스에서 여러 개의 PDB(Pluggable DB)를 관리하는 오라클 데이터베이스의 새로운 아키텍쳐입니다. 여러 개의 PDB를 만들면 자동으로 PDB_NAME을 서비스명으로 Default로 생성합니다. 이런 가상화된 PDB의 이동 및 복제라는 기술이 추가되어 Default Service보다는 새로운 User-Defined Service를 만들어 사용하도록 메뉴얼에서 안내하고 있습니다.

## Default Service는 언제 사용할까요?

Default Service는 Mount 상태에서도 접속이 가능한 서비스입니다. sysdba 권한이 있으면 원격에서도 접속이 가능합니다. 

이로 인해 RMAN을 활용한 백업/복구 작업이나 Standby DB 구성 및 복구 시 사용됩니다. 이러한 작업 대부분은 주로 데이터 조작이 아닌 관리적인 작업임을 알 수 있습니다. 데이터베이스 관리자가 특별한 상황에서 사용하는 용도로 이해하시면 좋을 것 같습니다.


## 정리

사실 애플리케이션 담당자들에게는 크게 중요하지 않을 수 있는 내용이겠지만,
데이터베이스 관리자가 애플리케이션 담당자에게 접속 정보를 제공할 때 고려해야 할 중요한 사항입니다.
데이터베이스를 어떻게 관리하며, 추후 애플리케이션 영향을 최소화하는 방법을 고민한다면 당연히 User-Defined Service를 사용하는 것이 필수입니다.<br>
Default Service는 주로 관리 측면에서 사용하고, User-Defined Service는 애플리케이션에 접속하는 서비스로 활용되어야 합니다.
