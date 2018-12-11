
set nocount on
declare @d datetime
declare @m datetime
declare @sql1 varchar(max)
declare @sql2 varchar(max)
set @d = getdate() -- data actual
set @m =dateadd (month,1, getdate())		--> é necessario ir modificando o mês à data actual. Para o mês de Janeiro, colocar o mês a 1. 
while @d <	cast ('20190101' as datetime )  --> é necessario incrementar o mês ao mês actual. para o mês de Janeiro, colocar 20180201. 


begin 
	if (select count(value) from sys.partition_range_values prv inner join sys.partition_functions pf on pf.function_id = prv.function_id where pf.function_id = 1 and cast ( value as char(8)) = convert(char(8), @d ,112) )=0
	begin
	
	-- match PS /FG - utilizar a quey sys.partition_schemes e sys.filegroups para fazer o match entre os PS's e os FG's. 
set @sql1=  '

ALTER PARTITION SCHEME [PS_DIARIA_DAT_F] NEXT USED [FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [04PS_DIARIA_IDX_F] NEXT USED [04FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [04PS_DIARIA_DAT_F] NEXT USED [04FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [01PS_DIARIA_IDX_F] NEXT USED [01FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [03PS_DIARIA_IDX_F] NEXT USED [03FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [01PS_DIARIA_DAT_F] NEXT USED [01FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [PS_DIARIA_DAT_A] NEXT USED [FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_A];
ALTER PARTITION SCHEME [02PS_DIARIA_IDX_F] NEXT USED [02FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [05PS_DIARIA_DAT_F] NEXT USED [05FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [02PS_DIARIA_DAT_F] NEXT USED [02FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [PS_DIARIA_IDX_A] NEXT USED [FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_A];
ALTER PARTITION SCHEME [05PS_DIARIA_IDX_F] NEXT USED [05FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [PS_DIARIA_IDX_F] NEXT USED [FG_PTC_IOD_IDX_'+convert(char(6), @d ,112)+'_F];
ALTER PARTITION SCHEME [03PS_DIARIA_DAT_F] NEXT USED [03FG_PTC_IOD_DAT_'+convert(char(6), @d ,112)+'_F];

'

print @sql1
--exec (@sql1)
	
	set @sql2='ALTER PARTITION FUNCTION PARTITION_A_DIARIA() SPLIT RANGE ('+convert(char(8), @d ,112) +');'
	print @sql2
	--exec (@sql2)

	end
	else 
		print  '-- value '+ convert(char(8), @d ,112) + ' exist'
	set @d= @d +1
end 
