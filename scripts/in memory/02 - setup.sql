/* 
	In-memory implementation #2
	Outer proc which wraps the native dequeue, if 41302 is thrown it retries instantly (no jitter, backoff)
*/
use TAQBenchmarks
go
create table dbo.InMemoryQueue
(
	Id int identity(1,1) not null
	,Priority tinyint not null
	,MessageTypeId int not null
	,Payload varchar(1000) not null
	,constraint PK_ClusteredQueue primary key nonclustered ( Priority desc, Id asc )
) with (memory_optimized = on);
go

create procedure dbo.EnqueueMessage
	@id int
	,@message_priority tinyint = 0
with native_compilation, schemabinding, execute as owner
as
begin atomic with (transaction isolation level = snapshot, language = N'us_english')

	declare @payload varchar(1000) = '<id>' + cast(@id as varchar(10)) + '</id>';

	insert into dbo.InMemoryQueue
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

create procedure dbo.DequeueMessage_Inner
with native_compilation, schemabinding, execute as owner
as
begin atomic with (transaction isolation level = snapshot, language = N'us_english')

	declare @Id int
			,@priority tinyint
			,@messageTypeId int
			,@payload varchar(1000);

	select top (1)	@Id = q.Id
					,@priority = q.Priority
					,@messageTypeId = q.MessageTypeId
					,@payload = q.Payload
	from		dbo.InMemoryQueue as q
	order by	q.Priority desc
				,q.Id asc

	delete from dbo.InMemoryQueue
	where	Id = @Id
	and		Priority = @priority

	select	@messageTypeId as MessageTypeId
			,@payload as Payload
	where	@messageTypeId is not null
end;
go
create procedure dbo.DequeueMessage
as
begin
	declare @attempts int = 0;

	attempt:

	begin try
		set @attempts += 1;
		exec dbo.DequeueMessage_Inner;
	end try
	begin catch
		if @attempts >= 20
			throw;

		if error_number() = 41302
			goto attempt;
			
		throw;
	end catch
end