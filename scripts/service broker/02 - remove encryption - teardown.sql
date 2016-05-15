use TAQBenchmarks
go
drop procedure dbo.EnqueueMessage
drop procedure dbo.DequeueMessage

drop broker priority HighPriority;
drop broker priority LowPriority;

drop service XML_Initiator_Service;
drop service XML_Receiver_Service;

drop queue XML_Initiator_Queue;
drop queue XML_Receiver_Queue;

drop contract XMLContract_LowPriority;
drop contract XMLContract_HighPriority

drop message type XMLMessage;
