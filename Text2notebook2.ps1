Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuration & Settings ---
$SettingsDir = Join-Path $env:USERPROFILE ".text2notebook"
if (-not (Test-Path $SettingsDir)) { New-Item -Path $SettingsDir -ItemType Directory -Force | Out-Null }
$SettingsFile = Join-Path $SettingsDir "settings.json"

function Get-Settings {
    if (Test-Path $SettingsFile) {
        try {
            return Get-Content $SettingsFile -Raw | ConvertFrom-Json
        } catch {
            return @{ InputDirectory = ""; OutputDirectory = "" }
        }
    }
    return @{ InputDirectory = ""; OutputDirectory = "" }
}

function Save-Settings {
    param ($InputDir, $OutputDir)
    $settings = @{
        InputDirectory = $InputDir
        OutputDirectory = $OutputDir
    }
    $settings | ConvertTo-Json | Set-Content $SettingsFile
}

function Convert-TextToNotebook {
    param (
        [Parameter(Mandatory=$true)]
        [string]$InputFilePath,
        [Parameter(Mandatory=$false)]
        [string]$OutputFilePath
    )

    $InputFile = Get-Item $InputFilePath

    if (-not $InputFile.Exists) {
        throw "Input file not found: $($InputFilePath)"
    }

    # Read content as UTF8
    $content = Get-Content -Path $InputFilePath -Encoding UTF8 -Raw

    # Replace slanted quotes and apostrophes
    # Left single quotation mark U+2018
    # Right single quotation mark U+2019
    # Left double quotation mark U+201C
    # Right double quotation mark U+201D
    # Prime U+2032 (often used as apostrophe or single quote)
    # Double Prime U+2033 (often used as double quote)

    $content = $content -replace "[‘’\u2032]", "'" # Slanted single quotes and prime to straight apostrophe
    $content = $content -replace "[“”\u2033]", "`"" # Slanted double quotes and double prime to straight double quote

    # Construct output file path
    if ([string]::IsNullOrWhiteSpace($OutputFilePath)) {
        $OutputFilePath = Join-Path -Path $InputFile.DirectoryName -ChildPath "$($InputFile.BaseName)_ansi.txt"
    }

    # Write content to output file with ANSI encoding
    $content | Set-Content -Path $OutputFilePath -Encoding Default
}

$currentSettings = Get-Settings

# --- Form Setup ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Text2Notebook Converter"
$form.Size = New-Object System.Drawing.Size(600, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Font = $font

# --- Controls ---

# Input File
$lblInput = New-Object System.Windows.Forms.Label
$lblInput.Text = "Input File:"
$lblInput.Location = New-Object System.Drawing.Point(20, 20)
$lblInput.AutoSize = $true
$form.Controls.Add($lblInput)

$txtInput = New-Object System.Windows.Forms.TextBox
$txtInput.Location = New-Object System.Drawing.Point(20, 45)
$txtInput.Size = New-Object System.Drawing.Size(450, 25)
$form.Controls.Add($txtInput)

$btnBrowseInput = New-Object System.Windows.Forms.Button
$btnBrowseInput.Text = "Browse..."
$btnBrowseInput.Location = New-Object System.Drawing.Point(480, 44)
$btnBrowseInput.Size = New-Object System.Drawing.Size(80, 27)
$form.Controls.Add($btnBrowseInput)

# Output Directory
$lblOutputDir = New-Object System.Windows.Forms.Label
$lblOutputDir.Text = "Output Directory:"
$lblOutputDir.Location = New-Object System.Drawing.Point(20, 85)
$lblOutputDir.AutoSize = $true
$form.Controls.Add($lblOutputDir)

$txtOutputDir = New-Object System.Windows.Forms.TextBox
$txtOutputDir.Location = New-Object System.Drawing.Point(20, 110)
$txtOutputDir.Size = New-Object System.Drawing.Size(450, 25)
$txtOutputDir.Text = $currentSettings.OutputDirectory
$form.Controls.Add($txtOutputDir)

$btnBrowseOutput = New-Object System.Windows.Forms.Button
$btnBrowseOutput.Text = "Browse..."
$btnBrowseOutput.Location = New-Object System.Drawing.Point(480, 109)
$btnBrowseOutput.Size = New-Object System.Drawing.Size(80, 27)
$form.Controls.Add($btnBrowseOutput)

# Output Filename
$lblOutputName = New-Object System.Windows.Forms.Label
$lblOutputName.Text = "Output Filename:"
$lblOutputName.Location = New-Object System.Drawing.Point(20, 150)
$lblOutputName.AutoSize = $true
$form.Controls.Add($lblOutputName)

$txtOutputName = New-Object System.Windows.Forms.TextBox
$txtOutputName.Location = New-Object System.Drawing.Point(20, 175)
$txtOutputName.Size = New-Object System.Drawing.Size(450, 25)
$form.Controls.Add($txtOutputName)

# Convert Button
$btnConvert = New-Object System.Windows.Forms.Button
$btnConvert.Text = "Convert"
$btnConvert.Location = New-Object System.Drawing.Point(20, 220)
$btnConvert.Size = New-Object System.Drawing.Size(540, 40)
$btnConvert.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($btnConvert)

# --- Event Handlers ---

$btnBrowseInput.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    
    # Use saved input directory if available
    if (-not [string]::IsNullOrWhiteSpace($currentSettings.InputDirectory) -and (Test-Path $currentSettings.InputDirectory)) {
        $ofd.InitialDirectory = $currentSettings.InputDirectory
    }

    if ($ofd.ShowDialog() -eq "OK") {
        $txtInput.Text = $ofd.FileName
        $fileItem = Get-Item $ofd.FileName
        
        # Auto-suggest Output Directory if empty
        if ([string]::IsNullOrWhiteSpace($txtOutputDir.Text)) {
            $txtOutputDir.Text = $fileItem.DirectoryName
        }
        
        # Auto-suggest Output Filename if empty
        if ([string]::IsNullOrWhiteSpace($txtOutputName.Text)) {
            $txtOutputName.Text = "$($fileItem.BaseName)_ansi.txt"
        }
    }
})

$btnBrowseOutput.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Select Output Directory"
    
    if (-not [string]::IsNullOrWhiteSpace($txtOutputDir.Text) -and (Test-Path $txtOutputDir.Text)) {
        $fbd.SelectedPath = $txtOutputDir.Text
    }

    if ($fbd.ShowDialog() -eq "OK") {
        $txtOutputDir.Text = $fbd.SelectedPath
    }
})

$btnConvert.Add_Click({
    $inputFile = $txtInput.Text
    $outputDir = $txtOutputDir.Text
    $outputName = $txtOutputName.Text

    # Validation
    if ([string]::IsNullOrWhiteSpace($inputFile) -or -not (Test-Path $inputFile -PathType Leaf)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid input file.", "Error", "OK", "Error")
        return
    }

    if ([string]::IsNullOrWhiteSpace($outputDir)) {
        [System.Windows.Forms.MessageBox]::Show("Please select an output directory.", "Error", "OK", "Error")
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($outputName)) {
        [System.Windows.Forms.MessageBox]::Show("Please specify an output filename.", "Error", "OK", "Error")
        return
    }

    # Ensure output directory exists
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory -Force | Out-Null
    }

    $fullOutputPath = Join-Path $outputDir $outputName

    try {
        # Execute the internal function
        Convert-TextToNotebook -InputFilePath $inputFile -OutputFilePath $fullOutputPath
        
        # Save defaults on success
        Save-Settings -InputDir (Split-Path $inputFile -Parent) -OutputDir $outputDir
        
        [System.Windows.Forms.MessageBox]::Show("Successfully converted file!`nSaved to: $fullOutputPath", "Success", "OK", "Information")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred:`n$($_.Exception.Message)", "Error", "OK", "Error")
    }
})

# --- Run ---
$form.ShowDialog() | Out-Null