param(
    [Parameter(Mandatory = $true)][string]$Url,
    [Parameter(Mandatory = $true)][string]$DestDir
)
$ErrorActionPreference = 'Stop'
$zip = Join-Path $env:TEMP ("arf-qflipper-" + [Guid]::NewGuid().ToString() + ".zip")
try {
    Invoke-WebRequest -Uri $Url -OutFile $zip -UseBasicParsing
    if (-not (Test-Path -LiteralPath $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }
    Expand-Archive -LiteralPath $zip -DestinationPath $DestDir -Force
}
finally {
    if (Test-Path -LiteralPath $zip) {
        Remove-Item -LiteralPath $zip -Force
    }
}
