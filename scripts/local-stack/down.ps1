<#
Hadrian local stack - stop Apache + MySQL started by up.ps1 (or the Laragon tray).
  powershell -ExecutionPolicy Bypass -File scripts/local-stack/down.ps1
#>

# Native tools here (mysqladmin) write progress to stderr, which PS 5.1 turns into
# error records - and a caller running with -ErrorActionPreference Stop would abort
# on them. Stopping the stack is best-effort by nature, so keep it non-terminating.
$ErrorActionPreference = 'Continue'

$laragon = 'C:\laragon'
$mysql   = (Get-ChildItem "$laragon\bin\mysql" -Directory -Filter 'mysql-*' | Sort-Object Name -Descending | Select-Object -First 1).FullName

# Apache is started as a plain process, not a Windows service, so `httpd -k shutdown`
# does not apply ("No installed service named Apache2.4") - stop the processes directly.
$httpd = @(Get-Process httpd -ErrorAction SilentlyContinue)
if ($httpd.Count) {
    Write-Host "[apache] stopping $($httpd.Count) process(es)"
    $httpd | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
} else { Write-Host "[apache] not running" }

# MySQL gets a graceful shutdown: a forced kill leaves InnoDB to recover on next start.
if (Get-Process mysqld -ErrorAction SilentlyContinue) {
    Write-Host "[mysql]  shutting down"
    & "$mysql\bin\mysqladmin.exe" -uroot shutdown 2>&1 | Out-Null
    $tries = 0
    while ((Get-Process mysqld -ErrorAction SilentlyContinue) -and $tries -lt 20) { Start-Sleep -Milliseconds 500; $tries++ }
    $left = @(Get-Process mysqld -ErrorAction SilentlyContinue)
    if ($left.Count) { Write-Host "[mysql]  did not stop gracefully, forcing"; $left | Stop-Process -Force -ErrorAction SilentlyContinue }
} else { Write-Host "[mysql]  not running" }

Write-Host "[done]   apache=$(@(Get-Process httpd -ErrorAction SilentlyContinue).Count) mysql=$(@(Get-Process mysqld -ErrorAction SilentlyContinue).Count)"
