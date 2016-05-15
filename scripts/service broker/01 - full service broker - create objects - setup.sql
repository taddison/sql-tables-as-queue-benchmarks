/*
	01 - Full Service Broker
	This test uses queues as queues, and is intended to be the 'heaviest' test
	We'll be opening 1 dialog per message, then an end conversation, and closing the conversaion from the other side
	May Remus forgive us for our sins [http://rusanu.com/2006/04/06/fire-and-forget-good-for-the-military-but-not-for-service-broker-conversations/]
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
