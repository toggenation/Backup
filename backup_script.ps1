# =================================
# 2026-07-18 13:56:15  
# james@toggen.com.au
# Shutdown VMware VMs
# 1. shutdown
# Standby VM2, Active VM1
# 2. 7zip backup
# 3. Startup
# Active VM1, Standby VM2
# 4.SCP to NAS
# =================================

# ================================
# CONFIGURATION IS IN config.ps1
# ================================
# Copy config.example.ps1 to config.ps1 and edit it to taste
. "$PSScriptRoot\config.ps1"

# ================================
# LOGGING FUNCTION
# ================================
function Log {
    param([string]$msg)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $msg"
    Write-Host $line
    Add-Content -Path $logFile -Value $line
}

# ================================
# VERIFY VM SHUTDOWN
# ================================
function Wait-ForShutdown {
    param([string]$vmx)

    while ($true) {
        $state = & $vmrun list | Select-String -Pattern $vmx -SimpleMatch
        if ($null -eq $state) {
            return
        }
        Log "Waiting for VM to shut down: $vmx"
        Start-Sleep -Seconds 5
    }
}

# ================================
# MAIN BACKUP PROCESS
# ================================

Log "Starting backup process."

foreach ($vm in $vmList) {

    Log "Stopping VM: $($vm.Name)"
    & $vmrun stop $vm.VMX soft

    Log "Verifying shutdown for: $($vm.Name)"
    Wait-ForShutdown $vm.VMX
    Log "VM is fully shut down: $($vm.Name)"
    Log "Wait for an extra ${vmShutdownWait} seconds for VM lck files to disapper"

    Start-Sleep -Seconds ${vmShutdownWait}
}

Log "VM shutdown complete."


Log "Start 7zip backup"
foreach ($vm in $vmList) {

    $archive = "$backupDir\$($vm.Name)-$timestamp.7z"

    if (Test-Path  $archive) {
        Log "Delete existing archive: $archive"
        Remove-Item $archive -Force
    }
    else {
        Log "No existing archive: $archive"
    }
    
    Log "Creating archive: $archive"
    # -bsp1 show progress
    & $zip a -t7z -bsp1 $archive $vm.Folder

    Start-Sleep 5

    $fileHash = Get-FileHash $archive
    $fileName = Split-Path $archive -Leaf
    Log "Create sha256sum for ${archive}"
    [IO.File]::WriteAllLines("${archive}.sha256sum", "$(${fileHash}.Hash.ToLower())  ${fileName}")

    Log "Backup completed for: $($vm.Name)"
}

Log "All VM backups completed."

# ================================
# SEND TO NAS
# ================================

Log "Starting send to NAS"

foreach ($vm in $vmList) {
    $archive = "$backupDir\$($vm.Name)-$timestamp.7z"
    
    Log "Sending archive to NAS: $archive"
    & $scp $scpArgs $archive "${nasUser}@${nasIp}:${nasPath}"

    Log "Sending sha256sum to NAS"
    & $scp $scpArgs "${archive}.sha256sum" "${nasUser}@${nasIp}:${nasPath}${fileName}.sha256sum"

    Log "Send to NAS completed for: $($vm.Name)"
}

Log "Send to NAS completed"

# ================================
# STARTUP
# ================================

$running = & $vmrun list

foreach ($i in ($vmList.count - 1)..0) {
    if ($running -contains $vmList[$i].vmx) {
        Log "Already running: $($vmList[$i].Name)"
    }
    else {
        Log "Starting:  $($vmList[$i].Name)" 
        & $vmrun start $vmList[$i].vmx gui
    }

    if ($vmList[$i] -eq $vmList[-1]) {
        Log "Sleeping $sleepSeconds seconds to wait for $($vmList[$i].Name) to boot"
        Start-Sleep -Seconds $sleepSeconds
    }
}

# ================================
# NOTIFICATIONS
# ================================

# Email notification
if ($sendEmail) {
    $body = Get-Content $logFile | Out-String
    Send-MailMessage -To $emailTo -From $emailFrom -Subject $emailSubject -Body $body -SmtpServer $smtpServer
    Log "Email notification sent."
}

Log "Backup script finished."