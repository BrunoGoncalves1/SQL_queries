-- ESTA QUERIE FICA EXECUTANDO PARA EVITAR QUE AS SESSOES DO DBA FIQUE BLOQUEANDO AS SESSOES DOS UTILIZADORES

declare @LoginExecutante varchar(100)

set @LoginExecutante = 'PTPORTUGAL\xcrja26'


WHILE (1 = 1)
      BEGIN
            DECLARE @v_spid INT = -1000
            DECLARE @v_KILL VARCHAR(50) = ''
            DECLARE @v_SQL VARCHAR(50) = ''
            DECLARE @v_PRINT VARCHAR(50) = ''

            SELECT TOP 1 @v_spid = er.blocking_session_id
              FROM sys.dm_exec_requests er WITH(NOLOCK)
                  INNER JOIN sys.dm_exec_sessions es WITH(NOLOCK)
                     ON es.session_id = er.session_id 
                    AND er.database_id > 0 
                    AND es.session_id <> @@SPID
                    AND er.session_id > 50
                  --  AND es.session_id > 50
            WHERE er.blocking_session_id IN (SELECT session_id
                                                               FROM sys.dm_exec_sessions es2
                                                              WHERE es2.original_login_name = @LoginExecutante
                                                           )
               AND er.wait_time > 5000 -- ms

            IF @v_spid > 50
                  BEGIN
                        SET @v_KILL = 'KILL ' + CAST(@v_spid AS VARCHAR(5))
                        SET @v_SQL = CONVERT(VARCHAR(20), GETDATE(), 120) + ': ' + @v_KILL 
                        EXEC (@v_KILL)

                        -- PRINT @v_SQL
                        RAISERROR (@v_SQL, 0, 1) WITH NOWAIT
                  END
            WAITFOR DELAY '00:00:03' -- waiting period to validate again
      END
