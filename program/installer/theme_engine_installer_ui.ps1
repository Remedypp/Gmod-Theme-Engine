function Get-ThemeEngineState([string]$GModPath) {
    if (-not (Test-GModPath $GModPath)) {
        return [pscustomobject]@{ Code = 'Invalid'; Message = 'Select the garrysmod folder that contains lua\includes\init.lua.' }
    }

    $includes = Join-Path $GModPath 'lua\includes'
    $loader = Join-Path $includes 'theme_engine_master.lua'
    $logo = Get-ThemeEngineLogoTarget $GModPath
    $originalLogoBackup = Get-ThemeEngineLogoOriginalBackup $GModPath
    $includePattern = '(?im)^[ \t]*include\s*\(\s*["'']theme_engine_master\.lua["'']\s*\)'
    $found = 0
    foreach ($name in @('init.lua', 'init_menu.lua')) {
        $content = [IO.File]::ReadAllText((Join-Path $includes $name))
        if ([regex]::IsMatch($content, $includePattern)) { $found++ }
    }

    $hasLoader = Test-Path $loader
    $hasLogo = Test-Path $logo
    $logoCurrent = $hasLogo -and (Test-Path $PayloadLogo) -and (Test-FilesEqual $logo $PayloadLogo)
    $restoredOriginalLogo = $hasLogo -and (Test-Path $originalLogoBackup) -and (Test-FilesEqual $logo $originalLogoBackup)
    if ($hasLoader -and $found -eq 2 -and $logoCurrent) {
        return [pscustomobject]@{ Code = 'Installed'; Message = 'Theme Engine loader and startup branding are installed correctly.' }
    }
    if (-not $hasLoader -and $found -eq 0 -and (-not $hasLogo -or $restoredOriginalLogo)) {
        return [pscustomobject]@{ Code = 'NotInstalled'; Message = 'Theme Engine loader is not installed.' }
    }
    return [pscustomobject]@{ Code = 'NeedsRepair'; Message = 'A partial or damaged installation was detected.' }
}

function New-ThemeButton([string]$Text, [int]$X, [int]$Y, [int]$Width, [int]$Height, [string]$Kind = 'Secondary') {
    $button = New-Object Windows.Forms.Button
    $button.Text = $Text
    $button.Location = New-Object Drawing.Point($X, $Y)
    $button.Size = New-Object Drawing.Size($Width, $Height)
    $button.FlatStyle = 'Flat'
    $button.Cursor = 'Hand'
    $button.Font = New-Object Drawing.Font('Segoe UI Semibold', 9)
    switch ($Kind) {
        'Primary' {
            $button.BackColor = [Drawing.Color]::FromArgb(16, 101, 143)
            $button.ForeColor = [Drawing.Color]::White
            $button.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(75, 191, 236)
        }
        'Danger' {
            $button.BackColor = [Drawing.Color]::FromArgb(66, 27, 31)
            $button.ForeColor = [Drawing.Color]::FromArgb(249, 167, 167)
            $button.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(171, 67, 74)
        }
        'Warm' {
            $button.BackColor = [Drawing.Color]::FromArgb(55, 41, 20)
            $button.ForeColor = [Drawing.Color]::FromArgb(241, 192, 105)
            $button.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(201, 135, 40)
        }
        default {
            $button.BackColor = [Drawing.Color]::FromArgb(13, 31, 42)
            $button.ForeColor = [Drawing.Color]::FromArgb(182, 215, 228)
            $button.FlatAppearance.BorderColor = [Drawing.Color]::FromArgb(57, 91, 106)
        }
    }
    return $button
}

function Confirm-Action([string]$Message, [string]$Title, [string]$Icon = 'Question') {
    return [Windows.Forms.MessageBox]::Show($Message, $Title, 'YesNo', $Icon) -eq 'Yes'
}

$ui = [pscustomobject]@{
    Entries = @()
    CurrentPage = 'Home'
    ReleaseTask = $null
}

$form = New-Object Windows.Forms.Form
$form.Text = 'Aperture Theme Engine Setup'
$form.ClientSize = New-Object Drawing.Size(1180, 760)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox = $false
$form.BackColor = [Drawing.Color]::FromArgb(6, 14, 20)
$form.ForeColor = [Drawing.Color]::FromArgb(224, 236, 241)
$form.Font = New-Object Drawing.Font('Segoe UI', 9)

$accent = [Drawing.Color]::FromArgb(69, 189, 236)
$muted = [Drawing.Color]::FromArgb(127, 151, 163)
$header = New-Object Windows.Forms.Panel
$header.Dock = 'Top'
$header.Height = 88
$header.BackColor = [Drawing.Color]::FromArgb(12, 27, 36)
$form.Controls.Add($header)

$logoPath = Join-Path (Split-Path -Parent $ScriptRoot) 'branding\theme-engine-installer-logo.png'
if (Test-Path $logoPath) {
    $logo = New-Object Windows.Forms.PictureBox
    $logo.Location = New-Object Drawing.Point(22, 10)
    $logo.Size = New-Object Drawing.Size(68, 68)
    $logo.SizeMode = 'Zoom'
    $logo.Image = [Drawing.Image]::FromFile($logoPath)
    $header.Controls.Add($logo)
}

$title = New-Object Windows.Forms.Label
$title.Text = 'APERTURE LABORATORIES  /  THEME ENGINE'
$title.Location = New-Object Drawing.Point(104, 18)
$title.Size = New-Object Drawing.Size(760, 28)
$title.Font = New-Object Drawing.Font('Segoe UI Semibold', 14)
$title.ForeColor = [Drawing.Color]::FromArgb(136, 216, 247)
$header.Controls.Add($title)

$subtitle = New-Object Windows.Forms.Label
$subtitle.Text = 'Controlled installation and Source UI resource management for Garry''s Mod'
$subtitle.Location = New-Object Drawing.Point(106, 50)
$subtitle.Size = New-Object Drawing.Size(720, 22)
$subtitle.ForeColor = $muted
$header.Controls.Add($subtitle)

$versionLabel = New-Object Windows.Forms.Label
$versionLabel.Text = "SETUP v$ProgramVersion"
$versionLabel.Location = New-Object Drawing.Point(864, 17)
$versionLabel.Size = New-Object Drawing.Size(270, 20)
$versionLabel.TextAlign = 'MiddleRight'
$versionLabel.ForeColor = [Drawing.Color]::FromArgb(121, 151, 164)
$header.Controls.Add($versionLabel)

$releaseStatus = New-Object Windows.Forms.Label
$releaseStatus.Text = 'Checking GitHub Releases...'
$releaseStatus.Location = New-Object Drawing.Point(818, 48)
$releaseStatus.Size = New-Object Drawing.Size(210, 24)
$releaseStatus.TextAlign = 'MiddleRight'
$releaseStatus.ForeColor = [Drawing.Color]::FromArgb(99, 128, 141)
$header.Controls.Add($releaseStatus)

$releaseButton = New-ThemeButton 'VIEW RELEASE' 1038 45 116 28 'Warm'
$releaseButton.Visible = $false
$header.Controls.Add($releaseButton)

$sidebar = New-Object Windows.Forms.Panel
$sidebar.Dock = 'Left'
$sidebar.Width = 194
$sidebar.BackColor = [Drawing.Color]::FromArgb(8, 20, 28)
$form.Controls.Add($sidebar)
$sidebar.BringToFront()

$navHome = New-ThemeButton 'INSTALLATION' 14 22 166 42 'Primary'
$navNative = New-ThemeButton 'NATIVE UI THEMES' 14 72 166 42 'Secondary'
$sidebar.Controls.Add($navHome)
$sidebar.Controls.Add($navNative)

$navNote = New-Object Windows.Forms.Label
$navNote.Text = "No files are changed without`r`na confirmation dialog."
$navNote.Location = New-Object Drawing.Point(18, 582)
$navNote.Size = New-Object Drawing.Size(160, 50)
$navNote.Anchor = 'Left,Bottom'
$navNote.ForeColor = [Drawing.Color]::FromArgb(96, 127, 141)
$sidebar.Controls.Add($navNote)

$contentHost = New-Object Windows.Forms.Panel
$contentHost.Dock = 'Fill'
$contentHost.Padding = New-Object Windows.Forms.Padding(24)
$contentHost.BackColor = [Drawing.Color]::FromArgb(7, 16, 23)
$form.Controls.Add($contentHost)
$contentHost.BringToFront()

$homePage = New-Object Windows.Forms.Panel
$homePage.Dock = 'Fill'
$homePage.BackColor = $contentHost.BackColor
$contentHost.Controls.Add($homePage)

$homeHeading = New-Object Windows.Forms.Label
$homeHeading.Text = 'Theme Engine installation'
$homeHeading.Location = New-Object Drawing.Point(28, 24)
$homeHeading.Size = New-Object Drawing.Size(650, 34)
$homeHeading.Font = New-Object Drawing.Font('Segoe UI Semibold', 18)
$homePage.Controls.Add($homeHeading)

$homeIntro = New-Object Windows.Forms.Label
$homeIntro.Text = 'Install adds the loader, startup logo, and one include line to each GMod initialization file. It never replaces or restores the complete official files.'
$homeIntro.Location = New-Object Drawing.Point(30, 62)
$homeIntro.Size = New-Object Drawing.Size(850, 40)
$homeIntro.ForeColor = $muted
$homePage.Controls.Add($homeIntro)

$pathCard = New-Object Windows.Forms.Panel
$pathCard.Location = New-Object Drawing.Point(28, 116)
$pathCard.Size = New-Object Drawing.Size(900, 120)
$pathCard.BackColor = [Drawing.Color]::FromArgb(9, 23, 31)
$pathCard.BorderStyle = 'FixedSingle'
$homePage.Controls.Add($pathCard)

$pathLabel = New-Object Windows.Forms.Label
$pathLabel.Text = 'GARRY''S MOD FOLDER'
$pathLabel.Location = New-Object Drawing.Point(18, 15)
$pathLabel.Size = New-Object Drawing.Size(300, 20)
$pathLabel.ForeColor = $accent
$pathLabel.Font = New-Object Drawing.Font('Segoe UI Semibold', 9)
$pathCard.Controls.Add($pathLabel)

$pathBox = New-Object Windows.Forms.TextBox
$pathBox.Location = New-Object Drawing.Point(18, 45)
$pathBox.Size = New-Object Drawing.Size(738, 28)
$pathBox.BackColor = [Drawing.Color]::FromArgb(14, 31, 41)
$pathBox.ForeColor = [Drawing.Color]::FromArgb(234, 243, 247)
$pathBox.BorderStyle = 'FixedSingle'
$pathCard.Controls.Add($pathBox)

$browse = New-ThemeButton 'Browse...' 772 42 108 32 'Secondary'
$pathCard.Controls.Add($browse)

$pathHint = New-Object Windows.Forms.Label
$pathHint.Text = 'Expected: ...\SteamLibrary\steamapps\common\GarrysMod\garrysmod'
$pathHint.Location = New-Object Drawing.Point(18, 82)
$pathHint.Size = New-Object Drawing.Size(820, 22)
$pathHint.ForeColor = [Drawing.Color]::FromArgb(91, 121, 135)
$pathCard.Controls.Add($pathHint)

$stateCard = New-Object Windows.Forms.Panel
$stateCard.Location = New-Object Drawing.Point(28, 254)
$stateCard.Size = New-Object Drawing.Size(900, 164)
$stateCard.BackColor = [Drawing.Color]::FromArgb(9, 23, 31)
$stateCard.BorderStyle = 'FixedSingle'
$homePage.Controls.Add($stateCard)

$stateLabel = New-Object Windows.Forms.Label
$stateLabel.Text = 'INSTALLATION STATUS'
$stateLabel.Location = New-Object Drawing.Point(18, 16)
$stateLabel.Size = New-Object Drawing.Size(300, 20)
$stateLabel.ForeColor = $accent
$stateLabel.Font = New-Object Drawing.Font('Segoe UI Semibold', 9)
$stateCard.Controls.Add($stateLabel)

$stateTitle = New-Object Windows.Forms.Label
$stateTitle.Location = New-Object Drawing.Point(18, 47)
$stateTitle.Size = New-Object Drawing.Size(835, 30)
$stateTitle.Font = New-Object Drawing.Font('Segoe UI Semibold', 14)
$stateCard.Controls.Add($stateTitle)

$stateDescription = New-Object Windows.Forms.Label
$stateDescription.Location = New-Object Drawing.Point(18, 83)
$stateDescription.Size = New-Object Drawing.Size(835, 54)
$stateDescription.ForeColor = $muted
$stateCard.Controls.Add($stateDescription)

$installButton = New-ThemeButton 'Install Theme Engine' 28 448 208 44 'Primary'
$fixButton = New-ThemeButton 'Fix installation' 28 448 188 44 'Primary'
$uninstallButton = New-ThemeButton 'Uninstall' 228 448 150 44 'Danger'
$workshopButton = New-ThemeButton 'Open Workshop page' 28 514 190 38 'Secondary'
$exampleThemeButton = New-ThemeButton 'Install example theme' 230 514 210 38 'Warm'
$homePage.Controls.Add($installButton)
$homePage.Controls.Add($fixButton)
$homePage.Controls.Add($uninstallButton)
$homePage.Controls.Add($workshopButton)
$homePage.Controls.Add($exampleThemeButton)

$actionStatus = New-Object Windows.Forms.Label
$actionStatus.Location = New-Object Drawing.Point(28, 574)
$actionStatus.Size = New-Object Drawing.Size(900, 56)
$actionStatus.ForeColor = $muted
$homePage.Controls.Add($actionStatus)

$nativePage = New-Object Windows.Forms.Panel
$nativePage.Dock = 'Fill'
$nativePage.BackColor = $contentHost.BackColor
$nativePage.Visible = $false
$contentHost.Controls.Add($nativePage)

$nativeHeading = New-Object Windows.Forms.Label
$nativeHeading.Text = 'Native Source UI themes'
$nativeHeading.Location = New-Object Drawing.Point(22, 18)
$nativeHeading.Size = New-Object Drawing.Size(520, 34)
$nativeHeading.Font = New-Object Drawing.Font('Segoe UI Semibold', 18)
$nativePage.Controls.Add($nativeHeading)

$nativeIntro = New-Object Windows.Forms.Label
$nativeIntro.Text = 'Inspect supported resource files from a GitHub repository. Nothing is downloaded into Garry''s Mod until you select files and confirm installation.'
$nativeIntro.Location = New-Object Drawing.Point(24, 55)
$nativeIntro.Size = New-Object Drawing.Size(900, 34)
$nativeIntro.ForeColor = $muted
$nativePage.Controls.Add($nativeIntro)

$repoBox = New-Object Windows.Forms.TextBox
$repoBox.Location = New-Object Drawing.Point(24, 94)
$repoBox.Size = New-Object Drawing.Size(680, 28)
$repoBox.Text = 'https://github.com/owner/repository'
$repoBox.BackColor = [Drawing.Color]::FromArgb(14, 31, 41)
$repoBox.ForeColor = [Drawing.Color]::FromArgb(234, 243, 247)
$repoBox.BorderStyle = 'FixedSingle'
$nativePage.Controls.Add($repoBox)

$loadRepoButton = New-ThemeButton 'Inspect repository' 718 91 170 34 'Primary'
$nativePage.Controls.Add($loadRepoButton)

$files = New-Object Windows.Forms.DataGridView
$files.Location = New-Object Drawing.Point(24, 142)
$files.Size = New-Object Drawing.Size(416, 360)
$files.Anchor = 'Top,Left'
$files.BackgroundColor = [Drawing.Color]::FromArgb(5, 13, 18)
$files.BorderStyle = 'FixedSingle'
$files.AllowUserToAddRows = $false
$files.AllowUserToDeleteRows = $false
$files.AllowUserToResizeRows = $false
$files.RowHeadersVisible = $false
$files.SelectionMode = 'FullRowSelect'
$files.MultiSelect = $false
$files.AutoGenerateColumns = $false
$files.EnableHeadersVisualStyles = $false
$files.ColumnHeadersDefaultCellStyle.BackColor = [Drawing.Color]::FromArgb(15, 37, 49)
$files.ColumnHeadersDefaultCellStyle.ForeColor = [Drawing.Color]::FromArgb(204, 229, 239)
$files.DefaultCellStyle.BackColor = [Drawing.Color]::FromArgb(8, 21, 29)
$files.DefaultCellStyle.ForeColor = [Drawing.Color]::FromArgb(201, 220, 228)
$files.DefaultCellStyle.SelectionBackColor = [Drawing.Color]::FromArgb(18, 79, 105)
[void]$files.Columns.Add((New-Object Windows.Forms.DataGridViewCheckBoxColumn -Property @{ Name='Install'; HeaderText='Use'; Width=42 }))
[void]$files.Columns.Add((New-Object Windows.Forms.DataGridViewTextBoxColumn -Property @{ Name='Path'; HeaderText='Resource file'; Width=280; ReadOnly=$true }))
[void]$files.Columns.Add((New-Object Windows.Forms.DataGridViewTextBoxColumn -Property @{ Name='Size'; HeaderText='Bytes'; Width=88; ReadOnly=$true }))
$nativePage.Controls.Add($files)

$changeCaption = New-Object Windows.Forms.Label
$changeCaption.Text = 'WHAT NATIVE UI INSTALLATION CHANGES'
$changeCaption.Location = New-Object Drawing.Point(458, 142)
$changeCaption.Size = New-Object Drawing.Size(480, 22)
$changeCaption.ForeColor = [Drawing.Color]::FromArgb(225, 159, 62)
$changeCaption.Font = New-Object Drawing.Font('Segoe UI Semibold', 8)
$nativePage.Controls.Add($changeCaption)

$changeSummary = New-Object Windows.Forms.RichTextBox
$changeSummary.Location = New-Object Drawing.Point(458, 168)
$changeSummary.Size = New-Object Drawing.Size(480, 300)
$changeSummary.ReadOnly = $true
$changeSummary.BorderStyle = 'FixedSingle'
$changeSummary.BackColor = [Drawing.Color]::FromArgb(8, 20, 27)
$changeSummary.ForeColor = [Drawing.Color]::FromArgb(190, 213, 222)
$changeSummary.Font = New-Object Drawing.Font('Segoe UI', 9)
$changeSummary.Text = "RESOURCE FILES`r`nChange Source and VGUI colors, fonts, spacing, borders, and control styling supported by the selected .res file.`r`n`r`nFONT FILES`r`nAdd fonts required by the selected interface.`r`n`r`nINSTALLATION RULES`r`nNothing is changed while inspecting a repository. Only checked files are installed. Existing destination resources are backed up before replacement. Garry's Mod must be restarted after installation or restore."
$nativePage.Controls.Add($changeSummary)

$selectedChange = New-Object Windows.Forms.Label
$selectedChange.Location = New-Object Drawing.Point(458, 482)
$selectedChange.Size = New-Object Drawing.Size(480, 82)
$selectedChange.ForeColor = [Drawing.Color]::FromArgb(154, 184, 196)
$selectedChange.Text = 'Select a repository file to see its destination and purpose.'
$nativePage.Controls.Add($selectedChange)

$nativeStatus = New-Object Windows.Forms.Label
$nativeStatus.Location = New-Object Drawing.Point(24, 516)
$nativeStatus.Size = New-Object Drawing.Size(410, 50)
$nativeStatus.Anchor = 'Top,Left'
$nativeStatus.ForeColor = $muted
$nativeStatus.Text = 'Repository inspection stays in memory until you explicitly install selected files.'
$nativePage.Controls.Add($nativeStatus)

$restoreButton = New-ThemeButton 'Restore latest backup' 540 576 182 36 'Secondary'
$installNativeButton = New-ThemeButton 'Install selected files' 736 572 202 42 'Warm'
$restoreButton.Anchor = 'Top,Left'
$installNativeButton.Anchor = 'Top,Left'
$nativePage.Controls.Add($restoreButton)
$nativePage.Controls.Add($installNativeButton)

function Set-InstallerPage([string]$Page) {
    $ui.CurrentPage = $Page
    $homePage.Visible = $Page -eq 'Home'
    $nativePage.Visible = $Page -eq 'Native'
    if ($Page -eq 'Home') {
        $homePage.BringToFront()
        $navHome.BackColor = [Drawing.Color]::FromArgb(16, 101, 143)
        $navNative.BackColor = [Drawing.Color]::FromArgb(13, 31, 42)
    } else {
        $nativePage.BringToFront()
        $navHome.BackColor = [Drawing.Color]::FromArgb(13, 31, 42)
        $navNative.BackColor = [Drawing.Color]::FromArgb(16, 101, 143)
    }
}

function Update-InstallationDisplay {
    $state = Get-ThemeEngineState $pathBox.Text
    $installButton.Visible = $state.Code -eq 'NotInstalled'
    $fixButton.Visible = $state.Code -in @('Installed', 'NeedsRepair')
    $uninstallButton.Visible = $state.Code -in @('Installed', 'NeedsRepair')
    $exampleThemeButton.Enabled = Test-GModPath $pathBox.Text
    $exampleThemeButton.Text = if (Test-ExampleThemeInstalled $pathBox.Text) { 'Reinstall example theme' } else { 'Install example theme' }
    switch ($state.Code) {
        'Installed' {
            $stateTitle.Text = 'Installed and ready'
            $stateTitle.ForeColor = [Drawing.Color]::FromArgb(105, 222, 167)
            $stateDescription.Text = 'Both menu includes, theme_engine_master.lua, and the Aperture startup logo are present. Use Fix to replace outdated loader assets, or Uninstall to remove the integration.'
        }
        'NeedsRepair' {
            $stateTitle.Text = 'Installation needs repair'
            $stateTitle.ForeColor = [Drawing.Color]::FromArgb(241, 178, 83)
            $stateDescription.Text = 'A loader file, include line, or startup logo is missing or outdated. Fix will make a backup and rebuild the complete installation.'
        }
        'NotInstalled' {
            $stateTitle.Text = 'Not installed'
            $stateTitle.ForeColor = [Drawing.Color]::FromArgb(186, 207, 216)
            $stateDescription.Text = 'No Theme Engine loader integration was detected. Installation will ask for confirmation before changing init.lua, init_menu.lua, or the loader file.'
        }
        default {
            $stateTitle.Text = 'Garry''s Mod folder required'
            $stateTitle.ForeColor = [Drawing.Color]::FromArgb(240, 126, 126)
            $stateDescription.Text = $state.Message
        }
    }
    $actionStatus.Text = $state.Message
}

$navHome.Add_Click({ Set-InstallerPage 'Home' })
$navNative.Add_Click({
    if (-not (Test-GModPath $pathBox.Text)) {
        [Windows.Forms.MessageBox]::Show('Select a valid Garry''s Mod folder on the Installation page first.', 'Garry''s Mod not found', 'OK', 'Warning') | Out-Null
        return
    }
    Set-InstallerPage 'Native'
})

$browse.Add_Click({
    $dialog = New-Object Windows.Forms.FolderBrowserDialog
    $dialog.Description = 'Select the Garry''s Mod garrysmod folder'
    if ($pathBox.Text) { $dialog.SelectedPath = $pathBox.Text }
    if ($dialog.ShowDialog($form) -eq 'OK') { $pathBox.Text = $dialog.SelectedPath }
    $dialog.Dispose()
})

$pathBox.Add_TextChanged({ Update-InstallationDisplay })

$workshopButton.Add_Click({
    if (Confirm-Action 'Open the Theme Engine Workshop page in Steam now?' 'Open Workshop') {
        Start-Process "steam://url/CommunityFilePage/$WorkshopId"
    }
})

$exampleThemeButton.Add_Click({
    $target = Get-ExampleThemeTarget $pathBox.Text
    $alreadyInstalled = Test-ExampleThemeInstalled $pathBox.Text
    $verb = if ($alreadyInstalled) { 'Replace the existing editable example theme' } else { 'Install the editable GMod Light example theme' }
    $detail = if ($alreadyInstalled) { "`r`n`r`nThe current folder will be backed up before replacement." } else { '' }
    if (-not (Confirm-Action "$verb in:`r`n$target$detail" 'Install example theme' 'Warning')) { return }
    $exampleThemeButton.Enabled = $false
    try {
        $result = Install-ExampleTheme $pathBox.Text
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(105, 222, 167)
        $actionStatus.Text = "Editable example installed in $($result.Target)"
        Update-InstallationDisplay
        $backupNote = if ($result.Backup) { "`r`n`r`nPrevious copy backed up to:`r`n$($result.Backup)" } else { '' }
        [Windows.Forms.MessageBox]::Show("The GMod Light example theme is ready in:`r`n$($result.Target)$backupNote`r`n`r`nEdit source files, run build_theme.ps1, then use Reload Selected inside Theme Engine.", 'Example theme installed', 'OK', 'Information') | Out-Null
    } catch {
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(240, 126, 126)
        $actionStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Example theme installation failed', 'OK', 'Error') | Out-Null
    } finally { $exampleThemeButton.Enabled = Test-GModPath $pathBox.Text }
})

$installButton.Add_Click({
    if (-not (Confirm-Action "Install Theme Engine into:`r`n$($pathBox.Text)`r`n`r`nThis adds the loader, startup logo, and one include line to init.lua and init_menu.lua. The complete official files are never replaced or backed up." 'Confirm installation' 'Warning')) { return }
    $installButton.Enabled = $false
    try {
        $result = Install-ThemeEngine $pathBox.Text
        $backupNote = if ($result.Backup) { " Previous Theme Engine files: $($result.Backup)" } else { '' }
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(105, 222, 167)
        $actionStatus.Text = "Installation completed.$backupNote"
        Update-InstallationDisplay
        [Windows.Forms.MessageBox]::Show("Theme Engine was installed successfully.`r`n`r`nThe installer preserved all existing GMod initialization code and added only the Theme Engine include lines.", 'Installation complete', 'OK', 'Information') | Out-Null
        if (Confirm-Action 'Would you like to open the Workshop page now to subscribe to the addon?' 'Workshop subscription') {
            Start-Process "steam://url/CommunityFilePage/$WorkshopId"
        }
    } catch {
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(240, 126, 126)
        $actionStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Installation failed', 'OK', 'Error') | Out-Null
    } finally { $installButton.Enabled = $true }
})

$fixButton.Add_Click({
    if (-not (Confirm-Action "Repair the Theme Engine installation in:`r`n$($pathBox.Text)`r`n`r`nThis refreshes Theme Engine files and repairs its include lines without replacing the complete GMod initialization files." 'Confirm repair' 'Warning')) { return }
    $fixButton.Enabled = $false
    try {
        $result = Install-ThemeEngine $pathBox.Text
        $backupNote = if ($result.Backup) { " Previous Theme Engine files: $($result.Backup)" } else { '' }
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(105, 222, 167)
        $actionStatus.Text = "Repair completed.$backupNote"
        Update-InstallationDisplay
        [Windows.Forms.MessageBox]::Show('Theme Engine was repaired successfully. Existing GMod initialization code was preserved.', 'Repair complete', 'OK', 'Information') | Out-Null
    } catch {
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(240, 126, 126)
        $actionStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Repair failed', 'OK', 'Error') | Out-Null
    } finally { $fixButton.Enabled = $true }
})

$uninstallButton.Add_Click({
    if (-not (Confirm-Action "Uninstall Theme Engine from:`r`n$($pathBox.Text)`r`n`r`nThis removes the loader, startup logo, and only the two include lines added by the installer. Official GMod initialization files are not replaced." 'Confirm uninstall' 'Warning')) { return }
    $uninstallButton.Enabled = $false
    try {
        $result = Uninstall-ThemeEngine $pathBox.Text
        $backupNote = if ($result.Backup) { " Removed Theme Engine files: $($result.Backup)" } else { '' }
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(105, 222, 167)
        $actionStatus.Text = "Uninstalled.$backupNote"
        Update-InstallationDisplay
        [Windows.Forms.MessageBox]::Show('Theme Engine integration was removed. All unrelated GMod initialization code was preserved.', 'Uninstall complete', 'OK', 'Information') | Out-Null
    } catch {
        $actionStatus.ForeColor = [Drawing.Color]::FromArgb(240, 126, 126)
        $actionStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Uninstall failed', 'OK', 'Error') | Out-Null
    } finally { $uninstallButton.Enabled = $true }
})

$loadRepoButton.Add_Click({
    $loadRepoButton.Enabled = $false
    $nativeStatus.Text = 'Reading repository metadata. No files are being installed...'
    $form.Refresh()
    try {
        $ui.Entries = @(Get-SourceThemeFiles $repoBox.Text)
        $files.Rows.Clear()
        foreach ($entry in $ui.Entries) {
            $index = $files.Rows.Add($entry.Install, $entry.Path, $entry.Size)
            $files.Rows[$index].Tag = $entry
        }
        if ($ui.Entries.Count -eq 0) { throw 'No supported resource/*.res or resource/fonts files were found.' }
        $nativeStatus.Text = "$($ui.Entries.Count) supported files found. Select a row to review what it changes."
    } catch {
        $nativeStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Repository inspection failed', 'OK', 'Warning') | Out-Null
    } finally { $loadRepoButton.Enabled = $true }
})

$files.Add_SelectionChanged({
    if ($files.SelectedRows.Count -ne 1) { return }
    $entry = $files.SelectedRows[0].Tag
    if (-not $entry) { return }
    $kind = if ($entry.Path -match '(?i)\.res$') { 'Source/VGUI resource definition' } else { 'Interface font asset' }
    $selectedChange.Text = "FILE: $($entry.Path)`r`nTYPE: $kind`r`nSIZE: $($entry.Size) bytes`r`nDESTINATION: garrysmod/$($entry.Path)"
    $nativeStatus.Text = 'Review the checked files, then choose Install selected files. Nothing has been installed yet.'
})

$installNativeButton.Add_Click({
    $selected = @()
    foreach ($row in $files.Rows) {
        if ([bool]$row.Cells['Install'].Value -and $row.Tag) { $selected += $row.Tag }
    }
    if ($selected.Count -eq 0) {
        [Windows.Forms.MessageBox]::Show('Select at least one resource file.', 'Nothing selected', 'OK', 'Information') | Out-Null
        return
    }
    if (-not (Confirm-Action "Install $($selected.Count) selected native UI files into:`r`n$($pathBox.Text)`r`n`r`nOriginal files will be backed up first. Garry's Mod must be restarted afterward." 'Confirm native UI installation' 'Warning')) { return }
    $installNativeButton.Enabled = $false
    try {
        $backup = Install-SourceTheme $pathBox.Text $selected
        $nativeStatus.Text = "Native UI files installed. Backup: $backup"
        [Windows.Forms.MessageBox]::Show("Selected native UI files were installed.`r`nRestart Garry's Mod to apply them.`r`n`r`nBackup: $backup", 'Installation complete', 'OK', 'Information') | Out-Null
    } catch {
        $nativeStatus.Text = $_.Exception.Message
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Native UI installation failed', 'OK', 'Error') | Out-Null
    } finally { $installNativeButton.Enabled = $true }
})

$restoreButton.Add_Click({
    try {
        $root = Join-Path $pathBox.Text 'theme_engine_source_backups'
        $latest = Get-ChildItem -LiteralPath $root -Directory -ErrorAction Stop | Sort-Object Name -Descending | Select-Object -First 1
        if (-not $latest) { throw 'No native Source UI backup was found.' }
        if (-not (Confirm-Action "Restore the latest native UI backup?`r`n$($latest.FullName)" 'Confirm restore')) { return }
        Restore-SourceThemeBackup $pathBox.Text $latest.FullName
        $nativeStatus.Text = "Restored: $($latest.FullName)"
        [Windows.Forms.MessageBox]::Show('Original native UI files were restored. Restart Garry''s Mod to apply the change.', 'Restore complete', 'OK', 'Information') | Out-Null
    } catch {
        [Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Restore failed', 'OK', 'Error') | Out-Null
    }
})

$releaseClient = New-Object Net.Http.HttpClient
$releaseClient.DefaultRequestHeaders.UserAgent.ParseAdd('GMod-Theme-Engine-Setup')
$releaseClient.DefaultRequestHeaders.Accept.ParseAdd('application/vnd.github+json')
$releaseTimer = New-Object Windows.Forms.Timer
$releaseTimer.Interval = 200
$releaseTimer.Add_Tick({
    if (-not $ui.ReleaseTask -or -not $ui.ReleaseTask.IsCompleted) { return }
    $releaseTimer.Stop()
    try {
        if ($ui.ReleaseTask.IsFaulted) { throw $ui.ReleaseTask.Exception.GetBaseException() }
        $release = ($ui.ReleaseTask.Result | ConvertFrom-Json)
        $tag = ([string]$release.tag_name).Trim()
        $remoteText = $tag -replace '^[vV]', ''
        $current = [version]$ProgramVersion
        $remote = [version]$remoteText
        if ($remote -gt $current) {
            $releaseStatus.Text = "Update $tag available"
            $releaseStatus.ForeColor = [Drawing.Color]::FromArgb(230, 193, 96)
            $releaseButton.Tag = [string]$release.html_url
            $releaseButton.Visible = $true
        } else {
            $releaseStatus.Text = 'You have the latest release'
            $releaseStatus.ForeColor = [Drawing.Color]::FromArgb(99, 154, 133)
        }
    } catch {
        $failure = [string]$_.Exception.Message
        if ($failure -match '\b404\b|Not Found') {
            $releaseStatus.Text = 'No published releases'
        } else {
            $releaseStatus.Text = 'Release check unavailable'
        }
        $releaseStatus.ForeColor = [Drawing.Color]::FromArgb(99, 128, 141)
    }
})

$releaseButton.Add_Click({
    $url = [string]$releaseButton.Tag
    if (-not $url) { return }
    if (Confirm-Action 'Open the latest Theme Engine release in your browser?' 'View GitHub Release') {
        Start-Process $url
    }
})

$form.Add_Shown({
    try {
        $ui.ReleaseTask = $releaseClient.GetStringAsync($LatestReleaseApi)
        $releaseTimer.Start()
    } catch {
        $releaseStatus.Text = 'Release check unavailable'
    }
})

$detected = @(Get-GModCandidates | Select-Object -Unique)
if ($detected.Count -gt 0) { $pathBox.Text = $detected[0] }
Update-InstallationDisplay
Set-InstallerPage 'Home'

$form.Add_FormClosed({
    $releaseTimer.Stop()
    $releaseTimer.Dispose()
    $releaseClient.Dispose()
    if ($logo -and $logo.Image) { $logo.Image.Dispose() }
})

[void]$form.ShowDialog()
