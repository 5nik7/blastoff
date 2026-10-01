# Blastoff command contract — 0.1.5 review build

## Paths

| Purpose | Resolution |
|---|---|
| Active config | Nonempty `STARSHIP_CONFIG`, otherwise `~/.config/starship.toml` |
| Storage root | Nonempty `BLASTOFF_HOME`, otherwise `~/.config/blastoff` |
| Themes | `<storage>/themes/<name>.toml` |
| Modules | `<storage>/modules/<name>.toml` |
| Backups | `<storage>/backups/<id>.toml` plus `<id>.json` |

Configured/import/migration paths must be absolute; leading `~` expands to home.
The user specifically requested `~/.config`; this build does not reinterpret
`XDG_CONFIG_HOME` or the Windows AppData directory. `STARSHIP_THEMES` and the old
`~/dots/config/starship` path are not implicitly adopted. Writes through symlink
or Windows reparse parent directories are refused. A dotfile setup with a linked
`.config` directory must use explicit real paths via the environment overrides.

## Installer contract

Public commands are `bash install.sh [--dry-run] [--prefix PATH]` and
`bash uninstall.sh [--dry-run] [--prefix PATH]`; no action word or `--yes` is needed.
All entry points default to native Termux `$PREFIX`, other POSIX `~/.local`, or
Windows `$LOCALAPPDATA/Programs/Blastoff` (fallback `~/.local`). These installation
paths do not change application storage/config resolution above.

Public install migrates verified legacy `~/.local` ownership if the selected
prefix differs. Target commit precedes legacy retirement; recorded cleanup resumes
on rerun. Modified owned files, unowned collisions, unsafe paths and unrelated
command shadowing block changes. No automatic downgrade or recursive removal.
Runtime versions are immutable; repeat installs restore missing support or refresh
unmodified supported output. Source checksums are mandatory even for dry-run and
never auto-refreshed. After reviewing deliberate source changes only, rebuild with
`bash scripts/build.sh`; rebuilding cannot bypass runtime immutability.

Discovery prefers native Bash/Fish/man locations. Zsh gets canonical
`share/zsh/site-functions/_blastoff` plus an owned native
`share/zsh/functions/Completion/Unix/_blastoff` copy where available, because
Termux's compiled fpath omits site-functions. Custom prefixes may require minimal
owned PATH/MANPATH/completion hooks. Regular profile encoding and unrelated content
are preserved; linked profiles/targets are refused with manual setup instructions,
not rewritten. Fish uses conf.d; available pwsh gets an absolute versioned manifest
import. Uninstall removes exact owned blocks/files, retaining unrelated profile
edits, user data and `<prefix>/share/blastoff/profile-backups` recovery copies.

Plans show version, prefix, changes and activation; `--color auto|always|never`
and NO_COLOR precedence apply. Dry-run writes nothing and runs no shell probes
or profiles. Installation never executes profiles automatically. Legacy
`bash scripts/install.sh install --yes` and native `scripts/install.ps1` remain
supported; fresh legacy installs leave activation manual unless already owning
integration. See INSTALLATION.md for compatibility/removal syntax and limitations.
Native Windows runtime verification remains pending.

## Commands and aliases

| Command | Behavior |
|---|---|
| No arguments | Compact branded welcome, version and examples; no dependency discovery, subprocesses or state writes |
| `-h`, `--help` | Shared branded header and grouped complete help; no dependency discovery, subprocesses or state writes |
| `--version` | Version without invoking Starship |
| `list`, `-l`, `--list`, `theme list` | Local themes and dynamically retrieved preset names |
| `current`, bare `-t`/`--theme` | Config path, existence, symlink status and byte-identical local matches |
| `theme apply NAME`, `-t NAME`, `--theme NAME` | Local name first; preset fallback if local is absent |
| `theme apply local:NAME` | Require a local theme |
| `theme apply preset:NAME` | Require a Starship preset |
| `theme save NAME` | Save active config under a new theme name |
| `theme copy SOURCE NAME` | Copy local theme or `preset:NAME` into local storage |
| `theme import ABSOLUTE-PATH NAME` | Validate/import external TOML |
| `theme delete NAME --force` | Back up then delete local theme; refuse the active config path or its symlink target |
| `preset list` | Query `starship preset --list` |
| `preset apply NAME` | Generate, validate and apply a built-in preset |
| `preset save NAME AS` | Save a built-in preset under a local name |
| `pick` | Choose local or preset source, then apply |
| `module list` | List stored snippets without Starship |
| `module save MODULE [NAME]` | Extract explicit module table and descendants from active config |
| `module load NAME` | Replace that module table and descendants in active config |
| `module delete NAME --force` | Back up then delete a stored snippet |
| `backup create` | Snapshot active config bytes, including invalid TOML if recovery is needed |
| `backup list` | List backup metadata |
| `backup restore ID` | Validate checksum/TOML; back up current config and restore snapshot as regular file |
| `migrate ABSOLUTE-DIRECTORY` | Copy discovered valid themes; refuse destination collisions |
| `doctor` | Read-only resolved paths and tool availability |
| `completion bash\|zsh\|fish` | Static completion script on stdout |

PowerShell additionally maps old exact spellings `-help`, `-list`, `-theme` to
GNU options. New examples use the shared command forms. Every other argument is
forwarded literally; quotes around names/paths use the caller's normal syntax.

`current` and `doctor` default to compact labeled human output: purple titles and
pink labels on color-capable terminals, plain text when redirected or NO_COLOR is
set. `current` shows all byte-identical local matches (or no match/no active config),
config path and file/link status. It does not guess a preset name. `doctor` shows
version, Python, resolved paths, config presence/link status and executable paths;
missing pickers are optional. Availability is not a tool execution or config
validity check. Neither command launches discovered tools or writes state.
Control characters in human path values are escaped. Explicit `--json` keeps the
existing single-object schemas, exact path values and uncolored machine output.

## Mutations, collisions and recovery

Apply writes a regular snapshot of the selected theme to the active path. It
does not create a symlink or modify the stored theme later when the config is
edited. Existing active content is always backed up before a changed apply,
module load or restore. An identical regular-file apply is a no-op.

Deleting a stored theme/module refuses a pathname that resolves to the active
config, including a regular config stored inside the theme/module directory.
Select a separate active config path first; `--force` cannot bypass this guard.
Backup metadata must be a JSON object; malformed metadata yields a clean error,
not a traceback, and restore does not modify the active config.

Stored destinations refuse collisions unless `--force` is supplied. Forced
replacements and deletions create backups first. Active symlinks refuse writes
unless `--replace-link` is supplied; the old link text is recorded in backup
metadata, its contents are snapshotted and its target stays untouched.
Restore restores content, not the old symlink relationship. Recreate a recorded
link manually only after reviewing its target and preserving the current file.

Backups use UTC timestamps plus random IDs, SHA-256 and original source paths.
No automatic pruning. `backup restore` accepts config backups only; recover a
stored theme using `theme import /absolute/backup.toml NEWNAME`. Stored-module
backup bytes can be copied to a new module file after inspecting/validating them.

Directory locks serialize cooperating Blastoff writers. Active writes also use
an adjacent config lock, so distinct storage roots targeting one config cooperate.
Locks fail closed; after a killed process, inspect them before manual removal.
An unexpected external edit before replacement aborts the write. This is not a
security boundary against a malicious process swapping paths in the final race
window. Multi-file backup/install/migration operations are not crash-transactional.
File writes are synced before replacement; parent-directory fsync is not done.

## Modules

A snippet contains one explicit table such as `[directory]`, `[git_branch]`,
`[custom.clock]`, plus its nested tables. A store name can differ from the module
path, e.g. `module save directory compact-directory`.
Loading replaces the whole saved module table, not just its supplied keys.
Settings outside that module remain equal and their text is retained. Table
blocks can move to the end; trailing comments within a removed block move with
that block or are replaced along with it. This is not a format-preserving editor
for comments associated with replaced tables.

The parser validates the complete config before and after merging and verifies
unrelated values. Headers are found outside strings/comments/array values, then
parsed as TOML. Root dotted keys and inline module tables are refused where the
selected module cannot be extracted/replaced losslessly. Convert them to an
explicit `[module]` table after a backup. No regex-only TOML rewriting, no
normalizing the whole document and no execution of Starship custom commands.
Syntax validation does not guarantee the installed Starship version recognizes
every option or module. Palettes/formats referenced by a snippet must already
exist in the target config; module loading does not rewrite global prompt format.

## Output, completion and exit status

`--json` returns one JSON object on stdout for operations or diagnostics; errors
are one JSON object on stderr. Help/version/completion remain their native text
formats. Human errors go to stderr; human results go to stdout. No ANSI in JSON.
Color is `auto`, `always`, or `never`; the presence of `NO_COLOR` wins. Auto color
requires a terminal and `TERM` other than `dumb`. Welcome and help (including
subcommand help) share one width-aware header. On UTF-8-capable terminal output,
the supplied 37-column, 13-row `lib/artwork/logo` is shown verbatim when it fits,
with a left-to-right purple-to-pink gradient when color is enabled. Narrow/dumb/
non-Unicode terminals, redirected output, missing or unsafe artwork fall back
to the compact ASCII wordmark. NO_COLOR retains the fitting logo without ANSI.
No image, Nerd Font, original logo script or ANSI asset is required or executed.
Artwork reads are optional and limited to 8 KiB/16 rows; only spaces, newlines,
Unicode Block Elements and Braille patterns are accepted. The supplied logo and
originals in `.local/logo` remain unchanged.

Help section headings, command/option names and branding use color; descriptions
remain plain. Help is generated from the shared parser grammar, grouped by task,
without duplicated brace-enclosed subcommand lists. All options, aliases,
descriptions and nested help remain available. `--color VALUE` / `--color=VALUE`
work before or after `-h`/`--help`, also for subcommands; the last color flag wins.
`--` still ends option processing, and invalid/missing color values return 2.
No Starship discovery, application state reads or subprocesses are needed.

Redirected output has no ANSI unless color is explicitly forced. With no command,
`--json` returns the existing single welcome/version/examples object. Help with
`--json` remains native help text (not a JSON schema), with no ANSI or block art
regardless of color flags. `NO_COLOR` presence always overrides forced color.

Picker requires stdin/stdout terminals, refuses JSON, uses fzf then gum then a
numbered menu. Escape/Ctrl-C cancels in fzf/gum. The fallback is line-oriented:
blank Enter, Escape then Enter, EOF or Ctrl-C cancels. Cancellation returns 130
and leaves config/storage unchanged; no mutation locks or backups are created.
Empty choices return 1; invalid numbered input returns 2. Ambient `FZF_*` and
`GUM_*` variables are not passed to picker children: they must not auto-select,
run inherited previews/bindings, alter selection semantics or start listeners.
Fzf uses an explicit purple/pink palette, ASCII-compatible border, source-prefixed
rows and key guide. Alt-P toggles its configuration preview. Below 80 columns the
preview is below the list; below 20 rows it starts hidden. Gum/numbered fallbacks
retain source labels and apply/cancel instructions, without a preview pane.

Fzf's only preview command is a shipped Python helper, invoked with a numeric row
ID, not a filename/theme string interpolated into a shell command. Paths are
quoted for the explicitly selected POSIX shell or PowerShell on Windows (native
Windows execution remains deferred). Windows without pwsh has no preview pane.
Shell startup-hook variables are removed. A private temporary session directory
contains the choice inventory and cached previews, and is removed on normal
selection/cancellation. Abrupt process death can leave a temporary preview cache;
it is not user theme storage. Preview results are snapshots; apply re-reads and
validates the selected source through existing safety checks.

Previews show name, source and syntax-colored TOML, never a rendered prompt.
No theme-defined commands execute, and no active config/storage writes occur.
Local reads retain the 4 MiB regular-file limit and refuse leaf symlinks. Display
is bounded to 64 KiB/200 lines/512 characters per line. Unsafe terminal controls,
invisible formatting/bidi and invalid bytes are removed/replaced before trusted
SGR colors are added. Preset previews invoke only `starship preset NAME`, with
64 KiB-plus-one pipe reads and a two-second deadline, and redirect Starship's
cache/config paths to the session. Successful and failed previews are cached for
the picker session, with a 16 MiB rendered-cache cap.
`NO_COLOR` and `--color never` disable preview/picker colors. No Nerd Font glyphs
are required. Starship may separately create its own cache during preset discovery. Shell completions are static, can
read local filenames, and never execute Blastoff, Starship, network calls or
write files. Live preset name completion is intentionally not performed.

Combined `list`/`theme list` (including aliases) and `pick` treat preset discovery
as optional. Missing/unlaunchable Starship, unsuccessful exit, ten-second timeout,
oversized/non-UTF-8 output or invalid preset-list lines make presets unavailable,
not local themes. Nonblank lines must each be usable portable names under the
same validation as preset selection; mixed valid/invalid output is rejected as a
whole. Blank/whitespace-only output is a successful empty list. Valid names are
sorted and deduplicated. No subprocess stderr or invalid output is echoed.

Combined listing returns 0 even if both groups are empty or presets unavailable
(unless local discovery itself fails). Human stdout keeps the local/preset groups,
marks unavailable presets `(unavailable)`, and sends one concise
`blastoff: warning: presets unavailable: REASON` to stderr. A successfully empty
group displays `(none)` with no warning. JSON listing emits exactly one stdout
object and no warning on stderr: existing `themes`, `presets` and
`starship_available` fields remain, with added
`preset_discovery: {"status": "ok", "error": null}` or
`preset_discovery: {"status": "unavailable", "error": "REASON"}`.
`starship_available` means executable discovery only, not successful preset
retrieval. An unavailable preset list is `[]`; callers use `preset_discovery` to
distinguish it from a successful empty list.

Picker warns once on stderr when presets are unavailable and still offers local
choices. Selection/application returns 0; cancellation stays 130 and does not
write config/storage. If no choices remain, it returns 1 with
`No themes or presets available` without launching fzf/gum or reading a numbered
selection. The unavailable warning, if any, distinguishes failure from an empty
successful discovery. Non-TTY/JSON picker requests still return 2 before discovery.

Explicit `preset list/apply/save`, `theme apply/copy preset:NAME`, and unqualified
preset fallback still return 3 for discovery/launch/timeout/output failures.
A successful empty list returns 0 for `preset list`; requesting an absent name
returns 1. Invalid generated preset TOML remains a validation failure (1).
Keyboard interruption is never downgraded to an availability warning (130).
Direct local operations and completions do not need preset discovery.

Completion is positional in Bash/Zsh/Fish. Global `--json`, `--force`,
`--replace-link`, and `--color VALUE` / `--color=VALUE` are recognized before or
after subcommands/operands. `--version` and leading aliases are offered only at
the root; help flags remain available in subcommands.

| Position | Offline candidates |
|---|---|
| Command/action; `completion` shell | Static command/action/shell names |
| Theme apply/copy source; leading `-t`/`--theme` | Local names, `local:` names, `preset:` prefix (no preset lookup) |
| Theme delete | Local names, no source prefixes |
| Module load/delete | Stored module names |
| Backup restore | Safe paired `.toml`/`.json` filenames; metadata/kind/checksum not validated until restore |
| Theme import first operand | Native file paths, with shell quoting for spaces |
| Migrate first operand | Directory paths |
| Destination names; module-save route | Free text, no misleading existing-name suggestions; module routes are not parsed from TOML |

Local name candidates exclude symlinks/nonregular files, names outside the
ASCII/96-character rule and reserved Windows device names. File-path completion
is navigation, not validation: execution still checks regular files, absolute
paths, TOML and destination safety. Empty/missing stores produce no names and
are not created. Completion never inspects backup contents or runs a parser.
See `INTERACTIVE-CHECKS.md` for automated and human terminal-check commands.

| Exit | Meaning |
|---|---|
| 0 | Success/no-op |
| 1 | File, TOML, collision, lock or safety failure |
| 2 | Usage/invalid name/noninteractive picker |
| 3 | Required preset dependency, process failure, timeout or unusable output |
| 130 | Cancellation/interruption |

Bash returns the process status. PowerShell exposes it through `$LASTEXITCODE`;
a function does not terminate the calling shell. Wrappers inherit streams and
TTY behavior. Native Windows/version-range validation remains pending; use
`WINDOWS-CHECKS.md` for isolated argv, stream and lifecycle checks. PowerShell's
native argument-passing and redirection behavior varies by version; do not treat
Linux PowerShell or WSL as Windows evidence. A preset request is limited to ten seconds. Individual file reads
are limited to 4 MiB. Built-in preset subprocess output is collected before its
size check, so the installed Starship executable is assumed trusted.
