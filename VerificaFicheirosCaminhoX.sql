-- SCRITP PARA VIZUALIZAR INFORMAÇÕES SOBRE OS FICHEIROS DE UM DETERMINADO CAMINHO

-- COLOCAR O CAMINHO NA VARIÁVEL ABAIXO

SET NOCOUNT ON


declare @CaminhoFicheiros varchar(500) -- caminho onde deseja verificar

set @CaminhoFicheiros = ''


IF OBJECT_ID('tempdb..#TempResults') IS NOT NULL
      DROP TABLE #TempResults

CREATE TABLE #TempResults
(
      DataBaseName VARCHAR(512)
      , FileGroup VARCHAR(512)
      , SpaceAvailable2Grow FLOAT
)

IF OBJECT_ID('tempdb..#DataBaseFiles') IS NOT NULL
      DROP TABLE #DataBaseFiles

CREATE TABLE #DataBaseFiles
(
      DataBaseName VARCHAR(512)
      , FileLogicalName VARCHAR(512)
      , FilePhysicalName VARCHAR(512)
      , FileSizeMB FLOAT
      , FIleType VARCHAR(512)
      , MaxSize VARCHAR(512)
      , Growth VARCHAR(512)
      , SpaceUsedMB FLOAT
      , AvailableSpaceMB FLOAT
      , State VARCHAR(512)
      , DataSpaceId VARCHAR(512)
      , FileGroup VARCHAR(512)
      , FileGroupType VARCHAR(512)
)

IF OBJECT_ID('tempdb..#DataBaseFilesFinal') IS NOT NULL
      DROP TABLE #DataBaseFilesFinal

CREATE TABLE #DataBaseFilesFinal
(	  RN INT
      ,DataBaseName VARCHAR(512)
      , FileLogicalName VARCHAR(512)
      , AvailableSpaceMB FLOAT
      , SpaceUsedMB FLOAT
      , FileGroup VARCHAR(512)
      , FileGroupType VARCHAR(512)
      , FilePhysicalName VARCHAR(512)
)

IF OBJECT_ID('tempdb..#DataBaseFileGroups') IS NOT NULL
      DROP TABLE #DataBaseFileGroups

CREATE TABLE #DataBaseFileGroups
(
      DataBaseName VARCHAR(512)
      , FileGroupName VARCHAR(512)
      , DataSpaceId VARCHAR(512)
      , Type VARCHAR(512)
)
IF OBJECT_ID('tempdb..#DataDirs') IS NOT NULL
      DROP TABLE #DataDirs
      
CREATE TABLE #DataDirs
(
      Dir VARCHAR(512)
      , StorageType VARCHAR(512)
      , TotalSpaceMB FLOAT
      , SpaceAvailableMB FLOAT
      , PercentFree FLOAT
)

IF OBJECT_ID('tempdb..#FileGroupSpace') IS NOT NULL
      DROP TABLE #FileGroupSpace
      
CREATE TABLE #FileGroupSpace
(
      DataBaseName VARCHAR(512)
      , FileGroupName VARCHAR(512)
      , AvailableAllocatedSpaceMB FLOAT
      , SpaceToGrowMB FLOAT
)

IF OBJECT_ID('tempdb..#UnlimitedFileGroups') IS NOT NULL
      DROP TABLE #UnlimitedFileGroups

CREATE TABLE #UnlimitedFileGroups
(
      DataBaseName VARCHAR(512)
      , FileGroup VARCHAR(512)
      , DriveOrMountPoint VARCHAR(512)
      , SpaceAvailableOnDriveMB INT
      , NumFiles INT
)

IF OBJECT_ID('tempdb..#Results') IS NOT NULL
      DROP TABLE #Results

CREATE TABLE #Results
(
      DataBaseName VARCHAR(512)
      , FileGroup VARCHAR(512)
      , SpaceAvailableUnlimitedFilesOnDriveMB INT
      , SpaceAvailableLimitedGrowthFilesMB INT
      , UnusedSpaceInFilesFilesMB INT
      , FileGroupSize INT
      , AvailableAllocatedSpaceMB INT
)

--################################INICIO################################--
--Verifica espaço em disco de acordo com a versão SQL Server
IF EXISTS(SELECT 1 FROM sys.sysobjects WHERE name='dm_os_volume_stats') AND (SELECT compatibility_level FROM sys.databases WHERE name=db_name()) > 80
BEGIN
      INSERT INTO #DataDirs (Dir, TotalSpaceMB, SpaceAvailableMB, PercentFree)
      EXEC('SELECT DISTINCT vs.volume_mount_point AS Dir,
            vs.total_bytes/1024/1024 as TotalSpaceMB, 
            vs.available_bytes/1024/1024 AS SpaceAvailableMB, 
            ROUND((vs.available_bytes*100)/(CAST(vs.total_bytes AS FLOAT)),2) AS PercentFree
      FROM sys.master_files AS mf WITH (NOLOCK)
            CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS vs 
      WHERE mf.database_id > 4')
END
ELSE 
BEGIN 
        DECLARE @cmdEnabled BIT
        DECLARE @advEnabled BIT
   
      IF NOT EXISTS(
            SELECT 1 AS config_value
            FROM  sys.configurations
            WHERE  name = 'show advanced options' 
                  AND CONVERT(INT, ISNULL(value, value_in_use)) = 1
      )
      BEGIN
            SET @advEnabled = 1
            EXEC sp_configure 'show advanced options', 1
            RECONFIGURE
      END
      
      IF NOT EXISTS(
            SELECT 1 AS config_value
            FROM  sys.configurations WITH (NOLOCK)
            WHERE  name = 'xp_cmdshell' 
                  AND CONVERT(INT, ISNULL(value, value_in_use)) = 1
      )
      BEGIN
            SET @cmdEnabled = 1
            EXEC sp_configure 'xp_cmdshell', 1
            RECONFIGURE
      END
      
      DECLARE @svrName VARCHAR(255)
      DECLARE @sql VARCHAR(400)

      SET @sql = 'powershell.exe -c "Get-WmiObject -Class Win32_Volume -Filter ''DriveType = 3'' | select name,capacity,freespace | foreach{$_.name+''|''+$_.capacity/1048576+''%''+$_.freespace/1048576+''*''}"'

      IF OBJECT_ID('tempdb..#output') IS NOT NULL
            DROP TABLE #output
      CREATE TABLE #output (line VARCHAR(255))
      
      INSERT #output
      EXEC xp_cmdshell @sql
      

      INSERT INTO #DataDirs (Dir, TotalSpaceMB, SpaceAvailableMB, PercentFree)
      SELECT DISTINCT RTRIM(LTRIM(SUBSTRING(line, 1, CHARINDEX('|', line) - 1))) AS drivename
            ,ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('|', line) + 1, (CHARINDEX('%', line) - 1) - CHARINDEX('|', line)))) AS FLOAT), 0) AS 'TotalSpaceMB'
            ,ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('%', line) + 1, (CHARINDEX('*', line) - 1) - CHARINDEX('%', line)))) AS FLOAT), 0) AS 'FreeSpaceMB'
            ,CAST((ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('%', line) + 1, (CHARINDEX('*', line) - 1) - CHARINDEX('%', line)))) AS FLOAT), 0) * 100.00)
            /ROUND(CAST(RTRIM(LTRIM(SUBSTRING(line, CHARINDEX('|', line) + 1, (CHARINDEX('%', line) - 1) - CHARINDEX('|', line)))) AS FLOAT), 0) AS NUMERIC(18,2)) AS PercentFree
      FROM #output A
            INNER JOIN sys.master_files B WITH (NOLOCK) ON B.physical_name LIKE rtrim(ltrim(SUBSTRING(A.line, 1, CHARINDEX('|', A.line) - 1))) + '%' 
                  AND B.database_id > 4
      WHERE line LIKE '[A-Z][:]%'

      IF @cmdEnabled IS NOT NULL
      BEGIN
            EXEC sp_configure 'xp_cmdshell', 0
            RECONFIGURE
      END
      
      IF @advEnabled IS NOT NULL
      BEGIN
            EXEC sp_configure 'show advanced options', 0
            RECONFIGURE
      END
END

--Elimina info de root mount points
DELETE FROM #DataDirs WHERE Dir IN (
      SELECT b.Dir 
      FROM #DataDirs a 
            INNER JOIN #DataDirs b ON a.Dir LIKE b.Dir + '%' AND LEN(b.Dir) < LEN(a.Dir)
)

--Obtem info de filegroups + ficheiros das BDs
INSERT INTO #DataBaseFileGroups(DataBaseName, FileGroupName, DataSpaceId, Type)
EXEC sp_MSforeachdb 'select "?", ISNULL(name,''*LOG*''), data_space_id, type_Desc from [?].sys.filegroups'

INSERT INTO #DataBaseFiles(DataBaseName, FileLogicalName, FilePhysicalName, FileSizeMB, FIleType, MaxSize, Growth, [SpaceUsedMB], [AvailableSpaceMB], State, DataSpaceId) 
EXEC sp_MSforeachdb '
use [?];
SELECT 
      DB_NAME(database_id) AS DataBaseName
      ,Name AS FileLogicalName
      ,Physical_Name AS FilePhysicalName 
      , (size*8)/1024 SizeMB
      , type_desc AS FIleType
      , CASE WHEN max_size = -1 AND growth = 0 THEN ''FIXEDSIZE'' WHEN max_size = -1 THEN ''UNLIMITED'' WHEN type_desc=''FILESTREAM'' THEN ''N/A'' ELSE CAST((CAST(max_size AS BIGINT)*8)/1024 AS VARCHAR)  END AS MaxSize
      , CASE WHEN max_size = -1 AND growth = 0 THEN ''FIXEDSIZE'' WHEN is_percent_growth = 1 THEN CONVERT(VARCHAR, growth)  + ''%'' WHEN type_desc=''FILESTREAM'' THEN ''N/A'' ELSE CONVERT(VARCHAR,(growth*8)/1024) + ''Mb'' END AS Growth
      , CONVERT(Decimal(15,2),ROUND(FILEPROPERTY(Name,''SpaceUsed'')/128.000,2)) AS [SpaceUsedMB]
      , CONVERT(Decimal(15,2),ROUND((Size-FILEPROPERTY(Name,''SpaceUsed''))/128.000,2)) AS [AvailableSpaceMB] 
      , state_desc AS State
      , data_space_id
FROM sys.master_files WITH (NOLOCK) WHERE DB_NAME(database_id) = ''?'' '

UPDATE #DataBaseFiles SET FileGroup = B.FileGroupName, FileGroupType = B.Type
FROM #DataBaseFiles A INNER JOIN #DataBaseFileGroups B ON A.DataBaseName = B.DataBaseName AND A.DataSpaceId = B.DataSpaceId

--Caracteriza os ficheiros de LOG com o FileGroup *LOG*
UPDATE #DataBaseFiles SET FileGroup = '*LOG*', FileGroupType = '*LOG_FILEGROUP*'
WHERE FileGroup IS NULL AND DataSpaceId = 0

INSERT INTO #UnlimitedFileGroups(DataBaseName, FileGroup, DriveOrMountPoint, SpaceAvailableOnDriveMB , NumFiles)
SELECT DataBaseName, FileGroup, Dir, MAX(SpaceAvailableMB) AS SpaceAvailableMB, COUNT(*) AS NumRecords
FROM #DataBaseFiles A
      INNER JOIN #DataDirs B ON A.FilePhysicalName LIKE B.Dir + '%'
WHERE MaxSize = 'UNLIMITED'
GROUP BY DataBaseName, FileGroup, Dir

INSERT INTO #Results(DataBaseName, FileGroup, SpaceAvailableUnlimitedFilesOnDriveMB)
SELECT DataBaseName, FileGroup, SUM(SpaceAvailableOnDriveMB) AS SpaceAvailableOnDriveMB
FROM #UnlimitedFileGroups
GROUP BY DataBaseName, FileGroup
ORDER BY DataBaseName


--Encontrar ficheiros de crescimento limitado sem ficheiros ilimitados na mesma drive do mesmo filegroup
INSERT INTO #TempResults (DataBaseName, FileGroup, SpaceAvailable2Grow)
SELECT DataBaseName, FileGroup, SUM(SpaceAvailable2Grow) AS SpaceAvailable2Grow
FROM
(
       SELECT A.DataBaseName, A.FileGroup, Dir, MAX(SpaceAvailableMB) AS SpaceAvailableMB, CASE WHEN SUM(CONVERT(INT, A.MaxSize)-A.FileSizeMB) > MAX(B.SpaceAvailableMB) THEN MAX(B.SpaceAvailableMB) ELSE SUM(CONVERT(INT, A.MaxSize)-A.FileSizeMB) END AS SpaceAvailable2Grow, COUNT(*) AS NumRecords, COUNT(C.FileGroup) FileGroupCount
       FROM #DataBaseFiles A
               INNER JOIN #DataDirs B ON A.FilePhysicalName LIKE B.Dir + '%'
               LEFT JOIN #UnlimitedFileGroups C ON A.DataBaseName = C.DataBaseName AND A.FileGroup = C.FileGroup AND B.Dir = C.DriveOrMountPoint
       WHERE MaxSize <> 'FIXEDSIZE' 
               AND MaxSize <> 'UNLIMITED' 
               AND FIleType IN ('ROWS','LOG')
               GROUP BY A.DataBaseName, A.FileGroup, Dir
               HAVING COUNT(C.FileGroup) = 0
) A
GROUP BY DataBaseName, FileGroup

INSERT INTO #Results(DataBaseName, FileGroup,SpaceAvailableLimitedGrowthFilesMB)
SELECT A.DataBaseName, A.FileGroup, A.SpaceAvailable2Grow
FROM #TempResults A 
       LEFT JOIN #Results B ON A.DataBaseName = B.DataBaseName AND A.FileGroup = B.FileGroup 
WHERE B.FileGroup IS NULL

UPDATE #Results SET SpaceAvailableLimitedGrowthFilesMB = A.SpaceAvailable2Grow
FROM #TempResults A 
       INNER JOIN #Results B ON A.DataBaseName = B.DataBaseName AND A.FileGroup = B.FileGroup

UPDATE #Results SET FileGroupSize = A.SpaceUsedMB, AvailableAllocatedSpaceMB = AvailableSpaceMB
FROM
(
      SELECT DataBaseName, FileGroup, CEILING(SUM(SpaceUsedMB)) AS SpaceUsedMB, CEILING(SUM(AvailableSpaceMB)) AS AvailableSpaceMB
      FROM #DataBaseFiles
      GROUP BY DataBaseName, FileGroup
) A INNER JOIN #Results B ON A.DataBaseName = B.DataBaseName AND A.FileGroup = B.FileGroup


UPDATE #DataDirs SET StorageType = B.FIleType
FROM #DataDirs A 
      LEFT JOIN #DataBaseFiles B ON B.FilePhysicalName LIKE A.Dir + '%' AND B.FIleType = 'ROWS'
          
UPDATE #DataDirs SET StorageType = ISNULL(StorageType + ',' + B.FIleType, B.FIleType)
FROM #DataDirs A 
      INNER JOIN #DataBaseFiles B ON B.FilePhysicalName LIKE A.Dir + '%' AND B.FIleType = 'LOG'

ALTER TABLE #DataBaseFiles ADD DataDir VARCHAR(MAX)
UPDATE #DataBaseFiles SET DataDir = A.Dir
FROM #DataDirs A INNER JOIN #DataBaseFiles B ON B.FilePhysicalName LIKE A.Dir + '%' 

--Geração de shrink de ficheiros
INSERT INTO #DataBaseFilesFinal
SELECT *
FROM (SELECT 
		ROW_NUMBER() OVER (PARTITION BY DataBaseName, FileGroup ORDER BY FileLogicalName) as RN
       , DataBaseName
       , FileLogicalName
       , AvailableSpaceMB
       , SpaceUsedMB
       , FileGroup
       , FileGroupType 
       , FilePhysicalName
FROM #DataBaseFiles A) A
WHERE 1 = 1
       AND DataBaseName NOT IN ('master','msdb','tempdb','model')
       --AND DataBaseName <> 'PTC_QS'
       --AND DataBaseName = 'PTC_LTA'
       AND FilePhysicalName LIKE @CaminhoFicheiros + 'N:\SQL_DATA_DEV_1[6-9]%'
       AND FilePhysicalName NOT LIKE @CaminhoFicheiros + '%.mdf'
	   AND (FileLogicalName LIKE '%200[0-9]%' or FileLogicalName LIKE '%201[0-9]%')
	   --AND (RN > 1 or (RN = 1 AND AvailableSpaceMB > 10))
	   --AND RN > 1
       --AND AvailableSpaceMB > 1024
       AND FileGroupType = 'ROWS_FILEGROUP'


SELECT TOP 100 *
FROM #DataBaseFilesFinal
ORDER BY 5

IF (1=0)
BEGIN
DECLARE filestomove CURSOR FOR
SELECT TOP 100 *
FROM #DataBaseFilesFinal
ORDER BY 5 

OPEN filestomove

declare @rn int
declare @databasename varchar(500)
declare @filelogicalname varchar(500)
declare @availablespace float
declare @spaceused float
declare @filegroup varchar(500)
declare @filegrouptype varchar(500)
declare @filephysicalname varchar(max)

declare @sql2 nvarchar(max)

FETCH NEXT FROM filestomove INTO @rn,@databasename, @filelogicalname,@availablespace,@spaceused,@filegroup,@filegrouptype,@filephysicalname

WHILE @@FETCH_STATUS = 0
BEGIN

set @sql2 = 'USE ['+@databasename+']

IF('+cast(@rn as nvarchar)+' = 1)
BEGIN
ALTER DATABASE ['+@databasename+'] ADD FILE
( NAME = N'''+@filegroup+'_00'',
 FILENAME = N''N:\SQL_DATA_DEV_11\RLPDEV2\'+@databasename+'\'+@filegroup+'_00.ndf'' ,
 SIZE = '+CAST(FLOOR(@spaceused)+1 as nvarchar)+'MB ,
 MAXSIZE = 31457280KB ,
 FILEGROWTH = 524288KB )
  TO FILEGROUP ['+@filegroup+']

END

DBCC SHRINKFILE ('+@filelogicalname+', EMPTYFILE); 
 
ALTER DATABASE ['+@databasename+']  REMOVE FILE '+@filelogicalname+''

--print @sql2
exec sp_executesql @sql2

FETCH NEXT FROM filestomove INTO @rn,@databasename, @filelogicalname,@availablespace,@spaceused,@filegroup,@filegrouptype,@filephysicalname

END

CLOSE filestomove
DEALLOCATE filestomove
END