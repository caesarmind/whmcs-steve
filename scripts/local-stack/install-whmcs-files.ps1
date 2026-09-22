<#
Hadrian local stack - drop a set of WHMCS files into C:\laragon\www\whmcs and
re-wire the repo junctions.

  powershell -ExecutionPolicy Bypass -File scripts/local-stack/install-whmcs-files.ps1 -Source "C:\path\to\whmcs"
  powershell -ExecutionPolicy Bypass -File scripts/local-stack/install-whmcs-files.ps1 -Source "C:\path\to\whmcs.zip"

-Source may be a folder or a .zip; a zip that contains a single top-level
folder is unwrapped automatically. The folder must be the WHMCS web root - the
directory holding init.php, clientarea.php and admin/.

What it does, in order:
  1. stops Apache/MySQL if running (files are in use otherwise)
  2. removes the three repo junctions so the copy can never write into the repo
  3. keeps the existing configuration.php unless -ResetConfig is passed
  4. copies the new files over C:\laragon\www\whmcs
  5. re-creates the junctions and restarts the stack

The junctions are the point of the whole setup: they make the install render
this checkout's templates/hadrian, modules/addons/Hadrian and hadrian_cart
directly, with no copy to keep in sync. Step 2 + step 5 exist so that a
`robocopy /MIR`-style overwrite can never delete repo files through a junction.
#>
param(
    [Parameter(Mandatory = $true)][string]$Source,
    [switch]$ResetConfig
)

$ErrorActionPreference = 'Stop'
$web  = 'C:\laragon\www\whmcs'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$junctions = @(
    @{ link = "$web\templates\hadrian";                 target = "$repo\hadrian\templates\hadrian" },
    @{ link = "$web\modules\addons\Hadrian";            target = "$repo\hadrian\modules\addons\Hadrian" },
    @{ link = "$web\templates\orderforms\hadrian_cart"; target = "$repo\hadrian_cart" }
)

# --- resolve the source to a folder ---------------------------------------
if (-not (Test-Path $Source)) { throw "Source not found: $Source" }
$src = (Resolve-Path $Source).Path
$tempExtract = $null

if ((Get-Item $src).PSIsContainer -eq $false) {
    if ([IO.Path]::GetExtension($src) -ne '.zip') { throw "Source must be a folder or a .zip file: $src" }
    $tempExtract = Join-Path ([IO.Path]::GetTempPath()) ("whmcs-src-" + [Guid]::NewGuid().ToString('N'))
    Write-Host "[src]    extracting $src"
    # Expand-Archive pipes every entry through the PowerShell object pipeline and
    # takes ~13 minutes on a WHMCS release (55k files); the .NET call does the
    # same work in under a minute.
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($src, $tempExtract)
    $src = $tempExtract
}

# unwrap a single top-level folder (zips usually ship one)
if (-not (Test-Path (Join-Path $src 'init.php'))) {
    $kids = @(Get-ChildItem $src -Directory)
    $files = @(Get-ChildItem $src -File)
    if ($kids.Count -eq 1 -and $files.Count -eq 0 -and (Test-Path (Join-Path $kids[0].FullName 'init.php'))) {
        $src = $kids[0].FullName
    }
}
foreach ($must in 'init.php', 'clientarea.php', 'admin') {
    if (-not (Test-Path (Join-Path $src $must))) {
        throw "$src does not look like a WHMCS web root (no $must). Point -Source at the folder that holds init.php."
    }
}
Write-Host "[src]    using $src"

# --- stop the stack --------------------------------------------------------
& (Join-Path $PSScriptRoot 'down.ps1')

# --- preserve configuration.php -------------------------------------------
$savedConfig = $null
$cfgPath = "$web\configuration.php"
if ((Test-Path $cfgPath) -and -not $ResetConfig) {
    $savedConfig = Get-Content $cfgPath -Raw
    Write-Host "[config] keeping the existing configuration.php (pass -ResetConfig to take the source's)"
}

# --- drop the junctions BEFORE copying ------------------------------------
foreach ($j in $junctions) {
    if (Test-Path $j.link) {
        Write-Host "[link]   removing junction $($j.link)"
        # rmdir on a junction removes the link only; the target is untouched.
        cmd /c rmdir "$($j.link)" | Out-Null
    }
}

# --- copy ------------------------------------------------------------------
Write-Host "[copy]   $src  ->  $web   (this takes a minute)"
$rc = Start-Process -FilePath robocopy.exe -ArgumentList @("`"$src`"", "`"$web`"", '/E', '/NFL', '/NDL', '/NJH', '/NJS', '/NP', '/R:1', '/W:1') -Wait -PassThru -NoNewWindow
# robocopy: 0-7 are success codes, 8+ are real failures.
if ($rc.ExitCode -ge 8) { throw "robocopy failed with exit code $($rc.ExitCode)" }
Write-Host "[copy]   done (robocopy $($rc.ExitCode))"

if ($savedConfig) { Set-Content -Path $cfgPath -Value $savedConfig -Encoding ascii -NoNewline }

# --- re-create the junctions ----------------------------------------------
foreach ($j in $junctions) {
    if (-not (Test-Path $j.target)) { Write-Warning "repo target missing, skipping: $($j.target)"; continue }
    if (Test-Path $j.link) { cmd /c rmdir "$($j.link)" | Out-Null }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $j.link) | Out-Null
    cmd /c mklink /J "$($j.link)" "$($j.target)" | Out-Null
    Write-Host "[link]   $($j.link)  ->  $($j.target)"
}

# --- back up -----------------------------------------------------------------
& (Join-Path $PSScriptRoot 'up.ps1')

if ($tempExtract -and (Test-Path $tempExtract)) { Remove-Item $tempExtract -Recurse -Force -ErrorAction SilentlyContinue }
