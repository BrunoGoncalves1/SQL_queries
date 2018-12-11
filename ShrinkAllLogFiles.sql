declare @dbname nvarchar(max), @logame nvarchar(max), @cmd nvarchar(max)

declare logcursor cursor for
select d.name, mf.name
from sys.master_files mf INNER JOIN sys.databases d ON d.database_id = mf.database_id and d.database_id > 4 and mf.type = 1

open logcursor

fetch next from logcursor into @dbname,@logame

while @@FETCH_STATUS = 0
begin

set @cmd = ' use ['+@dbname+'] DBCC SHRINKFILE('''+@logame+''',1)'
exec sp_executesql @cmd

fetch next from logcursor into @dbname,@logame

end

close logcursor
deallocate logcursor