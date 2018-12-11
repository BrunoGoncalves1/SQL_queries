
SELECT @@SERVERNAME Instancia, GETDATE() [Data/hora]
GO                                                                                                                                                               
SELECT  name ,
            recovery_model_desc ,
            state_desc ,
            d AS 'Last Full Backup' ,
            i AS 'Last Differential Backup' ,
            l AS 'Last log Backup'
    FROM    ( SELECT    db.name ,
                        db.state_desc ,
                        db.recovery_model_desc ,
                        type ,
                        backup_finish_date
              FROM      master.sys.databases db
                        LEFT OUTER JOIN msdb.dbo.backupset a ON a.database_name = db.name
              WHERE                     db.name <> 'tempdb'
            ) AS Sourcetable 
        PIVOT 
            ( MAX(backup_finish_date) FOR type IN ( D, I, L ) ) AS MostRecentBackup
            
