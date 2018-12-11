 
DECLARE @continue INT
DECLARE @rowcount INT
DECLARE @msg varchar(50)

SET @continue = 1

WHILE @continue = 1
BEGIN
    PRINT GETDATE()
	   -- TAMANHO DO BLOCO A APAGAR NO TOP
       DELETE TOP (50000)  FROM [DBA_PTSI].[aud].[waits]
       -- CONDICAO EM QUE datahora E O CAMPO DATA DA TABELA E NESTE CASO MENOS DE 3 MESES
	   where datahora < DATEADD(MONTH, -3, GetDate())
       SET @rowcount = @@rowcount 

   RAISERROR(@msg, 0, 1) WITH NOWAIT; 
    
    IF @rowcount = 0
    BEGIN
        SET @continue = 0
    END
END 
 
