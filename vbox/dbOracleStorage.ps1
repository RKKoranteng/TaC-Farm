# @name: dbOracleStorage.ps1
# @author: Richard Koranteng (RKKoranteng.com)
# @description: provision storage for database install & configuration

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
$oracleDataDisk="50240"

# declare log file
$logFileTS = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy-s')
$logFile = "$home\Downloads\tac-vbox-dboracle-$logFileTS.txt"

# timestamp function
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
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


# add and attach SATA and IDE storage controllers
#Write-Output "$(Get-TimeStamp) Attaching VM storage ..." | Tee-Object -FilePath $logFile -append
#VBoxManage storageattach $vmName --storagectl SATA --port 0 --device 0 --type hdd --medium $vmPath\$vmName\$vmName.vdi



