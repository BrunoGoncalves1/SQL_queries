
-- User_Hits ? Número de vezes que o índice teria sido utilizado caso já existisse
-- Estimated Improvement ? Percentagem estimada de improvement na  execução das queries se o índice existisse
-- Avg_Total_User_Cost ? Convém que seja o mais baixo possível, porque pode ser definido mais ou menos como o custo de manter o índice
-- Unique Compiles ?Quanto mais alto mais benéfico
-- Score ? Acima de 10000 o índice é claramente para adicionar, abaixo deste valor tem que ser estudado para verificar se o custo de manter o índice não é superior os -- ganhos que teríamos se o adicionássemos. Este valor é calculado pela seguinte query:
-- (user seeks + unique_compiles)  * avg_total_user_cost  *  avg_user_impact / 1000


SET NOCOUNT ON

DECLARE @DBLen int, @IC VARCHAR(4000), @ICWI VARCHAR(4000), @RI VARCHAR(4000), @DB VARCHAR(200), @IHK VARCHAR(200), @TBL VARCHAR(200), @Qryins VARCHAR(4000)

CREATE TABLE #IndexCreation (
	[DBid] int,
	DBName VARCHAR(200),
	[Table] VARCHAR(200),
	[User_Hits_on_Missing_Index] int,
	[Estimated_Improvement_Percent] DECIMAL(5,2),
	[Avg_Total_User_Cost] int,
	[Unique_Compiles] int,
	[Score] NUMERIC(19,3),
	[Equality] VARCHAR(1000),
	[Included] VARCHAR(4000),
	[Ix_Name] VARCHAR(100),
	Col1 VARCHAR(100) NULL,
	Col2 VARCHAR(100) NULL,
	Col3 VARCHAR(100) NULL,
	Col4 VARCHAR(100) NULL,
	Col5 VARCHAR(100) NULL,
	Col6 VARCHAR(100) NULL,
	Col7 VARCHAR(100) NULL,
	Col8 VARCHAR(100) NULL,
	Col9 VARCHAR(100) NULL,
	Col10 VARCHAR(100) NULL,
	Col11 VARCHAR(100) NULL,
	Col12 VARCHAR(100) NULL,
	Col13 VARCHAR(100) NULL,
	Col14 VARCHAR(100) NULL,
	Col15 VARCHAR(100) NULL,
	Col16 VARCHAR(100) NULL
	)

CREATE TABLE #IndexCreationSec (
	[Ix_Name] VARCHAR(200),
	DBName VARCHAR(200),
	[Table] VARCHAR(200),
	[Equality] VARCHAR(1000),
	[User_Hits_on_Missing_Index] int,
	[Estimated_Improvement_Percent] DECIMAL(5,2),
	[Avg_Total_User_Cost] int,
	[Unique_Compiles] int,
	[Score] NUMERIC(19,3)
	)

CREATE TABLE #TempIndexCreation(
	DBName sysname,
	[Ix_Name] VARCHAR(200),
	[Table] VARCHAR(200),
	Col1 VARCHAR(100) NULL,
	Col2 VARCHAR(100) NULL,
	Col3 VARCHAR(100) NULL,
	Col4 VARCHAR(100) NULL,
	Col5 VARCHAR(100) NULL,
	Col6 VARCHAR(100) NULL,
	Col7 VARCHAR(100) NULL,
	Col8 VARCHAR(100) NULL,
	Col9 VARCHAR(100) NULL,
	Col10 VARCHAR(100) NULL,
	Col11 VARCHAR(100) NULL,
	Col12 VARCHAR(100) NULL,
	Col13 VARCHAR(100) NULL,
	Col14 VARCHAR(100) NULL,
	Col15 VARCHAR(100) NULL,
	Col16 VARCHAR(100) NULL
	)

CREATE TABLE #tbl_DBAConsol_HypObj (
	[DBName] sysname,
	[Table] VARCHAR(200),
	[Object] VARCHAR(200),
	[Type] VARCHAR(10),
	)

CREATE TABLE #tbl_DBAConsol_Unused (
	[DBName] sysname,
	[Table] VARCHAR(200),
	[Ix_Name] VARCHAR(200),
	[Size_MB] DECIMAL(26,3),
	[Hits] bigint,
	[Reads_Ratio] DECIMAL(5,2),
	[Writes_Ratio] DECIMAL(5,2),
	[Updates] bigint,
	[Last_Update_Date] DATETIME NULL
	)
	

INSERT INTO #tbl_DBAConsol_HypObj
EXEC master.dbo.sp_MSforeachdb @command1='USE [?]; SELECT ''[?]'', QUOTENAME(OBJECT_NAME(i.id)), i.name, CASE WHEN INDEXPROPERTY(i.id, i.name, ''IsStatistics'') = 1 THEN ''STATISTICS'' ELSE ''INDEX'' END
FROM sysindexes i WHERE i.name LIKE ''hind_%'' AND (INDEXPROPERTY(i.id, i.name, ''IsStatistics'') = 1 AND INDEXPROPERTY(i.id, i.name, ''IsAutoStatistics'') = 0) OR (INDEXPROPERTY(i.id, i.name, ''IsHypothetical'') = 1)'

INSERT INTO #tbl_DBAConsol_Unused
EXEC master.dbo.sp_MSforeachdb @command1='USE [?]; SELECT ''[?]'', OBJECT_NAME(a.object_id), c.name,(SELECT used/128 FROM sysindexes b WHERE b.id = a.object_id AND b.name=c.name AND c.index_id = b.indid) AS [Space_Used],(a.user_seeks + a.user_scans + a.user_lookups) AS [Hits],
RTRIM(CONVERT(NVARCHAR(10),CAST(CASE WHEN (a.user_seeks + a.user_scans + a.user_lookups) = 0 THEN 0 ELSE CONVERT(REAL, (a.user_seeks + a.user_scans + a.user_lookups)) * 100 /
CASE (a.user_seeks + a.user_scans + a.user_lookups + a.user_updates) WHEN 0 THEN 1 ELSE CONVERT(REAL, (a.user_seeks + a.user_scans + a.user_lookups + a.user_updates)) END END AS DECIMAL(18,2)))) AS [Reads_Ratio],
RTRIM(CONVERT(NVARCHAR(10),CAST(CASE WHEN a.user_updates = 0 THEN 0 ELSE CONVERT(REAL, a.user_updates) * 100 /
CASE (a.user_seeks + a.user_scans + a.user_lookups + a.user_updates) WHEN 0 THEN 1 ELSE CONVERT(REAL, (a.user_seeks + a.user_scans + a.user_lookups + a.user_updates)) END END AS DECIMAL(18,2)))) AS [Writes_Ratio],
a.user_updates,a.last_user_update
FROM sys.dm_db_index_usage_stats a
JOIN dbo.sysobjects AS o ON (a.object_id = o.id)
JOIN sys.indexes AS c ON (a.object_id = c.object_id AND a.index_id = c.index_id)
WHERE o.type = ''U''			-- exclude system tables
AND c.is_unique = 0				-- no unique indexes
AND c.type = 2					-- nonclustered indexes only
AND c.is_primary_key = 0		-- no primary keys
AND c.is_unique_constraint = 0	-- no unique constraints
AND c.is_disabled = 0			-- only active indexes
AND OBJECTPROPERTY(c.[object_id], ''IsIndexable'') = 1
AND (a.index_id IS NULL OR ((a.user_seeks + a.user_scans + a.user_lookups) = 0 OR a.user_updates > 0))
AND a.database_id = DB_ID(''?'')'

INSERT INTO #IndexCreation ([DBid],DBName,[Table],[User_Hits_on_Missing_Index],[Estimated_Improvement_Percent],[Avg_Total_User_Cost],[Unique_Compiles],[Score],[Equality],[Included],[Ix_Name])
SELECT i.database_id AS [DBid],
	m.[name] AS DBName,
	RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)) AS [Table],
	[User_Hits_on_Missing_Index] = (s.user_seeks + s.user_scans),
	s.avg_user_impact, -- Query cost would reduce by this amount in percentage, on average.
	s.avg_total_user_cost, --Average cost of the user queries that could be reduced by the index in the group.
	s.unique_compiles, -- Number of compilations and recompilations that would benefit from this missing index group.
	(CONVERT(NUMERIC(19,3), s.user_seeks)+CONVERT(NUMERIC(19,3), s.user_scans))*CONVERT(NUMERIC(19,3), s.avg_total_user_cost)*CONVERT(NUMERIC(19,3), s.avg_user_impact) AS Score, --The higher the score, higher is the anticipated improvement for user queries.
	CASE	WHEN (i.equality_columns IS NOT NULL AND i.inequality_columns IS NULL) THEN i.equality_columns
			WHEN (i.equality_columns IS NULL AND i.inequality_columns IS NOT NULL) THEN i.inequality_columns
			ELSE i.equality_columns + ', ' + i.inequality_columns END AS [Equality],
	i.included_columns AS [Included],
	'IX_' + LEFT(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1),
	LEN(RIGHT(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), LEN(RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3))) - (CHARINDEX('.', RIGHT(i.[statement], LEN(i.[statement]) - (LEN(m.[name]) + 3)), 1)) - 1)) - 1) + '_' + CAST(i.index_handle AS NVARCHAR) AS [index_name]
FROM sys.dm_db_missing_index_details i
JOIN master..sysdatabases m ON i.database_id = m.dbid
JOIN sys.dm_db_missing_index_groups g ON i.index_handle = g.index_handle
JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
ORDER BY database_id, Equality, i.index_handle

INSERT INTO #IndexCreationSec
SELECT MAX(DISTINCT [Ix_Name]) AS [Ix_Name], DBName, [Table], [Equality], [User_Hits_on_Missing_Index], [Estimated_Improvement_Percent], [Avg_Total_User_Cost], [Unique_Compiles], [Score]
FROM #IndexCreation
WHERE [Included] IS NULL AND [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
GROUP BY DBName, [Table], [Equality], [User_Hits_on_Missing_Index], [Estimated_Improvement_Percent], [Avg_Total_User_Cost], [Unique_Compiles], [Score]

DECLARE @UpTime VARCHAR(12),@StartDate DATETIME
SELECT @StartDate = (SELECT login_time from master..sysprocesses where spid = 1)
SELECT @UpTime = DATEDIFF(mi, login_time, GETDATE()) FROM master..sysprocesses WHERE spid = 1
SELECT @StartDate AS Collecting_Data_Since, CONVERT(VARCHAR(4),@UpTime/60/24) + 'd ' + CONVERT(VARCHAR(4),@UpTime/60%24) + 'h ' + CONVERT(VARCHAR(4),@UpTime%60) + 'm' AS Collecting_Data_For

SELECT DBName,[Table],[User_Hits_on_Missing_Index],[Estimated_Improvement_Percent],[Avg_Total_User_Cost],[Unique_Compiles],[Score],[Equality],[Included],[Ix_Name]
FROM #IndexCreation
WHERE [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
ORDER BY DBName,[Score] DESC ,[User_Hits_on_Missing_Index],[Estimated_Improvement_Percent]

SELECT DBName, COUNT(DISTINCT [Ix_Name]) AS Total_Indexes_to_Create FROM #IndexCreation
WHERE [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
GROUP BY DBName

SELECT DBName, COUNT(DISTINCT [Ix_Name]) AS Indexes_with_INCLUDEs_to_Create FROM #IndexCreation
WHERE [Included] IS NOT NULL AND [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
GROUP BY DBName

SELECT DBName, COUNT(DISTINCT [Ix_Name]) AS Indexes_without_INCLUDEs_to_Create FROM #IndexCreation
WHERE [Included] IS NULL AND [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
GROUP BY DBName

SELECT DBName, [Type], COUNT(DISTINCT [Object]) AS Possibly_Hypothetical FROM #tbl_DBAConsol_HypObj
GROUP BY DBName, [Type]

SELECT DBName, COUNT(DISTINCT [Ix_Name]) AS Unused_nonclustered_Indexes FROM #tbl_DBAConsol_Unused
WHERE [Reads_Ratio] <15
GROUP BY DBName

SELECT 'Unused nonclustered indexes that can possibly be disabled' AS Comments,[DBName],[Table],[Ix_Name],[Size_MB],[Hits],CONVERT(NVARCHAR,[Reads_Ratio])+'/'+CONVERT(NVARCHAR,[Writes_Ratio]) AS [R/W_Ratio],[Updates],[Last_Update_Date]
FROM #tbl_DBAConsol_Unused
WHERE [Reads_Ratio] < 15

PRINT '--############# Index creation statements without INCLUDEs #############' + CHAR(10)

DECLARE cIC CURSOR FOR
SELECT '-- User Hits on Missing Index ' + [Ix_Name] + ': ' + CONVERT(VARCHAR(20),[User_Hits_on_Missing_Index]) + CHAR(10) +
	'-- Estimated Improvement Percent: ' + CONVERT(VARCHAR(6),[Estimated_Improvement_Percent]) + CHAR(10) +
	'-- Average Total User Cost: ' + CONVERT(VARCHAR(50),[Avg_Total_User_Cost]) + CHAR(10) +
	'-- Unique Compiles: ' + CONVERT(VARCHAR(50),[Unique_Compiles]) + CHAR(10) +
	'-- Score: ' + CONVERT(VARCHAR(20),[Score]) + CHAR(10) +
	'USE ' + QUOTENAME(DBName) + CHAR(10) + 'GO' + CHAR(10) + 'IF EXISTS (SELECT name FROM sysindexes WHERE name = N''' +
	[Ix_Name] + ''') DROP INDEX ' + [Table] + '.' +
	[Ix_Name] + ';' + CHAR(10) + 'GO' + CHAR(10) + 'CREATE NONCLUSTERED INDEX ' +
	[Ix_Name] + ' ON ' + [Table] + ' (' + [Equality] + ') WITH (PAD_INDEX = ON, FILLFACTOR = 70, ONLINE = ON);' + CHAR(10) + 'GO' + CHAR(10) -- AS CreateStatement
FROM #IndexCreationSec
ORDER BY DBName, [Table], [Ix_Name]
OPEN cIC
FETCH NEXT FROM cIC INTO @IC
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @IC
		FETCH NEXT FROM cIC INTO @IC
	END
CLOSE cIC
DEALLOCATE cIC

PRINT '--############# Index creation statements with INCLUDEs #############' + CHAR(10)

DECLARE cICWI CURSOR FOR
SELECT '-- User Hits on Missing Index ' + [Ix_Name] + ': ' + CONVERT(VARCHAR(20),[User_Hits_on_Missing_Index]) + CHAR(10) +
	'-- Estimated Improvement Percent: ' + CONVERT(VARCHAR(6),[Estimated_Improvement_Percent]) + CHAR(10) +
	'-- Average Total User Cost: ' + CONVERT(VARCHAR(50),[Avg_Total_User_Cost]) + CHAR(10) +
	'-- Unique Compiles: ' + CONVERT(VARCHAR(50),[Unique_Compiles]) + CHAR(10) +
	'-- Score: ' + CONVERT(VARCHAR(20),[Score]) + CHAR(10) +
	'USE ' + QUOTENAME(DBName) + CHAR(10) + 'GO' + CHAR(10) + 'IF EXISTS (SELECT name FROM sysindexes WHERE name = N''' +
	[Ix_Name] + ''') DROP INDEX ' + [Table] + '.' +
	[Ix_Name] + ';' + CHAR(10) + 'GO' + CHAR(10) + 'CREATE NONCLUSTERED INDEX ' +
	[Ix_Name] + ' ON ' + [Table] + ' (' + [Equality] + ')' + CHAR(10) + 'INCLUDE (' + [Included] + ') WITH (PAD_INDEX = ON, FILLFACTOR = 70, ONLINE = ON);' + CHAR(10) + 'GO' + CHAR(10) -- AS CreateStatementWithInclude
FROM #IndexCreation
WHERE [Included] IS NOT NULL AND [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
ORDER BY DBName, [Ix_Name]
OPEN cICWI
FETCH NEXT FROM cICWI INTO @ICWI
WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @ICWI
		FETCH NEXT FROM cICWI INTO @ICWI
	END
CLOSE cICWI
DEALLOCATE cICWI

DECLARE cRI CURSOR FOR SELECT QUOTENAME(DBName), [Ix_Name], [Table], [Equality]
						FROM #IndexCreation
						WHERE [Score] > 100 AND [User_Hits_on_Missing_Index] > 99
						GROUP BY DBName, [Table], [Equality], [Ix_Name]
						ORDER BY DBName, [Ix_Name]
OPEN cRI
FETCH NEXT FROM cRI INTO @DB, @IHK, @TBL, @RI
WHILE @@FETCH_STATUS = 0
	BEGIN
		--SELECT @DB, @IHK, @TBL, @RI
		DECLARE @TBLCol VARCHAR(4000)
		DECLARE @Col VARCHAR(50), @Colctr int, @Colctrdesc int, @StartPos int, @Length int
		SET @Colctr = 0
		SET @Colctrdesc = 0
		WHILE LEN(@RI) > 0
			BEGIN
				SET @StartPos = CHARINDEX(',', @RI)
				IF @StartPos < 0 SET @StartPos = 0
				SET @Length = LEN(@RI) - @StartPos - 1
				IF @Length < 0 SET @Length = 0
				IF @StartPos > 0
					BEGIN
						SET @Col = SUBSTRING(@RI, 1, @StartPos - 1)
						SET @RI = SUBSTRING(@RI, @StartPos + 1, LEN(@RI) - @StartPos)
						SET @Colctr = @Colctr + 1
					END
				ELSE
					BEGIN
						SET @Col = @RI
						SET @RI = ''
						SET @Colctr = @Colctr + 1
					END
				IF @TBLCol IS NULL
					BEGIN SET @TBLCol = CHAR(39) + LTRIM(RTRIM(@Col)) + CHAR(39) END
				ELSE
					BEGIN SET @TBLCol = @TBLCol + ',' + CHAR(39) + LTRIM(RTRIM(@Col)) + CHAR(39) END
			END
		IF @Colctr < 16
			BEGIN
				SET @Colctrdesc = 16 - @Colctr
				WHILE @Colctrdesc > 0
					BEGIN
						SET @TBLCol = @TBLCol + ',' + CHAR(39) + CHAR(39)
						SET @Colctrdesc = @Colctrdesc - 1
					END
				SET @Colctr = 0
			END
		SET @Qryins = 'INSERT INTO #TempIndexCreation (DBName,[Ix_Name],[Table],Col1,Col2,Col3,Col4,Col5,Col6,Col7,Col8,Col9,Col10,Col11,Col12,Col13,Col14,Col15,Col16)
VALUES (''' + @DB + ''',''' + RTRIM(@IHK) + ''',''' + @TBL + ''',' + @TBLCol + ')'
		EXECUTE (@Qryins)
		SET @TBLCol = NULL
		FETCH NEXT FROM cRI INTO @DB, @IHK, @TBL, @RI
	END
CLOSE cRI
DEALLOCATE cRI

UPDATE #IndexCreation
SET #IndexCreation.Col1 = #TempIndexCreation.Col1,#IndexCreation.Col2 = #TempIndexCreation.Col2,#IndexCreation.Col3 = #TempIndexCreation.Col3,#IndexCreation.Col4 = #TempIndexCreation.Col4,#IndexCreation.Col5 = #TempIndexCreation.Col5,
	#IndexCreation.Col6 = #TempIndexCreation.Col6,#IndexCreation.Col7 = #TempIndexCreation.Col7,#IndexCreation.Col8 = #TempIndexCreation.Col8,#IndexCreation.Col9 = #TempIndexCreation.Col9,#IndexCreation.Col10 = #TempIndexCreation.Col10,
	#IndexCreation.Col11 = #TempIndexCreation.Col11,#IndexCreation.Col12 = #TempIndexCreation.Col12,#IndexCreation.Col13 = #TempIndexCreation.Col13,#IndexCreation.Col14 = #TempIndexCreation.Col14,#IndexCreation.Col15 = #TempIndexCreation.Col15,#IndexCreation.Col16 = #TempIndexCreation.Col16
FROM #IndexCreation, #TempIndexCreation
WHERE #IndexCreation.[Table] = #TempIndexCreation.[Table] AND #IndexCreation.[Ix_Name] = #TempIndexCreation.[Ix_Name]

--SELECT * FROM #IndexCreation ORDER BY [Table],[Ix_Name]

SELECT 'Possibly redundant Indexes that will be created' AS Comments, I.DBName, I.[Table], I.[Ix_Name], I.[Equality] AS AllColName
FROM #IndexCreation I JOIN #IndexCreation I2
ON I.[Table] = I2.[Table] AND I.[Ix_Name] <> I2.[Ix_Name] AND I.Col1 = I2.Col2 AND I.Col2 = I2.Col1
WHERE I.[Included] IS NULL
GROUP BY I.DBName, I.[Table], I.[Ix_Name], I.[Equality]
ORDER BY I.[Table],I.[Ix_Name]

PRINT '--############# Existing hypothetical objects drop statements #############' + CHAR(10)

DECLARE @strSQL NVARCHAR(4000)
--SELECT 'Possibly Hypothetical Objects' AS Comments, DBName, [Table], [Object], [Type] FROM #tbl_DBAConsol_HypObj

DECLARE ITW_Stats CURSOR FOR SELECT 'USE ' + [DBName] + CHAR(10) + 'GO' + CHAR(10) + 'IF EXISTS (SELECT name FROM sysindexes WHERE name = N'''+ [Object] + ''')' + CHAR(10) +
CASE WHEN [Type] = 'STATISTICS' THEN 'DROP STATISTICS ' ELSE 'DROP INDEX ' END + [Table] + '.' + QUOTENAME([Object]) + ';' + CHAR(10) + 'GO' + CHAR(10) FROM #tbl_DBAConsol_HypObj ORDER BY DBName, [Table]
OPEN ITW_Stats
FETCH NEXT FROM ITW_Stats INTO @strSQL
WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @strSQL
	FETCH NEXT FROM ITW_Stats INTO @strSQL
END
CLOSE ITW_Stats
DEALLOCATE ITW_Stats

PRINT '--############# Existing unused indexes disable statements #############' + CHAR(10)

DECLARE cUnused CURSOR FOR SELECT 'USE ' + [DBName] + CHAR(10) + 'GO' + CHAR(10) + 'IF EXISTS (SELECT name FROM sysindexes WHERE name = N'''+ [Ix_Name] + ''')' + CHAR(10) +
'ALTER INDEX [' + [Ix_Name] + '] ON [' + [Table] + '] DISABLE;' + CHAR(10) + 'GO' + CHAR(10)
FROM #tbl_DBAConsol_Unused
WHERE [Reads_Ratio] < 15
ORDER BY DBName, [Table]
OPEN cUnused
FETCH NEXT FROM cUnused INTO @strSQL
WHILE (@@FETCH_STATUS = 0)
BEGIN
	PRINT @strSQL
	FETCH NEXT FROM cUnused INTO @strSQL
END
CLOSE cUnused
DEALLOCATE cUnused

DROP TABLE #tbl_DBAConsol_HypObj
DROP TABLE #tbl_DBAConsol_Unused
DROP TABLE #IndexCreation
DROP TABLE #IndexCreationSec
DROP TABLE #TempIndexCreation
GO