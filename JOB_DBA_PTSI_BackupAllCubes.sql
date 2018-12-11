USE [msdb]
GO

/****** Object:  Job [DBA PTSI - BackupAllCubes TCPRLP34]    Script Date: 11/18/2016 6:46:45 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 11/18/2016 6:46:45 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA PTSI - BackupAllCubes TCPRLP34', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'sa removido 7/2/2016 --PTPORTUGAL\SSASRLPPRDSRV adicionado/removido 7/2/2016', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'PTPORTUGAL\SSISRLPPRDSRV', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Eliminar *.abf existente no destino]    Script Date: 11/18/2016 6:46:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Eliminar *.abf existente no destino', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'del "\\10.163.34.227\d$\OLAP_BACKUP\*.abf"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup All Cubes TCPRLP34]    Script Date: 11/18/2016 6:46:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup All Cubes TCPRLP34', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=4, 
		@on_fail_action=4, 
		@on_fail_step_id=3, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/**************************************************************************************
ATENÇÃO:
            1. É necessário ter instalado o "Client Connectivity Tools" é uma feature do Setup do SQL Server
            2. Alterar o valor de @LinkedServerName pelo nome do Linked Server. 
            3. Alterar o valor de @DataSource pelo IP do servidor de OLAP
            4. Alterar o patch do Backup (@path)
            5. Se preferir não sobrescrever os backup alterar o valor da variável @AllowOverwrite para 0


ALTERAÇÕES EFETUADAS: 
            6. Devido aos cubos terem database_id diferentes dos nomes foi eefetuado o import do assembly (*.dll ASSP) na instancia SSAS [TCPRLP34]
	O download desta *.dll foi efetuado em http://asstoredprocedures.codeplex.com/releases/view/574328
	ASSP 2012 v1.3.7
***************************************************************************************/
DECLARE @SQL nvarchar(max)
DECLARE @LinkedServerName varchar(30), @DataSource varchar(30), @AllowOverwrite bit

SET @LinkedServerName = ''TCPRLP34'' -- None do linked Server identico a instância de AS 
SET @DataSource = ''10.163.208.67''   --IP da Instancia de AS
SET @AllowOverwrite = 1

DECLARE @path VARCHAR(256) -- Backup path
SET @path = ''D:\OLAP_BACKUP\'' -- Do not forget to add on the closing backslash !!!  -- Nome da Pasta do lado do AS

DECLARE @DT VARCHAR(20) -- Used for optional file name timestamp
-- Change timestamp to this format: _YYYY-MM-DD_HHMMSS
Set @DT = ''_'' + Replace(Replace(cast(getdate() as date), '':'', ''''), '' '', ''_'');


IF (SELECT COUNT(*) FROM sysservers WHERE srvname = @LinkedServerName) >= 1 BEGIN
	SET @SQL = ''EXEC master.dbo.sp_dropserver @server=N'''''' + @LinkedServerName + '''''', @droplogins=''''droplogins'''' ''
	EXEC(@SQL)
END
	
SET @SQL = ''
	USE [master]

	EXEC master.dbo.sp_addlinkedserver	@server = N'''''' + @LinkedServerName + '''''', @srvproduct=N'''''''', @provider=N''''MSOLAP'''', @datasrc=N'''''' + @DataSource + ''''''
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'''''' + @LinkedServerName + '''''',@useself=N''''False'''',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''collation compatible'''', @optvalue=N''''false''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''data access'''', @optvalue=N''''true''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''dist'''', @optvalue=N''''false''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''pub'''', @optvalue=N''''false''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''rpc'''', @optvalue=N''''true''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''rpc out'''', @optvalue=N''''true''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''sub'''', @optvalue=N''''false''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''connect timeout'''', @optvalue=N''''0''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''collation name'''', @optvalue=null
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''lazy schema validation'''', @optvalue=N''''false''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''query timeout'''', @optvalue=N''''0''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''use remote collation'''', @optvalue=N''''true''''
	EXEC master.dbo.sp_serveroption @server=N'''''' + @LinkedServerName + '''''', @optname=N''''remote proc transaction promotion'''', @optvalue=N''''true''''
''
EXEC(@SQL)

SET @SQL = ''
	DECLARE @name VARCHAR(50) -- Cube name  
	DECLARE @fileName VARCHAR(256) -- Backup filename 
	
	Declare @XMLA nvarchar(4000) -- The SSAS command in XML format

	DECLARE curCube CURSOR FOR  
	
	SELECT ID
	FROM openquery([''+ @LinkedServerName +''], ''''call ASSP.DiscoverXmlMetadataFull("Database")'''') as a
	ORDER BY CAST(CAST(EstimatedSize AS NVARCHAR(MAX)) AS BIGINT) DESC
	
	OPEN curCube   
	FETCH NEXT FROM curCube INTO @name   
	
	WHILE @@FETCH_STATUS = 0 BEGIN   
	
	-- Create the XMLA string (overwrites the same files again and again)
	Set @XMLA = N''''
	<Backup xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
		<Object>
		<DatabaseID>'''' + @name + ''''</DatabaseID>
		</Object>
		<File>'' + @path + '''''' + @name + ''''.abf</File>
		<AllowOverwrite>true</AllowOverwrite>
	</Backup>
	'''';	
	-- Execute the string across the linked server (SSAS)
	Exec (@XMLA) At ''  + @LinkedServerName + ''

	FETCH NEXT FROM curCube INTO @name   
END   

CLOSE curCube   
DEALLOCATE curCube
''

EXEC (@SQL);

SET @SQL = ''EXEC master.dbo.sp_dropserver @server=N'''''' + @LinkedServerName + '''''', @droplogins=''''droplogins'''' '';
EXEC(@SQL);', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [OnError]    Script Date: 11/18/2016 6:46:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'OnError', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @msg varchar(1000)
set @msg = ''Backup de cubos RELOP. Erro no job presente na instância TCPRLP36 JOB - Backup All Cubes TCPRLP34''
exec master..xp_logevent 50001, @msg , error
--RAISERROR (@Msg, 16, 1) WITH LOG 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [OnSuccess]    Script Date: 11/18/2016 6:46:45 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'OnSuccess', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @msg varchar(1000)
set @msg = ''Backup de cubos RELOP executado com sucesso.''
exec master..xp_logevent 50001, @msg , Informational
--RAISERROR (@Msg, 16, 1) WITH LOG', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20120207, 
		@active_end_date=99991231, 
		@active_start_time=230000, 
		@active_end_time=235959, 
		@schedule_uid=N'f1d57570-1495-4250-ac58-b2bf9101f9bc'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


