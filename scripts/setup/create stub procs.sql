use TAQBenchmarks
go
create procedure dbo.EnqueueMessage
	@id int
	,@message_priority tinyint = 0
as
begin
	return;
end;
go
create procedure dbo.DequeueMessage
as
begin
	select 1 as id;
end;