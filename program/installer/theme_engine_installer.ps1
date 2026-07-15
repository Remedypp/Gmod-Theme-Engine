Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Net.Http

$ErrorActionPreference = 'Stop'
$WorkshopId = '3765005303'
$ProgramRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$VersionFile = Join-Path $ProgramRoot 'VERSION'
$ProgramVersion = if (Test-Path $VersionFile) { (Get-Content -LiteralPath $VersionFile -Raw).Trim() } else { '1.0.0' }
$GitHubRepository = 'Remedypp/Gmod-Theme-Engine'
$LatestReleaseApi = "https://api.github.com/repos/$GitHubRepository/releases/latest"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Payload = Join-Path $ScriptRoot 'payload\theme_engine_master.lua'
$PayloadLogo = Join-Path $ScriptRoot 'payload\materials\theme_engine\loader\logo.png'
$ExampleThemePayload = Join-Path $ProgramRoot 'example theme\theme_engine_example_light'

. (Join-Path $ScriptRoot 'theme_engine_installer_core.ps1')
. (Join-Path $ScriptRoot 'theme_engine_installer_ui.ps1')
