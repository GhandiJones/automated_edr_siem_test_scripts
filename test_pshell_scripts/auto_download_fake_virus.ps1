$name = @("death-machine","scary","weird","dragon","monster","wild","shiny","not-a") | Get-Random
$name = $name + "-virus.txt"
$path = "$PSScriptRoot\$name"
Invoke-WebRequest -Uri "https://secure.eicar.org/eicar.com" -OutFile $path
Write-Output "Completed Eicar testing."
