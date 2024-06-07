---
layout: single
title: Linux환경에서 Network Latency를 발생시키는 방법
date: 2024-03-12 21:00
categories: 
  - linux
author: 
tags: 
  - linux
  - cloud
excerpt : 가상으로 Network Latency를 발생시키는 방법에 정리하였습니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 테스트 환경

|호스트명|서버환경|서버종류|OS종류|OS버전|Public망|Private망|
|-|-|-|-|-|-|-|-|
|inst1|OCI|VM(x86)|Oracle Linux|8.9|ens3 - 10.0.0.206|ens5 - 10.0.3.121|
|inst2|OCI|VM(x86)|Oracle Linux|8.9|ens3 - 10.0.0.245|ens5 - 10.0.3.249|

## 들어가며 

서버간 네트워크 연결이 되면 패킷을 주고 받으면서 통신을 하게 되는데, 물리적인 네트워크 연경상태, 회선크기, 거리에 따라서 다양한 영향요소로 있을수 있습니다.
대표적으로 네트워크 전송양을 의미하는 대역폭(bandwidth), 데이터 송수신하는데 걸리는 시간(Latency)으로 표현하는데요, 네트워크 환경에 따라 애플리케이션 혹은 DB성능 테스트틀 하려고 하면 동일한 네트워크 환경을 구성하여 테스트 하기 어렵습니다. 

리눅스 명령어로 간단하게 재현할수 있는 방법에 대해서 설명합니다. 

## 네트워크 트래픽 제어 방법

물리적인 네트워크 연결상태에 따라 다르겠지만 일부러 대역폭을 줄이거나 지연시간을 발생시키고 싶을때 사용하는 방법입니다. (성능을 더 좋게 하는것이 아니라 일부러 지연을 발생시키거나 대역폭을 제한하는 방법입니다.)

리눅스에서 네트워크 트래픽을 제어하는 tc(Traffic Control)명령어을 제공합니다. 
tc명령어 중에 tc qdisc(queue discrp이용하면 대역폭과 지연시간을 강제로 조정할수 있습니다. 

tc qdisc는 대기열 디스크립터를 설정하는 명령어입니다. 
사용할 디스크립터는 tbf, netem 입니다. 

tbf는 대역폭 제어, netem는 Delay를 발생시킬때 사용합니다. 

QDISC_KIND목록에 netem은 없는것으로 확인되었습니다. 
만약 디스크립터가 설치 되어 있지 않다면, 설치가 필요합니다. 

```
[root@inst2 ~]# tc qdisc add dev ens5 root netem delay 100ms
Error: Specified qdisc kind is unknown
```

```shell
yum install kernel-modules-extra kernel-debug-modules-extra
-- 서버재기동필요 
reboot
modprobe sch_netem
```

tc -s qdisc show dev ens5
tc qdisc help

ens5에 1Mbps로 대역폭을 설정했습니다.
```shell
tc qdisc delete dev ens5 root
tc qdisc add dev ens5 root tbf rate 10mbit burst 8kb limit 10000000
tc qdisc show
```
tc qdisc add dev ens5 root tbf rate 256kbit buffer 1600 limit 3000

tc qdisc add dev ens5 root tbf limit 10mbit burst 8kb rate 100mbit 

패킷딜레이 
tc qdisc add dev ens5 root netem delay 100ms

패킷손실
tc qdisc add dev ens5 root netem loss 50%

패키중복
tc qdisc add dev ens5 root netem dupliate 50%

패킷에러
tc qdisc add dev eth0 root netem corrup 50%


iperf3 -s

iperf3 -c 10.0.3.121 
tc qdisc add dev ens5 root netem rate 100mbit


tc qdisc add dev ens5 root tbf ra

tc qdisc add dev ens5 root netem delay 1ms

```shell
tc qdisc add dev ens5 root rate 1mbit 
```


---


ts qdisc설정내용을 확인합니다. 
```shell 
tc qdisc show
```

대역폭(bandwidth) 제한을 추가합니다.
```shell
tc qdisc add dev ens5 root tbf rate 1mbit burst 32kbit limit 1000
```

지연시간(latency) 발생을 추가합니다.
```shell
tc qdisc add dev ens5 root  netem delay 1ms
```

## 측정 도구 

tc명령어로 대역폭 및 통신시간을 확인할때 필요한 측정 도구들입니다. 

- iperf3 : 대역폭 측정
- ping : 통신소요시간 측정

### 1. 네트워트 대역폭 측정 방법

iperf3는 네트워크 대역폭을 측정하기 위한 도구로, 클라이언트와 서버 간의 통신을 통해 대역폭을 측정할수 있습니다. 

OS내부 방화벽이 있을경우 통신이 되지 않으므로 5201포트로 오픈해놓습니다. 

```shell
firewall-cmd --zone=public --list-ports
firewall-cmd --zone=public --add-port=5201/tcp --permanent
firewall-cmd --reload
```

수행결과입니다.
```shell
[root@inst1 ~]#  firewall-cmd --zone=public --list-ports
5201/tcp
```

iperf3는 서버 모두 실행이 되어야합니다. 한쪽서버는 server역할, 다른 서버는 client역할을 하게 됩니다. 

server 역할을 담당하는 서버에서는 -s옵션을 사용합니다.

```shell
iperf3 -s
```

client 역할을 담당하는 서버에서는 server역할을 담당하는 서버의 IP와 -c 옵션을 같이 사용합니다.

```shell
iperf3 -c [server 서버주소]
```

수행결과입니다. 

inst1 서버가 server역할을 합니다. 

```shell
[root@inst1 ~]#  iperf3 -s
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
Accepted connection from 10.0.3.249, port 56306
[  5] local 10.0.3.121 port 5201 connected to 10.0.3.249 port 56318
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   120 MBytes  1.01 Gbits/sec
[  5]   1.00-2.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   2.00-3.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   3.00-4.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   4.00-5.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   5.00-6.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   6.00-7.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   7.00-8.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   8.00-9.00   sec   124 MBytes  1.04 Gbits/sec
[  5]   9.00-10.00  sec   124 MBytes  1.04 Gbits/sec
[  5]  10.00-10.06  sec  7.85 MBytes  1.04 Gbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.06  sec  1.22 GBytes  1.04 Gbits/sec                  receiver
-----------------------------------------------------------
Server listening on 5201
-----------------------------------------------------------
```

inst2가 client역할을 하며 inst1로 접속해서 네트워크 대역폭을 확인합니다. 

```shell
[root@inst2 ~]# iperf3 -c 10.0.3.121
Connecting to host 10.0.3.121, port 5201
[  5] local 10.0.3.249 port 56318 connected to 10.0.3.121 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   128 MBytes  1.07 Gbits/sec    0   3.12 MBytes
[  5]   1.00-2.00   sec   125 MBytes  1.05 Gbits/sec    0   3.12 MBytes
[  5]   2.00-3.00   sec   124 MBytes  1.04 Gbits/sec    0   3.12 MBytes
[  5]   3.00-4.00   sec   124 MBytes  1.04 Gbits/sec    0   3.12 MBytes
[  5]   4.00-5.00   sec   124 MBytes  1.04 Gbits/sec    0   3.12 MBytes
[  5]   5.00-6.00   sec   125 MBytes  1.05 Gbits/sec    0   3.12 MBytes
[  5]   6.00-7.00   sec   124 MBytes  1.04 Gbits/sec    0   3.12 MBytes
[  5]   7.00-8.00   sec   124 MBytes  1.04 Gbits/sec    0   3.12 MBytes
[  5]   8.00-9.00   sec   125 MBytes  1.05 Gbits/sec    0   3.12 MBytes
[  5]   9.00-10.00  sec   124 MBytes  1.04 Gbits/sec    7   3.12 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  1.22 GBytes  1.04 Gbits/sec    7             sender
[  5]   0.00-10.06  sec  1.22 GBytes  1.04 Gbits/sec                  receiver
```

> 약 1Gbps 대역폭을 가지고 있는것을 알수 있습니다. 

### 2. 네트워크 통신 시간 측정 방법

네트워크 통신 시간을 측정할때 ping도구를 사용할수 있습니다. latency가 얼마가 있는지 직관적으로 판단할수 있는 도구입니다.

하나의 서버에서 다른 서버로 ping을 실행합니다. 
```shell
ping [대상서버주소] -c [횟수]
```

수행결과입니다. 

```shell
[root@inst2 ~]# ping 10.0.3.121 -c 10
PING 10.0.3.121 (10.0.3.121) 56(84) bytes of data.
64 bytes from 10.0.3.121: icmp_seq=1 ttl=64 time=0.408 ms
64 bytes from 10.0.3.121: icmp_seq=2 ttl=64 time=0.262 ms
64 bytes from 10.0.3.121: icmp_seq=3 ttl=64 time=0.222 ms
64 bytes from 10.0.3.121: icmp_seq=4 ttl=64 time=0.253 ms
64 bytes from 10.0.3.121: icmp_seq=5 ttl=64 time=0.250 ms
64 bytes from 10.0.3.121: icmp_seq=6 ttl=64 time=0.260 ms
64 bytes from 10.0.3.121: icmp_seq=7 ttl=64 time=0.276 ms
64 bytes from 10.0.3.121: icmp_seq=8 ttl=64 time=0.267 ms
64 bytes from 10.0.3.121: icmp_seq=9 ttl=64 time=0.266 ms
64 bytes from 10.0.3.121: icmp_seq=10 ttl=64 time=0.245 ms

--- 10.0.3.121 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 9203ms
rtt min/avg/max/mdev = 0.222/0.270/0.408/0.052 ms
[root@inst2 ~]#
```

> 네트워크 통신시 평균 0.2ms의 시간이 소요되었습니다.


## 네트워크 제어 테스트 수행

## 1. 테스트 환경

inst1, inst2 두개의 서버가 있습니다. 각 서버에는 두개의 vnic이 있습니다. 
ens3는 public망이고 ens5는 private 망으로 설정했습니다. 

네트워크 전송테스트를 할 인터페이스는 ens5 입니다. 
- 대역폭(bandwidth) 1Gbps, 통신시간(latency) 0.2 ms

```shell
[root@inst1 ~]# ip addr show ens5
3: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:00:17:03:3b:bc brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    inet 10.0.3.121/24 scope global ens5
       valid_lft forever preferred_lft forever
```

```shell
[root@inst2 ~]# ip addr show ens5
3: ens5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:00:17:01:0c:08 brd ff:ff:ff:ff:ff:ff
    altname enp0s5
    inet 10.0.3.249/24 scope global ens5
       valid_lft forever preferred_lft forever
```

## 2. 네트워크 대역폭 제어 테스트

ens5에 1Mbps로 대역폭을 설정했습니다.
```shell
tc qdisc delete dev ens5 root
tc qdisc add dev ens5 root tbf rate 10mbit burst 8kb limit 10000000
tc qdisc show
```

tc qdisc add dev ens5 root tbf limit 10mbit burst 8kb rate 100mbit 


패킷손실
tc qdisc add dev eth0 root netem loss 50%

iperf3 -s

iperf3 -c 10.0.3.121 -l 4Kb
tc qdisc add dev ens5 root netem rate 100mbit


tc qdisc add dev ens5 root tbf ra

tc qdisc add dev ens5 root netem delay 1ms

```shell
tc qdisc add dev ens5 root rate 1mbit 
```

## 마무리 


## 참고자료

https://blogs.oracle.com/cloud-infrastructure/post/linux-traffic-controller-latency-fetch-size-db