# ================================
# CONFIGURATION
# ================================
# Copy this from config.example.ps1 to config.ps1

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'vmrun', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'zip', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'scp', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'vmShutdownWait', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'nasUser', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'nasIp', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'smtpServer', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'emailTo', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'emailFrom', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'emailSubject', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'scpArgs', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'sendEmail', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'sleepSeconds', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'logFile', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'vmList', Justification = 'Used in pipeline/scope')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'nasPath', Justification = 'Used in pipeline/scope')]

param()

$vmrun = "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
$zip = "C:\Program Files\7-Zip\7z.exe"
$scp = "C:\WINDOWS\System32\OpenSSH\scp.exe"

# timeouts
$vmShutdownWait = 5
$sleepSeconds = 60

# NAS credentials
$nasUser = "nasuser"
$nasIp = '10.11.12.13'
$scpArgs = '-i .\.ssh\id_ed25519 -P 8022' # update this for the live env
# relative to `/volume1' so real path is `/volume1/shared_folder/sub_folder/backup/'
$nasPath = '/shared_folder/sub_folder/backup/'

$vmList = @(
    # put them in order of shutdown top first, bottom last to shutdown
    @{ Name = "VM2 - Standby"; VMX = "E:\VMWare\VM2\VM2.vmx"; Folder = "E:\VMWare\VM2" }
    @{ Name = "VM1 - Active"; VMX = "E:\VMWare\VM1\VM1.vmx"; Folder = "E:\VMWare\VM1" },
)

$backupDir = "c:\backup"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$timestamp = Get-Date -Format "yyyy-MM-dd"

$logFile = "$backupDir\Backup-$timestamp.log"

# Email settings
$sendEmail = $true
$emailTo = "james@example.com.au"
$emailFrom = $env:COMPUTERNAME + '@example.com.au'
$emailSubject = "VM Backup Completed"

# use your MX here but need an IPv4 address for email send to work
$smtpServer = (Resolve-DnsName -Name "example-com-au.mail.protection.outlook.com" -Type A)[0].IPAddress
