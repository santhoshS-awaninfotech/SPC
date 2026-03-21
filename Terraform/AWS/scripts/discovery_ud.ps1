<powershell>
$ErrorActionPreference = "SilentlyContinue"

#0 Define the new password
$newPassword = ConvertTo-SecureString "${ADMIN_PASSWORD}" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $newPassword
Write-Output "Administrator password reset successfully"

#1. Create users
$password = ConvertTo-SecureString "${USERA_PASSWORD}" -AsPlainText -Force
New-LocalUser -Name "userA" -Password $password -FullName "User A" -Description "Admin user created via script"
# Add the user to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member "userA"
write-output "userA completed"

$password = ConvertTo-SecureString "${USERB_PASSWORD}" -AsPlainText -Force
New-LocalUser -Name "userB" -Password $password -FullName "User B" -Description "Admin user created via script"
# Add the user to Administrators group
Add-LocalGroupMember -Group "Administrators" -Member "userB"
write-output "userB completed"

#2. Install Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
$pythonUrl = "https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe"
$pythonInstaller = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
write-output "Python completed"
}

#3 Install VS Code
$vsUrl = "https://update.code.visualstudio.com/latest/win32-x64/stable"
$vsInstaller = "$env:TEMP\vscode-installer.exe"
Invoke-WebRequest -Uri $vsUrl -OutFile $vsInstaller

Start-Process -FilePath $vsInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
Write-Output "VS Code installation completed"

Rename-Computer -NewName "${var.reg_code}SPC2RUNR${upper(substr(aws_instance.disc[count.index].availability_zone, -2, 2))}${count.index + 1}" -Force -Restart
</powershell>