SET NOCOUNT ON

DECLARE @text VARCHAR(MAX)

PRINT 'USE [' + DB_NAME() + ']'
PRINT 'GO'
--Add User To Database
--Usando o EXEC [sp_grantdbaccess
--Cria um Schema novo por cada user
/*
SELECT      'EXEC [sp_grantdbaccess]' + --CHAR(13) +
            --CHAR(9) + 
            '@loginame = ''' + [master].[dbo].[syslogins].[loginname] collate latin1_general_cs_as  + ''',' + --CHAR(13) +
           --CHAR(9) + 
            '@name_in_db = ''' + [sysusers].[name] + '''' --+ CHAR(13)
FROM  [dbo].[sysusers]
INNER JOIN [master].[dbo].[syslogins] ON [sysusers].[sid] = [master].[dbo].[syslogins].[sid]
--where     [sysusers].[name] = 'teste'
order by [sysusers].[name]*/
--Utilizar o conjunto de codigo acima ou este
--Add User To Database
--Usando o Create User (por defeito ficam com o schema DBO)
PRINT ''
PRINT '--CREATE USERS FOR LOGINS'

DECLARE txt_crete_user CURSOR
FOR
SELECT 'CREATE USER [' + [sysusers].[name] + '] FOR LOGIN [' + [master].[dbo].[syslogins].[loginname] collate latin1_general_cs_as + '] WITH DEFAULT_SCHEMA=[dbo]'
FROM [dbo].[sysusers]
INNER JOIN [master].[dbo].[syslogins] ON [sysusers].[sid] = [master].[dbo].[syslogins].[sid]
--where     [sysusers].[name] = 'teste'
WHERE uid > 4
ORDER BY [sysusers].[name]

OPEN txt_crete_user

FETCH NEXT
FROM txt_crete_user
INTO @text

WHILE @@FETCH_STATUS = 0
BEGIN
                PRINT @text

                FETCH NEXT
                FROM txt_crete_user
                INTO @text
END

CLOSE txt_crete_user

DEALLOCATE txt_crete_user

PRINT ''
PRINT '--DB_OWNER'

DECLARE @db_owner VARCHAR(MAX)

SELECT @db_owner = 'EXEC sp_changedbowner ''' + SUSER_SNAME(owner_sid) + ''',TRUE'
FROM sys.databases
WHERE database_id = DB_ID()

PRINT @db_owner
PRINT ''
PRINT '--FIX ORPHANED USERS'

DECLARE txt_crete_user CURSOR
FOR
--garante q o user é ligado ao login
SELECT 'EXEC sp_change_users_login ''Update_One'',' + '''' + [sysusers].[name] + ''',' + '''' + [sysusers].[name] + ''''
FROM [dbo].[sysusers]
INNER JOIN [master].[dbo].[syslogins] ON [sysusers].[sid] = [master].[dbo].[syslogins].[sid]
--where     [sysusers].[name] = 'teste'
WHERE uid > 4
ORDER BY [sysusers].[name]

OPEN txt_crete_user

FETCH NEXT
FROM txt_crete_user
INTO @text

WHILE @@FETCH_STATUS = 0
BEGIN
                PRINT @text

                FETCH NEXT
                FROM txt_crete_user
                INTO @text
END

CLOSE txt_crete_user

DEALLOCATE txt_crete_user

PRINT ''
PRINT '--ENROLE MEMBERS'

DECLARE txt_crete_user CURSOR
FOR
--Add Database Role
SELECT 'EXEC sp_addrolemember @rolename =' + SPACE(1) + QUOTENAME(USER_NAME(rm.role_principal_id), '''') + ', @membername =' + SPACE(1) + QUOTENAME(USER_NAME(rm.member_principal_id), '[''') AS '--Role Memberships'
FROM sys.database_role_members AS rm
--WHERE     USER_NAME(rm.member_principal_id) = @OldUser
WHERE rm.member_principal_id > 4
ORDER BY USER_NAME(rm.member_principal_id) ASC

OPEN txt_crete_user

FETCH NEXT
FROM txt_crete_user
INTO @text

WHILE @@FETCH_STATUS = 0
BEGIN
                PRINT @text

                FETCH NEXT
                FROM txt_crete_user
                INTO @text
END

CLOSE txt_crete_user

DEALLOCATE txt_crete_user

PRINT ''
PRINT '--GRANT DATABASE PERMISSIONS'

DECLARE txt_crete_user CURSOR
FOR
--Reporta Permissões ao nível da Base de Dados
--Por vezes estão alguns repetidos
SELECT 'GRANT ' + dp.permission_name collate latin1_general_cs_as + ' TO [' + dpr.NAME + ']'
FROM sys.database_permissions AS dp
INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id = dpr.principal_id
WHERE dpr.NAME NOT IN (
                               'public'
                               ,'guest'
                               )
                --AND permission_name='EXECUTE' 
                AND dpr.principal_id > 4
ORDER BY dpr.NAME

OPEN txt_crete_user

FETCH NEXT
FROM txt_crete_user
INTO @text

WHILE @@FETCH_STATUS = 0
BEGIN
                PRINT @text

                FETCH NEXT
                FROM txt_crete_user
                INTO @text
END

CLOSE txt_crete_user

DEALLOCATE txt_crete_user

PRINT ''
PRINT '--GRANT OBJECT PERMISSIONS'

DECLARE txt_crete_user CURSOR
FOR
--Reporta Permissões ao nível dos Objectos
SELECT 'GRANT ' + dp.permission_name collate latin1_general_cs_as + ' ON ' + s.NAME + '.' + o.NAME + ' TO [' + dpr.NAME + ']'
FROM sys.database_permissions AS dp
INNER JOIN sys.objects AS o ON dp.major_id = o.object_id
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id = dpr.principal_id
WHERE dpr.NAME NOT IN (
                               'public'
                               ,'guest'
                               )
                --AND permission_name='EXECUTE' 
                AND dpr.principal_id > 4
ORDER BY dpr.NAME

OPEN txt_crete_user

FETCH NEXT
FROM txt_crete_user
INTO @text

WHILE @@FETCH_STATUS = 0
BEGIN
                PRINT @text

                FETCH NEXT
                FROM txt_crete_user
                INTO @text
END

CLOSE txt_crete_user

DEALLOCATE txt_crete_user




