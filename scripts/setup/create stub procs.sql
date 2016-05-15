use TAQBenchmarks
go
if object_id('dbo.EnqueueMessage') is not null
	drop procedure dbo.EnqueueMessage
go
if object_id('dbo.DequeueMessage') is not null
	drop procedure dbo.DequeueMessage
go
create procedure dbo.EnqueueMessage
	@id int
	,@message_priority tinyint = 0
as
begin
	set nocount on;

	return;
end;
go
create procedure dbo.DequeueMessage
as
begin
	set nocount on;

	select cast('<id>1</id>' as xml) as Payload, 'TestType' as MessageType;
end;
