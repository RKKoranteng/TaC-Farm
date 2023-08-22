# @name: oel7.ps1
# @author: Richard Koranteng (RKKoranteng.com)
# @description: install VirtualBox and create OEL7 VM
#
# Change Log:
# 08.09.2023 - initial script
# 08.10.2023 - feat(add) check if VBox already installed
#            - feat(add) set vm path if already installed
#            - bugfix for 'error: Could not create a directory to save the settings file (VERR_ACCESS_DENIED)'
# 08.12.2023 - feat(add) logging functions

# declare OEL iso url
$isoURL = "https://yum.oracle.com/ISOS/OracleLinux/OL7/u7/x86_64/OracleLinux-R7-U7-Server-x86_64-dvd.iso"
#$isoName = "OracleLinux-R7-U7-Server-x86_64-dvd.iso"
$isoName = $isoURL.Split("/")[8]

# declare variables for VBox software
$vBoxExe = "VirtualBox-7.0.10-158379-Win.exe"
$vBoxVer = "7.0.10"

# declare VM name
$vmName = "ldev"

# declare path for VM objects
$vmPath="$HOME\VirtualBox VMs"

# declare VM OS; 'VBoxManage list ostypes' to get list of supported OS
$vmOS = "Oracle7_64"

# declare VM storage size in MB
$vmDiskSize = "20240"

# declare VM RAM and VRAM (in MB)
$memory = "4096"
$vram = "128"

# declare VM root credentials
$rootUser = "root"
$rootPassword = "welcome1"

# declare VM CPU
$cpu = "2"

# declare log file
$logFileTS = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy-s')
$logFile = "$home\Downloads\tac-vbox-oel7-$logFileTS.txt"

# timestamp function
function Get-TimeStamp {  
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# download ISO
if (!(Test-Path "$home\Downloads\$isoName" )) {
    Write-Output "$(Get-TimeStamp) Downloading $isoName iso ..." | Tee-Object -FilePath $logFile -append
    wget "$isoURL" -OutFile "$home\Downloads\$isoName"
} else {
    Write-Output "$(Get-TimeStamp) $isoName iso already downloaded ..." | Tee-Object -FilePath $logFile -append
}

## check if VBox is already installed
$installed = Get-Service -Name "VBoxSDS" -ErrorAction SilentlyContinue

if ( $installed.DisplayName -ne 'VirtualBox system service' ) 
{

    # download VBox 
    if (!(Test-Path "$home\Downloads\$vBoxExe" )) {
        Write-Output "$(Get-TimeStamp) Downloading VirtualBox $vBoxVer ..." | Tee-Object -FilePath $logFile -append
        wget "https://download.virtualbox.org/virtualbox/$vBoxVer/$vBoxExe" -OutFile "$home\Downloads\$vBoxExe"
    } else {
        Write-Output "$(Get-TimeStamp) VirtualBox $vBoxVer already downloaded ..." | Tee-Object -FilePath $logFile -append
    }

    # install VBox
    Write-Output "$(Get-TimeStamp) Installing VirtualBox Software ..." | Tee-Object -FilePath $logFile -append
    $vmEnvPath = "C:\VirtualBox"
    .$home\Downloads\$vBoxExe --msiparams INSTALLDIR=$vmEnvPath --silent --ignore-reboot
    Start-Sleep -Seconds 30
    $path = $Env:Path
    $newpath = $path.replace("$vmEnvPath","")
    $env:Path = $newpath
    $env:PATH = $env:PATH + ";$vmEnvPath;" 
}
else 
{
    Write-Output "$(Get-TimeStamp) VirtualBox already installed. Capturing existing settings ..." | Tee-Object -FilePath $logFile -append
    $vmFullPath = ((wmic service "VBoxSDS" get PathName /value | findstr /r /v "^$") -replace "PathName=","").Trim('"')
    $vmEnvPath = Split-Path -Path $vmFullPath
    $env:Path += ";$vmEnvPath" 
}

# create and register VM
Write-Output "$(Get-TimeStamp) Creating VM $vmName ..." | Tee-Object -FilePath $logFile -append
VBoxManage createvm --name $vmName --ostype $vmOS --register --basefolder $vmPath

# create VM storage medium
Write-Output "$(Get-TimeStamp) Creating VM storage ..." | Tee-Object -FilePath $logFile -append
VBoxManage createmedium disk --filename $vmPath\$vmName\$vmName.vdi --size $vmDiskSize

# add and attach SATA and IDE storage controllers
Write-Output "$(Get-TimeStamp) Attaching VM storage ..." | Tee-Object -FilePath $logFile -append
VBoxManage storagectl $vmName --name SATA --add SATA --controller IntelAhci
VBoxManage storageattach $vmName --storagectl SATA --port 0 --device 0 --type hdd --medium $vmPath\$vmName\$vmName.vdi
VBoxManage storagectl $vmName --name IDE --add ide
VBoxManage storageattach $vmName --storagectl IDE --port 0 --device 0 --type dvddrive --medium $home\Downloads\$isoName

# define VM general settings
# - set the VM RAM and virtual graphics card RAM size
Write-Output "$(Get-TimeStamp) Defining VM RAM and virtual graphic card RAM size ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --memory $memory --vram $vram

# - enable IO APIC
Write-Output "$(Get-TimeStamp) Enabling IO APIC ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --ioapic on

# - define boot order for VM
Write-Output "$(Get-TimeStamp) Defining boot order for VM ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --boot1 dvd --boot2 disk --boot3 none --boot4 none

# - define number of virtual CPUs for the VM
Write-Output "$(Get-TimeStamp) Defining number of virtual CPU for VM ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --cpus $cpu

# - disable VM audio (not needed for server) 
Write-Output "$(Get-TimeStamp) Disabling audio for VM ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --audio-driver none

# - disable USB. USB2.0, USB3.0 controllers
Write-Output "$(Get-TimeStamp) Disabling USB controllers for VM ..." | Tee-Object -FilePath $logFile -append
VBoxManage modifyvm $vmName --usb off
VBoxManage modifyvm $vmName --usbehci off
VBoxManage modifyvm $vmName --usbxhci off

# - define networking settings for VM
Write-Output "$(Get-TimeStamp) Defining VM network settings ..." | Tee-Object -FilePath $logFile -append
$wifiInterfaceName = (Get-NetAdapter -Name Wi-Fi).InterfaceDescription
VBoxManage modifyvm $vmName --nic1 bridged --bridgeadapter1 "$wifiInterfaceName"

# VM unattended install
Write-Output "$(Get-TimeStamp) Installing VM ..." | Tee-Object -FilePath $logFile -append
VBoxManage unattended install $vmName --user=$rootUser --password=$rootPassword --country=US --time-zone=EST --language=en-US --hostname=$vmName.localhost --iso=$home\Downloads\$isoName --start-vm=gui
