@echo off
rem 9:26 AM 14/07/2026
rem james@toggen.com.au
rem put this file in shell:startup (C:\Users\<user>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup)

echo "Auto starting Fasttools VMs..."
start "" "C:\Program Files\VMware\VMware Workstation\vmrun.exe" start "C:\VMWare\VM1\VM1.vmx"

timeout 60

start "" "C:\Program Files\VMware\VMware Workstation\vmrun.exe" start "C:\VMWare\VM2\VM2.vmx"s