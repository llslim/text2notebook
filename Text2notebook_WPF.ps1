# Load required assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms # Required for FolderBrowserDialog

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

# --- XAML UI Definition ---
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Text2Notebook Converter (WPF)" Height="320" Width="600" 
        WindowStartupLocation="CenterScreen" ResizeMode="NoResize"
        FontFamily="Segoe UI" FontSize="12">
    <Grid Margin="20">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        
        <!-- Input File -->
        <Label Grid.Row="0" Content="Input File:" Padding="0,0,0,5"/>
        <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="80"/>
            </Grid.ColumnDefinitions>
            <TextBox Name="txtInput" Grid.Column="0" Height="25" VerticalContentAlignment="Center"/>
            <Button Name="btnBrowseInput" Grid.Column="2" Content="Browse..." Height="25"/>
        </Grid>

        <!-- Output Directory -->
        <Label Grid.Row="2" Content="Output Directory:" Margin="0,15,0,5" Padding="0"/>
        <Grid Grid.Row="3">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="10"/>
                <ColumnDefinition Width="80"/>
            </Grid.ColumnDefinitions>
            <TextBox Name="txtOutputDir" Grid.Column="0" Height="25" VerticalContentAlignment="Center"/>
            <Button Name="btnBrowseOutput" Grid.Column="2" Content="Browse..." Height="25"/>
        </Grid>

        <!-- Output Filename -->
        <Label Grid.Row="4" Content="Output Filename:" Margin="0,15,0,5" Padding="0"/>
        <TextBox Name="txtOutputName" Grid.Row="5" Height="25" VerticalContentAlignment="Center"/>

        <!-- Convert Button -->
        <Button Name="btnConvert" Grid.Row="6" Content="Convert" Height="40" VerticalAlignment="Bottom" Background="LightBlue"/>
    </Grid>
</Window>
"@

# --- Load XAML ---
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# --- Find Controls ---
$txtInput = $window.FindName("txtInput")
$btnBrowseInput = $window.FindName("btnBrowseInput")
$txtOutputDir = $window.FindName("txtOutputDir")
$btnBrowseOutput = $window.FindName("btnBrowseOutput")
$txtOutputName = $window.FindName("txtOutputName")
$btnConvert = $window.FindName("btnConvert")

# --- Set Initial Values ---
$txtOutputDir.Text = $currentSettings.OutputDirectory

# --- Event Handlers ---

$btnBrowseInput.Add_Click({
    $ofd = New-Object Microsoft.Win32.OpenFileDialog
    $ofd.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
    
    if (-not [string]::IsNullOrWhiteSpace($currentSettings.InputDirectory) -and (Test-Path $currentSettings.InputDirectory)) {
        $ofd.InitialDirectory = $currentSettings.InputDirectory
    }

    if ($ofd.ShowDialog() -eq $true) {
        $txtInput.Text = $ofd.FileName
        $fileItem = Get-Item $ofd.FileName
        
        if ([string]::IsNullOrWhiteSpace($txtOutputDir.Text)) {
            $txtOutputDir.Text = $fileItem.DirectoryName
        }
        
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

    if ([string]::IsNullOrWhiteSpace($inputFile) -or -not (Test-Path $inputFile -PathType Leaf)) {
        [System.Windows.MessageBox]::Show("Please select a valid input file.", "Error", "OK", "Error")
        return
    }
    if ([string]::IsNullOrWhiteSpace($outputDir)) {
        [System.Windows.MessageBox]::Show("Please select an output directory.", "Error", "OK", "Error")
        return
    }
    if ([string]::IsNullOrWhiteSpace($outputName)) {
        [System.Windows.MessageBox]::Show("Please specify an output filename.", "Error", "OK", "Error")
        return
    }

    if (-not (Test-Path $outputDir)) { New-Item -Path $outputDir -ItemType Directory -Force | Out-Null }
    $fullOutputPath = Join-Path $outputDir $outputName

    try {
        Convert-TextToNotebook -InputFilePath $inputFile -OutputFilePath $fullOutputPath
        Save-Settings -InputDir (Split-Path $inputFile -Parent) -OutputDir $outputDir
        [System.Windows.MessageBox]::Show("Successfully converted file!`nSaved to: $fullOutputPath", "Success", "OK", "Information")
    } catch {
        [System.Windows.MessageBox]::Show("An error occurred:`n$($_.Exception.Message)", "Error", "OK", "Error")
    }
})

# --- Run ---
$window.ShowDialog() | Out-Null