#boot script HELLO I"M COPIED

#1. Create users
if (-not (Get-LocalUser -Name "userA" -ErrorAction SilentlyContinue)) {
net user userA $env:USERA_PASSWORD /add; net localgroup Administrators userA /add; 
}
if (-not (Get-LocalUser -Name "userB" -ErrorAction SilentlyContinue)) {
net user userB $env:USERB_PASSWORD /add; net localgroup Administrators userB /add;
}

#2. Install Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {

$pythonUrl = "https://www.python.org/ftp/python/3.13.12/python-3.13.12-amd64.exe"
$pythonInstaller = "$env:TEMP\python-installer.exe"
Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller

Start-Process -FilePath $pythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait
}

#3 Install PostgreSQL
if (-not (Get-Service -Name "postgresql-x64-16" -ErrorAction SilentlyContinue)) {
$pgUrl = "https://get.enterprisedb.com/postgresql/postgresql-18.3-2-windows-x64.exe"
$pgInstaller = "$env:TEMP\postgresql-installer.exe"
Invoke-WebRequest -Uri $pgUrl -OutFile $pgInstaller

Start-Process -FilePath $pgInstaller -ArgumentList "--mode unattended --unattendedmodeui none --install_runtimes 0 --prefix ""C:\Program Files\PostgreSQL\16"" --datadir ""C:\Program Files\PostgreSQL\16\data"" --superpassword $env:PGSQLPASSWORD" -Wait
} else { Write-Output "winget.exe not found"}
