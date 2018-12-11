SELECT DB_NAME(database_id) AS DatabaseName, name AS LogicalFileName, physical_name AS PhysicalFileName 
FROM sys.master_files AS mf
where DB_NAME(database_id) = 'ReportServerTempDB'


--ALTER DATABASE ReportServerTempDB SET OFFLINE WITH ROLLBACK IMMEDIATE

--robocopy "N:\SQL_DATA_DEV_22\RLPDEV1\ReportServerTempDB" "N:\SQL_DATA_DEV_03\RLPDEV1\ReportServerTempDB" ReportServerTempDB.mdf /mir /sec

--ALTER DATABASE ReportServerTempDB MODIFY FILE ( NAME = ReportServerTempDB, FILENAME = 'N:\SQL_DATA_DEV_03\RLPDEV1\ReportServerTempDB\ReportServerTempDB.mdf' );


--ALTER DATABASE ReportServerTempDB SET ONLINE