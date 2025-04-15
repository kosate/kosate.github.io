---
layout: single
title: Hybrid Data Guard 구성 방법
date: 2024-12-25 21:00
categories: 
  - Oracle
tags: 
   - Hybrid Data Guard
   - Active DataGuard
   - Redo Decrpytion
excerpt : "🚀 OCI Base Database Service를 Disater Recovery로 사용하여 Active DataGuard를 구성하는 방법을 소개합니다."
header : 
  teaser: /assets/images/blog/blog5.jpg
  overlay_image: /assets/images/blog/blog5.jpg
toc : true  
toc_sticky: true
---

## 들어가며


## Hybrid Data Guard 구성 방법

SQL> select name from v$datafile;

NAME
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/DB19C/system01.dbf
/u01/app/oracle/oradata/DB19C/sysaux01.dbf
/u01/app/oracle/oradata/DB19C/undotbs01.dbf
/u01/app/oracle/oradata/DB19C/users01.dbf

SQL> select member from V$logfile;
MEMBER
--------------------------------------------------------------------------------
/u01/app/oracle/oradata/DB19C/redo03.log
/u01/app/oracle/oradata/DB19C/redo02.log
/u01/app/oracle/oradata/DB19C/redo01.log




alter system reset db_domain scope=spfile sid='*';
alter system set global_names=false scope=both sid='*';       
update sys.props$ set value$='DB19C' where name = 'GLOBAL_DB_NAME';
select * from global_name;


db19c_prod19c =
    (DESCRIPTION=
      (ADDRESS=(PROTOCOL= TCP)(HOST= 10.0.0.242)(PORT= 1522))
      (CONNECT_DATA=
        (SERVER= DEDICATED)
        (SERVICE_NAME= DB19C_PROD19C)))

db19c_stb19c =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST =10.0.0.93 )(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = DB19C_STB19c)
    )
  )



## standby db삭제
 
srvctl config database -d db19c_stb19c

vi rm_dbfiles.sql
set heading off linesize 999 pagesize 0 feedback off trimspool on
spool /home/oracle/files.lst
select 'asmcmd rm '||name from v$datafile union all select 'asmcmd rm '||name from v$tempfile union all select 'asmcmd rm '||member from v$logfile;
spool off
create pfile='/home/oracle/db19c_stb19c.pfile' from spfile;         

sqlplus "/ as sysdba"
SQL> @rm_dbfiles.sql
SQL> exit

chmod 777 files.lst
srvctl stop database -d db19c_stb19c
./files.lst

## 패스워드키 설정

alter user sys identified by "WElcome12345##";
cp $ORACLE_HOME/dbs/orapwprod19c /tmp/orapwprod19c
scp -i ~/.ssh/privatekey /tmp/orapwprod19c opc@10.0.0.93:/tmp/orapwprod19c 


- 패스워드파일 위치 확인
srvctl config database -d db19c_stb19c
- 패스워드파일 복사
sudo su - grid
ASMCMD> pwcopy --dbuniquename DB19C_STB19C -f /tmp/orapwprod19c   +DATA/DB19C_STB19C/PASSWORD/pwfile
ls -al +DATA/DB19C_STB19C/PASSWORD/pwfile
- 패스워드 파일 위치 변경
srvctl modify database -d DB19C_STB19C -pwfile +DATA/DB19C_STB19C/PASSWORD/pwddb19c_stb19c.275.1190987783


## Standby DB구성  

- DR
startup mount
alter system set db_file_name_convert='/u01/app/oracle/oradata/DB19C','+DATA/DB19C_STB19C/DATAFILE' scope=spfile; 
alter system set log_file_name_convert='/u01/app/oracle/oradata/DB19C','+RECO/DB19C_STB19C/ONLINELOG' scope=spfile;
alter system set enable_pluggable_database=false  scope=spfile;
alter system set standby_file_management=auto scope=both sid='*';
SHUTDOWN IMMEDIATE;

--운영
alter system set db_file_name_convert='+DATA/DB19C_STB19C/DATAFILE', '/u01/app/oracle/oradata/DB19C' scope=spfile; 
alter system set log_file_name_convert='+RECO/DB19C_STB19C/ONLINELOG', '/u01/app/oracle/oradata/DB19C' scope=spfile;
alter system set standby_file_management=auto scope=both sid='*';

- 데이터 복제
$ rman target /
startup nomount;
restore standby controlfile from service 'db19c_prod19c';
alter database mount; 

RUN
{
  ALLOCATE CHANNEL c1 DEVICE TYPE DISK;
    set newname for datafile 1 to '+DATA'; 
    set newname for datafile 3 to '+DATA';
    set newname for datafile 4 to '+DATA'; 
    set newname for datafile 7 to '+DATA';
  restore database from service 'db19c_prod19c';
  switch datafile all;
}


RMAN> shutdown immediate;
startup mount;
select FORCE_LOGGING, FLASHBACK_ON, OPEN_MODE, DATABASE_ROLE, DATAGUARD_BROKER, PROTECTION_MODE from v$database ;
select sysdate,process,status,thread#,sequence#,block#  from v$managed_standby  where status!='IDLE';
select distinct process from gv$managed_standby;


## Stadnby Redo log
- 운영
select group#, type, member from v$logfile;
select bytes, group# from v$log; 
alter database add standby logfile thread 1 group 11 ('/u01/app/oracle/oradata/DB19C/stbredo11.log') size 209715200;
alter database add standby logfile thread 1 group 12 ('/u01/app/oracle/oradata/DB19C/stbredo12.log') size 209715200;
alter database add standby logfile thread 1 group 13 ('/u01/app/oracle/oradata/DB19C/stbredo13.log') size 209715200;
alter database add standby logfile thread 1 group 14 ('/u01/app/oracle/oradata/DB19C/stbredo14.log') size 209715200;

- DR
select group#, type, member from v$logfile;
select bytes, group# from v$log; 
alter database clear logfile group #;
select group#, type, member from v$logfile;
alter database add standby logfile thread 1 group 11('+RECO') size 209715200;
alter database add standby logfile thread 1 group 12('+RECO') size 209715200;
alter database add standby logfile thread 1 group 13('+RECO') size 209715200;
alter database add standby logfile thread 1 group 14('+RECO') size 209715200;


set pagesize 0 feedback off linesize 120 trimspool on
spool /tmp/clearlogs.sql
select distinct 'alter database clear logfile group '||group#||';' from v$logfile;
spool off
@/tmp/clearlogs.sql

## redo shipping

### DG브로커 설정
 - 운영
SELECT LOG_MODE, FORCE_LOGGING, FLASHBACK_ON, OPEN_MODE, DATABASE_ROLE FROM V$DATABASE;
show parameter standby_file_management

alter system set dg_broker_start=true scope=both;
show parameter dg_broker_start

- DR
alter system set dg_broker_config_file1 = '+RECO/DB19C_STB19C/dr1db19c_stb19c.dat' SCOPE=BOTH;
alter system set dg_broker_config_file2 = '+RECO/DB19C_STB19C/dr2db19c_stb19c.dat' SCOPE=BOTH;

alter system set dg_broker_start=true;
alter system set dg_broker_start=false;
select pname from v$process where pname like 'DMON%';


dgmgrl sys/WElcome12345##@db19c_prod19c
CREATE CONFIGURATION db19c AS PRIMARY DATABASE IS db19c_prod19c CONNECT IDENTIFIER IS db19c_prod19c;
ADD DATABASE db19c_stb19c AS CONNECT IDENTIFIER IS db19c_stb19c MAINTAINED AS PHYSICAL;
enable configuration
show configuration;

edit database db19c_stb19c set state=apply-off;
edit database db19c_stb19c set state=apply-on;

edit database db19c_prod19c set state=apply-off;
edit database db19c_prod19c set state=apply-on;

- DR
select sysdate, process, status, thread#, sequence#, block# 
from v$managed_standby 
where status!='IDLE';

- 운영
ALTER SYSTEM ARCHIVE LOG CURRENT ;

- DR
select sysdate, process, status, thread#, sequence#, block# 
from v$managed_standby 
where status!='IDLE';



NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
encrypt_new_tablespaces              string      DDL
tablespace_encryption                string      DECRYPT_ONLY
tde_configuration                    string      keystore_configuration=FILE
wallet_root                          string      /u01/app/oracle/product/19c/dbhome_1/dbs/tde
SQL> 

alter system set wallet_root='/u01/app/oracle/product/19c/dbhome_1/dbs/db19c_prod19c' scope=spfile;
alter system set tablespace_encryption=DECRYPT_ONLY scope=spfile;
alter system set "_tablespace_encryption_default_algorithm"='AES256' scope=both;
alter system set tde_configuration='keystore_configuration=FILE' scope=both;


DR (이미 설정되어 있음) 
--

TDE_CONFIGURATION, ENCRYPT_NEW_TABLESPACES,  WALLET_ROOT

SQL> show parameter wall 

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
encrypt_new_tablespaces              string      ALWAYS
tablespace_encryption                string      AUTO_ENABLE
tde_configuration                    string      keystore_configuration=FILE
wallet_root                          string      /opt/oracle/dcs/commonstore/wa
                                                 llets/db19c_stb19c
SQL> 


alter system set wallet_root='/opt/oracle/dcs/commonstore/wallets/db19c_stb19c' scope=spfile;
alter system set tablespace_encryption=AUTO_ENABLE scope=spfile;
alter system set "_tablespace_encryption_default_algorithm"='AES256' scope=both;
alter system set tde_configuration='keystore_configuration=FILE' scope=both;

select CON_ID, WRL_PARAMETER, WRL_TYPE, STATUS, WALLET_TYPE from V$ENCRYPTION_WALLET;
 
administer key management create keystore identified by "WElcome12345##";
administer key management create auto_login keystore from keystore identified by "WElcome12345##";
administer key management set key force keystore identified by "WElcome12345##" with  backup;

-- TDE복사...

scp -rp -i ~/.ssh/privatekey  /u01/app/oracle/product/19c/dbhome_1/dbs/db19c_prod19c/tde opc@10.0.0.93:/tmp/tde
cp -rp /tmp/tde/* /opt/oracle/dcs/commonstore/wallets/db19c_stb19c/tde/*

Hybrid Oracle Data Guard without Transparent Data Encryption (TDE) License 
https://www.youtube.com/watch?v=HsnOtef87mM

 
 SQL>  select con_id, status, wallet_type from v$encryption_wallet;

    CON_ID STATUS                         WALLET_TYPE
---------- ------------------------------ --------------------
         0 OPEN                           AUTOLOGIN

SQL> 


## 마무리 