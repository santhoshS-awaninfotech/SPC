#boot script HELLO I"M COPIED

#1. Create users
if (-not (Get-LocalUser -Name "userA" -ErrorAction SilentlyContinue)) {
net user userA $env:USERA_PASSWORD /add; net localgroup Administrators userA /add; 
}
if (-not (Get-LocalUser -Name "userB" -ErrorAction SilentlyContinue)) {
net user userB $env:USERB_PASSWORD /add; net localgroup Administrators userB /add;
}

# Wait until winget is available
Write-Host "Waiting for winget to be installed and ready..."

$maxAttempts = 60   # 10 minutes
$attempt = 0
while (-not (Get-Command winget -ErrorAction SilentlyContinue) -and $attempt -lt $maxAttempts) {
    Start-Sleep -Seconds 10
    $attempt++
    Write-Host "winget not found yet, retrying... ($attempt)"
}
Write-Host "winget is now available!"

#2. Install Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
winget install --id Python.Python.3.14 --source winget --accept-source-agreements --accept-package-agreements -e;
}

#3.1 Install PostgreSQL
if (-not (Get-Service -Name "postgresql-x64-16" -ErrorAction SilentlyContinue)) {
winget install --id PostgreSQL.PostgreSQL.16 --source winget --accept-source-agreements --accept-package-agreements -e;

#3.2 Set PostgreSQL Superuser password non-interactively
$pgBinPath  = "C:\Program Files\PostgreSQL\16\bin";
$pgDataPath = "C:\Program Files\PostgreSQL\16\data";
     
$pgHbaPath = Join-Path $pgDataPath "pg_hba.conf";
(Get-Content $pgHbaPath) -replace "scram-sha-256","trust" | Set-Content $pgHbaPath;
Restart-Service postgresql-x64-16;

& "$pgBinPath\psql.exe" -U postgres -h 127.0.0.1 -c "ALTER USER postgres WITH PASSWORD '$env:PGSQLPASSWORD';"

(Get-Content $pgHbaPath) -replace "trust","scram-sha-256" | Set-Content $pgHbaPath;
Restart-Service postgresql-x64-16;
}
