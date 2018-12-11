/**********************************************************************
Author:		Michael Antunes
Colaboração: Cláudio Silva
Create date: 2014-02-14
Description:	Permite gerar script veritas para um conjunto de databases
Correção: 2014-04-29
	- Quando era passado como parâmetro o nome do VIP e caso existam BDs que contenham esse mesmo nome o processo entrava em ciclo infinito.
	  Isto acontecia porque sempre que era feito o replace do VIP pela lista de BDs o VIP já tratado não era excluido nas iterações seguintes
	EX: VIP (dns_name da tabela sys.availability_group_listeners) = ABC
		BD: ABC_DB
Correção: 2014-02-19
	- Não estava a considerar as BD's sem AG. Adicionado a opção "Database_WithoutAG" no parâmetro @Database
Correção: 2014-03-05
	- Adicionado o parâmetro nome da instância no comando "bcp"
Correção: 2014-04-23
	- As BD em simple não fazem backup TLOG
	- Adicionado parametro para COPY_ONLY
	- Criado compatibilidade para SQL Server 2005, 2008, 2008R2 e 2012
Correção: 2014-04-30	
	- Removido do script o BATCHSIZE. Este parametro do script Veritas esta limitado a um valor de 1 a 32 o que limita as BD's em apenas 32 por instância
	- Adicionado o parâmetro @SQLCompression, para o caso do SQL Serer 2005 ou agentes Veritas abaixo da versão 7.0
	- Adicionado o parâmetro @BrowseCliente, exigido para alguns casos. Vazio = sem BrowseCliente
	- Excluído a tempdb dos backups
	- Excluído todas as BD que não estejam no estado OnLine (sys.databases.state = 0)
	- Corrigido a passagem do nome do AG para o parâmetro @Database
Correção: 2014-05-02
	- Adicionado novamente o BATCHSIZE. Este apenas pode assumir um valor entre 1 e 10, por defeito é 5.
	- Caso não exista nenhuma BD em FULL não é gerado o script de TLOG e caso este exista é eliminado.
	- Adicionado output da versão
Correção: 2014-05-30
	- Correção da exclusão da tempdb
	- Exemplo corrigido para compatibilidade com SQL Server 2005
	- Corrigido para collations CS-AS
Correção: 2014-07-14
	- Quando executado em uma “default instance” não é gerado o script veritas

Correção: 2014-08-04
	- Corrigido bug quando utilizado o "-" para eliminar uma BD da lista de backups a serem feitos
	- Corrigido bug ao eliminar ficheiro BCH do TLOG quando já não existir nenhuma BD com recovery model FULL
	- Corrigido bug que tentava eliminar o ficheiro BCH do TLOG mesmo quando este já não existia 

Correção: 2015-04-14
	- Ignora as SNAPSHOTS das bases de dados.

Correção: 2015-04-22
	- Quando são passados mais de 2 valores para o parâmetro @vDatabase, o script final gerado podia não ser correcto.

Correção: 2016-02-10
	- Se fosse passado o VIP do AG, corremos o risco de no momento da geração dos scripts de backup o AG não ser o PRIMARY.
	Tendo em conta que os backups FULL têm de ser feitos no PRIMARY, passamos a obter todas as BDs que estejam no PRIMARY actual.
	- O default passa a ser ALL_DATABASES que em casos que existam AGs incluí as BDs dos AGs que são PRIMARY e as BDs que não estejam
	nos AGs.

Correção: 2016-11-21
    - Corrigido Script, não excluia do script veritas bases de dados offline em AG.

Versão 3.9.2

Exemplo:
/************** FULL *****************/
DECLARE 
	@vType char(4)
	,@vDatabase varchar(max)
	,@vHost varchar(50)
	,@vInstance varchar(50)
	,@vNBServer varchar(100)
	,@vFileName varchar(1024)
	,@BrowseCliente varchar(100)
	,@CopyOnly bit
	,@SQLCompression bit

SELECT
	@vType = 'FULL'
	,@vDatabase = 'ALL_DATABASES'
	,@vHost = (SELECT CAST(SERVERPROPERTY ('MachineName') AS VARCHAR(30)))
	,@vInstance = (SELECT CAST(SERVERPROPERTY ('InstanceName') AS VARCHAR(30)))
	,@vNBServer = 'MASVTV.BK.PTLOCAL'
	,@vFileName = 'G:\VERITAS\FULL.bch'
	,@BrowseCliente = 'vjdsit45.bk.ptlocal'
	,@CopyOnly = 1
	,@SQLCompression = 1

EXEC [bck].[usp_GeraScriptVeritas]
	@Type = @vType
	,@Database = @vDatabase
	,@Host = @vHost
	,@Instance = @vInstance
	,@NBServer = @vNBServer
	,@FileName = @vFileName
	,@BrowseCliente = @BrowseCliente
	,@CopyOnly = @CopyOnly
	,@SQLCompression = @SQLCompression

/************** TLOG *****************/
SELECT
	@vType  = 'TLOG'
	,@vFileName = 'G:\VERITAS\TLOG.bch'
	,@CopyOnly = 0

EXEC [bck].[usp_GeraScriptVeritas]
	@Type = @vType
	,@Database = @vDatabase
	,@Host = @vHost
	,@Instance = @vInstance
	,@NBServer = @vNBServer
	,@BrowseCliente = @BrowseCliente
	,@FileName = @vFileName
	,@CopyOnly = @CopyOnly
	,@SQLCompression = @SQLCompression
	
**********************************************************************/

USE [DBA_PTSI]
GO
/****** Object:  StoredProcedure [bck].[usp_BackupAllDatabases_Full_or_TLOG]    Script Date: 04/12/2013 14:21:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE @SQL varchar(1024)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bck') BEGIN
	SET @SQL = 'CREATE SCHEMA [bck] AUTHORIZATION [dbo]';
	EXEC (@SQL);
END	
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'[bck].[usp_GeraScriptVeritas]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
	DROP PROCEDURE [bck].[usp_GeraScriptVeritas]
END
GO


CREATE PROCEDURE [bck].[usp_GeraScriptVeritas](
	@Type char(4) -- FULL; TLOG
	,@Database varchar(max) = 'ALL_DATABASES'
		--Pode ser utilizado o nome do VIP do AG
			-- PJPSIT70				=> Apenas as BDs do Availability Group PJPSIT70 (apenas SQL Server 2012). NOTA: Tem de ser o nome do LISTENER e não o do AG!!
		-- Database_WithoutAG => BD's se Availability Groups (apenas SQL Server 2012)
		--, @Database			= 'USER_DATABASES,-DBA' -- Todas as BD de utilizador menos a BD DBA
			-- USER_DATABASES		=> Apenas BD's de utilizador
			-- SYSTEM_DATABASES		=> Apenas BD's de sistema (master, model e msdb)
			-- ALL_DATABASES		=> Todas as BD's
			-- Customize			=> 'ALL_DATABASES,-DBA, -SS_DBA_Dashboard' => Todas as BD menos a DBA e SS_DBA_Dashboard
			-- Customize			=> <<Nome das BD's separado por , >>
			-- Exemplo				=> 'USER_DATABASES,-DBA,-SS_DBA_Dashboard' => Todas as BD's de utilizador menos a DBA e SS_DBA_Dashboard	
	,@Host varchar(50)
	,@Instance varchar(50)
	,@NBServer varchar(100)
	,@BrowseCliente varchar(100)
	,@BATCHSIZE int = 5 -- Valor entre 1 e 10
	,@FileName varchar(1024)
	,@CopyOnly bit = 0
	,@SQLCompression bit = 1
)
-- WITH ENCRYPTION
AS BEGIN 
	--SET @Type = 'FULL'
	--SET @Database = 'USER_DATABASES'
	--SET @Host = (SELECT CAST(SERVERPROPERTY ('MachineName') AS VARCHAR(30)))
	--SET @Instance = (SELECT CAST(SERVERPROPERTY ('InstanceName') AS VARCHAR(30)))
	--SET @NBServer = 'BCKPICMST01.BK.PTLOCAL'
	--SET @FileName = 'G:\VERITAS\FULL_teste.bch'

	SET NOCOUNT ON

	DECLARE @SQL nvarchar(max), @ParmDefinition nvarchar(500), @SQL2 varchar(max)
	DECLARE @SessionID uniqueidentifier 
	DECLARE @BATCHSIZE_aux int
	DECLARE @RecoveryModel int
	DECLARE @version char(20)
	DECLARE @Reccount int
	DECLARE @SPVersion varchar(10)
	
	DECLARE @defaultInstance bit
	
	IF @Instance IS NULL BEGIN
		SET @defaultInstance = 1
		SET @Instance = ''
	END ELSE BEGIN
		SET @defaultInstance = 0
	END 
	
	SET @SPVersion = '3.9.1'	

	SET @version = CONVERT(char(20),SERVERPROPERTY('productversion'));

	SET @SessionID = NEWID()

	IF OBJECT_ID('DBA_PTSI.bck.ScriptVeritas') IS NULL 
		BEGIN
			CREATE TABLE bck.ScriptVeritas (
				ID	int identity(1,1) PRIMARY KEY
				,SessionID uniqueidentifier   
				,DataHora datetime
				,Script varchar(max)
			)
		END
	
	--Verificar se o ficheiro de backups do TLOG existe (utilizado no final do script)
	declare @FileExists table (fileExists int, FileIsDirectory int, ParentDirectoryExists int)
	
--------------- DEFINIR AS BD'S PARA VERIFICAÇÃO
	DECLARE @SelectedDatabases TABLE (
		[DatabaseName] nvarchar(max),
		[DatabaseType] nvarchar(max),
		[Selected] bit,
		[RecoveryModel] int
	);

	IF CONVERT(FLOAT, LEFT(@version,2)) >= 11 BEGIN -- SE SQL SERVER 2012 OU SUPERIOR AS DMV's ABAIXO EXISTEM
		SET @SQL = N'
			DECLARE @Database_user  varchar(max), @Database_system varchar(max), @Database_WithoutAG varchar(max), @Database_AG  varchar(max);
			DECLARE @Remove bit;
			DECLARE @AG varchar(40) = null;

			SELECT @Database_user  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + rtrim(d.name)
															FROM sys.databases d
															WHERE d.database_id > 4
															AND d.state = 0
															AND source_database_id IS NULL
															FOR XML PATH('''')),2,8000)),'''');

			
			IF SUBSTRING(@Database, CHARINDEX(''Database_WithoutAG'', @Database, 1)-1, 1) = ''-''
				SET @Remove = 1
			ELSE 
				SET @Remove = 0

			

			SELECT @Database_WithoutAG  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + CASE WHEN @Remove = 1 THEN ''-'' + rtrim(d.name) ELSE  rtrim(d.name) END
															FROM sys.databases d
															WHERE d.database_id > 4
															AND d.state = 0
																AND d.group_database_id IS NULL
																AND source_database_id IS NULL
															FOR XML PATH('''')),2,8000)),'''');

			SELECT @Database_system  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + rtrim(d.name)
															FROM sys.databases d
															WHERE d.database_id in (1,3,4)-- A tempdb não deve ter backup
															FOR XML PATH('''')),2,8000)),'''');


			SET @Database = REPLACE(@Database, ''SYSTEM_DATABASES'', @Database_system);
			SET @Database = REPLACE(@Database, ''USER_DATABASES'', @Database_user);
			SET @Database = REPLACE(@Database, ''Database_WithoutAG'', @Database_WithoutAG);
			SET @Database = REPLACE(@Database, ''ALL_DATABASES'', @Database_user + '','' + @Database_system);

			SET @AG = (SELECT top 1 dns_name FROM sys.availability_group_listeners WHERE @Database like ''%'' + dns_name + ''%'')
			
			WHILE @AG IS NOT NULL 
				BEGIN

					IF SUBSTRING(@Database, CHARINDEX(@AG, @Database, 1)-1, 1) = ''-''
						SET @Remove = 1
					ELSE 
						SET @Remove = 0

					SET @AG = (SELECT top 1 dns_name FROM sys.availability_group_listeners WHERE @Database like ''%'' + dns_name + ''%'')

					SELECT @Database_AG  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + CASE WHEN @Remove = 1 THEN ''-'' + rtrim(database_name) ELSE rtrim(database_name) END
																	FROM sys.availability_group_listeners l
																		INNER JOIN sys.availability_databases_cluster d ON l.group_id = d.group_id
																	WHERE dns_name = @AG
																	FOR XML PATH('''')),2,8000)),'''');

					SET @Database = REPLACE(@Database, ISNULL(@AG, ''''), @Database_AG);

				END';

		SET @ParmDefinition = N'@Database varchar(max) OUTPUT';
		
		print @SQL
		
		EXECUTE sp_executesql @SQL, @ParmDefinition, @Database = @Database OUTPUT;

	END ELSE BEGIN
		DECLARE @Database_user  varchar(max), @Database_system varchar(max), @Database_WithoutAG varchar(max), @Database_AG  varchar(max);
		DECLARE @Remove bit;

		SELECT @Database_user  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT ',' + rtrim(d.name)
														FROM sys.databases d
														WHERE d.database_id > 4
															AND state = 0
															AND source_database_id IS NULL
														FOR XML PATH('')),2,8000)),'');

		SELECT @Database_system  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT ',' + rtrim(d.name)
														FROM sys.databases d
														WHERE d.database_id in (1,3,4) -- A tempdb não deve ter backup
															AND state = 0
														FOR XML PATH('')),2,8000)),'');


		SET @Database = REPLACE(@Database, 'SYSTEM_DATABASES', @Database_system);
		SET @Database = REPLACE(@Database, 'USER_DATABASES', @Database_user);
		SET @Database = REPLACE(@Database, 'ALL_DATABASES', @Database_user + ',' + @Database_system);

	END
	
	SET @Database = REPLACE(@Database, ', ', ',');
	SET @Database = REPLACE(@Database, '--', '-');

	WITH Databases1 (StartPosition, EndPosition, DatabaseItem) AS --SPLIT DAS DATABASES
	(
		SELECT 1 AS StartPosition,
				ISNULL(NULLIF(CHARINDEX(',', @Database, 1), 0), LEN(@Database) + 1) AS EndPosition,
				SUBSTRING(@Database, 1, ISNULL(NULLIF(CHARINDEX(',', @Database, 1), 0), LEN(@Database) + 1) - 1) AS DatabaseItem
		WHERE @Database IS NOT NULL

		UNION ALL

		SELECT CAST(EndPosition AS int) + 1 AS StartPosition,
				ISNULL(NULLIF(CHARINDEX(',', @Database, EndPosition + 1), 0), LEN(@Database) + 1) AS EndPosition,
				SUBSTRING(@Database, EndPosition + 1, ISNULL(NULLIF(CHARINDEX(',', @Database, EndPosition + 1), 0), LEN(@Database) + 1) - EndPosition - 1) AS DatabaseItem
		FROM Databases1
		WHERE EndPosition < LEN(@Database) + 1
	),
	Databases2 (DatabaseItem, Selected) AS --REMOVE AS DATABASES MARCADAS PARA EXCLUSÃO
	(
		SELECT 
			CASE 
				WHEN DatabaseItem LIKE '-%' 
					THEN RIGHT(DatabaseItem,LEN(DatabaseItem) - 1) 
					ELSE DatabaseItem 
				END AS DatabaseItem,
				CASE 
				WHEN DatabaseItem LIKE '-%' 
					THEN 0 
					ELSE 1 
				END AS Selected
		FROM Databases1
	), Databases3 (DatabaseItem, DatabaseType, Selected) AS --IDENTIFICA OS TIPOS DE DATABASE
	(
		SELECT 
			CASE 
				WHEN DatabaseItem IN('ALL_DATABASES','SYSTEM_DATABASES','USER_DATABASES') 
					THEN '%' 
					ELSE DatabaseItem	
			END AS DatabaseItem,
			CASE 
				WHEN DatabaseItem = 'SYSTEM_DATABASES' 
					THEN 'S' 
				WHEN DatabaseItem = 'USER_DATABASES' 
					THEN 'U' 
				ELSE NULL 
			END AS DatabaseType,
			Selected
		FROM Databases2
	), Databases4 (DatabaseName, DatabaseType, Selected) AS --REMOVE OS PARENTESES RETOS, SE EXISTIREM
	(
		SELECT 
			CASE 
				WHEN LEFT(DatabaseItem,1) = '[' AND RIGHT(DatabaseItem,1) = ']' 
					THEN PARSENAME(DatabaseItem,1) 
			
				ELSE DatabaseItem 
				END AS DatabaseItem,
				DatabaseType,
				Selected
		FROM Databases3
	)
	INSERT INTO @SelectedDatabases (DatabaseName, DatabaseType, Selected, RecoveryModel)
	SELECT d4.DatabaseName,
			d4.DatabaseType,
			d4.Selected,
			d.recovery_model
	FROM Databases4 d4
		INNER JOIN sys.databases d ON d.name = d4.DatabaseName
	OPTION (MAXRECURSION 0)
	
	DELETE FROM @SelectedDatabases
	WHERE (DatabaseName in (SELECT DatabaseName FROM @SelectedDatabases WHERE Selected = 0)
		OR DatabaseName = '')
	
--------------- <<FIM>>  DEFINIR AS BD'S PARA VERIFICAÇÃO

	SET @BATCHSIZE_aux = 1

	SELECT @Reccount = COUNT(*)	
	FROM @SelectedDatabases
	WHERE (RecoveryModel <> 3 AND @Type = 'TLOG') 

	WHILE EXISTS(SELECT * FROM @SelectedDatabases ) BEGIN

		SELECT DISTINCT
			 @Database = s.DatabaseName
			,@RecoveryModel = s.RecoveryModel
		FROM @SelectedDatabases s
					
		DELETE FROM @SelectedDatabases WHERE DatabaseName = @Database

		SET @SQL = ''

		IF @BATCHSIZE_aux = 1 BEGIN
			IF @BATCHSIZE < 1 
				SET @BATCHSIZE = 1
			IF @BATCHSIZE > 10
				SET @BATCHSIZE = 10
			SET @SQL = 'BATCHSIZE ' + CAST(@BATCHSIZE AS varchar(2)) + CHAR(13) + CHAR(10) 
			SET @BATCHSIZE_aux = 0
		END		
		IF (@RecoveryModel <> 3 AND @Type = 'TLOG') OR (@Type = 'FULL') BEGIN -- 3 = RecoveryModel Simple

				
			SET @SQL = @SQL + 'OPERATION BACKUP '				+ CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'DATABASE "' + @Database  + '" '  + CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'SQLHOST "' + @Host + '" '		+ CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'SQLINSTANCE "' + @Instance + '" '+ CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'NBSERVER "' + @NBServer + '" '	+ CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'MAXTRANSFERSIZE 6 '				+ CHAR(13) + CHAR(10) 

			IF @CopyOnly = 1
				SET @SQL = @SQL + 'COPYONLY TRUE '				+ CHAR(13) + CHAR(10) 
			
			SET @SQL = @SQL + 'BLOCKSIZE 7 '					+ CHAR(13) + CHAR(10) 

			IF @BrowseCliente <> ''
				SET @SQL = @SQL + 'BROWSECLIENT "' + @BrowseCliente + '"'	+ CHAR(13) + CHAR(10) 
			
			IF @Type = 'TLOG' 
				SET @SQL = @SQL + 'OBJECTTYPE TRXLOG '			+ CHAR(13) + CHAR(10) 
	
			SET @SQL = @SQL + 'NUMBUFS 2 '						+ CHAR(13) + CHAR(10) 
			SET @SQL = @SQL + 'VDITIMEOUTSECONDS 1800 '			+ CHAR(13) + CHAR(10) 
			
			IF @SQLCompression = 1
				SET @SQL = @SQL + 'SQLCOMPRESSION TRUE '		+ CHAR(13) + CHAR(10) 
			
			SET @SQL = @SQL + 'ENDOPER TRUE'					+ CHAR(13) + CHAR(10) 
		END

		INSERT INTO DBA_PTSI.bck.ScriptVeritas (SessionID, DataHora, Script) VALUES(@SessionID, GETDATE(), @SQL)
	END

	DECLARE @enableCMD bit
	IF NOT EXISTS (select * from sys.configurations where name='xp_cmdshell' and value=1) BEGIN
		EXEC master.dbo.sp_configure 'show advanced options', 1   
		RECONFIGURE   
		EXEC master.dbo.sp_configure 'xp_cmdshell', 1 -- enable CMD   
		RECONFIGURE   WITH OVERRIDE
		SET @enableCMD = 1
	END

	IF @Type = 'TLOG' AND @Reccount <= 0 BEGIN
			
		SET @SQL2 = ' xp_fileexist "' + @FileName + '"'
		insert into @FileExists
		exec (@SQL2)
				
		IF EXISTS (select fileExists from @FileExists where fileExists = 1) BEGIN
	
			SET @SQL2 = 'xp_cmdshell ''DEL /Q "' + @FileName + '"'''
			EXEC(@SQL2)
		END
		PRINT 'ok'
	END

	IF (@Type = 'TLOG' AND @Reccount > 0 ) OR (@Type = 'FULL') BEGIN
		IF @defaultInstance = 0 BEGIN
			SET @SQL2 = 'xp_cmdshell ''bcp "SELECT Script FROM DBA_PTSI.bck.ScriptVeritas WHERE SessionID = ''''' + CAST(@SessionID AS varchar(64))+ ''''' and Script <> ''''''''" queryout "' + @FileName + '" -T -c -S"' + @Host + '\' + @Instance  + '"'''
		END ELSE BEGIN
			SET @SQL2 = 'xp_cmdshell ''bcp "SELECT Script FROM DBA_PTSI.bck.ScriptVeritas WHERE SessionID = ''''' + CAST(@SessionID AS varchar(64))+ ''''' and Script <> ''''''''" queryout "' + @FileName + '" -T -c -S"' + @Host + '"'''
		END
		PRINT CHAR(10) + CHAR(13)
	
		EXEC(@SQL2)
	END


	IF @enableCMD = 0 BEGIN
		EXEC master.dbo.sp_configure 'show advanced options', 1 
		RECONFIGURE   
		EXEC master.dbo.sp_configure 'xp_cmdshell', 0 -- enable CMD   
		RECONFIGURE   WITH OVERRIDE
	END

	SELECT [Version] =  @SPVersion

END

GO

USE [msdb]
GO
/****** Object:  Job [DBA PTSI - Gerar Script Veritas]    Script Date: 04/21/2015 12:47:42 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/21/2015 12:47:42 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA PTSI - Gerar Script Veritas', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Gera o script veritas para efectuar backups.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Gera Script Veritas na pasta D:\VERITAS]    Script Date: 04/21/2015 12:47:42 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Gera Script Veritas na pasta D:\VERITAS', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE 
	@vType char(4)
	,@vDatabase varchar(max)
	,@vHost varchar(50)
	,@vInstance varchar(50)
	,@vNBServer varchar(100)
	,@vFileName varchar(1024)
	,@BrowseCliente varchar(100)
	,@CopyOnly bit
	,@SQLCompression bit

SELECT
	@vType = ''FULL''
	,@vDatabase = ''ALL_DATABASES''
	,@vHost = (SELECT CAST(SERVERPROPERTY (''MachineName'') AS VARCHAR(30)))
	,@vInstance = (SELECT CAST(SERVERPROPERTY (''InstanceName'') AS VARCHAR(30)))
	,@vNBServer = ''MASV1.BK.PTLOCAL''
	,@vFileName = ''D:\Veritas\''+  @vInstance + ''_FULL.bch''
	,@BrowseCliente = ''cjpapr01.bk.ptlocal''
	,@CopyOnly = 0
	,@SQLCompression = 0

EXEC [bck].[usp_GeraScriptVeritas]
	@Type = @vType
	,@Database = @vDatabase
	,@Host = @vHost
	,@Instance = @vInstance
	,@NBServer = @vNBServer
	,@FileName = @vFileName
	,@BrowseCliente = @BrowseCliente
	,@CopyOnly = @CopyOnly
	,@SQLCompression = @SQLCompression

/************** TLOG *****************/
SELECT
	@vType  = ''TLOG''
	,@vFileName = ''D:\Veritas\''+ @vInstance+ ''_TLog.bch''
	,@CopyOnly = 0

EXEC [bck].[usp_GeraScriptVeritas]
	@Type = @vType
	,@Database = @vDatabase
	,@Host = @vHost
	,@Instance = @vInstance
	,@NBServer = @vNBServer
	,@BrowseCliente = @BrowseCliente
	,@FileName = @vFileName
	,@CopyOnly = @CopyOnly
	,@SQLCompression = @SQLCompression', 
		@database_name=N'DBA_PTSI', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA PTSI - Gera Scripts Veritas', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150417, 
		@active_end_date=99991231, 
		@active_start_time=173000, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
