# VMware Workstation Backup Script

## What it does
1. Shutdown a list of VM's using `vmrun.exe` (shutdown Standby then Active)
1. Perform a 7zip backups of both VM directorys
2. Create an `sha256sum` checksum of each `7z` archive
3. Run SCP to copy the 7z archive amd `sha256sum` to a NAS
5. Startup the VM's again using `vmrun` (this time reverse the startup order - e.g. Active first then Standby)
6. Send an email notification including the backup log file


## How to use it
Copy `config.example.ps1` to `config.ps1` and edit for your environment

Add your VM's to the `$vmList` 

```pwsh
$vmList = @(
    # put them in order of shutdown
    @{ Name = "VM1 Standby"; VMX = "E:\VMWare\U2604LTS-NEW-WEB-TEST\U2604LTS-NEW-WEB-TEST.vmx"; Folder = "E:\VMWare\U2604LTS-NEW-WEB-TEST" },
    @{ Name = "VM2 Active"; VMX = "E:\VMWare\U2604LTS-SERVER-CLEAN\U2604LTS-SERVER-CLEAN.vmx"; Folder = "E:\VMWare\U2604LTS-SERVER-CLEAN" }
)
```

## How to run it

```pwsh
.\backup_script.ps1
```

