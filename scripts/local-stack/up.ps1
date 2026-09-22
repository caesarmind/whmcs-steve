<#
Hadrian local stack - start MySQL + Apache from the Laragon binaries.

  powershell -ExecutionPolicy Bypass -File scripts/local-stack/up.ps1
  powershell -ExecutionPolicy Bypass -File scripts/local-stack/up.ps1 -Foreground   # used by .claude/launch.json

Idempotent: anything already running (from a previous run or the Laragon tray) is left alone.
With -Foreground the script blocks for as long as Apache is up, so a preview tool can
treat it as "the server process"; Ctrl+C / stopping the preview stops Apache (MySQL stays).

WHMCS:  http://localhost:8088/          (admin: /admin/)
DB:     whmcs / whmcs @ localhost:3306  (root has no password - local only)
#>
param([switch]$Foreground)

$ErrorActionPreference = 'Stop'
$laragon = 'C:\laragon'
$apache  = (Get-ChildItem "$laragon\bin\apache" -Directory -Filter 'httpd-*' | Sort-Object Name -Descending | Select-Object -First 1).FullName
$mysql   = (Get-ChildItem "$laragon\bin\mysql"  -Directory -Filter 'mysql-*' | Sort-Object Name -Descending | Select-Object -First 1).FullName
if (-not $apache -or -not $mysql) { throw "Laragon apache/mysql binaries not found under $laragon\bin" }

function Test-Port([int]$port) {
    $c = New-Object Net.Sockets.TcpClient
    try { $c.Connect('127.0.0.1', $port); return $true } catch { return $false } finally { $c.Dispose() }
}

# --- MySQL ---------------------------------------------------------------
if (Test-Port 3306) {
    Write-Host "[mysql]  already listening on 3306"
} else {
    Write-Host "[mysql]  starting $mysql\bin\mysqld.exe"
    Start-Process -FilePath "$mysql\bin\mysqld.exe" -ArgumentList "--defaults-file=`"$mysql\my.ini`"" -WindowStyle Hidden
    $tries = 0
    while (-not (Test-Port 3306) -and $tries -lt 30) { Start-Sleep -Milliseconds 500; $tries++ }
    if (-not (Test-Port 3306)) { throw "mysqld did not come up on 3306 - see $laragon\data\mysql-8.4\*.err" }
    Write-Host "[mysql]  up"
}

# --- Apache --------------------------------------------------------------
# httpd -t prints even "Syntax OK" on stderr. Capture it here and re-emit on stdout, so a
# caller that redirects our stderr does not see a bare "Syntax OK" as an error record
# (PS 5.1 wraps redirected native stderr in NativeCommandError).
$eap = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
$check = & "$apache\bin\httpd.exe" -t 2>&1 | ForEach-Object { $_.ToString() }
$checkExit = $LASTEXITCODE
$ErrorActionPreference = $eap
$check | ForEach-Object { Write-Host "[apache] $_" }
if ($checkExit -ne 0) { throw "httpd -t failed; fix the config before starting" }

if (Test-Port 8088) {
    Write-Host "[apache] already listening on 8088"
    if ($Foreground) {
        Write-Host "[apache] -Foreground: waiting on the existing httpd process(es)"
        $procs = Get-Process httpd -ErrorAction SilentlyContinue
        if ($procs) { Wait-Process -InputObject $procs } else { while (Test-Port 8088) { Start-Sleep -Seconds 2 } }
    }
} elseif ($Foreground) {
    Write-Host "[apache] starting in the foreground; http://localhost:8088/"
    & "$apache\bin\httpd.exe"
} else {
    Write-Host "[apache] starting $apache\bin\httpd.exe"
    Start-Process -FilePath "$apache\bin\httpd.exe" -WindowStyle Hidden
    $tries = 0
    while (-not (Test-Port 8088) -and $tries -lt 20) { Start-Sleep -Milliseconds 500; $tries++ }
    if (-not (Test-Port 8088)) { throw "httpd did not come up on 8088 - see C:\laragon\www\whmcs-local-error.log" }
    Write-Host "[apache] up"
}

Write-Host ""
Write-Host "WHMCS client area : http://localhost:8088/"
Write-Host "WHMCS admin       : http://localhost:8088/admin/"
Write-Host "Installer (first run only): http://localhost:8088/install/install.php"
