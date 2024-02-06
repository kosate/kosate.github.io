---
layout: single
title: 클라우드 네트워크에서 Broadcast/Multicast 통신방법
date: 2024-01-30 21:00
categories: 
  - oci
author: 
tags: 
   - Oracle
   - oci
   - Oracle Cloud Infrastructure
excerpt : 일반적인 네트워크 통신 프로토콜과 GRE프로토콜 구현방법에 대해서 정리했습니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 개요

클라우드를 많이 사용하고 있나요? 클라우드환경에서 Multicast와 boardcast 통신하기 위한 설정방법에 대해서 정리하였습니다. 네트워크 전문가는 아니지만 여러가지 고민하고 조사했던 내용들입니다.

## 통신프로토콜 : TCP/IP와 UDP/IP

네트워크 통신할때 사용되는 대표적인 프로토콜(Protocols)은 TCP(Transmission Control Protocol)와 UDP(User Datagram Protocol)가 있습니다. 
TCP는 통신 연결시 3-way 핸드셰이크 작업을 통해 연결세션을 만들고 데이터의 전달과 순서를 보장하여 데이터를 안정적으로 전송한다음 연결을 종료합니다. 반면 UDP는 연결설정 및 종료이 없이 개별 패킷을 독립적으로 빠르게 전송합니다. 

- TCP와 UDP의 차이
  - 신뢰성 : TCP/IP는 신뢰성 있는 전송을 지향하며 패킷손실이 발생되면 재 전송하여 데이터 무결성을 보장합니다. UDP/IP는 패킷 손실 발생가능성이 있으므로 데이터 손실이 허용되는 프로그램에 사용되어야합니다.
  - 연결방식 : TCP/IP는 서로간에 신뢰성이 보장되어야하므로 1:1 Unicast방식으로 통신하며 UDP/IP는 특정 대상혹은 불특정 대상으로 패킷을 전송하므로 업무 특성에 따라서 Unicast, Multicast혹은 Broadcast방식으로 통신합니다.
  - 그외 흐름제어와 혼잡제어기능은 TCP에 내장되어 있고, UDP는 패킷 헤더의 크기가 상대적으로 작다는 특징이 있습니다. 

## 통신방법 : Unicast, Multicast, Broadcast

TCP/UDP 프로토콜을 사용할때 송신자와 수신자간에 데이터 전송하는 방법에 따라 3가지로 구분됩니다. 

- 통신 방법
  - Unicast(layer 2,3에서 동작) : 1:1 통신을 의미합니다. 하나의 송신자가 하나의 수신자에게 전송합니다. 가장 일반적인 통신 방법입니다.
  - Multicast(layer 2,3에서 동작) : 하나의 송신자가 다수 수신자에게 동시에 데이터를 전송합니다. 수신자는 IGMP (Internet Group Management Protocol)을 통해서 멀티케스트 그룹에 참여하며 송신자는 멀티케스트 주소를 가진 그룹에게 데이터를 전송하면 라우터는 전송받은 데이터를 수신자에게 전달합니다. 
  - BroadCast(layer 2에서 동작) : 하나의 송신자가 네트워크에 연결된 모든 장치로 데이터를 전송합니다. 송신자는 브로드케스트 주소로 메시지를 전송하면 물리적인 브로드케스트 도메인에 있는 모든 장치에게 메시지가 수신됩니다.

통신 프로토콜과 통신 방법을 연결하면 다양한 통신 방식이 있을수 있습니다. 

- 통신 사례
  - TCP/IP Unicast 통신 : 우리가 흔이 사용하는 웹브라우징, 이메일 전송, 파일 전송에 사용됩니다.
  - UDP/IP Unicast 통신 : 음성 통화, 비디오 스트리밍, 온라인 게임에서 사용됩니다.
  - UDP/IP Multicast 통신 : 여러 사용자에게 동시 동일한 비디오 전송시(비디오 스트리밍), 주식의 시세데이터 전송시 사용됩니다.
  - UDP/IP Broadcast 통신 : 대표적으로 DHCP(Dynamic Host Configuration Protocol)가 사용하는 방식(네트워크에 연결되면 자동으로 IP 주소를 할당)에서 사용됩니다.

인프라에서 사용되는 NTP(Network Time Protocol), SNMP(Simple Network Management Protocol), DNS(Domain Name System)들은 모두 UDP프로토콜을 사용합니다. 

## 클라우드에서 multicast와 broadcast가 지원되지 않는 이유?

클라우드환경에서는 모든 데이터는 네트워크을 통해서 전송됩니다. 서비스(업무통신) 패킷, 스토리지 패킷 모두 같은 네트워크를 사용합니다. 온프레미스에서 사용자망, 스토리지망, 관리망 구분되어 네트워크를  관리했지만, 클라우드 환경에서는 유연한 네트워크 설정을 위하여 가상 네트워크카드를 추가하는 작업등을 지원하기 때문에 용도에 맞게 물리적으로 네트워크 구성이 어려워졌습니다. (즉 패킷 혼잡도 제어하는게 중요하게 되었습니다.)

그렇기 때문에 클라우드 환경에서는 아무리 큰 대역폭이 있다고 하더라고 결국 테넌트간 공유해서 사용하므로 여러 대상으로 패킷을 전송하는 경우 네트워크 혼잡도 및 부하 증가가 발생될수 있습니다. 그래서 효율적으로 네트워크 자원 관리와 보안을 고려하여 Multicast와 broadcast를 대부분 지원하지 않게 됩니다.

아래 표는 클라우드 제공업체대상으로 조사한 내용입니다.( 2024년 2월 5일 기준)

AWS에서는 Transit Gateway기능에서 Multicast Domain관리 기능을 통해서 Multicast를 지원합니다. 

|CSP|Broadcast|Multicast|관련문구|근거문서|
|---|---|---|---|---|
|AWS|NO (Unknown - Broadcast에대한 문구가 없음)|YES|- Multicast<br />With Transit Gateway multicast, you can now easily create and manage multicast groups in the cloud, much easier than deploying and managing legacy hardware on premises. You can scale up and down your multicast solution in the cloud to simultaneously distribute a stream of content to multiple subscribers. With Transit Gateway multicast you have fine-grain control over who can produce and who can consume multicast traffic|<https://aws.amazon.com/transit-gateway/features/>{: target="_blank"}<br /><https://docs.aws.amazon.com/vpc/latest/tgw/vpc-tgw.pdf#what-is-transit-gateway>{: target="_blank"} |
|Azure|NO|NO|Do virtual networks support multicast or broadcast? No. Multicast and broadcast are not supported. |<https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq>{: target="_blank"}|
|GCP|NO|NO|VPC networks support IPv4 and IPv6 unicast addresses. VPC networks do not support broadcast or multicast addresses within the network. | <https://cloud.google.com/vpc/docs/vpc>{: target="_blank"}|
|OCI|NO|NO|Do you support IP multicast or broadcast within the VCN? No, not currently.| <https://www.oracle.com/cloud/networking/virtual-cloud-network-faq.html>{: target="_blank"}

> 위 내용은 인터넷 검색하여 정리된 내용입니다. 

그럼 Multicast 와 Broadcast 요건이 있는 업무를 클라우드에서 실행할수 있는 방법이 없을까요?

일반적으로 클라우드에서 지원되는 통신방식에 따라 추가적으로 기능을 개발합니다.
예로 원래 UDP의 Multicast 통신했던 프로그램을 Unicast도 지원하도록 추가 개발하는것이지요.
특히 노드간에 클러스터로 관리되어야 하는 솔루션들은 multicast에서 unicast로 추가 지원하도록 기능을 추가하는것 같습니다. 

## 클라우드에서 Multicat와 broadcast 통신을 위한 방법??

진짜 업무상에서 필요해서 사용해야할 경우 어떻게 해야될까요?

Generic Routing Encapsulation(GRE) 프로토콜 이용하여 패킷 캡슐화하는 방법이 있습니다.
클라우드 환경에서는 VPN설정할때 많이 사용되는데요? GRE Tunnel을 사용하면 라우팅이 불가능한 패킷을 라우팅 가능한 패킷에 넣어서 보낼수 있습니다. 

즉 Multicast/broadcast 패킷을 GRE tunnel로 보낼수 있습니다. 

정작 GRE프로토콜을 지원하지 않으면 이러한 기능도 사용할수 없겠죠?
클라우드 업체별로 GRE 프로토콜을 제공하는지 정리해보았습니다.

대부분의 클라우드 업체들은 GRE를 지원하는것으로 보입니다. 다만 Azure만 GRE를 block한다라고 되어 있어 지원되지 않는것 같습니다.

|CSP|GRE|관련문구|근거문서|
|---|---|---|---|
|AWS|YES|Protocol: The protocol to allow|<https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html>{: target="_blank"}|
|Azure|NO|You can use TCP, UDP, ESP, AH, and ICMP TCP/IP protocols in virtual networks. Unicast is supported in virtual networks. Multicast, broadcast, IP-in-IP encapsulated packets, and Generic Routing Encapsulation (GRE) packets are blocked in virtual networks. |<https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-faq>{: target="_blank"}|
|GCP|YES|IPv4 data packets between VMs: all IPv4 protocols.|<https://cloud.google.com/vpc/docs/vpc>{: target="_blank"}|
|OCI|YES|IP Protocol: Either a single IPv4 protocol or "all" to cover all protocols. |<https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/securityrules.htm#Security_Rules>{: target="_blank"}

> 위 내용은 인터넷 검색하여 정리된 내용입니다.  

## 호스트에 GRE 설정 하고, 테스트하기

GRE Tunnel중에 Layer 2에서 동작하는 GRETAP(Generic Routing Encapsulation Tunnel as a Point-to-Point Interface)을 사용합니다. GRE tunnel간 네트워크 확장되도록 Bride기능을 사용합니다.(GRE tunnel은 layer 3에서 동작, GRE tap은 Layer 2에서 동작)

- VM인스턴스간에 연결 - GRETap (호스트간 Point to Point로 Tunnel 설정, Layer 2)
- 네트워크 확장(GRE tunnel간 통신) - Bride(Layer 2)

호스트(VM 인스턴스) 구성은 다음과 같습니다. 모두다 리눅스 서버로 구성했습니다.

- 마스터 서버(10.0.0.197) : 특정 대역의 Overay network 생성해서 관리합니다. 호스트 1, 호스트 2로 GRE tunnel로 연결합니다. 호스트 1과 호스트 2가 통신할때는 마스터 서버의 bride기능을 통해서 연결됩니다. 
- 호스트 1(10.0.0.25) : 마스터 서버로 GRE tunnel을 연결합니다.
- 호스트 2(10.0.0.131) : 마스터 서버로 GRE tunnel을 연결합니다.

- 고려사항
  - 리눅스 서버 환경인 경우 broadcast 패킷이 무시되지 않기 위하여 커널 파라미터를 변경해야합니다.
{% include codeHeader.html %} 
```bash 
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=0
```
  - 클라우드 VM안에서는 OS 방화벽과 클라우드 네트워크 방화벽(Security List)이 있습니다. 모두 적절하게 GRE 통신이 가능하도록 해제합니다.

### 마스터 서버 설정 

**1. 브리지 네트워크 생성**

"bridge0"라는 이름의 브리지 인터페이스를 생성합니다. 브리지에 IP 주소 "172.16.254.1/24"를 할당합니다. 브리지를 활성화합니다.

{% include codeHeader.html %} 
```bash
ip link add name bridge0 type bridge
ip addr add 172.16.254.1/24 dev bridge0
ip link set bridge0 up
```

**2. GREtap 인터페이스를 설정**

호스트 1과 연결한 "gretap1"라는 이름의 GRE Tap 인터페이스를 생성합니다. 해당 GRE Tap 인터페이스를 활성화합니다.GRE Tap 인터페이스를 "bridge0" 브리지에 연결합니다.

{% include codeHeader.html %} 
```bash
ip link add gretap1 type gretap remote 10.0.0.25
ip link set dev gretap1 up
ip link set dev gretap1 master bridge0
```

호스트 2과 연결한 "gretap2"라는 이름의 GRE Tap 인터페이스를 생성합니다. 해당 GRE Tap 인터페이스를 활성화합니다.GRE Tap 인터페이스를 "bridge0" 브리지에 연결합니다.

{% include codeHeader.html %} 
```bash
ip link add gretap2 type gretap remote 10.0.0.131
ip link set dev gretap2 up
ip link set dev gretap2 master bridge0
```

생성된 GREtap 인터페이스가 브리지와 연결되지 않으면 호스트1, 호스트 2간 통신이 되지 않습니다.

**3. 라우팅 설정**

Multicast를 위하여 Multicast 주소범위인 224.0.0.0/8의 트래픽을 "bridge0" 인터페이스로 라우팅합니다.

{% include codeHeader.html %} 
```bash
ip route add 224.0.0.0/8 dev bridge0
```

### 호스트 1 설정

**1. GREtap 인터페이스를 설정**

"gretap1"이라는 이름의 GRE Tap 인터페이스를 생성합니다. 해당 GRE Tap 인터페이스를 특정 마스터 IP로 설정합니다. IP 주소 "172.16.254.2/24"를 할당합니다. GRE Tap 인터페이스를 활성화합니다.

{% include codeHeader.html %} 
```bash
ip link add gretap1 type gretap remote 10.0.0.197
ip addr add 172.16.254.2/24 dev gretap1
ip link set gretap1 up
```

**2. 라우팅 설정**

Multicast 주소 범위인 224.0.0.0/8의 트래픽을 "gretap1" 인터페이스로 라우팅합니다.

{% include codeHeader.html %} 
```bash
ip route add 224.0.0.0/8 dev gretap1
```

### 호스트 2 설정

**1. GREtap 인터페이스를 설정**

"gretap1"이라는 이름의 GRE Tap 인터페이스를 생성합니다. 해당 GRE Tap 인터페이스를 특정 마스터 IP로 설정합니다. IP 주소 "172.16.254.3/24"를 할당합니다. GRE Tap 인터페이스를 활성화합니다.

{% include codeHeader.html %} 
```bash
ip link add gretap2 type gretap remote 10.0.0.197
ip addr add 172.16.254.3/24 dev gretap2
ip link set gretap2 up
```

**2. 라우팅 설정**

Multicast 주소 범위인 224.0.0.0/8의 트래픽을 "gretap2" 인터페이스로 라우팅합니다.

{% include codeHeader.html %} 
```bash
ip route add 224.0.0.0/8 dev gretap2
```

### Broadcast 테스트

앞서 GREtap으로 연결하고 172.16.254.0/24의 대역을 설정하였습니다. 
Broadcast는 아이피주소 대역의 가장 마지막 주소인 172.16.254.255로 테스트할수 있습니다. 

- 테스트하는 방법은 
  - 가장 빠른 방법은 ping으로 -b옵션을 주고 ICMP을 Boradcast으로 테스트해볼수 있습니다. 
  - 두번째 방법은 프로그램을 작성해서 테스트하는 방법이 있습니다. 


#### python 테스트
아래는 python 프로그램을 이용하여 broadcast 테스트하는 예제입니다. stackoverflow에 있는 글을 참조하여 작성하였습니다.
<https://stackoverflow.com/questions/64066634/sending-broadcast-in-python>{:target="_blank"}

메시지를 전송하는 스크립트와 수신하는 스크립트로 구분되어 있습니다.

**Broadcast 전송하는 스크립트 (bcast_send.py)**

{% include codeHeader.html %} 
```python
## 스크립트 작성합니다.
$> cat bcast_send.py

import socket
import time

MCAST_GRP = '172.16.254.255'
MCAST_PORT = 5005
MESSAGE = 'Hello, Broadcast!'

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)  # UDP
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

MSG_ID = 1
while True:
  SEND_MSG = MESSAGE + ' ' +str(MSG_ID)
  sock.sendto(SEND_MSG.encode('utf-8'), ("172.16.254.255", 5005))
  print("message sent!")
  time.sleep(1)
  MSG_ID += 1

## 스크립트를 실행합니다.
$> python bcast_send.py
```

**Broadcast 수신하는 스크립트 (bcast_rev.py)**

{% include codeHeader.html %} 
```python
## 스크립트 작성합니다.
$> cat bcast_rev.py
import socket 

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEPORT, 1)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.bind(("", 5005))
while True:  
    print(sock.recv(10240))

## 스크립트를 실행합니다.
$> python bcast_rev.py
```

**테스트 결과**

broadcast 테스트 결과입니다. 
수신하는 서버에서 데이터가 수신되는것을 확인할수 있습니다. 

```bash
[root@instance2 ~]# python bcast_rev.py
b'Hello, Broadcast! 1'
b'Hello, Broadcast! 2'
b'Hello, Broadcast! 3'
b'Hello, Broadcast! 4'
b'Hello, Broadcast! 5'
b'Hello, Broadcast! 6'
b'Hello, Broadcast! 7'
```

#### ping 테스트

ping을 통해서 brodcast되는지 확인할수 있습니다. 

마스터 서버에서 broadcast 테스트할때 가장 빠릅니다. 그이유는 broadcast메시지는 마스터서버를 경유하여 전송되기 때문입니다. 호스트 1번에서 테스트 수행하면 호스트 2번으로 메시지가 전송될때 마스터 서버를 거처서 호스트 2번으로 메시지가 전달됩니다.

```bash
## 마스터서버에서 테스트 수행
[root@instance1 ~]#  ping 172.16.254.255 -b -w 5
WARNING: pinging broadcast address
PING 172.16.254.255 (172.16.254.255) 56(84) bytes of data.
64 bytes from 172.16.254.1: icmp_seq=1 ttl=64 time=0.029 ms
64 bytes from 172.16.254.3: icmp_seq=1 ttl=64 time=0.248 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=1 ttl=64 time=0.248 ms (DUP!)
64 bytes from 172.16.254.1: icmp_seq=2 ttl=64 time=0.020 ms
64 bytes from 172.16.254.3: icmp_seq=2 ttl=64 time=0.263 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=2 ttl=64 time=0.264 ms (DUP!)
64 bytes from 172.16.254.1: icmp_seq=3 ttl=64 time=0.040 ms
64 bytes from 172.16.254.3: icmp_seq=3 ttl=64 time=0.278 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=3 ttl=64 time=0.309 ms (DUP!)
64 bytes from 172.16.254.1: icmp_seq=4 ttl=64 time=0.041 ms
64 bytes from 172.16.254.3: icmp_seq=4 ttl=64 time=0.299 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=4 ttl=64 time=0.343 ms (DUP!)
64 bytes from 172.16.254.1: icmp_seq=5 ttl=64 time=0.033 ms
64 bytes from 172.16.254.3: icmp_seq=5 ttl=64 time=0.288 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=5 ttl=64 time=0.363 ms (DUP!)

--- 172.16.254.255 ping statistics ---
5 packets transmitted, 5 received, +10 duplicates, 0% packet loss, time 4083ms
rtt min/avg/max/mdev = 0.020/0.204/0.363/0.125 ms
[root@instance1 ~]#

## 호스트 1에서 테스트 수행
[root@instance2 ~]# ping 172.16.254.255 -b -w 5
WARNING: pinging broadcast address
PING 172.16.254.255 (172.16.254.255) 56(84) bytes of data.
64 bytes from 172.16.254.2: icmp_seq=1 ttl=64 time=0.022 ms
64 bytes from 172.16.254.1: icmp_seq=1 ttl=64 time=0.302 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=1 ttl=64 time=0.481 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=2 ttl=64 time=0.031 ms
64 bytes from 172.16.254.1: icmp_seq=2 ttl=64 time=0.285 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=2 ttl=64 time=0.444 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=3 ttl=64 time=0.034 ms
64 bytes from 172.16.254.1: icmp_seq=3 ttl=64 time=0.307 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=3 ttl=64 time=0.481 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=4 ttl=64 time=0.034 ms
64 bytes from 172.16.254.1: icmp_seq=4 ttl=64 time=0.334 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=4 ttl=64 time=0.509 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=5 ttl=64 time=0.035 ms
64 bytes from 172.16.254.1: icmp_seq=5 ttl=64 time=0.344 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=5 ttl=64 time=0.507 ms (DUP!)

--- 172.16.254.255 ping statistics ---
5 packets transmitted, 5 received, +10 duplicates, 0% packet loss, time 4095ms
rtt min/avg/max/mdev = 0.022/0.276/0.509/0.188 ms
[root@instance2 ~]#

## 호스트 2에서 테스트 수행
[root@instance3 ~]# ping 172.16.254.255 -b -w 5
WARNING: pinging broadcast address
PING 172.16.254.255 (172.16.254.255) 56(84) bytes of data.
64 bytes from 172.16.254.3: icmp_seq=1 ttl=64 time=0.024 ms
64 bytes from 172.16.254.1: icmp_seq=1 ttl=64 time=0.264 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=1 ttl=64 time=0.546 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=2 ttl=64 time=0.044 ms
64 bytes from 172.16.254.1: icmp_seq=2 ttl=64 time=0.270 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=2 ttl=64 time=0.462 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=3 ttl=64 time=0.027 ms
64 bytes from 172.16.254.1: icmp_seq=3 ttl=64 time=0.263 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=3 ttl=64 time=0.399 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=4 ttl=64 time=0.039 ms
64 bytes from 172.16.254.1: icmp_seq=4 ttl=64 time=0.356 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=4 ttl=64 time=0.510 ms (DUP!)
64 bytes from 172.16.254.3: icmp_seq=5 ttl=64 time=0.039 ms
64 bytes from 172.16.254.1: icmp_seq=5 ttl=64 time=0.311 ms (DUP!)
64 bytes from 172.16.254.2: icmp_seq=5 ttl=64 time=0.471 ms (DUP!)

--- 172.16.254.255 ping statistics ---
5 packets transmitted, 5 received, +10 duplicates, 0% packet loss, time 4099ms
rtt min/avg/max/mdev = 0.024/0.268/0.546/0.185 ms
[root@instance3 ~]#
```

### Multicast 테스트

Mutlicast 테스트를 위하여 python으로 작성했습니다. 

#### python 테스트

아래 스크립트는 아래 stackoverflow에 있는 댓글을 참조하여 작성하였습니다. 
<https://stackoverflow.com/questions/603852/how-do-you-udp-multicast-in-python>{:target="_blank"}

대부분 그대로 작성하였지만, Send스크립트에서 loop하는 부분을 추가하였습니다.

**Multicast 전송하는 스크립트 (mcast_send.py)**

{% include codeHeader.html %} 
```python 
$> vi mcast_send.py
import socket
import time

MCAST_GRP = '224.1.1.1'
MCAST_PORT = 5007
MESSAGE = 'Hello, Multicast!'

# regarding socket.IP_MULTICAST_TTL
# ---------------------------------
# for all packets sent, after two hops on the network the packet will not
# be re-sent/broadcast (see https://www.tldp.org/HOWTO/Multicast-HOWTO-6.html)
MULTICAST_TTL = 2

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, MULTICAST_TTL)

# For Python 3, change next line to 'sock.sendto(b"robot", ...' to avoid the
# "bytes-like object is required" msg (https://stackoverflow.com/a/42612820)
MSG_ID = 1

while True:
  SEND_MSG = MESSAGE + ' ' +str(MSG_ID)
  sock.sendto(SEND_MSG.encode('utf-8'), (MCAST_GRP, MCAST_PORT))
  print("message sent!")
  time.sleep(1)
  MSG_ID += 1

```
**Multicast 수신하는 스크립트 (mcast_rev.py)**

{% include codeHeader.html %} 
```python
$> vi mcast_rev.py
import socket
import struct

MCAST_GRP = '224.1.1.1'
MCAST_PORT = 5007
IS_ALL_GROUPS = True

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
if IS_ALL_GROUPS:
  # on this port, receives ALL multicast groups
  sock.bind(('', MCAST_PORT))
else:
  # on this port, listen ONLY to MCAST_GRP
  sock.bind((MCAST_GRP, MCAST_PORT))
mreq = struct.pack('4sl', socket.inet_aton(MCAST_GRP), socket.INADDR_ANY)

sock.setsockopt(socket.IPPROTO_IP, socket.IP_ADD_MEMBERSHIP, mreq)

while True:
  # For Python 3, change next line to "print(sock.recv(10240))"
  print(sock.recv(10240))
```

**Multicast 수신 결과**

```bash
[root@instance2 ~]# python mcast_rev.py
b'Hello, Multicast! 1'
b'Hello, Multicast! 2'
b'Hello, Multicast! 3'
b'Hello, Multicast! 4'
b'Hello, Multicast! 5'
b'Hello, Multicast! 6'
b'Hello, Multicast! 7'
...
```

## 마무리 

클라우드 네트워크에서 UDP/IP 전송시 multicast와 broadcast전송 방법에 대해서 알아보았습니다. 클라우드 Native한 기술은 아니지만 호스트 서버내에서 네트워크설정만으로 가능하고 또한 생각보다 쉽게 구성이 가능합니다. 

좀더 생각해보면 추가적인 고려사항이 있을것 같습니다. 마스터 서버가 down되었을 경우처럼 장애가 발생되었을 때는? 업무에서 요구되는 성능이 나올것인가? 등 다양한 업무 요건이외 아키텍쳐적으로 SPOF가 없는지 검토가 필요할것 같습니다. 

온프레미스 환경에서는 네트워크 분리 및 설정만으로 쉽게 구성이 가능했지만, 클라우드 환경에서는 클라우드 환경에 맞는 관리 방법이 존재하는것 같습니다. 

## 참고자료

- ChatGPT에 많이 물어보았습니다.