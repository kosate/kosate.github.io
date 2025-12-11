-- 작업 모니터링 
SQL> select  sid, serial#,  opname,target_desc,
    to_char(start_time, 'MM-DD HH24:MI') start_time,
    to_char(last_update_time, 'MM-DD HH24:MI') last_update_time,
    elapsed_seconds  "ELAPSED (sec)",
    sofar, totalwork, totalwork * 8 / 1024 / 1024 total_gb,
    round(sofar / totalwork * 100, 2) "COMPLETE (%)",
    round(totalwork * 8 / 1024  * round(sofar / totalwork , 2) / elapsed_seconds, 2) "MB/s"
    from gv$session_longops where sofar <> totalwork;
-- SQL구문 확인
SQL> select sql_text from v$sql s, v$session_longops lwhere s.sql_id=l.sql_id and l.opname=‘{Opname}’;
