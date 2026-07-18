param([string]$Version = '0.4.17-alpha')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$out = Join-Path $root "dist\STierBlizzSettings-v$Version.zip"
New-Item -ItemType Directory -Force -Path (Split-Path $out) | Out-Null
if (Test-Path $out) { Remove-Item -LiteralPath $out -Force }
Compress-Archive -Path (Join-Path $root 'STierBlizzSettings') -DestinationPath $out -CompressionLevel Optimal
$entries = [IO.Compression.ZipFile]::OpenRead($out).Entries.FullName
if (-not ($entries -match '^STierBlizzSettings[\\/]STierBlizzSettings\.toc$')) { throw 'Invalid addon ZIP structure.' }
if ($entries | Where-Object { $_ -match '(^|[\\/])(Tests|\.github)([\\/]|$)' }) { throw 'Development files leaked into ZIP.' }
Write-Output $out
