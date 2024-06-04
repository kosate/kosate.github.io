---
layout: single
title: Linux환경에서 VNC서버구성 및 noVNC 설정방법
date: 2024-03-12 21:00
categories: 
  - linux
author: 
tags: 
  - linux
  - cloud
  - noVNC
excerpt : 테스트 환경을 만들다보면 VNC설정 하기 여간 귀찮은 일이 아닙니다. 쉽게 웹브라우저로 VNC접속하는 환경구성에 대해서 알아보겠습니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 테스트 환경

|서버환경|서버종류|OS종류|OS버전|
|-|-|-|-|-|-|-|-|
|OCI|VM(x86)|Oracle Linux(redhat계열)|8.9|

## 들어가며 

학습 목적으로 실습환경을 생성할 경우가 있습니다. 
보통 실습할때는 SSH으로 접속하여 CLI로 실습하거나, 웹브라우저와 같이 GUI환경에서 실습할수 있습니다.
특히 GUI환경의 실습들은 애플리케이션 실행해야하고 애플리케이션 별로 서비스 포트 오픈 작업이 필요합니다. 

VNC환경을 구성하면 서버 안에서 데스크탑처럼 환경이 구성되므로, WINDOW에 익숙한 사람들인 쉽게 실습을 할수 있습니다.
또한 VNC환경 안에서 애플리케이션 실행할경우 server side에서 프로그램이 실행되므로 네트워크 접속 에러로 인한 영향도 받지 않습니다. 

VNC환경을 구성하면 VNC환경으로 접속하기 위해서는 VNC Client가 필요합니다. VNC Client로 별도 프로그램을 통해서 접속해야하므로 여간 귀찮은것이 아닙니다. 

VNC Client없이 웹브라우저로 VNC로 접속할수 있는 noVNC도구가 있습니다. 

본 내용에서는 VNC 서버 설정 및 noVNC 설정방법에 대해서 알아볼예정입니다.

## noVNC 환경 구성 절차

noVNC 환경을 구성하기 전에 서버에서 VNC Server가 실행되고 있어야합니다. 
먼저 VNC Server를 설정하도록 하겠습니다. 

### VNC Server 설정

VNC Server 구성을 하기 위해서는 GUI관련된 패키지가 Linux에 설치되어 있어야합니다. 
Linux에서 "server with gui" 그룹의 패키지를 설치합니다.

{% include codeHeader.html runas="root" copyable="true" codetype="shell" elapsedtime="60 sec" %}
```bash
yum group install "server with gui"
```

tiegervnc-server를 설치합니다. 

{% include codeHeader.html runas="root" copyable="true" codetype="shell" elapsedtime="60 sec" %}
```bash
yum install tigervnc-server
```
 
VNC Server에 접속할 OS유저를 지정합니다. 
저는 oracle OS유저가 이미 생성되어 있고, oracle OS유저로 VNC 접속이 되도록 설정하겠습니다. 
oracle유저를 vnc유저로 등록합니다. 

oracle OS유저를 VNC유저로 등록합니다.
{% include codeHeader.html runas="root" name="/etc/tigervnc/vncserver.users" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
#vi /etc/tigervnc/vncserver.users
:1=oracle
``` 

VNC 환경을 서비스로 등록하고 서버 재기동시에 자동으로 실행되도록 설정합니다. 
{% include codeHeader.html runas="root" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver_oracle@\:1.service
systemctl daemon-reload
systemctl enable vncserver_oracle@:1.service
systemctl start vncserver_oracle@:1.service
systemctl status vncserver_oracle@:1.service
```

VNC 접속을 위하여 Oracle유저의 VNC패스워드를 설정합니다. 
{% include codeHeader.html runas="oracle" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
su  - oracle
vncpasswd
```

vncpasswd 설정 내용입니다. 
```bash
oracle$> vncpasswd
Password:
Verify:
Would you like to enter a view-only password (y/n)? n
A view-only password is not used
oracle$>$
```

###  noVNC 설정

noVNC는 HTML VNC 클라이언트 자바스크립트 라이브러리로 VNC client없이 웹브라우저로 VNC에 접속할수 있는 도구입니다. 
iOS 및 Android를 포함한 모든 최신 브라우저에서 잘 작동합니다.
지원되는 브라우저 버전은 아래와 같습니다. 
- Chrome 64, Firefox 79, Safari 13.4, Opera 51, Edge 79

noVNC은 websocket(wss://)를 사용하므로 SSL 인증서가 필요합니다. 
noVNC을 위하여 self SSL 인증서를 생성합니다. 

{% include codeHeader.html runas="oracle" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
su - oracle
mkdir /home/oracle/novnc/
cd /home/oracle/novnc/
openssl req -x509 -nodes -newkey rsa:2048 -keyout /home/oracle/novnc/novnc.pem -out /home/oracle/novnc/novnc.pem -days 365 
```

SSL 인증서 생성 결과입니다.
```bash
oracle$> cd /etc/pki/tls/certs
oracle$> openssl req -x509 -nodes -newkey rsa:2048 -keyout /home/oracle/novnc/novnc.pem -out /home/oracle/novnc/novnc.pem -days 365
Generating a RSA private key
..+++++
.+++++
writing new private key to '/home/oracle/novnc/novnc.pem'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:KR
State or Province Name (full name) []:Seoul
Locality Name (eg, city) [Default City]:Seoul
Organization Name (eg, company) [Default Company Ltd]:회사명
Organizational Unit Name (eg, section) []:조직명
Common Name (eg, your name or your server's hostname) []:서버명
Email Address []:메일주소
oracle$>
```

noVNC를 다운받고 실행합니다. 이따 앞서 만든 SSL인증서를 사용합니다. 
novnc_proxy를 실행하면 자동으로 websockify(python3)를 다운받고 proxy서버가 실행됩니다. 

{% include codeHeader.html runas="oracle" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
cd /home/oracle/novnc
wget https://github.com/novnc/noVNC/archive/refs/tags/v1.4.0.tar.gz
tar zxvf v1.4.0.tar.gz
cd /home/oracle/novnc/noVNC-1.4.0
./utils/novnc_proxy --vnc localhost:5901 --cert /home/oracle/novnc/novnc.pem
```

noVNC 실행 화면입니다.

```bash
oracle$> ./utils/novnc_proxy --vnc localhost:5901 --cert /home/oracle/novnc/novnc.pem
Using local websockify at /home/oracle/novnc/noVNC-1.4.0/utils/websockify/run
Starting webserver and WebSockets proxy on port 6080
WebSocket server settings:
  - Listen on :6080
  - Web server. Web root: /home/oracle/novnc/noVNC-1.4.0
  - SSL/TLS support
  - proxying from :6080 to localhost:5901
 
Navigate to this URL:

    http://<ip>:6080/vnc.html?host=<hostname>&port=6080

Press Ctrl-C to exit
```

noVNC설치시 에러가 발생될수 있습니다. git 없다던가, numpy가 없어서 성능이 느리다는 에러가 발생되면 
root유저로 아래 명령어를 실행하여 조치합니다. 

```bash
yum install git
pip3 install numpy
```

(필요시) OS내에서 방화벽을 확인하여 6080 포트를 오픈합니다. 
{% include codeHeader.html runas="root" copyable="true" codetype="shell" elapsedtime="10 sec" %}
```bash
firewall-cmd --permanent --zone=public --add-port=6080/tcp
firewall-cmd --reload
```

웹 브라우저에서 해당 서버의 Public IP를 이용하여 VNC접속을 합니다. 
이때 URL에서 oracle OS유저에 설정된 vpnpassword을 넣을경우 자동 접속하도록 설정할수 있습니다.자동접속이 필요없는 경우 vcn.hml까지만 입력하시면 됩니다.

> http://[server_ip]:6080/vnc.html?password=<oracle's vcnpassword>&resize=scale&quality=9&autoconnect=true

![](/assets/images/blog/novnc/novnc.jpg)

## 마무리

리눅스 환경에서 VNC 서버를 구성하여 웹브라우저로 접속가능한 noVNC설정절차에 대해서 알아보았습니다. 
GUI가 필요한 실습환경을 위하여 VNC 서버를 구성했습니다. 
VNC Client를 통해서 접속할수도 있으나, 좀더 간편하게 VNC Client 없이 구성하는 방법을 사용하였습니다.
학습목적으로 실습환경구성시 client 환경에 영향을 받지 않는 실습환경을 구성하는것도 고려해볼수 있을것 같습니다.

## 참고자료

- <https://github.com/novnc/noVNC>{: target="_blank"}
- <https://novnc.com/info.html>{: target="_blank"}
- <https://github.com/novnc/websockify>{: target="_blank"}
- <https://hungpt7.github.io/en/note%20(484).html>{: target="_blank"}
