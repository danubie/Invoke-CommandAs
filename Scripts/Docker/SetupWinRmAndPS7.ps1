# enable WinRM over https
# kudos go to Tobias Fenster https://tobiasfenster.io/container-to-container-winrm
# inside the powershell container excute (because I cannot find a way to correctly escape it to be done in the Dockerfile)
$cert = New-SelfSignedCertificate -DnsName "dontcare" -CertStoreLocation Cert:\LocalMachine\My;
winrm create winrm/config/Listener?Address=*+Transport=HTTPS ('@{Hostname="dontcare"; CertificateThumbprint="' + $cert.Thumbprint + '"}')
winrm set winrm/config/service/Auth '@{Basic="true"}'
# download and install PS7 and enable PSRemoting for PS7
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
$ENV:PATH = 'C:\Program Files\PowerShell\7;' + $ENV:PATH; pwsh -File 'C:\Program Files\PowerShell\7\Install-PowerShellRemoting.ps1'
