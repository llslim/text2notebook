# Copyright (c) LL Slim LLC

# Define paths
$SourceScript = Join-Path $PSScriptRoot "Text2notebook_WPF.ps1"
$InstallDir = Join-Path $env:LOCALAPPDATA "Text2Notebook"
$InstalledScript = Join-Path $InstallDir "Text2notebook_WPF.ps1"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutFile = Join-Path $DesktopPath "Text2Notebook.lnk"
$StartMenuPath = [Environment]::GetFolderPath("Programs")
$StartMenuShortcutFile = Join-Path $StartMenuPath "Text2Notebook.lnk"

# 1. Create Install Directory
if (-not (Test-Path $InstallDir)) {
    New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
}

# 2. Copy Script to Install Directory
Copy-Item -Path $SourceScript -Destination $InstalledScript -Force

# 3. Create Shortcut to the Installed Script
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutFile)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$InstalledScript`""
$Shortcut.Description = "Text2Notebook Converter - (c) LL Slim LLC"
$Shortcut.Save()

# 4. Create Start Menu Shortcut
$ShortcutSM = $WshShell.CreateShortcut($StartMenuShortcutFile)
$ShortcutSM.TargetPath = "powershell.exe"
$ShortcutSM.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$InstalledScript`""
$ShortcutSM.Description = "Text2Notebook Converter - (c) LL Slim LLC"
$ShortcutSM.Save()

Write-Host "Installation Complete!"
Write-Host "App installed to: $InstallDir"
Write-Host "Shortcuts created: Desktop and Start Menu"