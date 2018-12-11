--PS_DIARIA_DAT_A      				
--PS_DIARIA_DAT_F       				
--PS_DIARIA_IDX_A      				
--PS_DIARIA_IDX_F 
SET NOCOUNT ON

USE PTC_QS

DECLARE @dbname VARCHAR(10)
DECLARE @BD varchar(10)

SET @dbname = 'PTC_QS'
SET @BD = 'PTC_QS'

SELECT 'PRINT ''SET DEADLOCK_PRIORITY HIGH;'''
union all
SELECT 'PRINT ''GO'''
union all

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA______'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_DAT__'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 1) + '''+@Ano+''' + right(ps.NAME, 2) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_IDX__'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_______'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_DAT___'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 2) + '''+@Ano+''' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_IDX___'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA________'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+'''  + '_' +  right(ps.NAME, 3) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_DAT____'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [' + left(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname), len(replace(ps.NAME, 'PS_DIARIA', 'FG_' + @dbname)) - 3) + '''+@Ano+''' + '_' + right(ps.NAME, 3) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DIARIA_IDX____'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_____DIARIA__'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+'''''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+''.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT_DIARIA__'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+'''''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+''.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 1) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX_DIARIA__'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_____DIARIA___'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+'''''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+''.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT_DIARIA___'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+'''''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+''.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + @dbname + '_' + substring(ps.NAME, 4, 3) + '_' + right(ps.NAME, 2) + '_''+@Ano+'']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX_DIARIA___'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_______NSOM'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT___NSOM'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX___NSOM'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_______ATIVIDADES'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT___ATIVIDADES'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_ACTIVIDADES_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX___ATIVIDADES'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_______SOLICITACAO'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT___SOLICITACAO'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + ''''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + '.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, 1) + '_' + substring(ps.NAME, 10, len(ps.NAME) - 9) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano2+''_' + substring(ps.NAME, 8, 1) + ']'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX___SOLICITACAO'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_____PROD_SERV_SIREL'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H'''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT_PROD_SERV_SIREL'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H'''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_H]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX_PROD_SERV_SIREL'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_____ESTADO_REQUISICAO'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F'''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT_ESTADO_REQUISICAO'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F'''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX_ESTADO_REQUISICAO'

UNION ALL

SELECT 'PRINT ''GO'''



------ GC --------------


UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_______VENDA'

UNION ALL

SELECT 'PRINT ''GO'''

UNION ALL

-- Files
SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F'''',FILENAME=''''''+@dataf+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_DAT___VENDA'

UNION ALL

SELECT 'PRINT ''ALTER DATABASE [''+@BD+''] ADD FILE (NAME=''''FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F'''',FILENAME=''''''+@dataf2+''\''+@BD+''\FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F.ndf'''',SIZE=1MB,MAXSIZE=15GB,FILEGROWTH=256MB) TO FILEGROUP [FG_' + substring(ps.NAME, 8, len(ps.NAME) - 7) + '_' + substring(ps.NAME, 4, 3) + '_''+@Ano+''_F]'''
FROM sys.partition_schemes ps
WHERE ps.NAME LIKE 'PS_IDX___VENDA'

UNION ALL

SELECT 'PRINT ''GO'''

