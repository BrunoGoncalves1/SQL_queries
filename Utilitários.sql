
return -- segurança para não executar todos comandos aqui listados de uma só vez.


-- saber o que está impedindo a limpeza do log
select name, log_reuse_wait , log_reuse_wait_desc
from  sys.databases


-- pesquisar o arquivo de log atual
exec sp_readerrorlog 0, 1, 'Could not allocate space for object'


-- Código para ser colocado como passo em caso de erros em JOBs
declare @msg varchar(1000)
set @msg = 'COLOQUE AQUI A MENSAGEM DESEJADA'
exec master..xp_logevent 50001, @msg , error



-- Vários scripts úteis
https://blogs.msdn.microsoft.com/blogdoezequiel/2013/02/19/sql-swiss-army-knife-series-is-indexed/



-- Link para ver a descrição de erros no SQL Server
https://msdn.microsoft.com/en-us/library/windows/desktop/ms681382(v=vs.85).aspx



-- Link para atalhos no SQL Server Management Studio
https://msdn.microsoft.com/en-us/library/ms174205.aspx


-- Ebooks
https://mva.microsoft.com/ebooks