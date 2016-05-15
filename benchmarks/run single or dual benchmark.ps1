$connectionString = Get-Content .\connectionstring.txt
$repeats = 4000
$threads = 4

$should_run_enqueue = $true
$should_run_dequeue = $false

if($should_run_enqueue)
{
    $command = "exec dbo.EnqueueMessage @id=1;"
    Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s ""$command""", "-w"
}

if($should_run_dequeue)
{
    $command = "exec dbo.DequeueMessage;"
    Start-Process .\SQLDriver.exe -ArgumentList "-c ""$connectionString""","-r $repeats", "-t $threads", "-s ""$command""", "-w"
}
