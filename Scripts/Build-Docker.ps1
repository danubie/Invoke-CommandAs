cd $PSScriptRoot/docker
$imageName = 'icadev'
$containerName = 'icadev'
docker build -t $imageName .

# starting the container for tests
docker run --rm -it -d -p 5985:5985 --name $containerName $imageName powershell
$dockerData = docker inspect $containerName | ConvertFrom-Json
$ip = $dockerdata.NetworkSettings.Networks.nat.IPAddress

Write-Host "Container $containername runs on IP $ip" -ForegroundColor Cyan
