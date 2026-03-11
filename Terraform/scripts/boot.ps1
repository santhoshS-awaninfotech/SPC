#boot script

#1. Create users
net user userA $env:USERA_PASSWORD /add
net user userB $env:USERB_PASSWORD /add
net localgroup Administrators userA /add
net localgroup Administrators userB /add

#2. Install Python
Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe -OutFile C:\python-installer.exe
Start-Process C:\python-installer.exe -ArgumentList '/quiet InstallAllUsers=1 PrependPath=1' -Wait

#3.1 Install PostgreSQL via winget
winget install --id PostgreSQL.PostgreSQL.16 `
    --source winget `
    --accept-source-agreements `
    --accept-package-agreements -e

#3.2 Set PostgreSQL Superuser password non-interactively
$pgBinPath  = "C:\Program Files\PostgreSQL\16\bin"
$pgDataPath = "C:\Program Files\PostgreSQL\16\data"
     
$pgHbaPath = Join-Path $pgDataPath "pg_hba.conf"
(Get-Content $pgHbaPath) -replace "scram-sha-256","trust" | Set-Content $pgHbaPath
Restart-Service postgresql-x64-16

& "$pgBinPath\psql.exe" -U postgres -h 127.0.0.1 -c "ALTER USER postgres WITH PASSWORD '$env:PGSQLPASSWORD';"

(Get-Content $pgHbaPath) -replace "trust","scram-sha-256" | Set-Content $pgHbaPath
Restart-Service postgresql-x64-16