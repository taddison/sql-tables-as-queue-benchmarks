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

create table dbo.QueueTracking
(
	Priority tinyint not null,
	ID int not null
)
go
create unique clustered index CUIX_QueueTracking on dbo.QueueTracking (Priority, Id) with (data_compression = page)
go
insert into dbo.QueueTracking
(
	Priority, Id
)
values
(0,1), (5,1)
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

	declare @dequeue table (Priority smallint, Id int, Payload varchar(1000), MessageTypeId int)
	declare @queueTrack table (Priority smallint primary key, Id int not null)

	insert @queueTrack
	select Priority, Id from dbo.QueueTracking;

	with CTE as (
		select top(1) q.Id, q.Priority
		from dbo.ClusteredQueue q with(rowlock, updlock, readpast, repeatableread)
		join @queueTrack qt
		on q.Priority = qt.Priority
		and q.ID > qt.ID
		order by q.Priority desc, q.Id
	)
	delete q
	output Deleted.Priority, Deleted.Id, Deleted.Payload, Deleted.MessageTypeId
	into @dequeue
	from dbo.ClusteredQueue q
	join cte c
	on q.Id = c.Id
	and q.Priority = c.Priority

	declare @id int
	declare @priority smallint

	select top (1) @id=ID, @priority=Priority from @dequeue

	if @id % 100 = 0
	begin
		update dbo.QueueTracking set Id = @id - 50
		where [Priority] = @priority
	end

	select d.Payload, d.MessageTypeId
	from @dequeue d
end;
go