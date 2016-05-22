use TAQBenchmarks
go

create table dbo.ClusteredQueue
(
	Id int identity(1,1) not null
	,Priority tinyint not null
	,MessageTypeId int not null
	,Payload varchar(1000) not null	
);
go
create unique clustered index CUIX_ClusteredQueue on dbo.ClusteredQueue ( Priority desc, Id asc ) with (data_compression = page)
go

create procedure dbo.EnqueueMessage
	@id int
	,@message_priority tinyint = 0
as
begin
	set nocount on;

	declare @payload varchar(1000) = '<id>' + cast(@id as varchar(10)) + '</id>';

	insert into dbo.ClusteredQueue
	(
		Priority
		,MessageTypeId
		,Payload
	)
	values
	(
		5
		,0
		,@payload
	);
end;
go

create procedure dbo.DequeueMessage
as
begin
	set nocount on;

	with cte as (
		select 	top (1)
				q.Payload
				,q.MessageTypeId
		from	dbo.ClusteredQueue as q with (readpast, rowlock)
		order by q.Priority desc, q.Id asc
	)
	delete from cte
	output deleted.Payload, deleted.MessageTypeId
end;
go