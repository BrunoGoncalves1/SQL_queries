-- saber o que está impedindo a limpeza do log
select name, log_reuse_wait , log_reuse_wait_desc
from  sys.databases


-- pesquisar o arquivo de log atual
exec sp_readerrorlog 0, 1, 'Could not allocate space for object'


-- Código para ser colocado como passo em caso de erros em JOBs
declare @msg varchar(1000)
set @msg = 'COLOQUE AQUI A MENSAGEM DESEJADA'
exec master..xp_logevent 50001, @msg , error