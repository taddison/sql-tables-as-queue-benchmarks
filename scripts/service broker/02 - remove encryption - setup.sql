/*
	02 - Remove encryption from dialog
*/
use TAQBenchmarks
go

create message type XMLMessage validation = well_formed_xml;
go

create contract XMLContract_HighPriority ( XMLMessage sent by any );
create contract XMLContract_LowPriority ( XMLMessage sent by any );
go

create queue XML_Initiator_Queue;
create queue XML_Receiver_Queue;
go

create service XML_Initiator_Service on queue XML_Initiator_Queue ( XMLContract_HighPriority, XMLContract_LowPriority );
create service XML_Receiver_Service on queue XML_Receiver_Queue ( XMLContract_HighPriority, XMLContract_LowPriority );
go

create broker priority HighPriority
for conversation
set (contract_name = XMLContract_HighPriority
	,priority_level = 8
	,local_service_name = any
	,remote_service_name = any
);

create broker priority LowPriority
for conversation
set (contract_name = XMLContract_LowPriority
	,priority_level = 2
	,local_service_name = any
	,remote_service_name = any
);
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

	declare @ch uniqueidentifier;

	begin dialog conversation @ch
	from service XML_Initiator_Service
	to service 'XML_Receiver_Service'
	on contract XMLContract_HighPriority
	with encryption = off;

	declare @message xml = '<id>' + cast(@id as varchar(10)) + '</id>';

	send on conversation @ch
	message type XMLMessage
	(@message);

	end conversation @ch;
end;
go
create procedure dbo.DequeueMessage
as
begin
	set nocount on;

	declare @ch uniqueidentifier
			,@payload xml
			,@message_type_name nvarchar(256);
	
	;receive top(1) @payload = cast(message_body as xml)
					,@message_type_name = message_type_name
					,@ch = conversation_handle
	from XML_Receiver_Queue;

	if(@message_type_name = 'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog')
	begin
		end conversation @ch;
	end;
	else if(@payload is not null)
	begin
		select @payload as Payload;
	end
	else
	begin
		select top 0 @payload as Payload
	end;
end;
