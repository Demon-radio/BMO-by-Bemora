# Requires: Godot 4.3 + Windows export templates installed.
# Usage (from project root): .\tools\export_windows.ps1
$ErrorActionPreference = "Stop"
$projectDir = Split-Path -Parent $PSScriptRoot
$preset = "Windows Desktop"
$outDir = Join-Path (Split-Path -Parent $projectDir) "BMO-by-Bemora-Release"
$outExe = Join-Path $outDir "BMO-by-Bemora.exe"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$godot = (Get-Command godot -ErrorAction SilentlyContinue).Source
if (-not $godot) {
  $cand = Get-ChildItem "C:\Program Files\Godot","C:\Program Files (x86)\Godot" -Filter *.exe -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($cand) { $godot = $cand.FullName }
}
if (-not $godot) {
  Write-Host "Godot not found. Install Godot 4.3 and add it to PATH, then re-run."
  Write-Host "After that, in Godot Editor: Project -> Manage Export Templates -> Download, then re-run this script."
  exit 1
}
Write-Host "Exporting '$preset' to $outExe ..."
& $godot --headless --path $projectDir --export-release $preset $outExe
Write-Host "Done. Share the whole folder: $outDir"
Get-ChildItem $outDir | Format-Table Name, Length -AutoSize
