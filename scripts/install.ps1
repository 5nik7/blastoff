# Invoke with: ./scripts/install.ps1 install --prefix "$HOME/.local" --yes
$entry = Join-Path $PSScriptRoot 'install.py'
if ($env:BLASTOFF_PYTHON) { & $env:BLASTOFF_PYTHON -I $entry @args }
elseif ($IsWindows -and (Get-Command py -ErrorAction SilentlyContinue)) { & py -3 -I $entry @args }
elseif (Get-Command python3 -ErrorAction SilentlyContinue) { & python3 -I $entry @args }
else { & python -I $entry @args }
exit $LASTEXITCODE
