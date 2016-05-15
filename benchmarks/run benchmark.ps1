$connectionString = Get-Content .\connectionstring.txt
$repeats = 5000
$threads = 4

$should_run_enqueue = $true
$should_run_dequeue = $true

if($should_run_enqueue)
{
    $command = "exec dbo.EnqueueMessage;"
    Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s $command", "-w"
}

if($should_run_dequeue)
{
    $command = "exec dbo.DequeueMessage;"
    Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s $command", "-w"
}
