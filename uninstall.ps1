#requires -Version 7.0
<#
.SYNOPSIS
Remove unchanged owned Blastoff PowerShell files and its exact profile block.
.DESCRIPTION
-WhatIf (or -DryRun) previews without writes. -Verbose adds resolution diagnostics.
Use the original -ModuleRoot for custom installations. User data, Starship config,
modified files, unrelated profile text and recovery backups remain intact.
.EXAMPLE
.\uninstall.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param([string]$ModuleRoot,[switch]$DryRun)
. (Join-Path $PSScriptRoot 'scripts/powershell_lifecycle.ps1')
Invoke-BlastoffLifecycle -Action uninstall -ModuleRoot $ModuleRoot -DryRun:$DryRun -WhatIf:$WhatIfPreference -Verbose:($VerbosePreference -ne 'SilentlyContinue')
exit $LASTEXITCODE
