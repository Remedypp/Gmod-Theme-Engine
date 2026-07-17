$ErrorActionPreference = 'Stop'
$logPath = Join-Path ([IO.Path]::GetTempPath()) 'ApertureThemeEngineInstaller.log'

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Net.Http

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
} catch {
    $details = "Aperture Theme Engine Installer failed to start.`r`n`r`n$($_.Exception.Message)`r`n`r`nDiagnostic log:`r`n$logPath"
    try {
        "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]`r`n$($_ | Out-String)" | Set-Content -LiteralPath $logPath -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
        [Windows.Forms.MessageBox]::Show($details, 'Aperture Theme Engine Installer', 'OK', 'Error') | Out-Null
    } catch {
        try { (New-Object -ComObject WScript.Shell).Popup($details, 0, 'Aperture Theme Engine Installer', 16) | Out-Null } catch {}
    }
    exit 1
}
