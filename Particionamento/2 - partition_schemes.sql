select 'ALTER PARTITION SCHEME ['+ps.name+'] NEXT USED ['+REPLACE(fg.name,'201701','''+convert(char(6), @d ,112)+''')+'];',
	fg.name as FileGroupname
    , dds.destination_id
    , dds.data_space_id
    , prv.value, ps.name, pf.function_id, pf.name
 from sys.partition_schemes ps
 inner join sys.partition_functions pf 
	on pf.function_id = ps.function_id
 inner join sys.destination_data_spaces as dds 
    on dds.partition_scheme_id = ps.data_space_id
 inner join sys.filegroups as fg 
    on fg.data_space_id = dds.data_space_id 
 left join sys.partition_range_values as prv 
    on prv.boundary_id = dds.destination_id and prv.function_id=ps.function_id 
 where CAST(prv.value as varchar) like '20170101' and pf.function_id = 65537