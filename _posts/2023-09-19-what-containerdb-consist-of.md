---
layout: single
title: Container DB의 파일 구조
date: 2023-09-19 02:00
categories: 
  - Oracle
books:
 - multitenant
author: 
tags: 
   - Oracle
   - multitenant
   - container db
excerpt : Container DB의 파일 구조에 대해서 알아봅니다.
header :
  teaser: /assets/images/blog/multitenant.jpg
  overlay_image: /assets/images/blog/multitenant.jpg
toc : true  
toc_sticky: true
---

## 개요

Container DB는 Non-CDB와 비슷한 구조로 구성되어 있습니다.
Container DB 내에서 파일들이 어떻게 관리되는지 알아보겠습니다.

## 데이터베이스를 구성하는 파일들

오라클 데이터베이스를 구성하는 주요 파일들은 어떤 것들이 있을까요?

- 데이터베이스 구성요소
  - spfile : 인스턴스 환경설정 정보
  - control files : 데이터 무결성을 위한 SCN번호 및 백업정보 저장
  - redo log files : 데이터 변경이력 (복구를 위해 사용)
  - data files : 인스턴스 정보 및 업무데이터가 저장된 파일
  - temp files : 정렬작업을 위한 공간
  - (optional) archived logs, flashback logs 

위 내용을 보면 알겠지만, Container DB는 일반적인 Non-CDB와 동일한 구조를 가지고 있습니다. 그리고 그 위에 올라가는 Pluggable DB도 일반적인 데이터베이스 구성 요소를 그대로 갖고 있습니다.

Container DB는 Pluggable DB를 관리하는 역할을 수행합니다. 따라서 Container DB는 여러 개의 Pluggable DB의 dictionary 정보를 통합해서 조회할 수 있는 기능을 제공하고 있습니다. 여러 개의 Pluggable DB(PDB)의 dictionary을 볼 때 각 PDB별로 구분이 되어야 할 것입니다. 그래서 오라클 데이터베이스 dictionary에 CON_ID 컬럼이 추가되었습니다.

### Container의미 및 CON_ID의 이해

Container DB에서는 모든 DB들이 Container입니다. Container DB 자체도 하나의 Container이며, 그 위에 올라가는 Pluggable DB도 또한 Container입니다. 각 Container들은 고유의 ID와 Name을 가지게 됩니다.

Container DB에서는 CON_ID 컬럼 값을 이용하여 어느 Container의 데이터인지 쉽게 구분할 수 있습니다. 이 때 말하는 '데이터'는 dictionary 데이터를 의미합니다. 오라클 데이터베이스의 dictionary 테이블을 desc로 확인하면 CON_ID가 들어간 것을 확인할 수 있습니다. Multitenant는 12c부터 지원되는 기능으로, 12c부터 Non-CDB 환경이든 CDB 환경이든 모두 동일한 Dictionary를 사용하고 있어서 Non-CDB에서도 CON_ID를 확인할 수 있습니다. Non-CDB 환경에서는 CON_ID 값이 모두 0으로 나타나지만, CDB 환경에서는 CON_ID 값을 통해 어느 Container의 데이터인지 확인할 수 있습니다.


- CON_ID값의 의미
  - 0일경우 - 특정 Container와 관련없이 CDB 전체와 관련된 데이터를 의미합니다.
  - 1일경우 - CDB$ROOT와 관련된 데이터를 의미합니다. (Container DB의 Container Name은 CDB$ROOT입니다. )
  - 2일경우 - PDB$SEED와 관련된 데이터를 의미합니다. (PDB$SEED는 사용자 PDB를 생성하기 위한 템플릿 PDB로 Container name은 PDB$SEED입니다.)
  - 3이상일 경우 - 사용자가 생성한 PDB와 관련된 데이터를 의미합니다. 

```sql
-- Container 목록 확인
SQL> select name, con_id,dbid, con_uid, guid from v$containers order by con_id;
NAME                     CON_ID       DBID    CON_UID GUID
-------------------- ---------- ---------- ---------- --------------------------------
CDB$ROOT                      1 1108973582          1 86B637B62FDF7A65E053F706E80A27CA
PDB$SEED                      2 1290924503 1290924503 FA51EB9D6E771B7CE0532A00000AC69E
PDB1                          3  909607496  909607496 FA520FA5EE3E396FE0532A00000AD419
```

## CDB의 데이터파일 구조

Container DB에 접속하여 데이터 파일 정보를 확인할 수 있습니다.
Container DB의 이름은 CDB$ROOT이며 con_id는 1입니다.
control file과 online redo log는 데이터베이스의 공통된 영역으로 Container DB와 Pluggable DB 둘 다 함께 사용합니다.
이 파일들은 데이터베이스 전체에서 공유되므로 con_id 값은 0으로 나타납니다.
Container DB에서 Dictionary를 조회하면 모든 Container들의 정보를 함께 조회할 수 있습니다.

```sql
-- con_id확인 (con_id가 1은 Container DB를 의미함)
SQL> show con_id
CON_ID
------------------------------
1
-- PDB목록확인
SQL> show pdbs
    CON_ID CON_NAME                       OPEN MODE  RESTRICTED
---------- ------------------------------ ---------- ----------
         2 PDB$SEED                       READ ONLY  NO
         3 PDB1                           READ WRITE NO
-- Control file 확인
SQL> select con_id, name  from v$controlfile;
   CON_ID NAME
---------- -----------------------------------------------------------------------------
         0 /oradata/CDB1/controlfile/o1_mf_l4nw6gdm_.ctl
         0 /oradata/fast_recovery_area/CDB1/controlfile/o1_mf_l4nw6gkt_.ctl
-- online redo logfile 확인
SQL> select con_id, group#, member from v$logfile order by group#;
    CON_ID     GROUP# MEMBER
---------- ---------- ---------------------------------------------------------------------------
         0          1 /oradata/CDB1/onlinelog/o1_mf_1_l4nw6jvq_.log
         0          1 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_1_l4nw6k5b_.log
         0          2 /oradata/CDB1/onlinelog/o1_mf_2_l4nw6jw2_.log
         0          2 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_2_l4nw6k6s_.log
         0          3 /oradata/CDB1/onlinelog/o1_mf_3_l4nw6jwr_.log
         0          3 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_3_l4nw6k6l_.log
-- data file 확인
SQL> select con_id, name from v$datafile order by con_id;
    CON_ID NAME
---------- --------------------------------------------------------------------------------------
         1 /oradata/CDB1/datafile/o1_mf_system_l4nw3247_.dbf
         1 /oradata/CDB1/datafile/o1_mf_sysaux_l4nw4h7n_.dbf
         1 /oradata/CDB1/datafile/o1_mf_undotbs1_l4nw58bc_.dbf
         1 /oradata/CDB1/datafile/o1_mf_users_l4nw59dg_.dbf
         2 /oradata/CDB1/datafile/o1_mf_system_l4nwcqfp_.dbf
         2 /oradata/CDB1/datafile/o1_mf_sysaux_l4nwcqfs_.dbf
         2 /oradata/CDB1/datafile/o1_mf_undotbs1_l4nwcqfw_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_system_l4nwzkpg_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_sysaux_l4nwzkpv_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_users_l4nwzx6x_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_undotbs1_l4nwzkpv_.dbf
-- temp file 확인
SQL> select con_id, name from v$tempfile order by con_id;
    CON_ID NAME
---------- ---------------------------------------------------------------------------------------
         1 /oradata/CDB1/datafile/o1_mf_temp_l4nw700w_.tmp
         2 /oradata/CDB1/datafile/temp012023-04-27_12-59-00-827-PM.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_temp_l4nwzkpw_.dbf 
```

## PDB의 데이터파일 구조

애플리케이션이 접근 가능한 Pluggable DB에 접속하여 파일 구조를 확인해보겠습니다.
해당 Pluggable DB에서 Dictionary를 조회하면 다른 Container의 데이터를 함께 조회하지 않고, 접속한 환경의 정보만 확인됩니다.
각 Container들은 명확하게 격리되어 있는 것을 확인할 수 있습니다.
Control file과 online redolog 파일들은 공통된 영역으로 Dictionary에서 같이 조회할 수 있습니다.

```sql
SQL> alter session set container=pdb1;
Session altered.
-- con_id확인
SQL> show con_id
CON_ID
------------------------------
3
SQL> select con_id, name  from v$controlfile;
   CON_ID NAME
---------- -----------------------------------------------------------------------------
         0 /oradata/CDB1/controlfile/o1_mf_l4nw6gdm_.ctl
         0 /oradata/fast_recovery_area/CDB1/controlfile/o1_mf_l4nw6gkt_.ctl
-- online redo logfile 확인
SQL> select con_id, group#, member from v$logfile order by group#;
    CON_ID     GROUP# MEMBER
---------- ---------- ------------------------------------------------------------------------
         0          1 /oradata/CDB1/onlinelog/o1_mf_1_l4nw6jvq_.log
         0          1 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_1_l4nw6k5b_.log
         0          2 /oradata/CDB1/onlinelog/o1_mf_2_l4nw6jw2_.log
         0          2 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_2_l4nw6k6s_.log
         0          3 /oradata/CDB1/onlinelog/o1_mf_3_l4nw6jwr_.log
         0          3 /oradata/fast_recovery_area/CDB1/onlinelog/o1_mf_3_l4nw6k6l_.log
-- data file 확인
SQL> select con_id, name from v$datafile order by con_id;
    CON_ID NAME
---------- --------------------------------------------------------------------------------------
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_system_l4nwzkpg_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_users_l4nwzx6x_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_undotbs1_l4nwzkpv_.dbf
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_sysaux_l4nwzkpv_.dbf
-- temp file 확인
SQL>  select con_id, name from v$tempfile order by con_id;
    CON_ID NAME
---------- -------------------------------------------------------------------------------------
         3 /oradata/CDB1/FA520FA5EE3E396FE0532A00000AD419/datafile/o1_mf_temp_l4nwzkpw_.dbf
```

## 마무리

Container DB의 데이터 파일 구조에 대해 알아보았습니다. Control file과 Online Redolog은 공통으로 사용되지만, 각 Container마다 system, sysaux, temp 등은 독립적으로 존재합니다. 그래서 하나의 데이터베이스로 통합된것이 아니라 분리된 데이터베이스들을 통합적으로 관리하는 관점으로 접근하면 좀더 쉽게 이해할수 있습니다.

Container DB내부적으로 dictionary link기능이 구현되어 있기 때문에 Container DB에서는 여러개의 Pluggable DB를 편리하게 관리하고, Pluggable DB의 이동 기술들을 구현할 수 있습니다.