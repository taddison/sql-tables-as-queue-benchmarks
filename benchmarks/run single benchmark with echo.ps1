$connectionString = Get-Content .\connectionstring.txt
$repeats = 16000
$threads = 1

$command = "exec dbo.EnqueueMessage @id=1;"

.\SQLDriver.exe -c ""$connectionString"" -r $repeats -t $threads -s ""$command""