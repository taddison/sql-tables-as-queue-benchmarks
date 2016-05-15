/* Review file-paths for your system, or remove to inherit from model
	- Key thing is to ensure files are large enough for us to not to autogrow during testing
 */
create database TAQBenchmarks on primary 
( name = N'TAQBenchmarks', filename = N'B:\SQL\TAQBenchmarks.mdf' , size = 1048576kb , filegrowth = 256000kb )
    log on 
( name = N'TAQBenchmarks_log', filename = N'B:\SQL\TAQBenchmarks_log.ldf' , size = 524288kb , filegrowth = 256000kb );
go
alter database TAQBenchmarks set compatibility_level = 120;
go
alter database TAQBenchmarks set enable_broker; 
go
alter database TAQBenchmarks set read_committed_snapshot on; 
go
alter database TAQBenchmarks set delayed_durability = allowed;
go
alter authorization on database::TAQBenchmarks to sa
go