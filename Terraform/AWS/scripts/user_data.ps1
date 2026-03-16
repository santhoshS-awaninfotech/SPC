
#0 
net user Administrator "${ADMIN_PASSWORD}"

#1. Create users
if (-not (Get-LocalUser -Name "userA" -ErrorAction SilentlyContinue)) {
net user userA "${USERA_PASSWORD}" /add; net localgroup Administrators userA /add; 
}
if (-not (Get-LocalUser -Name "userB" -ErrorAction SilentlyContinue)) {
net user userB "${USERB_PASSWORD}" /add; net localgroup Administrators userB /add;
}

#2. Install Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {

$pythonUrl = "https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe"
$pythonInstaller = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
write-output "Python completed"
}

#3 Install PostgreSQL
if (-not (Get-Service -Name "postgresql-x64-16" -ErrorAction SilentlyContinue)) {
$pgUrl = "https://get.enterprisedb.com/postgresql/postgresql-18.3-2-windows-x64.exe"
$pgInstaller = "$env:TEMP\postgresql-installer.exe"
Invoke-WebRequest -Uri $pgUrl -OutFile $pgInstaller

Start-Process -FilePath $pgInstaller -ArgumentList "--mode unattended --unattendedmodeui none --install_runtimes 0 --prefix ""C:\Program Files\PostgreSQL\16"" --datadir ""C:\Program Files\PostgreSQL\16\data"" --superpassword ""${PGSQLPASSWORD}""" -Wait
write-output "PostgreSQL completed"
} 

#3 Install VS Code
$vsUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
$vsInstaller = "$env:TEMP\vscode-installer.exe"
Invoke-WebRequest -Uri $vsUrl -OutFile $vsInstaller

Start-Process -FilePath $vsInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait
write-output "VScode completed"

#4 Install S3 Browser
$s3Url = "https://s3browser.com/s3browser-11-6-7.exe"
$s3Installer = "$env:TEMP\s3browser-installer.exe"
Invoke-WebRequest -Uri $s3Url -OutFile $s3Installer

Start-Process -FilePath $s3Installer -ArgumentList "/VERYSILENT /NORESTART" -Wait
write-output "S3 Browser completed"