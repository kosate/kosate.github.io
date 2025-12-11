1. Backup database before taking below step

2. Set PATH for perl:

set PATH=$ORACLE_HOME/perl/bin:$PATH
--OR--
export PATH=$ORACLE_HOME/perl/bin:$PATH
3. For being able to run the scripts for validating CATALOG and CATPROC the catcon.pl Perl script needs to be used in 12c environments:

SET VERIFY OFF
connect "SYS"/"&&sysPassword" as SYSDBA
set echo on
spool /tmp/validate_catalog.log append
alter session set "_oracle_script"=true;
alter pluggable database pdb$seed close;
alter pluggable database pdb$seed open;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /path_for_logs -b catalog $ORACLE_HOME/rdbms/admin/catalog.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /path_for_logs -b catproc $ORACLE_HOME/rdbms/admin/catproc.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /path_for_logs -b name_for_logs $ORACLE_HOME/rdbms/admin/utlrp.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /path_for_logs -b name_for_logs $ORACLE_HOME/rdbms/admin/utlrp.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /path_for_logs -b name_for_logs $ORACLE_HOME/rdbms/admin/utlrp.sql;
spool off
 4.execute following SQLs to fix any timestamp inconsistency:

declare
begin
  for cur1 in (select d.obj# objid from sys."_ACTUAL_EDITION_OBJ" d, sys.user$ du, sys.dependency$ dep,
           sys."_ACTUAL_EDITION_OBJ" p, sys.user$ pu
      where d.obj# = dep.d_obj# and p.obj# = dep.p_obj#
        and d.owner# = du.user# and p.owner# = pu.user#
        and d.status = 1                                    -- Valid dependent
        and bitand(dep.property, 1) = 1                     -- Hard dependency
        and d.subname is null                               -- !Old type version
        and not(p.type# = 32 and d.type# = 1)               -- Index to indextype
        and not(p.type# = 29 and d.type# = 5)               -- Synonym to Java
        and not(p.type# in(5, 13) and d.type# in (2, 55))   -- TABL/XDBS to TYPE
        and (p.status not in (1, 2, 4) or p.stime != dep.p_timestamp)) loop
        execute immediate 'begin dbms_utility.invalidate('||cur1.objid||'); end;';    
  end loop;
end;
/
