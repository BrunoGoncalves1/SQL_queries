SELECT d.name,sqltext.TEXT,
e.session_id,
e.status,
e.command,
e.cpu_time,
e.total_elapsed_time,
blocking_session_id,
percent_complete
FROM sys.dm_exec_requests e join
    sys.databases d on e.database_id = d.database_id
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
WHERE
    lower(command) like '%dbcc%' or blocking_session_id <> 0