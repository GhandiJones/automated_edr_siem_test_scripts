# Simple Powershell traffic generator installer
$FolderName = "C:\TrafficTest\"
$TrafficLocation = "raw.githubusercontent.com/GhandiJones/powershell_scripts/master/simple_net_traffic.ps1"

# Create sub-directory if needed
if (-Not (Test-Path $FolderName)) {
    #PowerShell Create directory if not exists
    New-Item $FolderName -ItemType Directory
    Write-Host "Folder Created successfully"
}

(wget https://$TrafficLocation).Content | Out-File -FilePath ($FolderName + 'simple_net_traffic.ps1')
schtasks /create /sc minute /mo 1 /tn SimpleGenerator /tr ("powershell.exe -file " + $TrafficLocation + " simple_net_traffic.ps1")
