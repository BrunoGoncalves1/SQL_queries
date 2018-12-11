SELECT      @@SERVERNAME Servidor,
              GETDATE() 'Data/Hora Atual'
            use master;
            
            SET NOCOUNT ON ;

            SELECT      @@SERVERNAME Servidor,
                                                                                              [SPID] =  ER.session_id ,
                        percent_complete [%] ,
                        blocked,
                              (estimated_completion_time/1000/60) AS ESTIMATEDMINUTESTOEND  ,
                              DATEADD(MS,estimated_completion_time,GETDATE()) AS ESTIMATEDENDTIME, 
                              DATEDIFF(MI,START_TIME,GETDATE()) TIMERUNNING,
                        [DATABASE] = DB_NAME(SP.DBID) ,
                        [STATUS] = ER.STATUS ,
                        [WAIT] = WAIT_TYPE ,
                        command ,
                                                                                              START_TIME,
                       [QUERY] = QT.TEXT ,
                                                                                ER.reads, ER.writes, ER.logical_reads,
[INDIVIDUAL QUERY] = SUBSTRING(QT.TEXT, ER.STATEMENT_START_OFFSET / 2,
                                                                                              ( CASE WHEN ER.STATEMENT_END_OFFSET = -1
                                                                                              THEN LEN(CONVERT(NVARCHAR(MAX), QT.TEXT))
                                                                                              * 2
                                                                                              ELSE ER.STATEMENT_END_OFFSET
                                                                                              END - ER.STATEMENT_START_OFFSET ) / 2),
                        PROGRAM = s.PROGRAM_NAME  ,
                        [USER] = NT_USERNAME ,
                        HOSTNAME
                        --,QP.query_plan AS xml_batch_query_plan
            FROM        sys.dm_exec_requests ER with (nolock)
                        left JOIN sys.sysprocesses SP with (nolock) ON ER.session_id = SP.spid
                                                                                              left JOIN sys.dm_exec_sessions s with (nolock) ON s.session_id = ER.session_id
                                                                                              CROSS APPLY sys.dm_exec_sql_text(ER.SQL_HANDLE) AS QT
                                                                              --            CROSS APPLY sys.dm_exec_query_plan(ER.plan_handle) QP 
            WHERE        ER.session_id > 50 -- IGNORAR SPIDS DE SISTEMA.
                        AND  ER.session_id NOT IN ( @@SPID ) -- IGNORAR ESTA INSTRUÇÃO.
                        --AND DB_NAME(SP.DBID) like 'GIP%' 
                        --AND  ER.session_id in(56,150)                                                      --and  NT_USERNAME in( 'XCRJA11')
					    --AND BLOCKED <> 0
						--AND command ='BACKUP DATABASE'
						--AND SPID=56 -- IN(71,109)
ORDER BY BLOCKED DESC, SPID

--kill 150
--SELECT * FROM sys.dm_exec_query_memory_grants
--SELECT top 10 session_id FROM sys.dm_exec_query_memory_grants 

--sp_who2 137

--select top 10 * from sys.dm_exec_query_memory_grants

--SELECT * FROM sys.dm_exec_sql_text(0x02000000653C09117FE243FA1A2DCE92FE0320A6989686EC)

--kill 90