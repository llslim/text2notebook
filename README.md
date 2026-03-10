# Text2Notebook Converter

**Copyright (c) LL Slim LLC**

Text2Notebook Converter is a Windows utility designed to prepare text files for legacy notebook applications. It converts UTF-8 text files to ANSI encoding and normalizes "smart" (slanted) quotes and apostrophes into standard straight quotes.

## Features

*   **Encoding Conversion:** Converts UTF-8 input to ANSI (Windows-1252) output.
*   **Character Normalization:** Replaces slanted single/double quotes and primes with standard ASCII apostrophes and quotes.
*   **GUI Interface:** Modern WPF-based user interface for easy file selection.
*   **Settings Persistence:** Remembers your last used input and output directories.

## Installation

### Option 1: MSI Installer (Recommended)
If you have the `.msi` file, simply double-click it to install. This will install the application to your user profile and create shortcuts on the Desktop and Start Menu.

### Option 2: PowerShell Installer
Run the included install script to set up the application without building an MSI.
1. Open PowerShell in the project directory.
2. Run: `.\Install.ps1`

### Option 3: Run Directly
You can run the application without installing it:
1. Right-click `Text2notebook_WPF.ps1`.
2. Select **Run with PowerShell**.

## Building the MSI

To build a standalone MSI installer, you need the **WiX Toolset v3.11**.

1. Install WiX Toolset v3.11.
2. Open PowerShell in the project directory.
3. Run the build script:
   ```powershell
   .\Build_MSI.ps1
   ```
4. The file `Text2Notebook.msi` will be generated in the same folder.

## Uninstallation

*   **If installed via MSI:** Go to Windows Settings > Apps > Installed Apps and uninstall "Text2Notebook Converter".
*   **If installed via Script:** Run `.\Uninstall.ps1` in the source directory.

## File Structure

*   `Text2notebook_WPF.ps1`: The main application script (WPF GUI).
*   `Text2notebook2.ps1`: Legacy WinForms version of the GUI.
*   `Install.ps1`: Script to install the app to `%LOCALAPPDATA%`.
*   `Uninstall.ps1`: Script to remove the app and shortcuts.
*   `Product.wxs`: WiX XML configuration for building the MSI.
*   `Build_MSI.ps1`: Script to compile the WiX source into an MSI.

## Requirements

*   Windows 10 or 11
*   PowerShell 5.1 or later
*   .NET Framework (pre-installed on most Windows systems)