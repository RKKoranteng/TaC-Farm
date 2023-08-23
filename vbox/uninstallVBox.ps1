# @name: uninstallVBox.ps1
# @author: Richard Koranteng (RKKoranteng.com)
# @description: uninstall virtualbox
#
# Change Log:
# 08.22.2023 - initial script

# declare log file
$logFileTS = (Get-Date).AddDays(-1).ToString('MM-dd-yyyy-s')
$logFile = "$home\Downloads\tac-vbox-uninstall-$logFileTS.txt"

# timestamp function
function Get-TimeStamp {
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
}

# obtain specific VBox version name
$packageName=(get-package -Name "*VirtualBox*" -ErrorAction SilentlyContinue).Name

# if VBox found, then uninstall
if ( $packageName ) {
    
    Write-Output "$(Get-TimeStamp) Uninstalling '$packageName' ..." | Tee-Object -FilePath $logFile -append
    Uninstall-Package -Name "$packageName"
    Write-Output "$(Get-TimeStamp) Uninstall  finished ..." | Tee-Object -FilePath $logFile -append
} else {
    Write-Output "$(Get-TimeStamp) VirtualBox is not installed on your computer. Nothing to do ..." | Tee-Object -FilePath $logFile -append
}
