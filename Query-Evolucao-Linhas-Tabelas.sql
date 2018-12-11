----------------------------------------------------------------------------------------------------
-- Nome.....: Query-Evolucao-Linhas-Tabelas.SQL
----------------------------------------------------------------------------------------------------
-- Descrição: Crescimento anual Top Tables últimos 5 anos
-- Data.....: 2017-05-08
-- Autor....: Biazi Bayer
----------------------------------------------------------------------------------------------------
;WITH 
TopTables AS (
	 SELECT TOP 50
			a1.object_id,
			a3.name AS SchemaName,
			a2.name AS TableName,
			a1.rows as Row_Count,
			(a1.reserved )* 8.0 / 1024 AS reserved_mb,
			a1.data * 8.0 / 1024 AS data_mb,
			(CASE WHEN (a1.used ) > a1.data THEN (a1.used ) - a1.data ELSE 0 END) * 8.0 / 1024 AS index_size_mb,
			(CASE WHEN (a1.reserved ) > a1.used THEN (a1.reserved ) - a1.used ELSE 0 END) * 8.0 / 1024 AS unused_mb
	FROM    (   SELECT
				ps.object_id,
				SUM ( CASE WHEN (ps.index_id < 2) THEN row_count    ELSE 0 END ) AS [rows],
				SUM (ps.reserved_page_count) AS reserved,
				SUM (CASE   WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
							ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END
					) AS data,
				SUM (ps.used_page_count) AS used
				FROM sys.dm_db_partition_stats ps
				GROUP BY ps.object_id
			) AS a1
	INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
	INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
	WHERE a2.type <> N'S' and a2.type <> N'IT'   
	order by a1.data desc 
),
SizeHistory AS
(
	SELECT [ObjectName],[2013], [2014], [2015], [2016], [2017]
	FROM
	(	SELECT [ObjectName],MAX([RowCount]) Linhas,YEAR([DateTaken]) Ano
		FROM [DBA_PTSI_Management].[dbo].[TableEvolution] TE
		GROUP BY [ObjectName],YEAR([DateTaken])
	) AS origem
	PIVOT
	(	MAX(Linhas) FOR Ano IN ([2013], [2014], [2015], [2016], [2017])) AS PivotTable
),
IndexUsage AS
(
	SELECT object_id,MAX(last_user_update) last_user_update,MAX(last_user_seek) last_user_seek, 
		MAX(last_user_scan) last_user_scan, MAX(last_system_lookup) last_system_lookup
	FROM [sys].[dm_db_index_usage_stats] 
	GROUP BY object_id
)
SELECT TT.SchemaName,
	TT.TableName,
	TT.Row_Count,
	TT.reserved_mb,
	SH.[2013], SH.[2014], SH.[2015], SH.[2016], SH.[2017],
	CONVERT(varchar(10),IU.last_user_update,121) last_user_update,
	CONVERT(varchar(10),COALESCE(last_user_seek,last_user_scan,last_system_lookup),121) last_user_read
FROM TopTables TT
	LEFT JOIN SizeHistory SH
		ON TT.TableName = SH.ObjectName
	LEFT JOIN IndexUsage IU
		ON TT.object_id=IU.object_id
ORDER BY reserved_mb desc


