# Define location of WiX Toolset (Adjust if you installed elsewhere)
$WixPath = "${env:ProgramFiles(x86)}\WiX Toolset v3.11\bin"

if (-not (Test-Path $WixPath)) {
    Write-Error "WiX Toolset not found at $WixPath.`nPlease install WiX Toolset v3.11 from https://wixtoolset.org/"
    exit
}

$Candle = Join-Path $WixPath "candle.exe"
$Light = Join-Path $WixPath "light.exe"
$SourceFile = "Product.wxs"
$ObjectFile = "Product.wixobj"
$MsiFile = "Text2Notebook.msi"

Write-Host "Compiling WiX source..."
& $Candle $SourceFile -out $ObjectFile

if (Test-Path $ObjectFile) {
    Write-Host "Linking MSI..."
    # -spdb suppresses the creation of a .pdb debug file
    & $Light $ObjectFile -out $MsiFile -spdb
    
    Write-Host "Success! MSI created: $PWD\$MsiFile" -ForegroundColor Green
}