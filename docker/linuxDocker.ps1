# @name: dockerLinuxBuild.ps1
# @author: Richard Koranteng (RKKoranteng.com)
# @description: ephemeral Linux environment for playing around

param
(
    [Parameter(Mandatory=$true)][string]$containerName
)

# name of Docker Desktop exe
$dockerExe="Docker Desktop Installer.exe"

# RHEL UBI version
# to search for all UBI in RHELRegistry(https://registry.access.redhat.com/) 'docker search registry.access.redhat.com/ubi'
$universalBaseImage="ubi9"

# logfile
$logFileTS = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy-s')
$logFile= "$home\Downloads\tac-dockerlinux-install-$logFileTS.txt"



# timestamp function
function Get-TimeStamp {  

    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}


# download Docker Desktop
if (!(Test-Path "$HOME\Downloads\$dockerExe")) {

    Write-Output "$(Get-TimeStamp) Downloading Docker Desktop Software ..." | Tee-Object -FilePath $logFile -append
    wget "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe?utm_source=docker&utm_medium=webreferral&utm_campaign=dd-smartbutton&utm_location=module&_gl=1*1k7jmog*_ga*MTE2NDA2Mzg1NS4xNjkyMTE3Nzgy*_ga_XJWPQMJYHQ*MTY5MjIwOTIyOC4yLjEuMTY5MjIwOTIzMC41OC4wLjA." -OutFile $HOME\Downloads\$dockerExe
}

# check if Docker Desktop is installed
$installed = Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue

# install Docker Desktop
# refer to Docker Doc (https://docs.docker.com/desktop/install/windows-install/)
if ( $installed.DisplayName -ne 'Docker Desktop Service' ) {
    
    # enable WSL 
    Write-Output "$(Get-TimeStamp) Enabling Windows Subsystem for Linux (WSL) ..." | Tee-Object -FilePath $logFile -append
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

    # enable Virtualization platform
    Write-Output "$(Get-TimeStamp) Enabling Windows Virtual Machine Platform ..." | Tee-Object -FilePath $logFile -append
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

    # wsl2 as default version
    Write-Output "$(Get-TimeStamp) Defining WSL2 as Default ..." | Tee-Object -FilePath $logFile -append
    wsl --set-default-version 2

    # silent install Docker Desktop 
    Write-Output "$(Get-TimeStamp) Installing Docker Desktop Software ..." | Tee-Object -FilePath $logFile -append
    Start-Process -FilePath "$HOME\Downloads\$dockerExe" -ArgumentList @("install","--accept-license","--quiet") -Wait
}

# install the Docker-Microsoft PackageManagement Provider
if (!(Get-Module -ListAvailable -Name DockerMsftProvider)) { 

    Write-Output "$(Get-TimeStamp) Installing Docker PowerShell module ..." | Tee-Object -FilePath $logFile -append
    Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
}

# for switch to Linux Containers
# use '-SwitchWindowsEngine' if running windows container
&$Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchLinuxEngine

# checkget Docker service status
$dockerService = Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue

# start Docker service
if ( $dockerService.Status -eq 'Stopped' ) {

    Write-Output "$(Get-TimeStamp) Starting Docker service ..." | Tee-Object -FilePath $logFile -append
    Start-Service com.docker* -Passthru
}

# start DockerDekstop
$dockerEngine="Docker Desktop.exe"
&$Env:ProgramFiles\Docker\Docker\$dockerEngine
Start-Sleep -Seconds 30


# check if RHEL UBI version docker image exist locally
$imageCheck = docker images | findstr "$universalBaseImage"

# pull RHEL UBI version docker image if it does not exist locally
if ( $imageCheck -eq $null ){

    Write-Output "$(Get-TimeStamp) Pulling RHEL $universalBaseImage ..." | Tee-Object -FilePath $logFile -append
    docker pull registry.access.redhat.com/$universalBaseImage
}

# check if docker container exist
$containerCheck = docker container ls -a | findstr "$containerName"

# create docker container if it does not exist locally
if ( $containerCheck -eq $null ){

    Write-Output "$(Get-TimeStamp) Creating Docker container '$containerCheck' ..." | Tee-Object -FilePath $logFile -append
    docker run -itd --name $containerName registry.access.redhat.com/$universalBaseImage bash
} else {
    Write-Output "$(Get-TimeStamp) Docker container '$containerName' already exist ..." | Tee-Object -FilePath $logFile -append
}
