SELECT sf.groupname as Filegroup,
a.name ,
cast(maxsize /1024 as bigint)*8 as MaxSize ,
CONVERT(Decimal(15,2),ROUND(a.Size/128.000,2)) [Currently Allocated Space (MB)],
CONVERT(Decimal(15,2),ROUND(FILEPROPERTY(a.Name,'SpaceUsed')/128.000,2)) AS [Space Used (MB)],
CONVERT(Decimal(15,2),ROUND((a.Size-FILEPROPERTY(a.Name,'SpaceUsed'))/128.000,2)) AS [Available Space (MB)],
--(cast(maxsize*8 /1024 as bigint) - (CONVERT(Decimal(15,2),ROUND(a.Size128.000,2)) - CONVERT(Decimal(15,2),ROUND((a.Size-FILEPROPERTY(a.Name,'SpaceUsed'))/128.000,2)))) AS MaxSpaceDisp,
LEFT(a.filename, CHARINDEX('\', a.filename,4)) AS Disk
, growth *8 /1024  as [Crescimento (MB)]
FROM sys.sysfiles AS a with (nolock) inner join sysfilegroups sf with (nolock) on a.groupid = sf.groupid
WHERE groupname LIKE '%PRIMARY%'
order by 1, 2

/* ADD FILE TO FILEGROUP
USE [master]
GO
ALTER DATABASE [RCA] ADD FILE
( NAME = N'FG_PTP_IOD_IDX_201503_F02',
 FILENAME = N'E:\SQL_DATA_28\MSSQL11.SQLRLPQA2\PTP_IOD\FG_PTP_IOD_IDX_201503_F02.ndf' ,
 SIZE = 2556MB ,
 MAXSIZE = 31457280KB ,
 FILEGROWTH = 524288KB )
  TO FILEGROUP [FG_PTP_IOD_IDX_201503_F]
GO
*/

/*
-- MODIFY FILE
USE [master]
GO
ALTER DATABASE [PTC_GC] MODIFY FILE ( NAME = N'FG_A_VENDA_DAT_2016_A_01', SIZE = 7168MB )
GO

 
DBCC SHRINKFILE (FG_PTP_IOD_DAT_201412_F3, EMPTYFILE); 
GO 
ALTER DATABASE [RCA]  REMOVE FILE FG_PTP_IOD_IDX_201503_F01
GO
 
*/