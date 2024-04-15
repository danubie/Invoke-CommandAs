# sample Invoke a command
$containerName = 'icadev'
$dockerData = docker inspect $containerName | ConvertFrom-Json
$ip = $dockerdata.NetworkSettings.Networks.nat.IPAddress
$pwd = ConvertTo-SecureString -String 'Inv-CmdAs!2024' -AsPlainText -Force
$cred = [pscredential]::new('IC', $pwd)
$splatRemote = @{
    Credential     = $cred
    ComputerName   = $ip
    Authentication = 'Basic'
    UseSSL         = $true
    SessionOption  = (New-PSSessionOption -SkipCACheck -SkipCNCheck)
}

if ((Get-Host).Name -like 'Visual*') {
    Write-Warning "This way of Enter-PSSession might hang using Visual Studio Code"
}

Write-Host "Checking PS5.1 Session" -ForegroundColor Cyan
Invoke-Command @splatRemote { $PSVersionTable }
Write-Host "Checking PS7 Session" -ForegroundColor Cyan
Invoke-Command @splatRemote { $PSVersionTable } -ConfigurationName Powershell.7
Write-Host "Entering PS7 Session" -ForegroundColor Cyan
Enter-PSSession @splatRemote -ConfigurationName Powershell.7