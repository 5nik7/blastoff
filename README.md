# blastoff

A Starship theme switcher and module library with the same behavior from Bash
and native PowerShell. This is a **0.1.6 review build** for integration with pi.
See `docs/STATUS.md` before treating it as a production release.

Fast, safe operation comes first. Human output uses purple/magenta accents;
JSON/pipes stay clean. The core uses Python 3.11+ and no third-party packages.
Bash and PowerShell forward to that core, so they share paths and operations.
Welcome and help share the actual terminal wordmark, with a compact fallback
for narrow/redirected output. Help groups and colors commands/options without
losing descriptions; `-h --color always` works in either option order. Neither
welcome nor help discovers presets. Fzf has an explicit palette and an Alt-P
configuration-preview toggle; previews never execute theme commands. See `docs/TERMINAL-UX.md` for safe source previews and update commands.

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

## Run from source

Bash (including Termux, without relying on `/usr/bin/env` shebang translation):

```sh
bash bin/blastoff                 # branded, width-aware welcome
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
blastoff pick
blastoff module save directory compact-directory
blastoff module load compact-directory
blastoff backup create
blastoff backup list
blastoff backup restore BACKUP-ID
blastoff theme delete travel --force
```

Save/copy refuse existing names unless `--force` is supplied. Delete requires
`--force` and makes a backup first. Apply copies theme bytes into a regular active
config and backs up changed existing content; it never edits the stored theme.
A symlinked active config requires explicit `--replace-link` to record the old
link and replace it while preserving its target. Listing is read-only, including
built-in presets. Module load replaces the selected table and descendants,
preserving unrelated settings. Unsupported inline/dotted layouts fail safely.

See `docs/CLI-CONTRACT.md` for aliases, collisions, output, recovery and limits;
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
python3 scripts/package.py
python3 scripts/verify.py
```

Tests use isolated temporary roots and offline fixtures. The archive preserves
the existing original sources in `.local/src` and assets in `.local/logo`.
The rebuild is already in this repository; no package integration is needed.
See `docs/TERMUX-AUDIT.md` for missing optional images and `docs/STATUS.md` for
native evidence, remaining human checks and deferred Windows validation.
