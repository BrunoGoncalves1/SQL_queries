USE [DBA_PTSI]
GO
/****** Object:  StoredProcedure [aud].[usp_checkbackups]    Script Date: 12/10/2017 12:04:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [aud].[usp_checkbackups] (
	@mailprofilename as varchar(500) = NULL
	, @recipients as varchar(8000) = NULL
	, @Database as nvarchar(max) = null  
		--Pode ser utilizado o nome do VIP do AG
		-- PJPSIT70				=> Apenas as BD do Availability Group PJPSIT70
		--Database_WithoutAG => Para as BD's que não pertencem a nenhum grupo
		--, @Database			= 'USER_DATABASES,-DBA' -- Todas as BD de utilizador menos a BD DBA
		-- USER_DATABASES		=> Apenas BD's de utilizador
		-- SYSTEM_DATABASES		=> Apenas BD's de sistema (master, model e msdb)
		-- ALL_DATABASES		=> Todas as BD's
		-- Customize			=> 'ALL_DATABASES,-DBA, -SS_DBA_Dashboard' => Todas as BD menos a DBA e SS_DBA_Dashboard
		-- Customize			=> <<Nome das BD's separado por , >>
		-- Exemplo				=> 'USER_DATABASES,-DBA,-SS_DBA_Dashboard' => Todas as BD's de utilizador menos a DBA e SS_DBA_Dashboard	
	, @ReportMail as varchar(20) = null
		-- 'All'
		-- 'Failed'
		-- 'Success'
		-- 'InProgress'
		-- 'Failed_InProgress'
	, @ErrorLog as bit = 1
	, @IntervaloUltimaExecucao as datetime = NULL -- valor default = 24 horas 
)
as begin

	print 'Version: 4.3'

	if object_id('tempdb..#dbsbak') is not null drop table #dbsbak
	if object_id('tempdb..#notbackedup') is not null drop table #notbackedup
	set nocount on;

	PRINT '@mailprofilename = ' + @mailprofilename 
	PRINT '@recipients = ' + @recipients
	PRINT '@Database = ' + @Database
	PRINT '@ErrorLog = ' + CAST(@ErrorLog AS CHAR(1))
	PRINT '@IntervaloUltimaExecucao = ' + CONVERT(VARCHAR(20), @IntervaloUltimaExecucao, 120)

	DECLARE @ParmDefinition nvarchar(500), @SQL2 nvarchar(max)
	DECLARE @IntervaloUltimaExecucao_aux datetime
	
	IF @IntervaloUltimaExecucao IS NULL 
		SET @IntervaloUltimaExecucao = DATEADD(HOUR, -24, getdate())
		

	declare @isError as bit;
	declare @version as char(20);
	declare @sql as nvarchar(max);
	declare @alarmdesc varchar(500);
	declare @SQLView varchar(1024)
	declare @QtyBDsNotBackup int
	declare @QtyBDsInExecutionBackup int

	set @isError = 0;

	set @version = CONVERT(char(20),SERVERPROPERTY('productversion'));

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
															WHERE d.database_id > 4 and (select sys.fn_hadr_backup_is_preferred_replica (d.name)) = 1
															FOR XML PATH('''')),2,8000)),'''');

			
			IF SUBSTRING(@Database, CHARINDEX(''Database_WithoutAG'', @Database, 1)-1, 1) = ''-''
				SET @Remove = 1
			ELSE 
				SET @Remove = 0

			

			SELECT @Database_WithoutAG  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + CASE WHEN @Remove = 1 THEN ''-'' + rtrim(d.name) ELSE  rtrim(d.name) END
															FROM sys.databases d
															WHERE d.database_id > 4
																AND d.group_database_id IS NULL
																AND d.source_database_id IS NULL
															FOR XML PATH('''')),2,8000)),'''');

			SELECT @Database_system  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + rtrim(d.name)
															FROM sys.databases d
															WHERE d.database_id in (1,3,4)-- A tempdb não deve ter backup
															AND d.source_database_id IS NULL
															FOR XML PATH('''')),2,8000)),'''');


			SET @Database = REPLACE(@Database, ''SYSTEM_DATABASES'', @Database_system);
			SET @Database = REPLACE(@Database, ''USER_DATABASES'', @Database_user);
			SET @Database = REPLACE(@Database, ''Database_WithoutAG'', @Database_WithoutAG);
			SET @Database = REPLACE(@Database, ''ALL_DATABASES'', @Database_user + '','' + @Database_system);

			SET @AG = (SELECT top 1 dns_name FROM sys.availability_group_listeners WHERE @Database like ''%'' + dns_name + ''%'')
			
			WHILE @AG IS NOT NULL BEGIN

				IF SUBSTRING(@Database, CHARINDEX(@AG, @Database, 1)-1, 1) = ''-''
					SET @Remove = 1
				ELSE 
					SET @Remove = 0

				SELECT @Database_AG  = ISNULL((SELECT ColumnList = SUBSTRING((SELECT '','' + CASE WHEN @Remove = 1 THEN ''-'' + rtrim(database_name) ELSE rtrim(database_name) END
																FROM sys.availability_group_listeners l
																	INNER JOIN sys.availability_databases_cluster d ON l.group_id = d.group_id
																WHERE dns_name = @AG
																FOR XML PATH('''')),2,8000)),'''');

				
				
				SET @AG = (SELECT top 1 dns_name FROM sys.availability_group_listeners WHERE @Database like ''%'' + dns_name + ''%'')
				
				SET @Database = REPLACE(@Database, ISNULL(@AG, ''''), @Database_AG);

				
			END';

		SET @ParmDefinition = N'@Database nvarchar(max) OUTPUT';
		
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
															AND source_database_id IS NULL
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


	select distinct b.database_name 
	into #DBsBak
	from msdb.dbo.backupset b
		join msdb.dbo.backupmediafamily m ON b.media_set_id = m.media_set_id
	where [type] like 'D' 
		and backup_start_date >= @IntervaloUltimaExecucao
		and b.database_name COLLATE Latin1_General_CI_AS in (select s.DatabaseName COLLATE Latin1_General_CI_AS from @SelectedDatabases s)


	select [DatabaseName] =  s.DatabaseName COLLATE Latin1_General_CI_AS  
	into #NotBackedUp 
	from @SelectedDatabases s
	except  
	select database_name COLLATE Latin1_General_CI_AS from #DBsBak;

	SELECT 
		[DatabaseName] = DB_NAME(r.database_id) 
		, r.start_time
		, [ElapsedTime_sec] = DATEDIFF(SECOND, r.start_time, GETDATE())
	INTO #InProgressBackup

	FROM sys.dm_exec_requests r 
		INNER JOIN @SelectedDatabases b ON DB_NAME(r.database_id) = b.DatabaseName 
	WHERE command = 'BACKUP DATABASE'		

	set @QtyBDsNotBackup = (select count(distinct DatabaseName)   from #NotBackedUp)
	set @QtyBDsInExecutionBackup = (select count(*) from #InProgressBackup)

	declare @tableHTML  nvarchar(max);
	set @tableHTML = '';
	declare @Subject as varchar(100)

	DECLARE @DBList VARCHAR(500)
	SET @DBList = ''

	IF (
			(@QtyBDsNotBackup > 0)
		AND (@QtyBDsInExecutionBackup = 0)
	   )
		BEGIN
			SELECT @DBList = @DBList + DatabaseName + CHAR(10)
			  FROM #NotBackedUp
			ORDER BY DatabaseName

			SET @DBList = SUBSTRING(@DBList, 2, LEN(@DBList))

			SELECT @alarmdesc = ' - DBA:Check SQL backup execution on host ' + @@servername + '.'
								+ CHAR(10) + 'Affected database(s): ' + @DBList  

			SET @isError = 1;

			IF @ErrorLog = 1
				EXEC master..xp_logevent 50001, @alarmdesc, error;
		END
	ELSE
		BEGIN
			IF (
						(@QtyBDsNotBackup > 0)
					AND (@QtyBDsInExecutionBackup > 0)
				)
			BEGIN
				SELECT @DBList = @DBList + DatabaseName + CHAR(10)
				  FROM #InProgressBackup
				ORDER BY DatabaseName

				SET @DBList = SUBSTRING(@DBList, 2, LEN(@DBList))

				SELECT @alarmdesc = ' - DBA:Full backup STILL execution on host ' + @@servername + '.'
									+ CHAR(10) + 'Affected database(s): ' + @DBList  

				SET @isError = 0;

				IF @ErrorLog = 1
					EXEC master..xp_logevent 50001, @alarmdesc, warning;
			END
		ELSE
			BEGIN
				SELECT @alarmdesc = ' - DBA:Successfully full backup execution on host ' + @@servername;

				SET @isError = 0;

				IF @ErrorLog = 1
					EXEC master..xp_logevent 50001, @alarmdesc, informational;
			END
		END;

	PRINT @alarmdesc

	/* INFO */
	select 
		[Database]  = d.DatabaseName
		,[Success] = CASE WHEN ISNULL(b.database_name, '') <> '' THEN 'Yes' ELSE 'No' END
		,[InProgess] =  CASE WHEN ISNULL(i.DatabaseName, '') <> '' THEN 'Yes' ELSE 'No' END 
		,[StartDate] = CASE WHEN ISNULL(i.DatabaseName, '') <> '' THEN CONVERT(VARCHAR(20), i.start_time, 120) ELSE '' END
		,[Failed] = CASE WHEN ISNULL(n.DatabaseName, '') <> '' THEN 'Yes' ELSE 'No' END
		,[IntervaloUltimaExecucao] = CONVERT(VARCHAR(20), @IntervaloUltimaExecucao, 120)
	FROM @SelectedDatabases d
		LEFT JOIN #DBsBak b ON b.database_name COLLATE Latin1_General_CI_AS= d.DatabaseName
		LEFT JOIN #NotBackedUp n ON n.DatabaseName COLLATE Latin1_General_CI_AS= d.DatabaseName
		LEFT JOIN #InProgressBackup i ON i.DatabaseName COLLATE Latin1_General_CI_AS= d.DatabaseName
	ORDER BY d.DatabaseName 
	/* FIM: INFO */


	if @mailprofilename is not null begin

		-- 'All'
		-- 'Failed'
		-- 'Success'
		-- 'InProgress'

		set @Subject = 'Backup execution on host ' + @@servername; 
		IF (@ReportMail = 'All') 
			OR (@ReportMail = 'Failed' AND @QtyBDsNotBackup > 0 and @QtyBDsInExecutionBackup = 0)
			OR (@ReportMail = 'Success' AND @QtyBDsNotBackup = 0 and @QtyBDsInExecutionBackup = 0)
			OR (@ReportMail = 'InProgress' AND @QtyBDsNotBackup > 0 and @QtyBDsInExecutionBackup > 0) 
			OR (@ReportMail = 'Failed_InProgress' AND (@QtyBDsNotBackup > 0 or @QtyBDsInExecutionBackup > 0))
		
		BEGIN
			SET @tableHTML =
					N'<H1>' + @Subject + '</H1>' +
					N'<table border="1">' +
					N'<tr>' + 
					N'<th>Database</th>' +
					N'<th>Success</th>' +
					N'<th>InProgess</th>' +
					N'<th>StartDate</th>' +
					N'<th>Failed</th>' +
					N'<th>IntervaloUltimaExecucao</th>' +
					N'</tr>' +
					CAST ( ( SELECT td = d.DatabaseName ,'',
									td = CASE WHEN ISNULL(b.database_name, '') <> '' THEN 'Yes' ELSE 'No' END  , '',
									td = CASE WHEN ISNULL(i.DatabaseName, '') <> '' THEN 'Yes' ELSE 'No' END  , '',
									td = CASE WHEN ISNULL(i.DatabaseName, '') <> '' THEN CONVERT(VARCHAR(20), i.start_time, 120) ELSE '' END  , '',
									td = CASE WHEN ISNULL(n.DatabaseName, '') <> '' THEN 'Yes' ELSE 'No' END  , '',
									td = CONVERT(VARCHAR(20), @IntervaloUltimaExecucao, 120), ''
								FROM @SelectedDatabases d
									LEFT JOIN #DBsBak b ON b.database_name COLLATE Latin1_General_CI_AS= d.DatabaseName
									LEFT JOIN #NotBackedUp n ON n.DatabaseName COLLATE Latin1_General_CI_AS= d.DatabaseName
									LEFT JOIN #InProgressBackup i ON i.DatabaseName COLLATE Latin1_General_CI_AS= d.DatabaseName
								ORDER BY d.DatabaseName 
								FOR XML PATH('tr'), TYPE 
					) AS NVARCHAR(MAX) ) +
					N'</table>' ;

			exec msdb.dbo.sp_send_dbmail 
				@profile_name = @MAILPROFILENAME,
				@recipients = @RECIPIENTS,
				@subject = @Subject ,
				@body = @tableHTML,
				@body_format = 'HTML';
		end

	end

	drop table #DBsBak;
	drop table #NotBackedUp;
end
