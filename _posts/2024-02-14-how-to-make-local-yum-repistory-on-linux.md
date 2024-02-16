---
layout: single
title: Linux에서 Local Yum Repository 설정방법
date: 2024-02-14 21:00
categories: 
  - linux
author: 
tags: 
  - linux
  - cloud
excerpt : Linux에서 Local yum repostory 설정하는 방법에 대해서 알아보겠습니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 들어가며

Redhat 계열 Linux 7이하에서는 yum(패키지 관리자) 을 통해서 rpm을 설치할수 있습니다.(Linux 8부터는 dnf를 사용합니다). Public 인터넷으로 연결이 되지 않는 환경에서는 rpm설치를 수동을 할수 밖에 없습니다. 

Local Yum Repository를 구성하여 설치할수 있는 방법에 대해서 정리하였습니다.

## Local Yum Repository 설정방법

Yum Repository구성시 외부의 Yum repository를 전부를 가져와서 구성할수 있거나 특정 rpm이 있으면 해당 rpm만으로도 구성할수 있습니다. 

- Yum Repository구성방법
  - 1) 외부의 Yum Repository전부를 가져옵니다 or 2) 특정 RPM으로 설정합니다.

- Yum Repository설정방법
  - 1) 로컬 파일로 설정합니다 or 2) HTTP서비스로 설정합니다.

Yum Repository를 HTTP서비스를 만들어서 제공하면 소프트웨어 패키지를 중앙에서 관리할수 있기 때문에 여러 서버에서 동일한 소프트웨어 버전 및 정책으로 관리할수 있습니다

본문에서는 Oracle Instance Client 19c rpm관련 yum repository를 구성하였습니다.

### 1. Yum Repository 디렉토리 생성

현재 Yum repository에 목록을 확인합니다.  

{% include codeHeader.html %} 
```bash
yum repolist
```
아무런 목록이 없습니다.
```bash
$> yum repolist
No repositories available
```

YUM repository 설정을 위하여 디렉토리를 신규로 생성했습니다.

{% include codeHeader.html %} 
```bash
mkdir -p /var/www/html/local-repo
cd /var/www/html/local-repo
chmod -R ugo+rX /var/www/html/local-repo
```

### 2. Yum Repository에 RPM추가

위에서 언급하였듯이 외부의 Yum Repository를 통채로 가져와서 설정할수 있습니다. 

{% include codeHeader.html %} 
```bash
cd /var/www/html/local-repo
wget --recursive --no-parent --no-host-directories https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/x86_64/ -P  /var/www/html/local-repo
```

아니면,

특정 RPM만 있다면 `createrepo` 명령어로 repository메타를 만들고 rpm을 넣어서 설정할수 있습니다.
createrepo 명령어를 통해서 Repository를 메타 정보를 생성합니다.

{% include codeHeader.html %} 
```bash
createrepo /var/www/html/local-repo
cp /path/oracle-instantclient19.22-basic-19.22.0.0.0-1.x86_64.rpm /var/www/html/local-repo
```

oracle-instantclient19.22-basic-19.22.0.0.0-1.x86_64.rpm 은 인터넷에서 미리 다운로드 받은 rpm파일 입니다.

> Linux 7에서는 `createrepo.rpm` 이었지만 Linux 8부터는 `createrepo_c.rpm`으로 rpm명이 변경되었습니다. 
> createrepo 명령어가 수행안되면 아래와 같이 설치할수 있습니다. 
> ```bash
> yum install createrepo
>
> or 
>
> wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/createrepo_c-libs-0.11.0-3.el8.x86_64.rpm
> wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/createrepo_c-libs-0.11.0-1.el8.x86_64.rpm
> wget https://yum.oracle.com/repo/OracleLinux/OL8/appstream/x86_64/getPackage/drpm-0.4.1-3.el8.x86_64.rpm
> rpm -ivh drpm-0.4.1-3.el8.x86_64.rpm
> rpm -ivh createrepo_c-libs-0.11.0-3.el8.x86_64.rpm
> rpm -ivh createrepo_c-0.11.0-3.el8.x86_64.rpm 
> ```

Yum Repository 생성 로그입니다. 

```bash
$> createrepo /var/www/html/local-repo
Directory walk started
Directory walk done - 7 packages
Temporary output repo path: /var/www/html/local-repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
```


### 3. Yum Repository 설정

Yum Repository 접속을 위하여 config 파일을 생성합니다. 

{% include codeHeader.html%} 
```bash
vi /etc/yum.repos.d/local-repo.repo
```
config 파일안에는 두개의 Repository를 설정하였습니다. 
첫번째는 로컬 파일에 있는 RPM을 제공하는 Repository이고, 두번째는 HTTP서비스로 접속되는 Repository입니다. 

{% include codeHeader.html name="/etc/yum.repos.d/local-repo.repo"%} 
```bash
[local-file-repo]
name=local-file-repo
baseurl=file:///var/www/html/local_repo
enabled=1
gpgcheck=0 

[remote-http-repo]
name=remote-http-repo
baseurl=http://localhost:8900/repo/OracleLinux/OL8/oracle/instantclient/x86_64/
enabled=1
gpgcheck=0 
```

HTTP서비스를 위하여 python으로 HTTP서버를 임시로 실행합니다.
만약 여러 서버에서 접속해서 사용해야되는 중앙화된 Repository로 관리하려면 좀더 다양한 기능을 가지고 있는 HTTP서비스를 설치하고 관리하는것을 권고드립니다. 
본문에는 간단하게 테스트하기 위해서 Python으로 간단하게 HTTP 서비스를 기동했습니다. 

{% include codeHeader.html%} 
```bash
cd /var/www/html/local-repo
python3 -m http.server 8900 &
```

### 4. Yum Repository 조회

Yum Repository를 조회합니다. 

{% include codeHeader.html%} 
```bash
yum repolist
```

실행결과입니다. 이전에는 아무런 목록이 보이지 않았지만, 지금은 두개모두 확인됩니다. 
```bash
$> yum repolist
repo id            repo name
local-file-repo    local-file-repo
remote-http-repo   remote-http-repo
```

로컬 디렉토리에 있는 Yum Repository에 Oracle instance Client RPM을 옮겨놨었죠?
Yum 명령어를 통해서 Oracle instance Client를 설치해보겠습니다. 

Repository명에 local-file-repo로 보이는것을 확인할수 있습니다. 

```bash
$> yum install oracle-instantclient19.10-basic.x86_64
Last metadata expiration check: 0:01:09 ago on Fri 16 Feb 2024 07:08:16 AM GMT.
Dependencies resolved.
===========================================================================================
 Package                           Architecture  Version         Repository          Size
===========================================================================================
Installing:
 oracle-instantclient19.10-basic   x86_64         19.10.0.0.0-1   local-file-repo    52 M

Transaction Summary
===========================================================================================
Install  1 Package

Total size: 52 M
Installed size: 227 M
Is this ok [y/N]: y
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                                      1/1
  Installing       : oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64                                                                                                                                                 1/1
  Running scriptlet: oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64                                                                                                                                                 1/1
  Verifying        : oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64                                                                                                                                                 1/1

Installed:
  oracle-instantclient19.10-basic-19.10.0.0.0-1.x86_64

Complete!
```

## 마무리

Local Yum Repository 생성하여 실행되는 절차를 확인해보았습니다. RPM간에 의존성때문에 설치 및 버전 관리가 어렵습니다. 기업내에서는 중앙화된 private 저장소를 통해서 표준화된 패키지 관리를 할수 있습니다. 
보안 취약점이 발견되면 영향도를 판단하고 정책을 만들어서 배포작업도 할수 있습니다. 

클라우드환경에서는 중앙화된 Repository를 이용하여 RPM패키지들을 쉽게 관리할수 있는 도구혹은 서비스로 제공하고 있는데요, 
내부적으로 저런게 구축하지 않았을까요?

## 참고문서 

- Oracle Linux: Is createrepo RPM Available in Oracle Linux 8 (Doc ID 2849607.1)