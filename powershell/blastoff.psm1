# Native PowerShell entry point for the same core used by Bash.
Set-StrictMode -Version Latest
$script:CorePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'lib/blastoff.py'
function Invoke-Blastoff {
    <#
    .SYNOPSIS
    Manage Starship themes and stored module configurations.
    .EXAMPLE
    blastoff --list
    .EXAMPLE
    blastoff module save directory compact-directory
    .NOTES
    Requires Python 3.11+. Native exit status is available in $LASTEXITCODE.
    #>
    # Deliberately not an advanced function: preserve GNU options verbatim.
    $forward = @($args | ForEach-Object {
        switch -CaseSensitive ([string]$_) {
            '-help' { '--help'; break }
            '-list' { '--list'; break }
            '-theme' { '--theme'; break }
            default { [string]$_ }
        }
    })
    if ($env:BLASTOFF_PYTHON) {
        $runtime = $env:BLASTOFF_PYTHON
        $prefix = @()
    } elseif ($IsWindows -and (Get-Command py -ErrorAction SilentlyContinue)) {
        $runtime = 'py'
        $prefix = @('-3')
    } elseif (Get-Command python3 -ErrorAction SilentlyContinue) {
        $runtime = 'python3'
        $prefix = @()
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $runtime = 'python'
        $prefix = @()
    } else {
        Write-Error 'blastoff requires Python 3.11+; set BLASTOFF_PYTHON to its executable path.'
        $global:LASTEXITCODE = 3
        return
    }
    & $runtime @prefix -I $script:CorePath @forward
    $global:LASTEXITCODE = $LASTEXITCODE
}
Set-Alias -Name blastoff -Value Invoke-Blastoff

# Register at import, without discovering/running Python or Starship. The wrapper
# deliberately has no declared parameters: PowerShell uses native completion for
# its unbound arguments too. -Native callbacks take THREE arguments, not the five
# arguments used by a named PowerShell parameter completer.
Register-ArgumentCompleter -Native -CommandName blastoff, Invoke-Blastoff -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $words = @()
    foreach ($element in $commandAst.CommandElements | Select-Object -Skip 1) {
        # Ignore the token being completed, and any tokens after the cursor.
        if ($element.Extent.EndOffset -ge $cursorPosition) { break }
        if ($element -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
            $words += $element.Value
        } elseif ($element -is [System.Management.Automation.Language.CommandParameterAst]) {
            $words += $element.Extent.Text
        } else {
            # Never evaluate variables, subexpressions, or expandable strings.
            return
        }
    }
    $positionals = @()
    $pendingColor = $false
    $literal = $false
    foreach ($word in $words) {
        if ($pendingColor) { $pendingColor = $false; continue }
        if (-not $literal) {
            if ($word -ceq '--') { $literal = $true; continue }
            if ($word -cin @('--json', '--force', '--replace-link')) { continue }
            if ($word -ceq '--color') { $pendingColor = $true; continue }
            if ($word.StartsWith('--color=', [StringComparison]::Ordinal)) { continue }
            if ($positionals.Count -eq 0) {
                if ($word -cin @('-l', '--list', '-list')) { $positionals += 'list'; continue }
                if ($word -cin @('-t', '--theme', '-theme')) {
                    $positionals += 'theme', 'apply'; continue
                }
            }
        }
        $positionals += $word
    }
    $current = ([string]$wordToComplete).Trim("'" + '"')
    $candidates = @()
    $kind = ''
    $prefix = ''
    if ($pendingColor) {
        $candidates = @('auto', 'always', 'never')
    } elseif (-not $literal -and $current.StartsWith('--color=', [StringComparison]::Ordinal)) {
        $candidates = @('--color=auto', '--color=always', '--color=never')
    } elseif (-not $literal -and $current.StartsWith('-')) {
        $candidates = @('-h', '--help', '--json', '--color', '--force', '--replace-link')
        if ($positionals.Count -eq 0) {
            $candidates += '--version', '-l', '--list', '-t', '--theme', '-help', '-list', '-theme'
        }
    } elseif ($positionals.Count -eq 0) {
        $candidates = @('list', 'current', 'pick', 'doctor', 'theme', 'preset', 'module', 'backup', 'migrate', 'completion')
    } elseif ($positionals.Count -eq 1) {
        switch -CaseSensitive ($positionals[0]) {
            theme { $candidates = @('list', 'apply', 'save', 'copy', 'import', 'delete') }
            preset { $candidates = @('list', 'apply', 'save') }
            module { $candidates = @('list', 'save', 'load', 'delete') }
            backup { $candidates = @('create', 'list', 'restore') }
            completion { $candidates = @('bash', 'zsh', 'fish') }
        }
    } elseif ($positionals.Count -eq 2) {
        switch -CaseSensitive ($positionals -join ':') {
            { $_ -cin @('theme:apply', 'theme:copy') } {
                $kind = 'themes'
                if ($current.StartsWith('local:', [StringComparison]::Ordinal)) { $prefix = 'local:' }
                elseif ($current.StartsWith('preset:', [StringComparison]::Ordinal)) { $kind = '' }
                else { $candidates = @('local:', 'preset:') }
            }
            'theme:delete' { $kind = 'themes' }
            { $_ -cin @('module:load', 'module:delete') } { $kind = 'modules' }
        }
    }
    # Only inspect filenames for existing-name operands. Destination names,
    # module-save routes, backup IDs and preset names intentionally stay free text.
    # Path operands are left to the shell; this is not config/TOML validation.
    if ($kind) {
        try {
            $root = $env:BLASTOFF_HOME
            if (-not $root) { $root = Join-Path $HOME '.config/blastoff' }
            elseif ($root -eq '~') { $root = $HOME }
            elseif ($root.StartsWith('~/') -or ($IsWindows -and $root.StartsWith('~\'))) {
                $root = Join-Path $HOME $root.Substring(2)
            }
            # Follow only storage-root aliases; child/file links stay excluded.
            # Inspect each target before following it: Tab must not probe UNC or
            # mapped network drives. Target/LinkType also work on PowerShell 7.0.
            for ($redirect = 0; ; $redirect++) {
                if (-not [IO.Path]::IsPathFullyQualified($root) -or $root -match '^[\\/]{2}') { return }
                if ($IsWindows -and ([IO.DriveInfo]::new([IO.Path]::GetPathRoot($root))).DriveType -eq 'Network') { return }
                $item = Get-Item -LiteralPath $root -Force -ErrorAction Stop
                if (-not $item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::Device)) { return }
                if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { break }
                if ($redirect -ge 40 -or $item.LinkType -notin @('SymbolicLink', 'Junction')) { return }
                $targets = @($item.Target)
                if ($targets.Count -ne 1 -or -not $targets[0]) { return }
                $target = [string]$targets[0]
                if ($IsWindows -and ($target.StartsWith('\??\') -or $target.StartsWith('\\?\'))) {
                    $target = $target.Substring(4)
                    if ($target.StartsWith('UNC\', [StringComparison]::OrdinalIgnoreCase)) { return }
                }
                $root = [IO.Path]::GetFullPath($target, [IO.Path]::GetDirectoryName($item.FullName))
            }
            $directory = Join-Path $root $kind
            $unsafe = [IO.FileAttributes]::ReparsePoint -bor [IO.FileAttributes]::Device
            $item = Get-Item -LiteralPath $directory -Force -ErrorAction Stop
            if (-not $item.PSIsContainer -or ($item.Attributes -band $unsafe)) { return }
            foreach ($file in Get-ChildItem -LiteralPath $directory -File -Force -Filter '*.toml' -ErrorAction Stop) {
                if ($file.Attributes -band $unsafe) { continue }
                # Fail closed on Unix hosts lacking file-type metadata rather
                # than offer a FIFO/device as a regular stored configuration.
                if (-not $IsWindows) {
                    if (-not $file.PSObject.Properties['UnixMode'] -or $file.UnixMode -notlike '-*') { continue }
                }
                if ($file.Extension -cne '.toml') { continue }
                $name = $file.BaseName
                if ($name -cnotmatch '\A[A-Za-z0-9][A-Za-z0-9_-]{0,95}\z') { continue }
                if ($name -match '\A(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])\z') { continue }
                $candidates += "$prefix$name"
            }
        } catch {
            # Missing/inaccessible stores are ordinary empty completion sources.
        }
    }
    foreach ($candidate in $candidates | Sort-Object -CaseSensitive -Unique) {
        if ($candidate.StartsWith($current, [StringComparison]::OrdinalIgnoreCase)) {
            # Every emitted token is static or a validated portable ASCII name;
            # no user filename can inject PowerShell quoting or executable text.
            [System.Management.Automation.CompletionResult]::new($candidate, $candidate, 'ParameterValue', $candidate)
        }
    }
}
Export-ModuleMember -Function Invoke-Blastoff -Alias blastoff
