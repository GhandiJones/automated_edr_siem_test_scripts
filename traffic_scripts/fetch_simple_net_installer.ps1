$ScriptLocation = Invoke-WebRequest https://raw.githubusercontent.com/GhandiJones/powershell_scripts/master/traffic_scripts/install_simple_net_generator.ps1
Invoke-Expression $($ScriptLocation.Content)
