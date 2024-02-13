---
layout: single
title: Apache Zeppelin에서 Oracle 연결하기
date: 2024-02-12 15:00
categories: 
  - Oracle
author: 
tags: 
   - Oracle
   - Apache Zeppelin
excerpt : Apache Zeppelin노트북에서 Oracle를 조회할수 있도록 연결하는 방법에 대해서 정리하였습니다.
toc : true  
toc_sticky: true
---

## 개요

Apache Zeppelin은 데이터 분석 및 시각화를 위한 오픈 소스 웹 기반 노트북 플랫폼입니다. 데이터 과학자, 분석가들이 데이터를 탐색하기 위해서 코드를 실행하고 시각화할수 있습니다. 주요 지원언어로는 Apache Spark, Python, R, SQL, Scala등이 여러 언어 지원이 가능합니다. 

Apache 프로젝트이므로 빅데이터 플랫폼과 연계성이 뛰어나며, Java기반으로 JDBC드라이버를 이용하여 다양한 DB에 연결할수 있습니다. 

Apache Zeppelin에서 Oracle DB로 연결하는 방법에 대해서 알아보겠습니다. 

## Apache Zeppelin과 Jupyter 비교

Zeppelin 노트북과 비교되는 Jupyter노트북이 있습니다. 둘다 데이터 과학 및 분석을 위해서 노트북 환경을 제공합니다. 

- Zeppelin 노트북은 다양한 데이터 소스를 지원, 풍부한 시각화기능을 내장하여 데이터 조회 및 분석하는데 유용합니다. Apache Spark와의 통합을 강조하기 때문에 대용량 데이터셋 및 분석 처리에 적합하고, 데이터 분석시 필요한 협업기능 및 다중 사용자 환경을 지원합니다. 
- Jupyter 노트북은 Python기반으로 고급분석할때 더 유용합니다. 대체로 작은 규모의 데이터셋에 대한 개발 및 실험을 위한 용도로 사용되고, 다양한 라이브러리 및 확장 기능을 제공합니다. Zeppelin이 비해서 좀 더 활발한 커뮤니티를 가지고 있어서 그런지, 클라우드 환경에서는 Zeppelin보다 Jupyter노트북이 더 많이 선택되는것 같습니다. 

본 문에서는 Zeppelin 설치하도록 하겠습니다.

## Apache Zeppelin 설치

Apache Zeppelin에서 지원되는 interpreter목록은 아래 사이트에서 확인가능합니다. 
주로 Big data플랫폼 관련 환경들과 PostgreSQL, MySQL, MariaDB, Redshift 등을 지원합니다. 

Supported Interpreters
- <https://zeppelin.apache.org/supported_interpreters.html>{:target="_blank"}

Apache Zeppelin을 설치후에 Oracle용 Interpreter를 추가하겠습니다. 

### 1. 바이너리 다운로드 및 설치

Apache Zeppelin설치를 위하여 바이너리 파일 다운로드 (Binary package with all interpreters)받습니다. 
아래 사이트에 접속합니다. 

- <https://zeppelin.apache.org/download.html>{:target="_blank"}

> Apache Zeppelin 설치방법은 바이너리 다운로드하여 설치하는 방법과 Docker를 통해서 기동하는 방법 두가지를 제공합니다. 본문에서는 바이너리 다운로드하여 설치하는 절차로 진행했습니다.

(2024년 2월 13일기준 0.11.0 버전입니다.)
{% include codeHeader.html name="zeppelin-0.11.0-bin-all.tgz(843M)" %} 
```bash
wget https://dlcdn.apache.org/zeppelin/zeppelin-0.11.0/zeppelin-0.11.0-bin-all.tgz
```

다운로드 받은 바이너리 파일을 압축 해제 합니다. 
{% include codeHeader.html %} 
```bash
tar -xvf zeppelin-0.11.0-bin-all.tgz
mv zeppelin-0.11.0-bin-all/ zeppelin/
```

Zeppelin 시작합니다.
{% include codeHeader.html %} 
```bash
./zeppelin/bin/zeppelin-daemon.sh start
```

Zeppelin 시작 로그는 아래와 같습니다.
```bash
$> ./zeppelin/bin/zeppelin-daemon.sh start
Please specify HADOOP_CONF_DIR if USE_HADOOP is true
Log dir doesn't exist, create /home/oracle/zeppelin/logs
Pid dir doesn't exist, create /home/oracle/zeppelin/run
Zeppelin start                                             [  OK  ]
```

Zeppelin 중지합니다. 
{% include codeHeader.html %} 
```bash
./zeppelin/bin/zeppelin-daemon.sh stop
```

Zeppelin 중지 로그는 아래와 같습니다.
```bash
$> ./zeppelin/bin/zeppelin-daemon.sh stop
Please specify HADOOP_CONF_DIR if USE_HADOOP is true
Zeppelin stop                                              [  OK  ]
```

### 2. Apache Zeppelin 설정 (IP address, Port, Multi-User)

처음설치이후에 실행하면 127.0.0.1:8080으로 접속할수 있습니다.
서버 외부에서 접속하기 위해서는 127.0.0.1 에서 0.0.0.0으로 변경해야 합니다.( 외부로 접속되기때문에 보안에 신경을 써야합니다.)

**conf 파일을 수정하여 서비스 아이피 및 포트 설정합니다.**

zeppelin-site.xml 설정 파일을 새로 생성합니다.

{% include codeHeader.html %} 
```bash
cd ./zeppelin/conf
cp zeppelin-site.xml.template  zeppelin-site.xml
vi zeppelin-site.xml
```

아이피와 포트를 설정합니다.

{% include codeHeader.html name="./zeppelin/conf/zeppelin-site.xml"%} 
```bash
<property>
  <name>zeppelin.server.addr</name>
  <value>0.0.0.0</value>
  <description>Server binding address</description>
</property>

<property>
  <name>zeppelin.server.port</name>
  <value>8080</value>
  <description>Server port.</description>
</property>
```

OS 방화벽을 오픈합니다.

외부 접속되기 위해서는 OS방화벽 오픈이 필요합니다. linux환경에서는 firewall설정작업이 필요합니다.
{% include codeHeader.html %} 
```bash
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload
```

**Zeppelin에서는 다중 사용자 설정이 가능합니다.**

다중 사용자를 위해서 shiro.ini설정파일을 새로 생성합니다.

{% include codeHeader.html%} 
```bash
cd ./zeppelin/conf
cp shiro.ini.template shiro.ini
vi shiro.ini
```

Zeppelin 접속 사용자를 추가합니다.

{% include codeHeader.html name="./zeppelin/conf/shiro.ini"%} 
```bash
[users]
admin = password1, admin
```

Zeppelin 시작합니다.
{% include codeHeader.html %} 
```bash
./zeppelin/bin/zeppelin-daemon.sh start
```

인증방식 및 권한에 대한 세부 설정이 가능합니다.

- 지원되는 인증방식 : Active Directory, LDAP, PAM, Knox SSO, HTTP SPENGO Authentication
- 그외 그룹 및 권한, 쿠키설정이 가능합니다.
  

### 3. Apache Zeppelin 접속

설정한 아이피와 포트로 접속합니다. 

- 웹브라우저로 접속 : http://ip_address:8080/

![](/assets/images/blog/zeppelin/login1.jpg)

오른쪽 상단의 `Login 버튼`을 클릭합니다. 

./zeppelin/conf/shiro.ini파일에 설정한 사용자 정보를 넣습니다. 

- User Name : admin
- Password : password1

![](/assets/images/blog/zeppelin/login2.jpg)

접속이 완료되었습니다. 

![](/assets/images/blog/zeppelin/login3.jpg)

## Oracle 접속 설정

Oracle 접속을 위해서는 JDBC 드라이버가 필요합니다. 
JDBC 드라이버를 이용하여 interpreter를 생성합니다. 

### 1. Oracle 접속을 위한 Interpreter 추가

Oracle접속을 위한 JDBC 드라이버 다운로드받습니다.

- <https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html>{:target="_blank"}

(2024년 2월 13일 기준 최신버전은 23.3 입니다. )

JDBC 드라이버는 zeppelin의 interpreter/jdcb 경로에 다운로드 받습니다.

{% include codeHeader.html name="ojdbc11.jar(7MB)"%} 
```bash
cd ./zeppelin/interpreter/jdbc
wget -O ojdbc11.jar https://download.oracle.com/otn-pub/otn_software/jdbc/233/ojdbc11.jar
```

Zeppelin 웹화면에서 Interpreter 화면으로 이동 합니다. 
오른쪽 상단 사용자를 클릭하면 `Interpreter` 메뉴가 나옵니다. 클릭합니다.

![](/assets/images/blog/zeppelin/interpreter1.jpg)


`+Create` 버튼을 클릭하여 새로운 Interpreter를 생성합니다.

- Interpreter Name : osql
- Interpreter group : jdbc
 
![](/assets/images/blog/zeppelin/interpreter2.jpg)

Interpreter하단에 Properties에서 DB 접속 정보를 설정합니다. 

- default.url : jdbc:oracle:thin:@xxx.xxx.x:1521/서비스명
- default.user : *********
- default.password : ************
- default.driver : oracle.jdbc.driver.OracleDriver

![](/assets/images/blog/zeppelin/interpreter3.jpg)

`SAVE` 버튼을 클릭하여 Interpreter 생성 작업을 완료합니다. 

### 2. Notebook 세션 생성 및 SQL실행

`Notebook` 메뉴을 선택후에 `+Create New Note`를 클릭합니다. 노트북 신규 세션이 생성됩니다.

![](/assets/images/blog/zeppelin/notebook1.jpg)

Note 이름과 default interpreter를 선택합니다. 이전단계에서 생성한 osql를 선택합니다.

- Note Name : Oracle Test
- Default Intepreter : osql

![](/assets/images/blog/zeppelin/notebook2.jpg)

SQL 실행하여 결과를 확인합니다. 실행할때는 오른쪽 `▷`를 클릭합니다.

{% include codeHeader.html%} 
```sql
%osql
select sysdate from dual;
```

![](/assets/images/blog/zeppelin/notebook3.jpg)

다른 데이터를 조회합니다.

![](/assets/images/blog/zeppelin/notebook4.jpg)

## 마무리

Apache Zeppelin을 통해서 Oracle DB에 접속하는 방법에 대해서 알아보았습니다. JDBC 기능을 사용하므로 Oracle DB뿐만 아니라 다양한 RDBMS과 연결할수 있습니다. 여러개의 소스에 있는 데이터들을 연관 조회할때 유용할것 같습니다.

## 참고문서

- <https://zeppelin.apache.org/>{:target="_blank"}
- <https://www.oracle.com/database/technologies/appdev/jdbc.html>{:target="_blank"}