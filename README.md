# SQL Tables as Queues + Benchmarks
A collection of scripts & tools designed to demonstrate various methods of modelling a queue in MS SQL Server and the relative performance of each method.

You'll need an instance of SQL Server to target, and depending on which setup you deploy you will need SQL 2016 Enterprise/Developer.  Most examples work and have been tested on SQL 2014.

## Getting Started
1. Clone the repo
2. Create the database by running [this script](/scripts/setup/create database.sql)
3. Pick a setup you'd like to test - the simplest is [this one](/scripts/setup/create stub procs.sql) which is a pair of empty procs
4. Modify the connectionstring.txt file (located in the benchmarking folder) to provide appropriate server details
5. Run one of the benchmarks - I reccommend PowerShell ISE and starting with the [simplest benchmark](/benchmarks/run single benchmark with echo.ps1)

## Analysing waits
A script is included which will capture all waits driven by the SQLDriver application (application name is specified in the connectionstring.txt file), and then display summary data.  Additional instructions are included in the [SQL script](/benchmarks/extended event analysis.sql)

## Solution requirements
All solutions implemented must implement the following (and if they don't they should call that out):
- Message priority (higher priority messages are dequeued before lower priority messages)
- FIFO delivery for messages of equal priority
- Does not require a manual cleanup process (e.g. a heap with deletes will grow forever, dangling conversations endpoints will never go away)
- Dequeue procedure returns an XML payload, and message type name
- If there are no messages to dequeue the procedure should return an empty result set (0 rows) immediately
- Enqueue procedure accepts an integer, which is encoded in an XML payload

## Benchmarking methodology
Still todo.  Current thoughts are that there will be multiple solution types (e.g. Service Broker, Clustered Table, Hekaton, Ring Buffer) and the best performing from each category would be ranked against each other, and then inside of each category comparisons could be performed against similar solutions.

Ideally you'll be sending in a pull request with details on how your solution outperforms the current front-runner.  Some process of formally validating those claims on other hardware is needed, as well as sharing any analysis.

## What is SQLDriver
If you don't want to run a random executable you downloaded from the internet (why wouldn't you?), then you can build it from source: https://github.com/taddison/SQLDriver

## How to contribute
Send a PR with a new implementation/open an issue/run some benchmarks on your hardware and share the results!
