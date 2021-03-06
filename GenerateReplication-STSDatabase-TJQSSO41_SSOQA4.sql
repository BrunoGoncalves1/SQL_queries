-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'STSDatabase', @optname = N'publish', @value = N'true'
GO

exec [STSDatabase].sys.sp_addlogreader_agent @job_login = null, @job_password = null, @publisher_security_mode = 1
GO
exec [STSDatabase].sys.sp_addqreader_agent @job_login = null, @job_password = null, @frompublisher = 1
GO
-- Adding the transactional publication
use [STSDatabase]
exec sp_addpublication @publication = N'STSDatabase', @description = N'Transactional publication of database ''STSDatabase'' from Publisher ''VJQSSO30\SSOQA3''.', @sync_method = N'native', @retention = 0, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'false', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @repl_freq = N'continuous', @status = N'active', @independent_agent = N'true', @immediate_sync = N'true', @allow_sync_tran = N'false', @autogen_sync_procs = N'false', @allow_queued_tran = N'false', @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'true', @enabled_for_p2p = N'true', @enabled_for_het_sub = N'false', @p2p_conflictdetection = N'true', @p2p_originator_id = 3, @p2p_continue_onconflict = N'true'
GO


exec sp_addpublication_snapshot @publication = N'STSDatabase', @frequency_type = 4, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 8, @frequency_subday_interval = 1, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'NT AUTHORITY\SYSTEM'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'PTPORTUGAL\PT-DBA-SQLSERVER'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'PTSI\ST-ABD-SQLServer'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'PTSI\XWIN146'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'STAGINGINTRA\sqlssoqaagtsrv'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'NT SERVICE\MSSQL$SSOQA4'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'NT SERVICE\SQLAgent$SSOQA4'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'P2P'
GO
exec sp_grant_publication_access @publication = N'STSDatabase', @login = N'distributor_admin'
GO

-- Adding the transactional articles
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'Configuration', @source_owner = N'dbo', @source_object = N'Configuration', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Configuration', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboConfiguration0572872953411919490]', @del_cmd = N'CALL [sp_MSdel_dboConfiguration0572872953411919490]', @upd_cmd = N'SCALL [sp_MSupd_dboConfiguration0572872953411919490]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'dtStsAuditLog', @source_owner = N'dbo', @source_object = N'dtStsAuditLog', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'dtStsAuditLog', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dbodtStsAuditLog20200723601213369278]', @del_cmd = N'CALL [sp_MSdel_dbodtStsAuditLog20200723601213369278]', @upd_cmd = N'SCALL [sp_MSupd_dbodtStsAuditLog20200723601213369278]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'dtStsAuditLogArchive', @source_owner = N'dbo', @source_object = N'dtStsAuditLogArchive', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'dtStsAuditLogArchive', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dbodtStsAuditLogArchive77501846701323954893]', @del_cmd = N'CALL [sp_MSdel_dbodtStsAuditLogArchive77501846701323954893]', @upd_cmd = N'SCALL [sp_MSupd_dbodtStsAuditLogArchive77501846701323954893]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'IdentityProviderDisplayName', @source_owner = N'dbo', @source_object = N'IdentityProviderDisplayName', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'IdentityProviderDisplayName', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboIdentityProviderDisplayName1946636501095512901]', @del_cmd = N'CALL [sp_MSdel_dboIdentityProviderDisplayName1946636501095512901]', @upd_cmd = N'SCALL [sp_MSupd_dboIdentityProviderDisplayName1946636501095512901]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'LoginTemplates', @source_owner = N'dbo', @source_object = N'LoginTemplates', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'LoginTemplates', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboLoginTemplates981594661893622740]', @del_cmd = N'CALL [sp_MSdel_dboLoginTemplates981594661893622740]', @upd_cmd = N'SCALL [sp_MSupd_dboLoginTemplates981594661893622740]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'LogOperationType', @source_owner = N'dbo', @source_object = N'LogOperationType', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'LogOperationType', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboLogOperationType1881271620496102754]', @del_cmd = N'CALL [sp_MSdel_dboLogOperationType1881271620496102754]', @upd_cmd = N'SCALL [sp_MSupd_dboLogOperationType1881271620496102754]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'Mapping', @source_owner = N'dbo', @source_object = N'Mapping', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'Mapping', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboMapping10139302050331618516]', @del_cmd = N'CALL [sp_MSdel_dboMapping10139302050331618516]', @upd_cmd = N'SCALL [sp_MSupd_dboMapping10139302050331618516]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'NotificationAudit', @source_owner = N'dbo', @source_object = N'NotificationAudit', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'NotificationAudit', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboNotificationAudit02069531485551349739]', @del_cmd = N'CALL [sp_MSdel_dboNotificationAudit02069531485551349739]', @upd_cmd = N'SCALL [sp_MSupd_dboNotificationAudit02069531485551349739]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'NotificationLoginTemplate', @source_owner = N'dbo', @source_object = N'NotificationLoginTemplate', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'NotificationLoginTemplate', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboNotificationLoginTemplate10803468602114973351]', @del_cmd = N'CALL [sp_MSdel_dboNotificationLoginTemplate10803468602114973351]', @upd_cmd = N'SCALL [sp_MSupd_dboNotificationLoginTemplate10803468602114973351]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'NotificationMessage', @source_owner = N'dbo', @source_object = N'NotificationMessage', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'NotificationMessage', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboNotificationMessage296457630774128300]', @del_cmd = N'CALL [sp_MSdel_dboNotificationMessage296457630774128300]', @upd_cmd = N'SCALL [sp_MSupd_dboNotificationMessage296457630774128300]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'NotificationRule', @source_owner = N'dbo', @source_object = N'NotificationRule', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'NotificationRule', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboNotificationRule50254986001620611362]', @del_cmd = N'CALL [sp_MSdel_dboNotificationRule50254986001620611362]', @upd_cmd = N'SCALL [sp_MSupd_dboNotificationRule50254986001620611362]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'RelyingPartyProviders', @source_owner = N'dbo', @source_object = N'RelyingPartyProviders', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'RelyingPartyProviders', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboRelyingPartyProviders9857743241026786696]', @del_cmd = N'CALL [sp_MSdel_dboRelyingPartyProviders9857743241026786696]', @upd_cmd = N'SCALL [sp_MSupd_dboRelyingPartyProviders9857743241026786696]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'Reports', @source_owner = N'dbo', @source_object = N'Reports', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Reports', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboReports1192668015538149899]', @del_cmd = N'CALL [sp_MSdel_dboReports1192668015538149899]', @upd_cmd = N'SCALL [sp_MSupd_dboReports1192668015538149899]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'SharedKeys', @source_owner = N'dbo', @source_object = N'SharedKeys', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'SharedKeys', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboSharedKeys40094625801960928515]', @del_cmd = N'CALL [sp_MSdel_dboSharedKeys40094625801960928515]', @upd_cmd = N'SCALL [sp_MSupd_dboSharedKeys40094625801960928515]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TAuditLogOperations', @source_owner = N'dbo', @source_object = N'TAuditLogOperations', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TAuditLogOperations', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTAuditLogOperations79378090101686421373]', @del_cmd = N'CALL [sp_MSdel_dboTAuditLogOperations79378090101686421373]', @upd_cmd = N'SCALL [sp_MSupd_dboTAuditLogOperations79378090101686421373]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TAuditLogs', @source_owner = N'dbo', @source_object = N'TAuditLogs', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TAuditLogs', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTAuditLogs2056103663576527555]', @del_cmd = N'CALL [sp_MSdel_dboTAuditLogs2056103663576527555]', @upd_cmd = N'SCALL [sp_MSupd_dboTAuditLogs2056103663576527555]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TCCRequestState', @source_owner = N'dbo', @source_object = N'TCCRequestState', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TCCRequestState', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTCCRequestState020874640711520178930]', @del_cmd = N'CALL [sp_MSdel_dboTCCRequestState020874640711520178930]', @upd_cmd = N'SCALL [sp_MSupd_dboTCCRequestState020874640711520178930]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TClientApps', @source_owner = N'dbo', @source_object = N'TClientApps', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TClientApps', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTClientApps336225730259212279]', @del_cmd = N'CALL [sp_MSdel_dboTClientApps336225730259212279]', @upd_cmd = N'SCALL [sp_MSupd_dboTClientApps336225730259212279]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TDeviceTokens', @source_owner = N'dbo', @source_object = N'TDeviceTokens', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TDeviceTokens', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTDeviceTokens184671577801724700598]', @del_cmd = N'CALL [sp_MSdel_dboTDeviceTokens184671577801724700598]', @upd_cmd = N'SCALL [sp_MSupd_dboTDeviceTokens184671577801724700598]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TIdentitySelector', @source_owner = N'dbo', @source_object = N'TIdentitySelector', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TIdentitySelector', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTIdentitySelector01933528015826368626]', @del_cmd = N'CALL [sp_MSdel_dboTIdentitySelector01933528015826368626]', @upd_cmd = N'SCALL [sp_MSupd_dboTIdentitySelector01933528015826368626]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TOAuthTokens', @source_owner = N'dbo', @source_object = N'TOAuthTokens', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'TOAuthTokens', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTOAuthTokens022895071401460810940]', @del_cmd = N'CALL [sp_MSdel_dboTOAuthTokens022895071401460810940]', @upd_cmd = N'SCALL [sp_MSupd_dboTOAuthTokens022895071401460810940]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'TOAuthTokensAdditional', @source_owner = N'dbo', @source_object = N'TOAuthTokensAdditional', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'TOAuthTokensAdditional', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboTOAuthTokensAdditional011582662501840143782]', @del_cmd = N'CALL [sp_MSdel_dboTOAuthTokensAdditional011582662501840143782]', @upd_cmd = N'SCALL [sp_MSupd_dboTOAuthTokensAdditional011582662501840143782]'
GO
use [STSDatabase]
exec sp_addarticle @publication = N'STSDatabase', @article = N'VirtualPersona', @source_owner = N'dbo', @source_object = N'VirtualPersona', @type = N'logbased', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008035DDF, @identityrangemanagementoption = N'manual', @destination_table = N'VirtualPersona', @destination_owner = N'dbo', @status = 24, @vertical_partition = N'false', @ins_cmd = N'CALL [sp_MSins_dboVirtualPersona64937524302111874945]', @del_cmd = N'CALL [sp_MSdel_dboVirtualPersona64937524302111874945]', @upd_cmd = N'SCALL [sp_MSupd_dboVirtualPersona64937524302111874945]'
GO

-- Adding the transactional subscriptions
use [STSDatabase]
exec sp_addsubscription @publication = N'STSDatabase', @subscriber = N'VJQSSO30\SSOQA3', @destination_db = N'STSDatabase', @subscription_type = N'Push', @sync_type = N'replication support only', @article = N'all', @update_mode = N'read only', @subscriber_type = 0
exec sp_addpushsubscription_agent @publication = N'STSDatabase', @subscriber = N'VJQSSO30\SSOQA3', @subscriber_db = N'STSDatabase', @job_login = null, @job_password = null, @subscriber_security_mode = 1, @frequency_type = 64, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 4, @frequency_subday_interval = 5, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @dts_package_location = N'Distributor'
GO

