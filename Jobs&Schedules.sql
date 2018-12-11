USE msdb
Go

SELECT dbo.sysjobs.Name AS 'Job Name', 
   'Job Enabled' = CASE dbo.sysjobs.Enabled
      WHEN 1 THEN 'Yes'
      WHEN 0 THEN 'No'
   END,
   'Frequency' = CASE dbo.sysschedules.freq_type
      WHEN 1 THEN 'Once'
      WHEN 4 THEN 'Daily'
      WHEN 8 THEN 'Weekly'
      WHEN 16 THEN 'Monthly'
      WHEN 32 THEN 'Monthly relative'
      WHEN 64 THEN 'When SQLServer Agent starts'
   END, 
   'Start Date' = CASE active_start_date
      WHEN 0 THEN null
      ELSE
      substring(convert(varchar(15),active_start_date),1,4) + '/' + 
      substring(convert(varchar(15),active_start_date),5,2) + '/' + 
      substring(convert(varchar(15),active_start_date),7,2)
   END,
   'Start Time' = CASE len(active_start_time)
      WHEN 1 THEN cast('00:00:0' + right(active_start_time,2) as char(8))
      WHEN 2 THEN cast('00:00:' + right(active_start_time,2) as char(8))
      WHEN 3 THEN cast('00:0' 
            + Left(right(active_start_time,3),1)  
            +':' + right(active_start_time,2) as char (8))
      WHEN 4 THEN cast('00:' 
            + Left(right(active_start_time,4),2)  
            +':' + right(active_start_time,2) as char (8))
      WHEN 5 THEN cast('0' 
            + Left(right(active_start_time,5),1) 
            +':' + Left(right(active_start_time,4),2)  
            +':' + right(active_start_time,2) as char (8))
      WHEN 6 THEN cast(Left(right(active_start_time,6),2) 
            +':' + Left(right(active_start_time,4),2)  
            +':' + right(active_start_time,2) as char (8))
   END,
    CASE(dbo.sysschedules.freq_subday_interval)
      WHEN 0 THEN 'Once'
      ELSE cast('Every ' 
            + right(dbo.sysschedules.freq_subday_interval,2) 
            + ' '
            +     CASE(dbo.sysschedules.freq_subday_type)
                     WHEN 1 THEN 'Once'
                     WHEN 4 THEN 'Minutes'
                     WHEN 8 THEN 'Hours'
                  END as char(16))
    END as 'Subday Frequency'
FROM dbo.sysjobs 
LEFT OUTER JOIN dbo.sysjobschedules 
ON dbo.sysjobs.job_id = dbo.sysjobschedules.job_id
INNER JOIN dbo.sysschedules ON dbo.sysjobschedules.schedule_id = dbo.sysschedules.schedule_id 
--where freq_subday_type = 8 and freq_subday_interval = 1
