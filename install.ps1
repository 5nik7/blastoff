#requires -Version 7.0
<#
.SYNOPSIS
Install Blastoff for the executing PowerShell 7+ CurrentUser.
.DESCRIPTION
Use -WhatIf (or -DryRun) to inspect exact owned files and profile edits without
writing. -Verbose explains resolution. -ModuleRoot selects a custom Modules
parent; -ProfilePath overrides CurrentUserAllHosts; -NoProfile skips integration.
No dependencies are downloaded and execution policy is never changed.
.EXAMPLE
.\install.ps1 -WhatIf -Verbose
.EXAMPLE
.\install.ps1 -NoProfile
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param([string]$ModuleRoot,[string]$ProfilePath,[switch]$NoProfile,[switch]$DryRun)
if ($NoProfile -and $ProfilePath) { Write-Error '-ProfilePath and -NoProfile are mutually exclusive'; exit 2 }
. (Join-Path $PSScriptRoot 'scripts/powershell_lifecycle.ps1')
Invoke-BlastoffLifecycle -Action install -ModuleRoot $ModuleRoot -ProfilePath $ProfilePath -NoProfile:$NoProfile -DryRun:$DryRun -WhatIf:$WhatIfPreference -Verbose:($VerbosePreference -ne 'SilentlyContinue')
exit $LASTEXITCODE
