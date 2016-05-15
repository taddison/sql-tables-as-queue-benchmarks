$connectionString = Get-Content .\connectionstring.txt
$repeats = 4000
$threads = 4

# Seed with records to prevent the dequeue getting ahead of the enqueue
$command = "exec dbo.EnqueueMessage @id=1;"
.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""

# Benchmark start
$command = "exec dbo.EnqueueMessage @id=1;"
Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s ""$command""", "-w"

# end conversation messages
$repeats = $repeats * 2
$command = "exec dbo.DequeueMessage;"
Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s ""$command""", "-w"

