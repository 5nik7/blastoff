#requires -Version 7.0
# Native adapter acceptance. Source must have reviewed, current CHECKSUMS.json.
$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$temporary=Join-Path ([IO.Path]::GetTempPath()) ('blastoff lifecycle ü '+[guid]::NewGuid().ToString('N'))
$moduleRoot=Join-Path $temporary 'Modules'
$profile=Join-Path $temporary "profile ' ü.ps1"
$pwsh=Join-Path $PSHOME $(if ($IsWindows) {'pwsh.exe'} else {'pwsh'})
function Snapshot {
    if (-not (Test-Path -LiteralPath $temporary)) { return '' }
    (@(Get-ChildItem -LiteralPath $temporary -Recurse -Force | ForEach-Object {
        $_.FullName+'|'+$_.LastWriteTimeUtc.Ticks+'|'+$(if (-not $_.PSIsContainer) {(Get-FileHash -LiteralPath $_.FullName).Hash})
    }) -join "`n")
}
try {
    $before=Snapshot
    & $pwsh -NoProfile -File (Join-Path $root 'install.ps1') -ModuleRoot $moduleRoot -ProfilePath $profile -WhatIf
    if ($LASTEXITCODE -ne 0 -or (Snapshot) -cne $before) { throw 'WhatIf changed files or failed' }
    & $pwsh -NoProfile -File (Join-Path $root 'install.ps1') -ModuleRoot $moduleRoot -ProfilePath $profile
    if ($LASTEXITCODE -ne 0) { throw 'Install failed' }
    $installed=Snapshot
    & $pwsh -NoProfile -File (Join-Path $root 'install.ps1') -ModuleRoot $moduleRoot -ProfilePath $profile
    if ($LASTEXITCODE -ne 0 -or (Snapshot) -cne $installed) { throw 'Repeat install was not idempotent' }
    & $pwsh -NoProfile -File (Join-Path $root 'uninstall.ps1') -ModuleRoot $moduleRoot -WhatIf
    if ($LASTEXITCODE -ne 0 -or (Snapshot) -cne $installed) { throw 'Uninstall WhatIf changed files' }
    & $pwsh -NoProfile -File (Join-Path $root 'uninstall.ps1') -ModuleRoot $moduleRoot
    if ($LASTEXITCODE -ne 0) { throw 'Uninstall failed' }
    'Native lifecycle adapter passed on '+$PSVersionTable.OS+' / '+$PSVersionTable.PSVersion
} finally {
    # Only this freshly generated temporary fixture; never a discovered user root.
    if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Recurse -Force }
}
