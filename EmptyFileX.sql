
DECLARE @v_SpaceUsed FLOAT = 99999
DECLARE @v_str_SpacedUsed VARCHAR(10)
DECLARE @v_value INT
DECLARE @v_name VARCHAR(250)

SET @v_value = 30720
SET @v_name = 'iSellLogging_FG_PRIMARY_02'

WHILE( @v_SpaceUsed > @v_value)
      BEGIN
            SELECT @v_SpaceUsed = CAST(FILEPROPERTY(a.Name,'SpaceUsed')/128.000 AS float)
              FROM sys.sysfiles AS a with (nolock)
            WHERE a.name = @v_name
            
            -- SELECT * FROM sys.sysfiles 

            SET @v_str_SpacedUsed = CAST(@v_SpaceUsed AS VARCHAR(10))

            RAISERROR (@v_str_SpacedUsed, 0, 1) WITH NOWAIT
            
            WAITFOR DELAY '00:00:05'
      END
GO

KILL 102
GO

DBCC SHRINKFILE (N'iSellLogging_FG_PRIMARY_02', 30720)


ALTER DATABASE [iSellLogging] MODIFY FILE ( NAME = N'iSellLogging_FG_PRIMARY_02', MAXSIZE = 30720MB )
GO
