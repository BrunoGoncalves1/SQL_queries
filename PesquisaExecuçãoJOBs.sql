 use msdb
 
 select 
 
 top 10
 step_id,
 b.name,
 message,
 run_date, 
 run_duration 

 from
	SysJobHistory as a
		left join SysJobs  as b on a.job_id = b.job_id

where 

	b.name = 'WAN_PROCESS'		-- Nome do JOB a ser pesquisado
	and run_date >= '20170307'	-- Data a ser pesquisada
order by step_id, run_date 