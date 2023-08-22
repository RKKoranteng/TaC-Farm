# @name: oracleDB.ps1
# @author: Richard Koranteng (RKKoranteng.com)
# @description: stage VM for deploying oracle database
#
# Change Log:
# 08.21.2023 - initial script

# prompt user for vmName
param
(
    [Parameter(Mandatory=$true)][string]$vmName
)

# declare storage
$oracleHomeDisk="oracleHome"
$oracleBackupDisk="oracleBackup"
$oracleRedoADisk="oracleRedoA"
$oracleRedoBDisk="oracleRedoB"
$oracleDataDisk="oracleData"

# declare VM storage size in MB
$oracleHomeDiskSize="10240"
$oracleBackupDiskSize="10240"
$oracleRedoADiskSize="5024"
$oracleRedoBDiskSize="5024"
$oracleDataDiskSize="50240"

# declare path for VM objects
$vmPath="$HOME\VirtualBox VMs"

# declare log file
$logFileTS = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy-s')
$logFile = "$home\Downloads\tac-vbox-dboracle-$logFileTS.txt"

# timestamp function
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# check if VM exist
$vmCheck=vboxmanage showvminfo "$vmName" | findstr "Name:"
$vmExist=($vmCheck.Split(":")[1]).trim()

# if VM found
if ( $vmExist -Match $vmName ){
    
    Write-Output "$(Get-TimeStamp) VM '$vmName' found ..." | Tee-Object -FilePath $logFile -append
    
    # get VM status
    $vmStatus=((vboxmanage showvminfo "$vmName" | findstr "State:").Split(":")[1]).Split("(")[0].trim() 

    # poweroff vm
    if ( $vmStatus -Match 'running' ){
        Write-Output "$(Get-TimeStamp) Powering off VM '$vmName' ..." | Tee-Object -FilePath $logFile -append
        vboxmanage controlvm "$vmName" acpipowerbutton
    } else {
       Write-Output "$(Get-TimeStamp) VM '$vmName' already powered off ..." | Tee-Object -FilePath $logFile -append
    }

    # create VM storage medium
    Write-Output "$(Get-TimeStamp) Creating VM storage '$oracleHomeDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage createmedium disk --filename $vmPath\$vmName\$oracleHomeDisk.vdi --size $oracleHomeDiskSize

    Write-Output "$(Get-TimeStamp) Creating VM storage '$oracleBackupDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage createmedium disk --filename $vmPath\$vmName\$oracleBackupDisk.vdi --size $oracleBackupDiskSize

    Write-Output "$(Get-TimeStamp) Creating VM storage '$oracleRedoADisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage createmedium disk --filename $vmPath\$vmName\$oracleRedoADisk.vdi --size $oracleRedoADiskSize

    Write-Output "$(Get-TimeStamp) Creating VM storage '$oracleRedoBDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage createmedium disk --filename $vmPath\$vmName\$oracleRedoBDisk.vdi --size $oracleRedoBDiskSize

    Write-Output "$(Get-TimeStamp) Creating VM storage '$oracleDataDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage createmedium disk --filename $vmPath\$vmName\$oracleDataDisk.vdi --size $oracleDataDiskSize


    # attach storage
    Write-Output "$(Get-TimeStamp) Attaching VM storage '$oracleHomeDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage storageattach $vmName --storagectl SATA --port 2 --device 0 --type hdd --medium $vmPath\$vmName\$oracleHomeDisk.vdi

    Write-Output "$(Get-TimeStamp) Attaching VM storage '$oracleBackupDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage storageattach $vmName --storagectl SATA --port 3 --device 0 --type hdd --medium $vmPath\$vmName\$oracleBackupDisk.vdi

    Write-Output "$(Get-TimeStamp) Attaching VM storage '$oracleRedoADisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage storageattach $vmName --storagectl SATA --port 4 --device 0 --type hdd --medium $vmPath\$vmName\$oracleRedoADisk.vdi

    Write-Output "$(Get-TimeStamp) Attaching VM storage '$oracleRedoBDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage storageattach $vmName --storagectl SATA --port 5 --device 0 --type hdd --medium $vmPath\$vmName\$oracleRedoBDisk.vdi

    Write-Output "$(Get-TimeStamp) Attaching VM storage '$oracleDataDisk' ..." | Tee-Object -FilePath $logFile -append
    VBoxManage storageattach $vmName --storagectl SATA --port 6 --device 0 --type hdd --medium $vmPath\$vmName\$oracleDataDisk.vdi

} else {
    Write-Output "$(Get-TimeStamp) Unable to find VM '$vmName' ..." | Tee-Object -FilePath $logFile -append
}
