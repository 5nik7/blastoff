# blastoff

A Starship theme switcher and module library with the same behavior from Bash
and native PowerShell. This is a **0.1.10 review build** for integration with pi.
See `docs/STATUS.md` before treating it as a production release.

Fast, safe operation comes first. Human output uses purple/magenta accents;
Human output remains readable when redirected; JSON requires explicit --json. The core uses Python 3.11+ and no third-party packages.
Bash and PowerShell forward to that core, so they share paths and operations.
Bare `blastoff`, `-h`, and `--help` show the same full help, with the actual terminal
wordmark and a compact header for narrow/redirected output. Global flags without
a command also show help; `blastoff --json` retains its JSON welcome object.
Help groups and colors commands/options without losing descriptions;
`-h --color always` works in either option order. Help never discovers presets.
Fancy Unicode is the default picker;
`pick --fzf` (or `pick fzf`) respects compatible user styling.
`pick --fancy [unicode|ascii]` and `pick fancy` remain explicit choices. Ctrl-X toggles initially
visible, responsive source previews; previews never execute theme commands.
See `docs/TERMINAL-UX.md` for safe source previews and update commands.

Start with `docs/PI-SETUP.md` for pi, `AGENTS.md` for agent rules and
`docs/PROGRAMMING-PREFERENCES.md` for Nick's programming preferences.

## Paths

| Item | Default |
|---|---|
| Active Starship config | `~/.config/starship.toml` or nonempty `$STARSHIP_CONFIG` |
| Stored themes | `~/.config/blastoff/themes/*.toml` |
| Stored modules | `~/.config/blastoff/modules/*.toml` |
| Backups | `~/.config/blastoff/backups/` |

`BLASTOFF_HOME` overrides the storage root only. Put a valid `example.toml` in the
themes directory and it appears on the next `--list`; there is no registry to edit.
The storage root may be a directory link, such as
`~/.config/blastoff -> ~/dots/config/blastoff`: Blastoff uses its existing target
and leaves the link intact. `doctor` reports the real storage path. Links beneath
storage and active-config write protections remain unchanged. See the
[dotfiles notes](docs/TERMUX-QUICKSTART.md#linked-dotfiles-storage) for limits.

## Install

From the reviewed source directory (Python 3.11+ and Bash required):

```sh
bash install.sh --dry-run
bash install.sh
# When removal is wanted:
bash uninstall.sh --dry-run
bash uninstall.sh
```

No action word or `--yes` is needed. Use `--prefix /absolute/path` for a custom
location. Defaults are native Termux `$PREFIX`, other POSIX `~/.local`, and
Windows `$LOCALAPPDATA/Programs/Blastoff` (fallback `~/.local`). Public install
migrates verified legacy `~/.local` ownership when the selected target differs.
Native discovery is preferred; custom prefixes may need minimal owned profile
hooks. Linked profiles are preserved or refused with manual setup instructions.
Uninstall retains user data, unrelated profile content and recovery backups.
See [installation and compatibility guidance](docs/INSTALLATION.md) before use.
Dry-run writes nothing; source checksums remain mandatory, never auto-refreshed.

PowerShell 7+ has its own root interface (no Bash or WSL):

```powershell
.\install.ps1 -WhatIf -Verbose
.\install.ps1
.\uninstall.ps1 -WhatIf
.\uninstall.ps1
```

It installs a self-contained CurrentUser module and one owned profile import.
Use `-NoProfile` for manual integration, or explicit `-ModuleRoot`/`-ProfilePath`.
`-DryRun` is an alias in behavior for `-WhatIf`. See [PowerShell paths, parity,
startup and retention](docs/POWERSHELL.md). Native execution remains a separate gate.

## Run from source

Bash (including Termux, without relying on `/usr/bin/env` shebang translation):

```sh
bash bin/blastoff                 # full help, identical to -h/--help
bash bin/blastoff --help
bash bin/blastoff --version
bash bin/blastoff --list
bash bin/blastoff doctor --json
```

PowerShell 7+ (native Windows needs no Bash or WSL):

```powershell
Import-Module ./powershell/blastoff.psd1
blastoff --help
blastoff --version
blastoff --list
blastoff doctor --json
$LASTEXITCODE
```

PowerShell finds `py -3` on Windows or Python 3 on PATH. `BLASTOFF_PYTHON` can
name an explicit interpreter executable, not a command string with extra flags.
Python 3.11+ is required; preset commands also need Starship. fzf/gum are optional.

## Use

```sh
blastoff -t example
blastoff theme apply local:example
blastoff preset save catppuccin-powerline catppuccin
blastoff theme save work
blastoff theme copy work travel
blastoff pick                          # fancy Unicode by default
blastoff pick --fzf                    # compatible user fzf styling
blastoff pick --fancy ascii            # explicit ASCII borders
blastoff theme edit --dry-run          # inspect target/editor without launching
blastoff theme edit                    # staged editing with recovery
blastoff theme save                    # y/as/N for known local destination
blastoff module save directory compact-directory
blastoff module load compact-directory
blastoff module show compact-directory
blastoff backup create
blastoff backup list                   # spaced records, distinct field colors
blastoff backup list --json            # explicit machine format
blastoff backup restore BACKUP-ID
blastoff backup delete --all --dry-run
blastoff backup delete BACKUP-ID --yes
blastoff theme delete travel --force
```

Explicit save/copy refuse existing names unless `--force` is supplied. Interactive
no-name save uses provenance and asks `Save edits to "<theme>"? [y/as/N]`; yes
authorizes a backed-up replacement. Changed/unknown origins require save-as.
Theme/module delete requires `--force` and makes a backup first. Backup delete is
permanent, shows its frozen selection/count and defaults to No; use `--yes` for
explicit noninteractive deletion, or `--pick` for fzf Tab/Shift-Tab selection. Apply copies theme bytes into a regular active
config and backs up changed existing content; it never edits the stored theme.
A symlinked active config requires explicit `--replace-link` to record the old
link and replace it while preserving its target. Listing is read-only, including
built-in presets. Module load replaces the selected table and descendants,
preserving unrelated settings. Unsupported inline/dotted layouts fail safely.

All mutations support `--dry-run` without writes or interaction; `-v/--verbose`
sends diagnostics to stderr. Editor order is `$EDITOR`, nvim, vim, vi, code, nano.
Invalid/conflicted edits are retained at a reported recovery path. `current` keeps
last-loaded history independently of current content matches.

See [recovery and troubleshooting](docs/RECOVERY.md) and
`docs/CLI-CONTRACT.md` for aliases, collisions, output, recovery and limits;
`docs/INSTALLATION.md` for lifecycle/completions/manual; `docs/MIGRATION.md` for
moving legacy themes without moving Starship's config. For everyday Termux use,
start with `docs/TERMUX-QUICKSTART.md` and the user-run update plan in
`docs/TERMUX-INSTALL-PLAN.md`. No live installation is implied by these docs. Native Windows validation is explicitly deferred;
it does not block Termux use.

## Validate and package

```sh
python3 -m unittest discover -s tests -v
for file in bin/blastoff scripts/install.sh completions/blastoff.bash; do bash -n "$file" || break; done
zsh -n completions/blastoff.zsh
# On hosts with these tools:
fish -n completions/blastoff.fish
pwsh -NoProfile -File tests/parity.ps1
python3 scripts/benchmark.py
# After final code, documentation and evidence edits:
python3 scripts/package.py
python3 scripts/verify.py
```

Tests use isolated temporary roots and offline fixtures. The archive preserves
the existing original sources in `.local/src` and assets in `.local/logo`.
The rebuild is already in this repository; no package integration is needed.
See `docs/TERMUX-AUDIT.md` for missing optional images and `docs/STATUS.md` for
native evidence, remaining human checks and deferred Windows validation.

`blastoff list` highlights the tracked theme as `[current]` in pink and keeps `local:` /
`preset:` prefixes dim so names stand out. Edited content retains its origin as
`[last loaded; modified]`; unknown origins remain unknown. `blastoff current`
provides the explicit local-content matching query. JSON listing is unchanged.
See [theme-list visual review](docs/TERMINAL-UX.md#theme-list-readability--0110).
