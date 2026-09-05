# Diyetsel Windows Setup Builder
# Requires: Flutter SDK + Inno Setup 6 (ISCC.exe)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
if (-not $Root) { $Root = (Resolve-Path "$PSScriptRoot\..").Path }

$IsccCandidates = @(
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
  "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
)
$Iscc = $IsccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $Iscc) {
  Write-Error "Inno Setup 6 bulunamadi. https://jrsoftware.org/isinfo.php adresinden kurun."
}

Write-Host "==> Flutter Windows release build..." -ForegroundColor Cyan
Set-Location $Root
flutter build windows --release
if ($LASTEXITCODE -ne 0) { throw "flutter build windows failed" }

$ReleaseDir = Join-Path $Root "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $ReleaseDir "diyetsel.exe"))) {
  throw "Release diyetsel.exe bulunamadi: $ReleaseDir"
}

$Dist = Join-Path $Root "dist"
New-Item -ItemType Directory -Force -Path $Dist | Out-Null

$Iss = Join-Path $PSScriptRoot "diyetsel.iss"
Write-Host "==> Inno Setup derleniyor..." -ForegroundColor Cyan
& $Iscc $Iss
if ($LASTEXITCODE -ne 0) { throw "ISCC failed" }

$Setup = Get-ChildItem $Dist -Filter "e-Diyet-Setup-*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $Setup) {
  $Setup = Get-ChildItem $Dist -Filter "Diyetsel-Setup-*.exe" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
}
if (-not $Setup) { throw "Setup exe bulunamadi: $Dist" }
Write-Host ""
Write-Host "Setup hazir:" -ForegroundColor Green
Write-Host "  $($Setup.FullName)"
Write-Host ("  Boyut: {0:N1} MB" -f ($Setup.Length / 1MB))
