select fg.name,
'ALTER DATABASE ['+ DB_NAME() +'] ADD FILE ( NAME = N'''+replace(f.name,'2017','2018')+''',FILENAME = N'''+replace(f.physical_name,'2017','2018')+''', SIZE = 1MB, MAXSIZE = 30GB, FILEGROWTH = 512MB) TO FILEGROUP ['+replace(fg.name,'2017','2018')+'] ;
GO
RAISERROR ('''+replace(f.name,'2017','2018')+'.ndf'', 0, 1) WITH NOWAIT
GO' as addfileCRMA, 
'ALTER DATABASE ['+ DB_NAME() +'] ADD FILEGROUP ['+replace(fg.name,'2017','2018')+'];
GO' as ADDFileGroup
from sys.database_files f
left join sys.filegroups fg on f.data_space_id=fg.data_space_id
where fg.name like '%2017%'
order by 3 desc
