---
layout: single
title: 리눅스에서 Minikube설치하기
date: 2024-02-15 21:00
categories: 
  - container
author: 
tags: 
  - linux
  - podman
excerpt : Linux에서 Minikube설치하는 절차에 대해서 알아보겠습니다.
header :
  teaser: /assets/images/blog/cloud2.jpg
  overlay_image: /assets/images/blog/cloud2.jpg
toc : true  
toc_sticky: true
---

## 들어가며

Kubernetes의 미니 버전인 minikube를 설치하는 방법에 대해서 정리하였습니다.

minikube 홈페이지에서 설치하기 쉽게 설명되고 있어서 직접 수행한 명령어와 로그들을 같이 정리하였습니다. 
- minikube 문서 : <https://minikube.sigs.k8s.io/docs/start/>{:target="_blank"}

## Minikube 

Minikube는 Kubernetes를 로컬 개발 환경에서 쉽게 실행하고 관리할 수 있게 도와주는 도구입니다. 개발자들이 Kubernetes 클러스터를 간편하게 설정하고 실험하며 애플리케이션을 개발하는 데 사용됩니다.

Minikube를 사용하면 개발자는 로컬 머신에서 단일 노드 Kubernetes 클러스터를 실행할 수 있습니다. 
실제 운영 환경이 아닌 로컬에서도 Kubernetes를 사용하여 애플리케이션을 테스트하고 디버깅할 수 있습니다.

Minikube 시작을 위해서는 Container 혹은 Virtual Machine Manager가 필요하며 `minikube start --driver=가상화환경` 명령어를 설정하여 해당 가상화 환경에서 지원하는 드라이버를 사용하게 됩니다. 

MiniKube설치를 위한 시스템 요건

- 2 CPUs이상, 2GB 메모리, 20G 디스크
- 인터넷연결이 되는 환경
- Container 혹은 Virtual Machine Manager가 필요 
  - Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation
- 설치유저는 sudo 권한이 있어야함.
  
저는 Redhat 계열 리눅스서버에서 설치하도록 하겠습니다.

{% include codeHeader.html runas="Any User" copyable="false" codetype="Shell" elapsedtime="1 sec" %}
```bash
$> cat /etc/redhat-release
Red Hat Enterprise Linux release 8.9 (Ootpa)
```

### 1. Minikube 설치

root유저로 접속하여 minikube 를 설치합니다.

{% include codeHeader.html runas="root" copyable="true" codetype="Shell" elapsedtime="10 sec" %}
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
rpm -Uvh minikube-latest.x86_64.rpm
``` 

설치 로그입니다. 

```bash
$> curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 19.3M  100 19.3M    0     0  13.4M      0  0:00:01  0:00:01 --:--:-- 13.4M
$> rpm -Uvh minikube-latest.x86_64.rpm
Verifying...                          ################################# [100%]
Preparing...                          ################################# [100%]
Updating / installing...
   1:minikube-1.32.0-0                ################################# [100%]
```

### 2. Cluster 기동

root유저가 아닌 다른 관리자(oracle)유저로 접속하여 Cluster를 기동합니다. 

{% include codeHeader.html  runas="oracle" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash
minikube start
```

Cluster기동이 필요한 container환경이 없을 경우 아래과 에러가 발생됩니다.

```bash
* minikube v1.32.0 on Oracle 8.9 (kvm/amd64)
* Unable to pick a default driver. Here is what was considered, in preference order:
* Alternatively you could install one of these drivers:
 - docker: Not installed: exec: "docker": executable file not found in $PATH
 - kvm2: Not installed: exec: "virsh": executable file not found in $PATH
 - podman: Not installed: exec: "podman": executable file not found in $PATH
 - qemu2: Not installed: exec: "qemu-system-x86_64": executable file not found in $PATH
 - virtualbox: Not installed: unable to find VBoxManage in $PATH

X Exiting due to DRV_NOT_DETECTED: No possible driver was detected. Try specifying --driver, or see https://minikube.sigs.k8s.io/docs/start/
```

root유저로 podman을 설치하였습니다.
{% include codeHeader.html runas="root" copyable="true" codetype="Shell" elapsedtime="30 sec" %}
```bash
yum install podman
```

minikube 클러스터 관리(oracle)유저가 podman을 수행하시키도록 sudo 권한을 추가합니다.
root유저로 사용자를 추가합니다. 

{% include codeHeader.html  name="/etc/sudoers" runas="root" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash
echo 'oracle ALL=(ALL) NOPASSWD: /usr/bin/podman' | tee -a /etc/sudoers
```

root유저가 아닌 다른 관리자(oracle)유저로 접속하여 Cluster를 기동합니다. 

{% include codeHeader.html  runas="oracle" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash
minikube start --driver=podman
```

minikube 실행 로그입니다. `E0218`로 시작되는 에러는 추후에 개선된예정이므로 무시하면 됩니다.

```bash
$> minikube start
* minikube v1.32.0 on Oracle 8.9 (kvm/amd64)
* Automatically selected the podman driver
* Using Podman driver with root privileges
* Starting control plane node minikube in cluster minikube
* Pulling base image ...
* Downloading Kubernetes v1.28.3 preload ...
    > gcr.io/k8s-minikube/kicbase...:  453.90 MiB / 453.90 MiB  100.00% 36.62 M
    > preloaded-images-k8s-v18-v1...:  403.35 MiB / 403.35 MiB  100.00% 31.47 M
E0218 07:19:00.646554   61763 cache.go:189] Error downloading kic artifacts:  not yet implemented, see issue #8426
* Creating podman container (CPUs=2, Memory=3900MB) ...
* Preparing Kubernetes v1.28.3 on Docker 24.0.7 ...
  - Generating certificates and keys ...
  - Booting up control plane ...
  - Configuring RBAC rules ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
* kubectl not found. If you need it, try: 'minikube kubectl -- get pods -A'
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### 3. kubectl 설치 

kubectl 설치를 합니다. `mimikube`명령어를 이용하면 적절한 kubectl를 다운로드 받아서 설치합니다.

{% include codeHeader.html  runas="oracle" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash
minikube kubectl -- get po -A
```

kubectl설치 로그입니다.

```bash
$> minikube kubectl -- get po -A
    > kubectl.sha256:  64 B / 64 B [-------------------------] 100.00% ? p/s 0s
    > kubectl:  47.56 MiB / 47.56 MiB [-------------------] 100.00% ? p/s 200ms
NAMESPACE     NAME                               READY   STATUS    RESTARTS      AGE
kube-system   coredns-5dd5756b68-dg4q4           1/1     Running   0             107s
kube-system   etcd-minikube                      1/1     Running   0             2m
kube-system   kube-apiserver-minikube            1/1     Running   0             2m
kube-system   kube-controller-manager-minikube   1/1     Running   0             2m2s
kube-system   kube-proxy-ww7mh                   1/1     Running   0             107s
kube-system   kube-scheduler-minikube            1/1     Running   0             2m
kube-system   storage-provisioner                1/1     Running   1 (76s ago)   118s
```

kubectl명령어에 대한 alias를 설정합니다.

{% include codeHeader.html  runas="oracle" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash
alias kubectl="minikube kubectl --"
```

kubectl명령어로 minikube내 component들을 확인합니다. 

{% include codeHeader.html  runas="oracle" copyable="true" codetype="Shell" elapsedtime="5 sec" %}
```bash 
kubectl get all
```

```bash
$> kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   13m
```

### Cluster 관리

Kubernetes(minikube)를 잠시 중지합니다.
```bash
minikube pause
```

Kubernetes(minikube)를 재개합니다.
```bash
minikube unpause
```

Kubernetes(minikube)를 중지합니다.
```bash
minikube stop
```

Kubernetes(minikube)를 삭제합니다.
```bash
minikube delete --all
```

## 마무리 

minikube와 podman을 이용한 설치 방법에 대해서 알아보았습니다. 

Kubernetes는 여러노드로 cluster구성해야되서 부담이 되었는데, minikube를 이용하면 PC환경에서 쉽게 테스트해볼수 있습니다. 다양한 서비스들, 컴포넌트를 이용해서 사이드 프로젝트를 진행해봐야겠습니다.

## 참고문서 

- minikube 문서 : <https://minikube.sigs.k8s.io/docs/start/>{:target="_blank"}
- Install Minikube on Oracle Linux : <https://luna.oracle.com/lab/8b2f7860-3204-4cd3-8d55-3f6de9ca03c2/steps>{:target="_blank"}