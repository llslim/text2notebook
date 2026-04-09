# ConvertQuoteMarks Converter

**Copyright (c) LL Slim LLC**

ConvertQuoteMarks Converter is a Windows utility designed to prepare text files for legacy notebook applications. It converts UTF-8 text files to ANSI encoding and normalizes "smart" (slanted) quotes and apostrophes into standard straight quotes.

## Features

*   **Encoding Conversion:** Converts UTF-8 input to ANSI (Windows-1252) output.
*   **Character Normalization:** Replaces slanted single/double quotes and primes with standard ASCII apostrophes and quotes.
*   **GUI Interface:** Modern WPF-based user interface for easy file selection.
*   **Settings Persistence:** Remembers your last used input and output directories.

## Installation

### Option 1: MSI Installer (Recommended)
Download the latest `ConvertQuoteMarks.msi` file from the **[Releases page](https://github.com/llslim/ConvertQuoteMarks/releases)** on GitHub. Simply double-click the downloaded file to install. This will install the application to your user profile and create shortcuts on the Desktop and Start Menu.

### Option 2: PowerShell Installer
Run the included install script to set up the application without building an MSI.
1. Open PowerShell in the project directory.
2. Run: `.\Install.ps1`

### Option 3: Run Directly
You can run the application without installing it:
1. Right-click `ConvertQuoteMarks_WPF.ps1`.
2. Select **Run with PowerShell**.

### Option 4: Scoop
You can install both the GUI and CLI versions using [Scoop](https://scoop.sh/):
```powershell
scoop install https://raw.githubusercontent.com/llslim/ConvertQuoteMarks/main/ConvertQuoteMarks.json
```
Once installed, use `ConvertQuoteMarks` for the GUI or `ConvertQuoteMarks-cli` for the command-line interface.

## Building the MSI and Releasing

To build a standalone MSI installer, you need the **WiX Toolset v3.14**. To automatically publish a release, you need the **GitHub CLI (`gh`)**.

1. Install WiX Toolset v3.14.
2. Open PowerShell in the project directory.
3. Run the build script:
   ```powershell
   .\WinMSI\Build_MSI.ps1
   ```
4. The file `ConvertQuoteMarks.msi` will be generated in the `WinMSI` folder.

### Publishing a Release
When you are ready to publish a new version:
1. Ensure the GitHub CLI is authenticated (`gh auth login`).
2. Run the release script with your desired version tag:
   ```powershell
   .\release.ps1 -TagName "v1.0.0"
   ```
This script will automatically trigger the MSI build and immediately upload it as an asset to a new GitHub Release!

## Uninstallation

*   **If installed via MSI:** Go to Windows Settings > Apps > Installed Apps and uninstall "ConvertQuoteMarks Converter".
*   **If installed via Script:** Run `.\Uninstall.ps1` in the source directory.

## File Structure

*   `ConvertQuoteMarks_WPF.ps1`: The main application script (WPF GUI).
*   `ConvertQuoteMarks.ps1`: The CLI worker script.
*   `ConvertQuoteMarks.json`: Scoop package manifest.
*   `ConvertQuoteMarks2.ps1`: Legacy WinForms version of the GUI.
*   `Install.ps1`: Script to install the app to `%LOCALAPPDATA%`.
*   `Uninstall.ps1`: Script to remove the app and shortcuts.
*   `WinMSI\Product.wxs`: WiX XML configuration for building the MSI.
*   `WinMSI\Build_MSI.ps1`: Script to compile the WiX source into an MSI.

## Requirements

*   Windows 10 or 11
*   PowerShell 5.1 or later
*   .NET Framework (pre-installed on most Windows systems)ilding the MSI.
*   `WinMSI\Build_MSI.ps1`: Script to compile the WiX source into an MSI.

## Requirements

*   Windows 10 or 11
*   PowerShell 5.1 or later
*   .NET Framework (pre-installed on most Windows systems)