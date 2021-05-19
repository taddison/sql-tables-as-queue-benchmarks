# SQL Tables as Queues + Benchmarks
A collection of scripts & tools designed to demonstrate various methods of modelling a queue in MS SQL Server and the relative performance of each method.

You'll need an instance of SQL Server to target, and depending on which setup you deploy you will need SQL 2016 Enterprise/Developer.  Most examples work and have been tested on SQL 2014.

## Getting Started
1. Clone the repo
2. Create the database by running [this script](/scripts/setup/create%20database.sql)
3. Pick a setup you'd like to test - the simplest is [this one](/scripts/setup/create%20stub%20procs.sql) which is a pair of empty procs
4. Modify the connectionstring.txt file (located in the benchmarking folder) to provide appropriate server details
5. Run one of the benchmarks - I reccommend PowerShell ISE and starting with the [simplest benchmark](/benchmarks/run%20single%20benchmark%20with%20echo.ps1)

## Analysing waits
A script is included which will capture all waits driven by the SQLDriver application (application name is specified in the connectionstring.txt file), and then display summary data.  Additional instructions are included in the [SQL script](/benchmarks/extended%20event%20analysis.sql)

## Solution requirements
All solutions implemented must implement the following (and if they don't they should call that out):
- Message priority (higher priority messages are dequeued before lower priority messages)
- 'Loose' FIFO delivery for messages of equal priority (see note 1 below)
- The same message can not be read by two consumers (see note 2 below)
- Does not require a manual cleanup process (e.g. a heap with deletes will grow forever, dangling conversations endpoints will never go away)
- Dequeue procedure returns a varchar payload, and message type Id (see note 3 below)
- If there are no messages to dequeue the procedure should return an empty result set (0 rows) immediately
- Enqueue procedure accepts an integer, which is encoded in a varchar payload

1. FIFO does not need to be strict (we're not aiming to serialise access to the queue)
2. We're assuming the external system will not open any additional transactions (which would allow them to e.g. pop a message, read it, then rollback the outer transaction)
3. Using a varchar payload keeps the system fairly generic and allows for a variety of data to be stored (JSON, XML, etc.)

## Benchmarking methodology
- Enqueue performance. Starting with an empty queue enqueue with 1...N threads
- Dequeue performance. Starting with a 'full' queue and dequeue with 1...N threads
- Ghost hunting 👻. Enqueue N records and then dequeue them. And then repeat multiple times and assess performance (does it degrade on each run?)
  - Massive kudos to [Forrest][Forrest Blog] for pointing out that ghost records are why queues can/do suck so bad in SQL Server

SQLDriver allows for easy collection of results in these trials - the first example builds a CSV of results for 1...8 threads doing dequeues:

```powershell
"id,threads,repeats,duration,completed,failed,median,p90,p95,p99,p999,max" | Out-File results.csv

for($threads = 1; $threads -le 8; $threads++) {
    .\SQLDriver.exe -r 5 -t $threads -c "server=localhost;initial catalog=master;integrated security=sspi" -s "exec dbo.DequeueMessage" -m -i "BenchmarkOne" *>> results.csv
}
```

> m is minimal mode, i gives the row in the results an id, and *>> redirects the output to a file

If we wanted to capture the ghost hunting example we might use:

```powershell
$enqueue = "exec dbo.EnqueueMessage @id = 1"
$dequeue = "exec dbo.DequeueMessage"

"id,threads,repeats,duration,completed,failed,median,p90,p95,p99,p999,max" | Out-File results.csv
for($cycles = 1; $cycles -le 10; $cycles++) {
    $id = "Cycle $cycles enqueue"
    .\SQLDriver.exe -r 5 -t 5 -c "server=localhost;initial catalog=TAQBenchmarks;integrated security=sspi" -s $enqueue -m -i $id *>> results.csv

    $id = "Cycle $cycles dequeue"
    .\SQLDriver.exe -r 5 -t 5 -c "server=localhost;initial catalog=TAQBenchmarks;integrated security=sspi" -s $dequeue -m -i $id *>> results.csv
    
    Write-Host "Cycle $cycles complete"
}
```

Which would give a results file similar to:

```csv
id,threads,repeats,duration,completed,failed,median,p90,p95,p99,p999,max
Cycle 1 enqueue,5,5,22,25,0,0,2,5,15,15,15
Cycle 1 dequeue,5,5,20,25,0,0,2,5,15,15,15
Cycle 2 enqueue,5,5,23,25,0,0,1,5,17,17,17
Cycle 2 dequeue,5,5,21,25,0,0,1,5,16,16,16
Cycle 3 enqueue,5,5,22,25,0,0,2,5,16,16,16
Cycle 3 dequeue,5,5,23,25,0,0,2,6,16,16,16
```

## What is SQLDriver
If you don't want to run a random executable you downloaded from the internet (why wouldn't you?), then you can build it from source: https://github.com/taddison/SQLDriver

## How to contribute
Send a PR with a new implementation/open an issue/run some benchmarks on your hardware and share the results!

[Forrest Blog]: https://forrestmcdaniel.com/
