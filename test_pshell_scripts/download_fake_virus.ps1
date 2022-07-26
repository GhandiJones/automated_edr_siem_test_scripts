$name = @("death-machine","scary","weird","dragon","monster","wild","shiny","not-a") | Get-Random
$name = $name + "-virus.txt"
$path = "$PSScriptRoot\test_output\$name"
Invoke-WebRequest -Uri "https://secure.eicar.org/eicar.com" -OutFile $path
