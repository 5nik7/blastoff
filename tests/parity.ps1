#requires -Version 7.2
# Run in a disposable native Windows process: pwsh -NoProfile -File ./tests/parity.ps1
# This harness needs 7.2+ native stderr semantics; it does NOT certify the
# manifest's entire 7.0+ range. Literal-argument behavior is deliberately tested,
# not normalized to hide Legacy argument-passing failures.
param([switch]$KeepSandbox)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false # Expected nonzero statuses are assertions.
if (-not $IsWindows) { throw 'Native Windows is required; Linux PowerShell/WSL is not Windows evidence.' }
$root = Split-Path $PSScriptRoot -Parent
$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ('blastoff parity ü ' + [Guid]::NewGuid().ToString('N'))
$names = @('BLASTOFF_HOME','STARSHIP_CONFIG','BLASTOFF_PYTHON','NO_COLOR',
           'HOME','USERPROFILE','XDG_CONFIG_HOME','XDG_CACHE_HOME','STARSHIP_CACHE')
$previous = @{}
foreach ($key in $names) { $previous[$key] = [Environment]::GetEnvironmentVariable($key, 'Process') }
$success = $false
$utf8 = [Text.UTF8Encoding]::new($false)
try {
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    # Resolve Python before changing its home. Do not edit PATH.
    if ($env:BLASTOFF_PYTHON) { $runtime = $env:BLASTOFF_PYTHON; $prefixArgs = @() }
    elseif (Get-Command py -CommandType Application -ErrorAction SilentlyContinue) { $runtime = (Get-Command py -CommandType Application).Source; $prefixArgs = @('-3') }
    elseif (Get-Command python3 -CommandType Application -ErrorAction SilentlyContinue) { $runtime = (Get-Command python3 -CommandType Application).Source; $prefixArgs = @() }
    else { $runtime = (Get-Command python -CommandType Application).Source; $prefixArgs = @() }
    $resolved = & $runtime @prefixArgs -c 'import sys; assert sys.version_info >= (3,11); print(sys.executable)'
    if ($LASTEXITCODE -ne 0 -or -not $resolved) { throw 'A native Windows Python 3.11+ executable is required.' }
    $python = ([string]$resolved).Trim()
    $platform = & $python -c 'import os; print(os.name)'
    if ($LASTEXITCODE -ne 0 -or $platform -ne 'nt') { throw 'Python must be native Windows, not WSL.' }
    $env:HOME = $temporaryRoot
    $env:USERPROFILE = $temporaryRoot
    $env:BLASTOFF_HOME = Join-Path $temporaryRoot 'store with spaces ü'
    $env:STARSHIP_CONFIG = Join-Path $temporaryRoot 'active config ü/starship.toml'
    $env:XDG_CONFIG_HOME = Join-Path $temporaryRoot 'xdg'
    $env:XDG_CACHE_HOME = Join-Path $temporaryRoot 'cache'
    $env:STARSHIP_CACHE = Join-Path $temporaryRoot 'starship-cache'
    $env:NO_COLOR = '1'
    Write-Output "PowerShell $($PSVersionTable.PSVersion); Python $python; argument mode: $(Get-Variable PSNativeCommandArgumentPassing -ValueOnly -ErrorAction SilentlyContinue)"

    # An argv echo companion isolates the actual module's native-call boundary.
    # Comparing two equally broken native calls is not proof of literal forwarding.
    $probeRoot = Join-Path $temporaryRoot 'argv probe'
    New-Item -ItemType Directory -Path (Join-Path $probeRoot 'lib'),(Join-Path $probeRoot 'powershell') | Out-Null
    $probeModule = Join-Path $probeRoot 'powershell/blastoff.psm1'
    Copy-Item -LiteralPath (Join-Path $root 'powershell/blastoff.psm1') -Destination $probeModule
    [IO.File]::WriteAllText((Join-Path $probeRoot 'lib/blastoff.py'), 'import json,sys; print(json.dumps(sys.argv[1:]))', $utf8)
    $env:BLASTOFF_PYTHON = $python
    $probe = Import-Module $probeModule -Force -PassThru
    $literal = @('', 'space value', 'Unicode ü λ', 'quote"inside', 'trailing\', '-HELP')
    $echoed = @(Invoke-Blastoff @literal | ConvertFrom-Json)
    if ($LASTEXITCODE -ne 0 -or $echoed.Count -ne $literal.Count) { throw 'Literal argv count/exit mismatch (check PowerShell version and argument mode).' }
    for ($i = 0; $i -lt $literal.Count; $i++) {
        if ($echoed[$i] -cne $literal[$i]) { throw "Literal argv mismatch at index $i" }
    }
    Remove-Module -ModuleInfo $probe -Force

    # Import must not start Python or depend on a preexisting active config.
    $env:BLASTOFF_PYTHON = Join-Path $temporaryRoot 'not-present-python.exe'
    $global:LASTEXITCODE = 61
    Import-Module (Join-Path $root 'powershell/blastoff.psd1') -Force
    if ($LASTEXITCODE -ne 61 -or (Test-Path -LiteralPath $env:BLASTOFF_HOME) -or
        (Test-Path -LiteralPath $env:STARSHIP_CONFIG)) { throw 'Module import had runtime/filesystem side effects.' }
    $env:BLASTOFF_PYTHON = $python
    $missing = Join-Path $temporaryRoot "missing path ü's.toml"
    $cases = @(
        @{ A=@('--version'); C=0 }, @{ A=@('--help'); C=0 },
        @{ A=@('--list','--json'); C=0 }, @{ A=@('current','--json'); C=0 },
        @{ A=@('doctor','--json'); C=0 }, @{ A=@('module','list','--json'); C=0 },
        @{ A=@('--json','theme','apply'); C=2 },
        @{ A=@('theme','save','../unsafe','--json'); C=2 },
        @{ A=@('theme','save','','--json'); C=2 },
        @{ A=@('theme','import',$missing,'missing','--json'); C=1 },
        @{ A=@('-help'); C=0 }, @{ A=@('-list','--json'); C=0 },
        @{ A=@('-theme','--json'); C=0 }
    )
    $passed = 0
    foreach ($case in $cases) {
        $invocation = $case.A
        $mapped = @($invocation | ForEach-Object {
            if ($_ -ceq '-help') { '--help' } elseif ($_ -ceq '-list') { '--list' }
            elseif ($_ -ceq '-theme') { '--theme' } else { $_ }
        })
        $baselineError = Join-Path $temporaryRoot 'baseline.err'
        $moduleError = Join-Path $temporaryRoot 'module.err'
        $baseline = (& $python -I (Join-Path $root 'lib/blastoff.py') @mapped 2> $baselineError | Out-String)
        $baselineCode = $LASTEXITCODE
        $actual = (blastoff @invocation 2> $moduleError | Out-String)
        $actualCode = $LASTEXITCODE
        $errorText = [IO.File]::ReadAllText($moduleError)
        if ($baselineCode -ne $case.C -or $actualCode -ne $case.C -or $baseline -cne $actual -or
            [IO.File]::ReadAllText($baselineError) -cne $errorText) {
            throw ('Parity mismatch: ' + ($invocation -join ' ') + "; expected=$($case.C), core=$baselineCode, module=$actualCode; stderr=$errorText")
        }
        if ($case.C -ne 0 -and ($actual.Trim().Length -ne 0 -or ($errorText | ConvertFrom-Json).code -ne $case.C)) {
            throw 'Error stream/JSON contract mismatch'
        }
        $passed++
    }
    if (Test-Path -LiteralPath $env:BLASTOFF_HOME) { throw 'Read-only cases created storage.' }
    $themeDir = Join-Path $env:BLASTOFF_HOME 'themes'
    New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $themeDir 'purple.toml'), "[directory]`nstyle = 'purple'`n", $utf8)
    blastoff -theme purple --json | Out-Null
    if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $env:STARSHIP_CONFIG)) { throw 'Legacy theme alias failed' }
    blastoff module save directory compact --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Module save failed' }
    blastoff module load compact --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Module load failed' }
    Write-Output "Passed literal argv/import checks, $passed read/error parity cases and 3 isolated mutations."
    $success = $true
} finally {
    foreach ($key in $names) { [Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process') }
    if ($success -and -not $KeepSandbox) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    } else {
        Write-Warning "Retained disposable fixture for inspection: $temporaryRoot"
    }
}
