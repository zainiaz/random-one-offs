SELECT TOP 100
    j.name AS [job name],
    h.step_name AS [step name],
    h.run_status AS [run status],
    CASE h.run_status 
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 4 THEN 'In Progress'
    END AS [run status desc],
	h.run_date as [raw run date],
    h.run_time as [raw run time],
	CONCAT(
	    STUFF(STUFF(CAST(h.run_date AS VARCHAR), 7, 0, '-'), 5, 0, '-'),
	    ' ',
	    STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR), 6), 3, 0, ':'), 6, 0, ':')
	) as [formatted date-time]
FROM msdb.dbo.sysjobhistory h
INNER JOIN msdb.dbo.sysjobs j
ON h.job_id = j.job_id
WHERE 
j.job_id='<JOB ID>'
AND 
((
h.run_status in (0, 3) -- 0 = Failed, 3 = Canceled
AND CONVERT(DATETIME,
CONCAT(
	STUFF(STUFF(CAST(h.run_date AS VARCHAR), 7, 0, '-'), 5, 0, '-'),
	' ',
	STUFF(STUFF(RIGHT('000000' + CAST(h.run_time AS VARCHAR), 6), 3, 0, ':'), 6, 0, ':')
	)
) >= DATEADD(HOUR, -2, GETDATE()) -- Only jobs that have run in the last 2 hours
) OR j.enabled = 0)
ORDER BY h.run_date DESC, h.run_time DESC;