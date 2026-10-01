# Blastoff agent instructions

Read `docs/PROGRAMMING-PREFERENCES.md`, `docs/CLI-CONTRACT.md`, and
`docs/IMPLEMENTATION-PLAN.md` before changing behavior. Read `docs/STATUS.md`
for evidence and unfinished platform gates. Current user instructions win.

## Priorities

1. Protect user data and keep operations predictable.
2. Keep startup and common operations fast; measure instead of guessing.
3. Match the Bash and native PowerShell command contract.
4. Provide colorful, compact human output and clean machine output.
5. Ship help, Bash/Zsh/Fish completion, man page, install/uninstall, version,
   changelog, checksums, tests and practical documentation together.

The user selected one shared Python 3.11+ core with thin Bash/PowerShell entry
points. Do not introduce separate implementations of the same behavior.
Do not add Node, proot, network services, telemetry or required picker tools.

## Repository and reference sources

The user's actual repository is
`/data/data/com.termux/files/home/repos/blastoff`.
Inspect its existing Git status, tracked files, AGENTS files and docs first.
Reference scripts/module live in `.local/src`; branding work lives in
`.local/logo`. These are sources to inspect, not paths to execute automatically.
The supplied archive is a review workspace, not a checkout of that repository.
Never assume it represents main or copy it over existing work blindly.

## File safety

- Starship's active config is nonempty `$STARSHIP_CONFIG`, otherwise
  `~/.config/starship.toml`, even if the override does not exist yet.
- Store themes in `~/.config/blastoff/themes` and modules in
  `~/.config/blastoff/modules`; `BLASTOFF_HOME` overrides only the storage root.
- Resolve storage-root directory links once; aliases share the canonical lock.
  Keep linked storage children and active-config parent write protections strict.
- Help, version, list, doctor and completions must not create files/directories.
- Validate UTF-8 TOML before a mutation. Keep unrelated module settings intact.
- Back up replaced/deleted content. Stage in the destination directory and
  replace atomically. Detect external edits, locks and unsafe destinations.
- Never write through an active config symlink. Require `--replace-link` to
  record the old link and replace it; leave its target alone.
- Never break a lock automatically, recursively delete user directories or
  silently migrate legacy paths. Migration copies from an explicit source.
- Never run a theme's custom commands, use eval, or render a live prompt as
  validation. Generic TOML validity is not full Starship schema validation.
- No installs, profile edits, PATH changes, live-config changes or Git pushes
  as part of tests. All fixture writes belong in isolated temporary roots.

## Working style

Make a concrete plan, then implement bounded slices with acceptance checks.
Continue routine reversible work without repeated confirmation. Ask only for
missing decisions that block safe progress or genuinely destructive actions
outside the user's instructions. Inspect diffs and preserve unrelated changes.
Do not commit/push the user's repository without being asked. Do not rewrite
history or move release tags. Report what changed, why, actual tests and gaps.

Prefer `rg`, explicit argument arrays and focused helpers. Keep optional tools
optional. Do not build fake safety from regex-only TOML edits. All entry points
must forward arguments, streams, cancellation and exit status predictably.
The PowerShell function uses `$LASTEXITCODE`; a shell script returns the native
process status. Never claim that a function sets the parent shell process code.

## Verification

Run `python3 -m unittest discover -s tests -v` on Linux/Termux or
`py -3 -m unittest discover -s tests -v` on Windows.
Run `bash -n bin/blastoff scripts/install.sh completions/blastoff.bash`,
`zsh -n completions/blastoff.zsh`, `fish -n completions/blastoff.fish`, and
`groff -Tutf8 -man man/blastoff.1` where the native tool exists.
Use `tests/parity.ps1` to compare PowerShell output/exit status with the core.
Run `python3 scripts/benchmark.py`; distinguish Python, Bash and PowerShell
startup. Record machine, host OS, runtime and sample count.
Rebuild checksums using `python3 scripts/package.py` after changes.
Use `scripts/verify.py` to check the source archive before installing.
Treat native Termux and native Windows runs as separate release gates.
A Linux run or fake Starship fixture does not prove either gate.
