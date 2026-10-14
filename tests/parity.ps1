#requires -Version 7.0
# Run in a disposable native Windows process: pwsh -NoProfile -File ./tests/parity.ps1
# Record the actual host/version. Linux/WSL runs never certify native Windows.
param([switch]$KeepSandbox,[switch]$AllowNonWindows)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false # Expected nonzero statuses are assertions.
if (-not $IsWindows -and -not $AllowNonWindows) { throw 'Use -AllowNonWindows for a separately labelled Linux/WSL run; it is not Windows evidence.' }
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
    if ($LASTEXITCODE -ne 0 -or $platform -ne $(if ($IsWindows) { 'nt' } else { 'posix' })) { throw 'Python must match the PowerShell host platform.' }
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
    Copy-Item -LiteralPath (Join-Path $root 'powershell/runtime.ps1') -Destination (Join-Path $probeRoot 'powershell/runtime.ps1')
    # Independent probe decoder: assert original argv, not equality between two
    # frontend calls that might both corrupt the same argument.
    [IO.File]::WriteAllText((Join-Path $probeRoot 'lib/blastoff.py'), 'import base64,json,sys; assert sys.argv[1]=="--_powershell-argv-v1"; print(json.dumps(json.loads(base64.b64decode(sys.argv[2]))["argv"]))', $utf8)
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
        @{ A=@(); C=0 }, @{ A=@('-h'); C=0 },
        @{ A=@('--color','never'); C=0 }, @{ A=@('--verbose','--dry-run'); C=0 },
        @{ A=@('--json'); C=0 }, @{ A=@('--json','--help'); C=0 },
        @{ A=@('--list','--json'); C=0 }, @{ A=@('current','--json'); C=0 },
        @{ A=@('doctor','--json'); C=0 }, @{ A=@('module','list','--json'); C=0 },
        @{ A=@('--json','theme','apply'); C=2 },
        @{ A=@('theme','save','../unsafe','--json'); C=2 },
        @{ A=@('theme','save','','--json'); C=2 },
        @{ A=@('theme','import',$missing,'missing','--json'); C=1 },
        @{ A=@('-help'); C=0 }, @{ A=@('-list','--json'); C=0 },
        @{ A=@('-theme','--json'); C=0 },
        @{ A=@('theme','save','--json'); C=2 },
        @{ A=@('backup','delete','--all','--dry-run','--json'); C=0 },
        @{ A=@('backup','delete','yes','--json'); C=2 },
        @{ A=@('module','show','--json'); C=2 },
        @{ A=@('pick','--fancy','ascii','--dry-run','--json'); C=0 },
        @{ A=@('pick','--fzf','--dry-run','--json'); C=0 },
        @{ A=@('backup','list'); C=0 },
        @{ A=@('--json','backup','list'); C=0 },
        @{ A=@('pick','fancy','--fzf'); C=2 }
    )
    $rootHelp = (& $python -I (Join-Path $root 'lib/blastoff.py') --help | Out-String)
    if ($LASTEXITCODE -ne 0) { throw 'Root help failed' }
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
        if (($invocation.Count -eq 0 -or ($invocation -join ' ') -in @('-h','--help','--color never','--verbose --dry-run')) -and
            ($actual -cne $rootHelp -or $errorText.Length -ne 0)) {
            throw 'Implicit/explicit root help differs'
        }
        $passed++
    }
    if (Test-Path -LiteralPath $env:BLASTOFF_HOME) { throw 'Read-only cases created storage.' }
    $themeDir = Join-Path $env:BLASTOFF_HOME 'themes'
    New-Item -ItemType Directory -Path $themeDir -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $themeDir 'purple.toml'), "[directory]`nstyle = 'purple'`n", $utf8)
    blastoff -theme purple --json | Out-Null
    if ($LASTEXITCODE -ne 0 -or !(Test-Path -LiteralPath $env:STARSHIP_CONFIG)) { throw 'Legacy theme alias failed' }
    $originalActive = [IO.File]::ReadAllText($env:STARSHIP_CONFIG)
    $listNoColor = $env:NO_COLOR
    try {
        foreach ($modified in @($false,$true)) {
            if ($modified) { [IO.File]::WriteAllText($env:STARSHIP_CONFIG, $originalActive+"# edited`n", $utf8) }
            foreach ($flags in @(@('--color','never'),@('--color','always'),@('--json'))) {
                [Environment]::SetEnvironmentVariable('NO_COLOR', $null, 'Process')
                $baseline = (& $python -I (Join-Path $root 'lib/blastoff.py') list @flags 2> (Join-Path $temporaryRoot 'list-core.err') | Out-String)
                $baselineCode = $LASTEXITCODE
                $actual = (blastoff list @flags 2> (Join-Path $temporaryRoot 'list-module.err') | Out-String)
                if ($baselineCode -ne 0 -or $LASTEXITCODE -ne 0 -or $actual -cne $baseline) { throw 'Theme-list output parity mismatch' }
                if ([IO.File]::ReadAllText((Join-Path $temporaryRoot 'list-core.err')) -cne [IO.File]::ReadAllText((Join-Path $temporaryRoot 'list-module.err'))) { throw 'Theme-list diagnostic parity mismatch' }
                if ($flags[0] -ne '--json') {
                    $marker = if ($modified) { '[last loaded; modified]' } else { '[current]' }
                    if (-not $actual.Contains($marker)) { throw 'Theme-list origin marker missing' }
                }
            }
        }
    } finally {
        $env:NO_COLOR = $listNoColor
        [IO.File]::WriteAllText($env:STARSHIP_CONFIG, $originalActive, $utf8)
    }
    blastoff module save directory compact --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Module save failed' }
    blastoff module load compact --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Module load failed' }
    blastoff module show compact --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Module show failed' }
    $backup = blastoff backup create --json | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) { throw 'Backup create failed' }
    $savedColumns=$env:COLUMNS
    try {
        foreach ($columns in @('80','24')) {
            $env:COLUMNS=$columns
            foreach ($flags in @(@('--color','never'),@('--json'))) {
                $baseline=(& $python -I (Join-Path $root 'lib/blastoff.py') backup list @flags | Out-String)
                $baselineCode=$LASTEXITCODE
                $actual=(blastoff backup list @flags | Out-String)
                if ($baselineCode -ne 0 -or $LASTEXITCODE -ne 0 -or $actual -cne $baseline) { throw 'Populated backup-list parity mismatch' }
                if ($flags[0] -eq '--color' -and $columns -eq '24' -and $actual -notmatch '(?m)^  Size: ') { throw 'Narrow backup size row missing' }
            }
        }
    } finally { $env:COLUMNS=$savedColumns }
    blastoff backup delete $backup.backup --yes --json | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Backup delete failed' }
    Write-Output "Passed literal argv/import checks, $passed read/error parity cases and isolated mutation/view/deletion checks."
    $success = $true
} finally {
    foreach ($key in $names) { [Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process') }
    if ($success -and -not $KeepSandbox) {
        Remove-Item -LiteralPath $temporaryRoot -Recurse -Force
    } else {
        Write-Warning "Retained disposable fixture for inspection: $temporaryRoot"
    }
}
