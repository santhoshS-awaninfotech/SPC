<powershell>
$ErrorActionPreference = "SilentlyContinue"
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] script started" | Out-File C:\Userdata.log -Append
#0 Define the new password
$newPassword = ConvertTo-SecureString "${ADMIN_PASSWORD}" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $newPassword
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Administrator password reset successfully" | Out-File C:\Userdata.log -Append

#1. Create users
$password = ConvertTo-SecureString "${USERA_PASSWORD}" -AsPlainText -Force
New-LocalUser -Name "userA" -Password $password -FullName "User A" -Description "Admin user created via script"
# Add the user to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member "userA"
write-output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] userA completed" | Out-File C:\Userdata.log -Append

$password = ConvertTo-SecureString "${USERB_PASSWORD}" -AsPlainText -Force
New-LocalUser -Name "userB" -Password $password -FullName "User B" -Description "Admin user created via script"
# Add the user to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member "userB"
write-output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] userB completed" | Out-File C:\Userdata.log -Append

#2. Install Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
$pythonUrl = "https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe"
$pythonInstaller = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
write-output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Python installed" | Out-File C:\Userdata.log -Append
}

#3 Install VS Code
$vsUrl = "https://update.code.visualstudio.com/latest/win32-x64/stable"
$vsInstaller = "$env:TEMP\vscode-installer.exe"
Invoke-WebRequest -Uri $vsUrl -OutFile $vsInstaller

Start-Process -FilePath $vsInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] VS Code installation completed" | Out-File C:\Userdata.log -Append

Rename-Computer -NewName "${HOSTNAME}" -Force -Verbose
Write-Output "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Host Renamed" | Out-File C:\Userdata.log -Append
Restart-Computer -Force

</powershell>