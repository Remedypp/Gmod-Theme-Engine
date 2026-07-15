function Test-GModPath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path)) { return $false }
    return (Test-Path (Join-Path $Path 'lua\includes\init.lua')) -and
           (Test-Path (Join-Path $Path 'lua\includes\init_menu.lua'))
}

function Get-ThemeEngineLogoTarget([string]$GModPath) {
    return Join-Path $GModPath 'materials\theme_engine\loader\logo.png'
}

function Get-ThemeEngineLogoOriginalBackup([string]$GModPath) {
    return Join-Path $GModPath 'theme_engine_installer_backup\original\materials\theme_engine\loader\logo.png'
}

function Test-FilesEqual([string]$Left, [string]$Right) {
    if (-not (Test-Path $Left) -or -not (Test-Path $Right)) { return $false }
    try { return (Get-FileHash -LiteralPath $Left -Algorithm SHA256).Hash -eq (Get-FileHash -LiteralPath $Right -Algorithm SHA256).Hash } catch { return $false }
}

function Get-ExampleThemeTarget([string]$GModPath) {
    return Join-Path $GModPath 'addons\theme_engine_example_light'
}

function Test-ExampleThemeInstalled([string]$GModPath) {
    if (-not (Test-GModPath $GModPath)) { return $false }
    $target = Get-ExampleThemeTarget $GModPath
    return (Test-Path (Join-Path $target 'build_theme.ps1')) -and
           (Test-Path (Join-Path $target 'source\theme_manifest.json'))
}

function Install-ExampleTheme([string]$GModPath) {
    if (-not (Test-GModPath $GModPath)) { throw 'Select a valid garrysmod folder first.' }
    if (-not (Test-Path (Join-Path $ExampleThemePayload 'source\theme_manifest.json'))) {
        throw 'The installer payload is missing the editable example theme.'
    }

    $addonsRoot = [IO.Path]::GetFullPath((Join-Path $GModPath 'addons')).TrimEnd('\') + '\'
    $target = [IO.Path]::GetFullPath((Get-ExampleThemeTarget $GModPath))
    if (-not ($target + '\').StartsWith($addonsRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'The example theme target escaped the Garry''s Mod addons folder.'
    }

    $backup = $null
    if (Test-Path $target) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = Join-Path $GModPath "theme_engine_installer_backup\example-theme-$stamp"
        New-Item -ItemType Directory -Path (Split-Path -Parent $backup) -Force | Out-Null
        Copy-Item -LiteralPath $target -Destination $backup -Recurse -Force
        Remove-Item -LiteralPath $target -Recurse -Force
    }

    try {
        New-Item -ItemType Directory -Path $target -Force | Out-Null
        Copy-Item -Path (Join-Path $ExampleThemePayload '*') -Destination $target -Recurse -Force
        if (-not (Test-ExampleThemeInstalled $GModPath)) { throw 'The example theme copy could not be verified.' }
    } catch {
        if (Test-Path $target) { Remove-Item -LiteralPath $target -Recurse -Force }
        if ($backup -and (Test-Path $backup)) { Copy-Item -LiteralPath $backup -Destination $target -Recurse -Force }
        throw
    }

    return [pscustomobject]@{ Target = $target; Backup = $backup }
}

function Get-GModCandidates {
    $roots = New-Object System.Collections.Generic.List[string]
    $direct = New-Object System.Collections.Generic.List[string]
    $steamKeys = @(
        'HKCU:\Software\Valve\Steam',
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
        'HKLM:\SOFTWARE\Valve\Steam'
    )
    foreach ($key in $steamKeys) {
        try {
            $item = Get-ItemProperty -Path $key
            foreach ($property in @('SteamPath', 'InstallPath')) {
                $value = $item.$property
                if ($value) { $roots.Add([IO.Path]::GetFullPath($value)) }
            }
        } catch {}
    }

    $probe = [IO.DirectoryInfo]$ScriptRoot
    while ($probe) {
        if (Test-GModPath $probe.FullName) { $direct.Add($probe.FullName) }
        $probe = $probe.Parent
    }
    foreach ($steamRoot in @($roots)) {
        if (-not $steamRoot) { continue }
        $vdf = Join-Path $steamRoot 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdf) {
            $raw = Get-Content -LiteralPath $vdf -Raw
            foreach ($match in [regex]::Matches($raw, '"path"\s+"([^"]+)"')) {
                $roots.Add(($match.Groups[1].Value -replace '\\\\', '\'))
            }
        }
    }

    $seen = @{}
    foreach ($candidate in $direct) {
        if (-not $seen[$candidate]) {
            $seen[$candidate] = $true
            $candidate
        }
    }
    foreach ($root in $roots) {
        if (-not $root) { continue }
        $candidate = Join-Path $root 'steamapps\common\GarrysMod\garrysmod'
        try { $candidate = [IO.Path]::GetFullPath($candidate) } catch { continue }
        if (-not $seen[$candidate] -and (Test-GModPath $candidate)) {
            $seen[$candidate] = $true
            $candidate
        }
    }
}

function Install-ThemeEngine([string]$GModPath) {
    if (-not (Test-GModPath $GModPath)) {
        throw 'Select the garrysmod folder that contains lua\includes\init.lua.'
    }
    if (-not (Test-Path $Payload)) {
        throw 'The installer payload is missing theme_engine_master.lua.'
    }
    if (-not (Test-Path $PayloadLogo)) {
        throw 'The installer payload is missing materials\theme_engine\loader\logo.png.'
    }

    $includes = Join-Path $GModPath 'lua\includes'
    $initFiles = @(
        (Join-Path $includes 'init.lua'),
        (Join-Path $includes 'init_menu.lua')
    )
    $targetLoader = Join-Path $includes 'theme_engine_master.lua'
    $hadLoader = Test-Path $targetLoader
    $targetLogo = Get-ThemeEngineLogoTarget $GModPath
    $originalLogoBackup = Get-ThemeEngineLogoOriginalBackup $GModPath
    $backup = $null
    if ((Test-Path $targetLoader) -or (Test-Path $targetLogo)) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = Join-Path $GModPath "theme_engine_installer_backup\theme-engine-$stamp"
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
    }
    if (Test-Path $targetLoader) {
        Copy-Item -LiteralPath $targetLoader -Destination (Join-Path $backup 'theme_engine_master.lua') -Force
    }
    if (Test-Path $targetLogo) {
        $snapshotLogo = Join-Path $backup 'materials\theme_engine\loader\logo.png'
        New-Item -ItemType Directory -Path (Split-Path -Parent $snapshotLogo) -Force | Out-Null
        Copy-Item -LiteralPath $targetLogo -Destination $snapshotLogo -Force
        if (-not $hadLoader -and -not (Test-FilesEqual $targetLogo $PayloadLogo) -and -not (Test-Path $originalLogoBackup)) {
            New-Item -ItemType Directory -Path (Split-Path -Parent $originalLogoBackup) -Force | Out-Null
            Copy-Item -LiteralPath $targetLogo -Destination $originalLogoBackup -Force
        }
    }

    Copy-Item -LiteralPath $Payload -Destination $targetLoader -Force
    New-Item -ItemType Directory -Path (Split-Path -Parent $targetLogo) -Force | Out-Null
    Copy-Item -LiteralPath $PayloadLogo -Destination $targetLogo -Force
    $utf8 = New-Object Text.UTF8Encoding($false)
    $includeLine = 'include( "theme_engine_master.lua" )'
    $includePattern = '(?im)^[ \t]*include\s*\(\s*["'']theme_engine_master\.lua["'']\s*\)\s*(?:--[^\r\n]*)?\r?\n?'
    foreach ($file in $initFiles) {
        $content = [IO.File]::ReadAllText($file)
        $content = [regex]::Replace($content, $includePattern, '')
        $content = $content.TrimEnd() + "`r`n`r`n" + $includeLine + "`r`n"
        [IO.File]::WriteAllText($file, $content, $utf8)
    }
    return [pscustomobject]@{ Backup = $backup }
}

function Uninstall-ThemeEngine([string]$GModPath) {
    if (-not (Test-GModPath $GModPath)) { throw 'Select a valid garrysmod folder first.' }

    $includes = Join-Path $GModPath 'lua\includes'
    $initFiles = @((Join-Path $includes 'init.lua'), (Join-Path $includes 'init_menu.lua'))
    $loader = Join-Path $includes 'theme_engine_master.lua'
    $logo = Get-ThemeEngineLogoTarget $GModPath
    $originalLogoBackup = Get-ThemeEngineLogoOriginalBackup $GModPath
    $backup = $null
    if ((Test-Path $loader) -or (Test-Path $logo)) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backup = Join-Path $GModPath "theme_engine_installer_backup\removed-theme-engine-$stamp"
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
    }
    if (Test-Path $loader) {
        Copy-Item -LiteralPath $loader -Destination (Join-Path $backup 'theme_engine_master.lua') -Force
    }
    if (Test-Path $logo) {
        $snapshotLogo = Join-Path $backup 'materials\theme_engine\loader\logo.png'
        New-Item -ItemType Directory -Path (Split-Path -Parent $snapshotLogo) -Force | Out-Null
        Copy-Item -LiteralPath $logo -Destination $snapshotLogo -Force
    }

    $utf8 = New-Object Text.UTF8Encoding($false)
    $includePattern = '(?im)^[ \t]*include\s*\(\s*["'']theme_engine_master\.lua["'']\s*\)\s*(?:--[^\r\n]*)?\r?\n?'
    foreach ($file in $initFiles) {
        $content = [IO.File]::ReadAllText($file)
        $content = [regex]::Replace($content, $includePattern, '')
        [IO.File]::WriteAllText($file, $content.TrimEnd() + "`r`n", $utf8)
    }
    if (Test-Path $loader) { Remove-Item -LiteralPath $loader -Force }
    if (Test-Path $originalLogoBackup) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $logo) -Force | Out-Null
        Copy-Item -LiteralPath $originalLogoBackup -Destination $logo -Force
    } elseif (Test-Path $logo) {
        Remove-Item -LiteralPath $logo -Force
        $loaderMaterialDir = Split-Path -Parent $logo
        $themeMaterialDir = Split-Path -Parent $loaderMaterialDir
        if ((Test-Path $loaderMaterialDir) -and @(Get-ChildItem -LiteralPath $loaderMaterialDir -Force).Count -eq 0) { Remove-Item -LiteralPath $loaderMaterialDir -Force }
        if ((Test-Path $themeMaterialDir) -and @(Get-ChildItem -LiteralPath $themeMaterialDir -Force).Count -eq 0) { Remove-Item -LiteralPath $themeMaterialDir -Force }
    }
    return [pscustomobject]@{ Backup = $backup }
}


function ConvertFrom-GitHubUrl([string]$Url) {
    $match = [regex]::Match($Url.Trim(), '^https?://github\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+?)(?:\.git)?(?:/.*)?$')
    if (-not $match.Success) { throw 'Use a GitHub repository URL: https://github.com/owner/repository' }
    return [pscustomobject]@{ Owner = $match.Groups[1].Value; Repository = $match.Groups[2].Value }
}

function Invoke-GitHubJson([string]$Url) {
    return Invoke-RestMethod -Uri $Url -Headers @{ 'User-Agent' = 'GMod-Theme-Engine-Installer'; 'Accept' = 'application/vnd.github+json' } -UseBasicParsing
}

function Get-SourceThemeFiles([string]$Url) {
    $repo = ConvertFrom-GitHubUrl $Url
    $info = Invoke-GitHubJson "https://api.github.com/repos/$($repo.Owner)/$($repo.Repository)"
    $branch = [uri]::EscapeDataString([string]$info.default_branch)
    $tree = Invoke-GitHubJson "https://api.github.com/repos/$($repo.Owner)/$($repo.Repository)/git/trees/$branch`?recursive=1"
    if ($tree.truncated) { throw 'This repository is too large to inspect safely. Use a smaller theme repository.' }

    $files = @()
    foreach ($item in $tree.tree) {
        if ($item.type -ne 'blob') { continue }
        $path = ([string]$item.path) -replace '\\', '/'
        if ($path -match '(^|/)\.\.(?:/|$)' -or $path -notmatch '^(?i)resource/') { continue }
        $isRes = $path -match '(?i)\.res$'
        $isFont = $path -match '(?i)^resource/fonts/[^/]+\.(ttf|otf)$'
        if (-not $isRes -and -not $isFont) { continue }
        if ([long]$item.size -gt 4194304) { continue }
        $encodedPath = (($path -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
        $files += [pscustomobject]@{
            Install = $isRes
            Path = $path
            Type = $(if ($isRes) { 'Valve Resource' } else { 'Font' })
            Size = [long]$item.size
            RawUrl = "https://raw.githubusercontent.com/$($repo.Owner)/$($repo.Repository)/$branch/$encodedPath"
        }
    }
    return $files | Sort-Object Path
}

function Get-GitHubBytes([string]$Url) {
    $client = New-Object Net.WebClient
    $client.Headers['User-Agent'] = 'GMod-Theme-Engine-Installer'
    try { return $client.DownloadData($Url) } finally { $client.Dispose() }
}

function Restore-SourceThemeBackup([string]$GModPath, [string]$BackupPath) {
    $manifestPath = Join-Path $BackupPath 'manifest.json'
    if (-not (Test-Path $manifestPath)) { throw 'The selected backup has no manifest.json.' }
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    foreach ($item in $manifest.files) {
        $relative = ([string]$item.path) -replace '/', '\'
        if ($relative -match '\.\.' -or $relative -notmatch '^(?i)resource\\') { throw 'Backup contains an unsafe path.' }
        $target = [IO.Path]::GetFullPath((Join-Path $GModPath $relative))
        $root = [IO.Path]::GetFullPath($GModPath).TrimEnd('\') + '\'
        if (-not $target.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw 'Backup target escaped the Garry''s Mod folder.' }
        if ($item.originalExists) {
            $saved = Join-Path $BackupPath $relative
            if (-not (Test-Path $saved)) { throw "Backup file is missing: $relative" }
            New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
            Copy-Item -LiteralPath $saved -Destination $target -Force
        } elseif (Test-Path $target) {
            Remove-Item -LiteralPath $target -Force
        }
    }
}

function Install-SourceTheme([string]$GModPath, [array]$Entries) {
    if (-not (Test-GModPath $GModPath)) { throw 'Select a valid garrysmod folder first.' }
    if (-not $Entries -or $Entries.Count -eq 0) { throw 'Select at least one resource file to install.' }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = Join-Path $GModPath "theme_engine_source_backups\$stamp"
    New-Item -ItemType Directory -Path $backup -Force | Out-Null
    $manifestFiles = @()

    try {
        foreach ($entry in $Entries) {
            $relative = ([string]$entry.Path) -replace '/', '\'
            if ($relative -match '\.\.' -or $relative -notmatch '^(?i)resource\\') { throw "Unsafe repository path: $relative" }
            $target = [IO.Path]::GetFullPath((Join-Path $GModPath $relative))
            $root = [IO.Path]::GetFullPath($GModPath).TrimEnd('\') + '\'
            if (-not $target.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { throw "Path escaped Garry's Mod: $relative" }
            $originalExists = Test-Path $target
            if ($originalExists) {
                $saved = Join-Path $backup $relative
                New-Item -ItemType Directory -Path (Split-Path -Parent $saved) -Force | Out-Null
                Copy-Item -LiteralPath $target -Destination $saved -Force
            }
            $manifestFiles += [pscustomobject]@{ path = ([string]$entry.Path); originalExists = [bool]$originalExists }
        }

        $manifest = [pscustomobject]@{ createdAt = (Get-Date).ToString('o'); files = $manifestFiles }
        $manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $backup 'manifest.json') -Encoding UTF8

        foreach ($entry in $Entries) {
            $bytes = Get-GitHubBytes ([string]$entry.RawUrl)
            if (-not $bytes -or $bytes.Length -gt 4194304) { throw "Invalid or oversized file: $($entry.Path)" }
            $target = Join-Path $GModPath (([string]$entry.Path) -replace '/', '\')
            New-Item -ItemType Directory -Path (Split-Path -Parent $target) -Force | Out-Null
            [IO.File]::WriteAllBytes($target, $bytes)
        }
        return $backup
    } catch {
        if (Test-Path (Join-Path $backup 'manifest.json')) {
            try { Restore-SourceThemeBackup $GModPath $backup } catch {}
        }
        throw
    }
}
