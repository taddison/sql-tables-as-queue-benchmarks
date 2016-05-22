# Dequeue tests - 1, 2, 4, 8 threads
$connectionString = Get-Content .\connectionstring.txt
$command = "exec dbo.DequeueMessage;"
$repeats = 20000

$threads = 1
write-host $threads "Threads executing " $command " " $repeats " times"
.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""

$threads = 2
write-host $threads "Threads executing " $command " " $repeats " times"
.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""

$threads = 4
write-host $threads "Threads executing " $command " " $repeats " times"
.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""

$threads = 8
write-host $threads "Threads executing " $command " " $repeats " times"
.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""