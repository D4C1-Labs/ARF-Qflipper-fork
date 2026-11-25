param(
    [Parameter(Mandatory = $true)][string]$Url,
    [Parameter(Mandatory = $true)][string]$DestDir
)
$ErrorActionPreference = 'Stop'
$zip = Join-Path $env:TEMP ("arf-qflipper-" + [Guid]::NewGuid().ToString() + ".zip")
try {
    Write-Host "ARF setup: downloading package from website..."
    try {
        Start-BitsTransfer -Source $Url -Destination $zip -DisplayName "ARF package download" -Description "Downloading latest ARF runtime"
    } catch {
        Invoke-WebRequest -Uri $Url -OutFile $zip -UseBasicParsing
    }

    Write-Host "ARF setup: extracting package..."
    if (-not (Test-Path -LiteralPath $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $DestDir -Force
    Write-Host "ARF setup: package installed."
}
finally {
    if (Test-Path -LiteralPath $zip) {
        Remove-Item -LiteralPath $zip -Force
    }
}
