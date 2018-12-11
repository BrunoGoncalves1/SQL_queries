/**************************************************************************************
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

SET @LinkedServerName = 'TCPRLP34' -- None do linked Server identico a instância de AS 
SET @DataSource = '10.163.208.67'   --IP da Instancia de AS
SET @AllowOverwrite = 1

DECLARE @path VARCHAR(256) -- Backup path
SET @path = 'D:\OLAP_BACKUP\' -- Do not forget to add on the closing backslash !!!  -- Nome da Pasta do lado do AS

DECLARE @DT VARCHAR(20) -- Used for optional file name timestamp
-- Change timestamp to this format: _YYYY-MM-DD_HHMMSS
Set @DT = '_' + Replace(Replace(cast(getdate() as date), ':', ''), ' ', '_');


IF (SELECT COUNT(*) FROM sysservers WHERE srvname = @LinkedServerName) >= 1 BEGIN
	SET @SQL = 'EXEC master.dbo.sp_dropserver @server=N''' + @LinkedServerName + ''', @droplogins=''droplogins'' '
	EXEC(@SQL)
END
	
SET @SQL = '
	USE [master]

	EXEC master.dbo.sp_addlinkedserver	@server = N''' + @LinkedServerName + ''', @srvproduct=N'''', @provider=N''MSOLAP'', @datasrc=N''' + @DataSource + '''
	EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N''' + @LinkedServerName + ''',@useself=N''False'',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''collation compatible'', @optvalue=N''false''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''data access'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''dist'', @optvalue=N''false''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''pub'', @optvalue=N''false''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''rpc'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''rpc out'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''sub'', @optvalue=N''false''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''connect timeout'', @optvalue=N''0''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''collation name'', @optvalue=null
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''lazy schema validation'', @optvalue=N''false''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''query timeout'', @optvalue=N''0''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''use remote collation'', @optvalue=N''true''
	EXEC master.dbo.sp_serveroption @server=N''' + @LinkedServerName + ''', @optname=N''remote proc transaction promotion'', @optvalue=N''true''
'
EXEC(@SQL)

SET @SQL = '
	DECLARE @name VARCHAR(50) -- Cube name  
	DECLARE @fileName VARCHAR(256) -- Backup filename 
	
	Declare @XMLA nvarchar(4000) -- The SSAS command in XML format

	DECLARE curCube CURSOR FOR  
	
	SELECT ID
	FROM openquery(['+ @LinkedServerName +'], ''call ASSP.DiscoverXmlMetadataFull("Database")'') as a
	ORDER BY CAST(CAST(EstimatedSize AS NVARCHAR(MAX)) AS BIGINT) DESC
	
	OPEN curCube   
	FETCH NEXT FROM curCube INTO @name   
	
	WHILE @@FETCH_STATUS = 0 BEGIN   
	
	-- Create the XMLA string (overwrites the same files again and again)
	Set @XMLA = N''
	<Backup xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
		<Object>
		<DatabaseID>'' + @name + ''</DatabaseID>
		</Object>
		<File>' + @path + ''' + @name + ''.abf</File>
		<AllowOverwrite>true</AllowOverwrite>
	</Backup>
	'';	
	-- Execute the string across the linked server (SSAS)
	Exec (@XMLA) At '  + @LinkedServerName + '

	FETCH NEXT FROM curCube INTO @name   
END   

CLOSE curCube   
DEALLOCATE curCube
'

EXEC (@SQL);

SET @SQL = 'EXEC master.dbo.sp_dropserver @server=N''' + @LinkedServerName + ''', @droplogins=''droplogins'' ';
EXEC(@SQL);