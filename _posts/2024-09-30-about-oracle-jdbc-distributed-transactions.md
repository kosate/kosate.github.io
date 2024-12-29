---
layout: single
title: 분산 트랜잭션 (XA)에 관해서
date: 2024-09-30 21:00
categories: 
  - msa 
tags: 
   - msa
   - XA
   - Distributed Transaction    
excerpt : Oracle 데이터베이스에서 XA분산 트랜잭션 처리를 위한 주요 컴포넌트 및 JDBC 라이브러리에 대해서 간략하게 정리하였습니다.
header : 
  teaser: /assets/images/blog/blog5.jpg
  overlay_image: /assets/images/blog/blog5.jpg
toc : true  
toc_sticky: true
---

**참고사항** <br>본문은 [JDBC Developer's Guide의 Distributed Transactions](https://docs.oracle.com/en/database/oracle/oracle-database/19/jjdbc/distributed-transactions.html){:target="_blank"} 메뉴얼을 참고하여 정리하였습니다.
{: .notice} 

## 들어가며

최근에 XA 분산 프로토콜에 대해서 관심을 갖게되는 일이 발생했습니다. 
마이크로서비스에서도 XA 프로토콜에 대해서 관심이 많아지고 있습니다. 모든 기업이 완벽하게 서비스별로 데이터스토어를 구성할수 없고, 여러개의 서비스에서 데이터 스토어를 공유해서 사용되는 업무환경을 자주 목격하는것 같습니다. 
빅뱅형식이든 단계적으로 접근할때, 혹은 해당 산업의 특성들을 고려했을때 생각보다 많은 기업들이 XA프로토콜을 고민하게 됩니다. 

XA처리를 위한 구성요소 및 Oracle JDBC만 가지고 있는 트랜잭션 전환기법에 대해서 알아보겠습니다. 

## XA 처리를 위한 주요 컴포넌트 

일반적으로 트랜잭션 처리를 위하여 DataSource, Connection객체가 있습니다.
XA트랜잭션에서는 이와 매핑이 되는 XADatasource, XAConnection객체가 있고, XA처리를 위한 XAResouce라는 것이 추가적으로 존재합니다.
각 컴포넌트별로 설명합니다.

1. XADataSource
   - XADataSource는 Connection Pooled 데이터 소스 및 기타 데이터 소스의 확장으로 개념과 기능면이 유사합니다. 
   - 분산 트랜잭션에 사용될 Resource Manager마다 하나의 XADataSource가 있습니다. XADataSource로부터 XAConnection이 생성됩니다. 
2. XAConnection
   - XAConnection은 Pooled Connection의 확장으로 개념과 기능면이 유사합니다. 
   - XAConnection은 물리적인 데이터베이스 Connection을 캡슐화하여 물리적 Connection을 관리합니다. 
   - 분산 트랜잭션에서 동일한 데이터베이스에서 여러개 세션이 필요할 경우 하나의 XADataSource에서 여러개의 XAConnection을 생성할수 있습니다. 
   - XAConnection은 OracleXAResource 인스턴스 및 JDBC Connection 객체를 생성합니다.
3. XAResource
   - XAResource는 트랜잭션 관리자가 분산 트랜잭션을 조정하는데 사용합니다. 
   - OracleXAResource는 XAConnection 인스턴스와 1:1관계를 가지고 Oracle 세션과도 1:1관계를 가집니다.
   - OracleXAReousrce인스턴스에서 연관된 세션에서 실행중인 트랜잭션의 분기 start, prepare, commit/rollback을 수행합니다.
   - XA의 2 Phase Commit에서 1 Phase단계에서 트랜잭션 관리자는 각 OracleXAReousrce 인스턴스에 prepare작업을 수행합니다. 정상적으로 분기 작업이 완료되면 2 Phase단계인 Commit작업이 각 OracleXAResource인스턴스에서 수행됩니다.
4. Transaction ID
   - 트랜잭션 분기를 식별할때 사용됩니다. 
   - 특정 분산 트랜잭션과 연관된 모든 OracleXAResource 인스턴스는 동일한 분산 Transaction ID를 가집니다.

## 글로벌 트랜잭션과 로컬 트랜잭션 전환

애플리케이션은 로컬 트랜잭션과 글로벌 트랜잭션간 Connection를 공유할수 있으며 로컬 트랜잭션과 글로벌 트랜잭션간 Connection을 전환할수 있습니다. 

Connection은 항상 다음중 하나의 모드를 가집니다.
1. NO_TXN : 해당 Connection을 사용하는 트랜잭션이 없음을 의미합니다.
2. LOCAL_TXN : Autocommit이 False이거나 disable상태에서  로컬 트랜잭션이 해당 Connection을 사용합니다. 
3. GLOBAL_TXN : 글로벌 트랜잭션이 해당 Connection을 사용합니다. 

각 Connection은 수행된 작업에 따라 자동으로 모드가 전환됩니다. Connection이 인스턴스화되어 있을때는 항상 NO_TXN 모드로 있습니다. 
이러한 작업을 Oracle 데이터베이스와 연동된 JDBC드라이버에서 내부적으로 관리됩니다.


|현재모드|NO_TXN로 전환될때|LOCAL_TXN로 전환될때|GLOBAL_TXN로 전환될때|
|---|---|---|---|
|NO_TXN|해당사항없음|Auto-commit이 False이며 DML수행될때|XAConnection으로부터 획득한 XAResource에서 start 메소드가 호출될때|
|LOCAL_TXN|DDL수행될때, Commit/rollback수행될때|해당사항없음|XAConnection으로부터 획득한 XAResource에서 start 메소드가 호출될때|
|GLOBAL_TXN|XAConnection으로부터 획득한 XAResource에서 end 메소드가 호출될때|전환되지못함|해당사항없음|


작업에 대한 제약사항
현재 Connection Mode는 트랜잭션내에서 유효한 작업을 제한할수 있습니다. 
1. LOCAL_TXN모드에서 애플리케이션이 XAResource에서 prepare, commit, rollback, forget,또는 end를 호출해야서는 안됩니다. 이러한 시도는 XAException을 발생시킵니다.
2. GLOBAL_TXN모드에서 애플리케이션이 java.sql.Connection에서 commit, rollback, rollback(savepoint), setAutoCommit(true), 또는 setSavepoint를 호출해서는 안되며 oracle.jdbc.OracleConnection에서 OracleSetSavePoint혹은 oracleRollback을 호출해서는 안됩니다. 이러한 시도는 SQLException을 발생시킵니다.

## Oracle XA 패키지

Oracle은 XA표준에 따라 분산 트랜잭션 기능을 구현한 클래스를 포함하여 세가지 패키지를 제공합니다. 
1. oracle.jdbc.xa
2. oracle.jdbc.xa.client
3. oracle.jdbc.xa.server

XADataSource와 XAconnection, XAReousrce에 대한 클래스는 client패키지와 server패키지에 모두 포함되어 있습니다. OracleXid및 OracleXAException클래스는 oracle.jdbc.xa패키지에 포함되어 있습니다. 

미들웨어에서 XA를 처리할경우 client패키지를 임포트하고, XA코드가 대상 Oracle DB에서 실행될경우 server패키지를 임포트합니다. client과 server패키지의 클래스명이 동일하므로 주의해서 사용해야합니다.

## XA 샘플코드 

두개의 XADataSource에서 이용하여 XA처리하는 코드입니다. 
2 Phase Commit의 prepare작업과 commit작업을 수동하는것을 확인할수 있습니다. 

{% include codeHeader.html copyable="true" codetype="java"%}
```java
// Create XADataSource instances and set properties.
OracleXADataSource oxds1 = new OracleXADataSource();
oxds1.setURL("jdbc:oracle:oci:@");
oxds1.setUser("HR");
oxds1.setPassword("hr");

OracleXADataSource oxds2 = new OracleXADataSource();

oxds2.setURL("jdbc:oracle:thin:@(description=(address=(host=localhost)
            (protocol=tcp)(port=5521))(connect_data=(service_name=orcl)))");
oxds2.setUser("HR");
oxds2.setPassword("hr");

// Get XA connections to the underlying data sources
XAConnection pc1  = oxds1.getXAConnection();
XAConnection pc2  = oxds2.getXAConnection();

// Get the physical connections
Connection conn1 = pc1.getConnection();
Connection conn2 = pc2.getConnection();

// Get the XA resources
XAResource oxar1 = pc1.getXAResource();
XAResource oxar2 = pc2.getXAResource();

// Create the Xids With the Same Global Ids
Xid xid1 = createXid(1);
Xid xid2 = createXid(2);

// Start the Resources
oxar1.start (xid1, XAResource.TMNOFLAGS);
oxar2.start (xid2, XAResource.TMNOFLAGS);

// Execute SQL operations with conn1 and conn2
doSomeWork1 (conn1);
doSomeWork2 (conn2);

// END both the branches -- IMPORTANT
oxar1.end(xid1, XAResource.TMSUCCESS);
oxar2.end(xid2, XAResource.TMSUCCESS);

// Prepare the RMs
int prp1 =  oxar1.prepare (xid1);
int prp2 =  oxar2.prepare (xid2);

System.out.println("Return value of prepare 1 is " + prp1);
System.out.println("Return value of prepare 2 is " + prp2);

boolean do_commit = true;

if (!((prp1 == XAResource.XA_OK) || (prp1 == XAResource.XA_RDONLY)))
    do_commit = false;

if (!((prp2 == XAResource.XA_OK) || (prp2 == XAResource.XA_RDONLY)))
    do_commit = false;

System.out.println("do_commit is " + do_commit);
System.out.println("Is oxar1 same as oxar2 ? " + oxar1.isSameRM(oxar2));

if (prp1 == XAResource.XA_OK)
    if (do_commit)
        oxar1.commit (xid1, false);
    else
        oxar1.rollback (xid1);

if (prp2 == XAResource.XA_OK)
    if (do_commit)
        oxar2.commit (xid2, false);
    else
        oxar2.rollback (xid2);

    // Close connections
conn1.close();
conn1 = null;
conn2.close();
conn2 = null;

pc1.close();
pc1 = null;
pc2.close();
pc2 = null;
```

## 마무리

XA처리를 위한 기본 구성요소와 샘플 코드에 대해서 알아보았습니다. 
대부분의 개발환경에서는 Annotation을 통하여 코드를 간결하게 작성합니다. 하지만 때로는 raw 코드로 내부 동작 방식을 이해하는것도 필요하다고 생각합니다. 

## 참고자료 

- 오라클 메뉴얼 : <https://docs.oracle.com/en/database/oracle/oracle-database/19/jjdbc/distributed-transactions.html#GUID-FD21627C-0183-4AF3-8719-8490F069A41E>{:target="_blank"}