# Simple Powershell traffic generator
$FolderName = "C:\TrafficTest\files\"
$sites = "google.com", "yahoo.com", "microsoft.com"

# Create sub-directory if needed
if (-Not (Test-Path $FolderName)) {
    #PowerShell Create directory if not exists
    New-Item $FolderName -ItemType Directory
    Write-Host "Folder Created successfully"
}

# Loop through addresses, pull html, output to file
Foreach ($i in $sites){
    (wget http://$i).Content | Out-File -FilePath ($FolderName + ($i.Replace(".", "_")) + '.txt')
}
