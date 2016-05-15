/* 
	Create and analyses an extended event (XE) session which captures wait stats for the SQLDriver program only
	Inspired by the work of Paul Randall: http://www.sqlskills.com/blogs/paul/capturing-wait-stats-for-a-single-operation/
	Don't use the XE session when benchmarking, only for figuring out what to tune next

	- You may need to modify your file paths
	- Each time you stop/start the trace a new file will be created
	- When you do the data import ALL files are coming in, so you can either delete between runs, import by name, or filter on timestamp once imported
*/
if exists ( select * from sys.server_event_sessions where name = 'SQLDriverWaits' )
    drop event session SQLDriverWaits on server;
go

create event session SQLDriverWaits on server
add event sqlos.wait_info (
    where	sqlserver.client_app_name = N'SQLDriver'
	and		opcode = 1 /* End - otherwise we get the start & end of every wait */
	and		duration > 0
),
add event sqlos.wait_info_external (
    where sqlserver.client_app_name = N'SQLDriver'
	and		opcode = 1
	and		duration > 0
)
add target package0.asynchronous_file_target ( set filename = N'B:\SQL\SQLDriverWaits.xel' )
with (max_dispatch_latency = 1 seconds);
go

alter event session SQLDriverWaits on server state = start
/* Run workload */
alter event session SQLDriverWaits on server state = stop

if object_id('tempdb.dbo.#xetemp') is not null
	drop table #xetemp

SELECT cast(event_data as xml) as EventData
into #xetemp
from sys.fn_xe_file_target_read_file ('B:\SQL\SQLDriverWaits*.xel',null,NULL,NULL);

select	dat.WaitType
		,count(*) as WaitCount
		,sum(dat.Duration) as WaitTime
		,sum(coalesce(dat.SignalDuration,0)) as SignalWaitTime /* Only populated for internal waits */
from #xetemp as x
cross apply (
	select x.EventData.value('(/event/data[@name=''wait_type'']/text)[1]','varchar(100)') as WaitType
			,x.EventData.value('(/event/data[@name=''duration''])[1]', 'bigint') as Duration
			,x.EventData.value('(/event/data[@name=''signal_duration''])[1]', 'bigint') as SignalDuration
) as dat
group by dat.WaitType
order by count(*) desc