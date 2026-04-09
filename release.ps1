param(
    [Parameter(Mandatory=$true)]
    [string]$TagName,
    [string]$Title,
    [string]$Notes
)

if ([string]::IsNullOrWhiteSpace($Title)) { $Title = $TagName }
if ([string]::IsNullOrWhiteSpace($Notes)) { $Notes = "Release $TagName" }

# Ensure GitHub CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ and login via 'gh auth login' before running this script."
    exit 1
}

$msiPath = "WinMSI\ConvertQuoteMarks.msi"

# Build the MSI
Write-Host "Building MSI..."
.\WinMSI\Build_MSI.ps1
if (-not $?) {
    Write-Error "MSI Build failed."
    exit 1
}

if (-not (Test-Path $msiPath)) {
    Write-Error "MSI file not found at $msiPath after build."
    exit 1
}

Write-Host "Creating GitHub Release $TagName..."
gh release create $TagName $msiPath -t $Title -n $Notes

if ($?) {
    Write-Host "Release created successfully!" -ForegroundColor Green
} else {
    Write-Error "Failed to create release."
}
