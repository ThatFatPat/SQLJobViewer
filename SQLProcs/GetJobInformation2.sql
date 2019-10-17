CREATE proc GetJobInformation AS SELECT 
    [sJOB].[name] AS [Name]
	, [sSCH].[name] AS [Schedule Name]
    , [sDBP].[name] AS [Owner]
    , [sJOB].[description] AS [Description]
    , CASE [sJOB].[enabled]
        WHEN 1 THEN 'Yes'
        WHEN 0 THEN 'No'
      END AS [Is Enabled?]
    , [sJOB].[date_created] AS [Created On]
    , [sJOB].[date_modified] AS [Last ModifiedOn]
    , [sSVR].[name] AS [Server Name]
    , CASE
        WHEN [sSCH].[schedule_uid] IS NULL THEN 'No'
        ELSE 'Yes'
      END AS [Is Scheduled?]
	, CASE WHEN [sJOBHIS].[run_status]=0 THEN 'Failed'
		WHEN [sJOBHIS].[run_status]=1 THEN 'Succeeded'
		WHEN [sJOBHIS].[run_status]=2 THEN 'Retry'
		WHEN [sJOBHIS].[run_status]=3 THEN 'Cancelled'
		ELSE 'Unknown' 
	  END [Outcome]
FROM
    [msdb].[dbo].[sysjobs] AS [sJOB]
    LEFT JOIN [msdb].[sys].[servers] AS [sSVR]
        ON [sJOB].[originating_server_id] = [sSVR].[server_id]
    LEFT JOIN [msdb].[dbo].[syscategories] AS [sCAT]
        ON [sJOB].[category_id] = [sCAT].[category_id]
    LEFT JOIN [msdb].[dbo].[sysjobsteps] AS [sJSTP]
        ON [sJOB].[job_id] = [sJSTP].[job_id]
        AND [sJOB].[start_step_id] = [sJSTP].[step_id]
    LEFT JOIN [msdb].[sys].[database_principals] AS [sDBP]
        ON [sJOB].[owner_sid] = [sDBP].[sid]
    LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
        ON [sJOB].[job_id] = [sJOBSCH].[job_id]
    LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
        ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id]
	LEFT JOIN [msdb].[dbo].[sysjobhistory] AS [sJOBHIS]
		ON [sJOBHIS].[job_id] = [sJOB].[job_id]
ORDER BY [Name]