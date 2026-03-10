param (
    [Parameter(Mandatory=$true)]
    [string]$InputFilePath,
    [Parameter(Mandatory=$false)]
    [string]$OutputFilePath
)

$InputFile = Get-Item $InputFilePath

if (-not $InputFile.Exists) {
    Write-Error "Input file not found: $($InputFilePath)"
    exit 1
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

Write-Host "Successfully converted '$($InputFilePath)' to ANSI with straight quotes."
Write-Host "Output file: '$($OutputFilePath)'"
