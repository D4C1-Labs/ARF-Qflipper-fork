param(
    [Parameter(Mandatory = $true)][string]$Url,
    [Parameter(Mandatory = $true)][string]$DestDir
)
$ErrorActionPreference = 'Stop'
$zip = Join-Path $env:TEMP ("arf-qflipper-" + [Guid]::NewGuid().ToString() + ".zip")
try {
    Write-Host "OmniCore setup: downloading package from website..."
    try {
        Start-BitsTransfer -Source $Url -Destination $zip -DisplayName "OmniCore package download" -Description "Downloading latest OmniCore runtime"
    } catch {
        Invoke-WebRequest -Uri $Url -OutFile $zip -UseBasicParsing
    }

    Write-Host "OmniCore setup: extracting package..."
    if (-not (Test-Path -LiteralPath $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $DestDir -Force
    Write-Host "OmniCore setup: package installed."
}
finally {
    if (Test-Path -LiteralPath $zip) {
        Remove-Item -LiteralPath $zip -Force
    }
}
