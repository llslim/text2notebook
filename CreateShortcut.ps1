$ScriptPath = Join-Path $PSScriptRoot "Text2notebook_WPF.ps1"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ShortcutFile = Join-Path $DesktopPath "Text2Notebook.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutFile)

$Shortcut.TargetPath = "powershell.exe"
# -WindowStyle Hidden ensures the black console window doesn't stay open
$Shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Shortcut.Description = "Text2Notebook Converter"
$Shortcut.Save()

Write-Host "Shortcut created successfully: $ShortcutFile"