param([switch]$NoDataMirror)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$source = Join-Path $scriptRoot "source"
$folder = "theme_engine_example_light"
$probe = [IO.DirectoryInfo]$scriptRoot
$gameRoot = $null
while ($probe) {
    if (Test-Path (Join-Path $probe.FullName "lua\includes\init.lua")) {
        $gameRoot = $probe.FullName
        break
    }
    $probe = $probe.Parent
}
$addonOut = Join-Path $scriptRoot ("data_static\theme_engine_full_themes\" + $folder)
$outputs = @($addonOut)
if (-not $NoDataMirror -and $gameRoot) {
    $dataOut = Join-Path $gameRoot ("data\theme_engine_full_themes\" + $folder + "\data_static\theme_engine_full_themes\" + $folder)
    $outputs += $dataOut
}
$utf8 = New-Object System.Text.UTF8Encoding($false)
New-Item -ItemType Directory -Force -Path $outputs | Out-Null
function Read-Utf8([string]$path) { [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8) }
function Write-Utf8([string]$path, [string]$text) { [System.IO.File]::WriteAllText($path, $text, $script:utf8) }
function Write-Payload([string]$file, [string]$text) {
    foreach ($out in $script:outputs) {
        Write-Utf8 (Join-Path $out ($file + ".dte.txt")) $text
    }
}
function Protect-Dte([string]$text, [string]$key) {
    if ([string]::IsNullOrEmpty($key)) { $key = "theme_engine" }
    $plain = $script:utf8.GetBytes($text)
    $keyBytes = $script:utf8.GetBytes($key)
    $outBytes = New-Object byte[] ($plain.Length)
    for ($i = 0; $i -lt $plain.Length; $i++) {
        $kb = $keyBytes[$i % $keyBytes.Length]
        $outBytes[$i] = [byte](($plain[$i] + $kb + ($i + 1)) % 256)
    }
    "DTE1:" + [Convert]::ToBase64String($outBytes)
}
$directFiles = @(
    "main_menu.css",
    "addons_page.css",
    "start_new_game.css",
    "servers.css",
    "saves_dupes_demos.css",
    "bottom_navbar.css",
    "loading_screen.css",
    "menu_templates.html",
    "theme_manifest.json",
    "full_shell.html"
)
foreach ($file in $directFiles) {
    $src = Join-Path $source $file
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing source file: $src" }
    $plain = Read-Utf8 $src
    Write-Payload $file (Protect-Dte $plain ($folder + ":" + $file))
}
$templateMap = [ordered]@{
    "template/main.html" = "main.html"
    "template/newgame.html" = "newgame.html"
    "template/addon_list.html" = "addon_list.html"
    "template/servers.html" = "servers.html"
    "template/saves.html" = "saves.html"
    "template/dupes.html" = "dupes.html"
    "template/demos.html" = "demos.html"
}
$templates = [ordered]@{}
foreach ($key in $templateMap.Keys) {
    $src = Join-Path (Join-Path $source "templates") $templateMap[$key]
    if (-not (Test-Path -LiteralPath $src)) { throw "Missing template: $src" }
    $templates[$key] = Read-Utf8 $src
}
$templatesJson = $templates | ConvertTo-Json -Depth 8 -Compress
Write-Utf8 (Join-Path $source "full_templates.generated.json") $templatesJson
Write-Payload "full_templates.json" (Protect-Dte $templatesJson ($folder + ":full_templates.json"))
Write-Host "Built Theme Engine template payloads in:"
foreach ($out in $outputs) { Write-Host "  $out" }
if (-not $gameRoot) { Write-Host "No Garry's Mod root was found; only the Workshop-ready addon payload was built." }
