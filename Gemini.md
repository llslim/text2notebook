# Project Context: Text2Notebook

## Overview
This project is a Windows PowerShell application that converts text files from UTF-8 to ANSI encoding. It specifically targets the normalization of typography (smart quotes) to standard ASCII characters for compatibility with legacy notebook software.

## Core Logic
The core conversion logic is found in the `Convert-TextToNotebook` function:
1.  **Input:** Reads file as UTF-8.
2.  **Regex Replacement:**
    *   Replaces `[‘’\u2032]` with `'` (Straight apostrophe).
    *   Replaces `[“”\u2033]` with `"` (Straight double quote).
3.  **Output:** Saves file using `Encoding Default` (ANSI).

## Key Files

### Application
*   **`Text2notebook_WPF.ps1`**: The primary entry point. It contains the XAML definition for the UI, the conversion logic, and settings management.
*   **`settings.json`**: Stores `InputDirectory` and `OutputDirectory`. Located in `$env:USERPROFILE\.text2notebook\`.

### Deployment
*   **`Install.ps1`**: Copies the script to `$env:LOCALAPPDATA\Text2Notebook` and creates shortcuts (Desktop & Start Menu).
*   **`Uninstall.ps1`**: Removes the artifacts created by the install script.
*   **`Product.wxs`**: WiX Toolset v3.11 XML definition. Defines a per-user MSI installer that deploys the PowerShell script and sets registry keys for tracking.
*   **`Build_MSI.ps1`**: Automates `candle.exe` and `light.exe` execution to build the MSI.

### Legacy/Dev
*   **`Text2notebook2.ps1`**: A Windows Forms (WinForms) implementation of the GUI.
*   **`text2notebook.ps1`**: A CLI-only worker script.
*   **`text2notebook_gui.ps1`**: A wrapper that calls the CLI worker script.

## Development Notes
*   **Execution Policy:** Scripts run with `-ExecutionPolicy Bypass` in shortcuts to ensure they launch on restricted systems.
*   **Window Style:** Shortcuts use `-WindowStyle Hidden` to suppress the PowerShell console window during GUI execution.
*   **WiX:** The MSI build process requires the WiX Toolset binaries to be present in `%ProgramFiles(x86)%\WiX Toolset v3.11\bin`.

## Copyright
LL Slim LLC