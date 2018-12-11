USE PTC_QS										-- rever

set nocount on
--	PRINT 'ALTER PARTITION SCHEME 2PS_DIARIA_DAT_CLIENTES_PTC_A NEXT USED [FG_CLIENTES_PTC_DAT_'+@Ano+'_A]'
--	PRINT 'ALTER PARTITION FUNCTION [PARTITION_F_DIARIA]() SPLIT RANGE ('+@CodData+ ')'
--select ps.name PScheme, pf.name PFunction from sys.partition_schemes ps join sys.partition_functions pf on (ps.function_id=pf.function_id)
--select distinct pf.name PFunction from sys.partition_functions pf

declare @dbname varchar(10)
set @dbname= 'PTC_QS'							-- rever


SELECT 'PRINT ''SET DEADLOCK_PRIORITY HIGH;'''
union all
SELECT 'PRINT ''GO'''
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED ['+left(replace(ps.name,'PS_DIARIA','FG_'+@dbname),len(replace(ps.name,'PS_DIARIA','FG_'+@dbname))-1)+'''+@Ano+'''+right(ps.name,2)+'];'''
from sys.partition_schemes ps 
where ps.name like 'PS_DIARIA______'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED ['+left(replace(ps.name,'PS_DIARIA','FG_'+@dbname),len(replace(ps.name,'PS_DIARIA','FG_'+@dbname))-2)+'''+@Ano+'''+right(ps.name,3)+'];'''
from sys.partition_schemes ps 
where ps.name like 'PS_DIARIA_______'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED ['+left(replace(ps.name,'PS_DIARIA','FG_'+@dbname),len(replace(ps.name,'PS_DIARIA','FG_'+@dbname))-3)+'''+@Ano+'''+right(ps.name,4)+'];'''
from sys.partition_schemes ps 
where ps.name like 'PS_DIARIA________'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+@dbname+'_'+substring(ps.name,4,3)+'_'+right(ps.name,1)+'_''+@Ano+''];'''
from sys.partition_schemes ps 
where ps.name like 'PS_____DIARIA__'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+@dbname+'_'+substring(ps.name,4,3)+'_'+right(ps.name,2)+'_''+@Ano+''];'''
from sys.partition_schemes ps 
where ps.name like 'PS_____DIARIA___'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,1)+'_'+substring(ps.name,10,len(ps.name)-9)+'_'+substring(ps.name,4,3)+'_''+@Ano+''_'+substring(ps.name,8,1)+'];'''
from sys.partition_schemes ps 
where ps.name like 'PS_______NSOM'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,1)+'_ACTIVIDADES_'+substring(ps.name,4,3)+'_''+@Ano+''_'+substring(ps.name,8,1)+'];'''
from sys.partition_schemes ps 
where  ps.name like 'PS_______ATIVIDADES'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,1)+'_'+substring(ps.name,10,len(ps.name)-9)+'_'+substring(ps.name,4,3)+'_''+@Ano2+''_'+substring(ps.name,8,1)+'];'''
from sys.partition_schemes ps 
where ps.name like 'PS_______SOLICITACAO'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,len(ps.name)-7)+'_'+substring(ps.name,4,3)+'_''+@Ano+''_H];'''
from sys.partition_schemes ps 
where ps.name like 'PS_____PROD_SERV_SIREL'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,len(ps.name)-7)+'_'+substring(ps.name,4,3)+'_''+@Ano+''_F];'''
from sys.partition_schemes ps 
where ps.name like 'PS_____ESTADO_REQUISICAO'
union all
select 'PRINT ''ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED [FG_'+substring(ps.name,8,len(ps.name)-7)+'_'+substring(ps.name,4,3)+'_''+@Ano+''_F];'''
from sys.partition_schemes ps 
where ps.name like 'PS_______VENDA'
