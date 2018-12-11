DECLARE @Database SYSNAME
DECLARE c CURSOR FOR SELECT name FROM sys.databases where [state] = 0 and database_id > 4 and name = 'DEV3_SITEB'
OPEN c
FETCH NEXT FROM c INTO @Database
WHILE @@FETCH_STATUS = 0 BEGIN 

	DECLARE @ErrorLog bit = 0
	DECLARE @Error_MBLivre int = 5120 
	DECLARE @Error_PercentualOcupado int  = 90
	DECLARE @Warning_MBLivre int = 7168
	DECLARE @Warning_PercentualOcupado int = 80

	IF OBJECT_ID('tempdb..#CRJfilestats') IS NOT NULL drop table #CRJfilestats
	IF OBJECT_ID('tempdb..#CRJfilegroup') IS NOT NULL drop table #CRJfilegroup
	IF OBJECT_ID('tempdb..#final') IS NOT NULL drop table #final

	declare @SQL nvarchar(max)

	create table #final (id int identity(1,1), name varchar(255),nro_ficheiros int, reservado int, ocupado int, livre int, percentagem smallint)

	create table #CRJfilestats (
		fileid int, 
		filegroup int, 
		totalextents decimal, 
		usedextents decimal, 
		name varchar(255), 
		filename varchar(1000)
	) 

	create table #CRJfilegroup (groupid int, groupname varchar(256)) 

	insert into #CRJfilestats     
	exec ('use [' + @Database + '] DBCC showfilestats with no_infomsgs') 

	insert into #CRJfilegroup 
	exec ('use [' + @Database + '] select  groupid, groupname from sysfilegroups')


	set @SQL = N'
	use [' + @Database + ']

	select 
		''' + @Database + '''
		,[FGroup]			= g.groupname 
		,[QTD Ficheiros]	= DataFileQT.QT
		,[Reservado (MB)]	= convert(decimal,sum(TotalExtents)*64/1024.)
		,[Ocupado (MB)]		= convert(decimal,sum(TotalExtents)*64/1024.) - convert(decimal,sum((TotalExtents - UsedExtents) * 64 / 1024.))
		,[Livre (MB)]		= convert(decimal,sum((TotalExtents - UsedExtents) * 64 / 1024.))
		,[% Ocupado]		= convert(decimal,100*convert(float,sum(UsedExtents))/sum(TotalExtents) )
		, CASE 
			WHEN convert(decimal,sum((TotalExtents - UsedExtents) * 64 / 1024.)) < '+CAST(@Error_MBLivre as nvarchar)+' and convert(decimal,100*convert(float,sum(UsedExtents))/sum(TotalExtents) ) > '+CAST(@Error_PercentualOcupado as nvarchar)+' THEN ''ERROR''
			WHEN convert(decimal,sum((TotalExtents - UsedExtents) * 64 / 1024.)) < '+ CAST(@Warning_MBLivre as nvarchar)+' and convert(decimal,100*convert(float,sum(UsedExtents))/sum(TotalExtents) ) > '+CAST(@Warning_PercentualOcupado as nvarchar)+' THEN ''WARN'' 
		  ELSE ''OK'' END AS STATUS
	from #CRJfilestats f 
		join #CRJfilegroup g on f.filegroup = g.groupid 
		cross apply (
					select f.name, [QT]	= COUNT(df.name)
					from sys.filegroups f
						inner join sys.database_files df on f.data_space_id = df.data_space_id
					where f.name = g.groupname collate Latin1_General_CI_AS
					group by f.name
		) as DataFileQT
	group by g.groupname, DataFileQT.QT 
	order by 6 desc'
	
	--print @SQL
	EXECUTE sp_executesql @SQL

	drop table #CRJfilestats
	drop table #CRJfilegroup
	drop table #final

	FETCH NEXT FROM c INTO @Database
END
CLOSE c
DEALLOCATE c