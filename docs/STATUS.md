# Blastoff rebuild checkpoint — 2026-10-01

## Implemented

0.1.5 review build with one Python 3.11+ standard-library core, Bash entry point
and PowerShell 7+ module. Includes requested storage/config paths, read-only
local/preset listing, theme apply/save/copy/import/delete, backups/restore, module
save/load/delete, explicit legacy copying, optional picker, JSON/color, static
Bash/Zsh/Fish completions, offline PowerShell completion on module import,
manpage, versioned install/uninstall and checksums.

Planning bundle includes preference guide with evidence distinctions, AGENTS,
command contract, source audit, architecture decision, implementation plan,
pi setup guide, four pi workflow skills and four prompt templates. The moved
working tree is now audited; see `TERMUX-AUDIT.md` for renamed references and
missing package images. Existing `.local/src` and `.local/logo` files were left
untouched. No live config, real-prefix installation, shell profile or PATH was
changed. No commit, push, tag or publication was performed.

## Supplied gradient header and readable status — 0.1.5

Welcome and root/nested help now render `lib/artwork/logo` unchanged: 37 columns,
13 rows of Braille artwork, with the existing left-to-right purple-to-pink gradient.
NO_COLOR retains fitting artwork without color. Narrow, non-Unicode, dumb and
redirected output retain the ASCII fallback. Optional reads remain bounded,
regular-file-only and character-validated; no original ANSI artwork is replayed.
Old reference assets are not used as runtime headers or modified by this change.

`current` (including bare `-t`/`--theme`) and `doctor` now default to labeled human
output with purple titles and pink labels, without repeating the large logo.
Current preserves local byte-match semantics, including multiple matches and
missing/unmatched config cases. Doctor reports paths/presence/tool availability,
not TOML validity or successful tool execution. Both remain read-only, do not
launch discovered tools, honor NO_COLOR/redirection and escape terminal controls
in human path values. Explicit `--json` keeps the existing schemas and exact paths.
Version 0.1.5 permits an upgrade without rewriting older immutable runtimes.

Native Termux evidence (Python 3.14.6, aarch64; no native Windows or PowerShell):

- `test_current.py`: 12 passed in 5.348 s; default human/explicit JSON, aliases,
  exact schemas, missing/multiple matches, symlinks, control escaping, color policy,
  native PTY/Bash parity, no config reads/tool launches for doctor and no writes.
- Fresh temporary 0.1.5 ZIP plus `python3 -B -m unittest discover -s tests -v`:
  **154 tests in 82.680 s: 152 passed, 2 skipped**. Includes gradient/header safety,
  installed artwork after source removal, lifecycle/migration/discovery regression
  coverage, and unchanged data-safety checks. Real-Starship opt-in and unavailable
  PowerShell execution were skipped; Windows remains explicitly deferred.
- Bash wrappers/completion, Zsh and Fish syntax checks passed. Manual lint initially
  caught one overlong input line; wrapping it yielded clean `mandoc -Tlint`.
  `git diff --check` passed. Ruff diagnostics contained warnings, not errors;
  no new type-check or native Windows claim is made.
- Source inventory review found added `lib/artwork/logo`, `tests/test_current.py`
  and a reference `.local/logo/logo`, plus an independently edited reference
  `.local/logo/blastoff.txt`. The two reference files are identical logo text with
  trailing whitespace/control data; they are preserved verbatim as archival
  references, never selected or executed by the runtime. Packaging boundaries
  remain unchanged; task logs, bytecode and build output stay excluded.

Final documentation/manual changes are followed by the existing build workflow,
source/archive/outer-checksum verification and public install/uninstall dry-runs.
No live installation, configuration/profile edit, commit or publication is made.
Human font/gradient appearance and native Windows remain separate unverified gates.

## Battery-style public lifecycle — 0.1.4

Implemented root `install.sh` / `uninstall.sh` wrappers: normal execution needs
neither an action word nor `--yes`; `--dry-run` is read-only and `--prefix` wins.
Native Termux defaults to `$PREFIX`, other POSIX hosts to `~/.local`, and Windows
to LOCALAPPDATA/Programs/Blastoff (or `~/.local`). Legacy entry points retain their
explicit-approval/manual-integration compatibility. Runtime identity is 0.1.4;
versioned storage and ownership remain internal implementation details.

The driver now inspects and plans before applying changes. It installs runtime,
artwork, command, completions and manual together; conditionally manages owned
integration only when discovery needs it. Linked profiles and their targets are
preserved. Normal Termux discovery does not need profile edits. This native Zsh's
compiled fpath omits site-functions, so the canonical completion is accompanied
by an owned copy in `share/zsh/functions/Completion/Unix/_blastoff`. Fish vendor
and Bash framework paths were inspected with isolated native shell probes.
Bash frameworks supporting command-relative completion use that automatic path.

Public installation plans migration of the verified `~/.local` installation to
a different selected prefix. Target ownership commits before old verified files
are retired; pending cleanup is recorded and retryable. Modified/unrelated files
and unsafe paths cause refusal. Newer installed versions are not downgraded;
repeat install reuses immutable runtime and restores missing owned support files.
Uninstall preserves user data and unrelated profile text. Profile recovery backups
remain after uninstall; reinstall chooses a fresh backup name rather than adopting
or overwriting an unowned retained backup. This is not a crash-atomic transaction.

Safety review findings were reproduced as failing unit tests before correction:
retrying an integrated migration, transferring retained completion ownership, and
install/uninstall/reinstall with retained profile backups. All three regressions
now pass. No runtime/profile/config live installation was performed. Inspection
found installed 0.1.3 under `~/.local`; unlike older observations, the Dots legacy
`~/dots/scripts/blastoff` pathname is absent. Nothing was committed or published.

Native Termux verification:

- `bash install.sh --dry-run`: exit 0; VERSION 0.1.4, PREFIX
  `/data/data/com.termux/files/usr`, CURRENT 0.1.3 in `~/.local`. The plan identifies
  the shadowing owned `~/.local/bin/blastoff`, runtime/support migration and the
  native Zsh discovery copy. No profile edits are planned. Ends with
  `DONE preview complete; no files changed`.
- `python3 -B -m unittest discover -s tests -p test_lifecycle_planning.py -v`:
  11 passed (4.005 s); default-prefix branches, newer-version skip, concurrent
  edits, target rollback, resumable cleanup, linked/owned integration boundaries,
  BOM/CRLF preservation and actual Zsh compinit discovery in a temporary
  projection of its native autoload directory.
- `python3 -B -m unittest discover -s tests -p test_installer_public.py -v`:
  14 passed (19.208 s); isolated public wrappers, dry-run snapshots, repeat repair,
  source-independent installed runtime, format-1 migration, conflict refusals,
  preservation and actual fresh Bash/Zsh/Fish command/completion discovery plus
  native man lookup. These shells used temporary HOME/XDG/ZDOTDIR/prefix roots,
  never real profiles. No live `$PREFIX` install was used as test evidence.
- Packaging/wrapper diagnostics: 7 tests passed (1.088 s), including archive
  contents/modes, exclusions, exact argv/streams/status and actionable integrity
  errors. The explicit inventory now contains 104 source files.
- Full suite using a freshly built temporary ZIP:
  `BLASTOFF_TEST_ARCHIVE="$temporary/blastoff-rebuild-0.1.4.zip" python3 -B -m
  unittest discover -s tests -v`: 140 tests in 88.662 s, **138 passed, 2 skipped**.
  The installed-package upgrade/uninstall rehearsal passed. Real-Starship opt-in
  and unavailable PowerShell engine checks were skipped. Native Windows remains
  deferred; platform-branch fixtures are not native Windows certification.
- Separate Bash wrapper/completion syntax checks, Zsh/Fish completion syntax and
  `git diff --check` passed. A single manual overlong-line warning was wrapped
  after the suite; final packaging repeats manual lint and source verification.
  Ruff reported warnings, not errors; optional `ty` remains unavailable (install
  it or update the configured command before claiming type-check coverage).

Final packages are rebuilt through `bash scripts/build.sh` after documentation
edits. Source/ZIP/tar.gz inventories, outer SHA256SUMS and repeat-build identity
are checked before handoff. Integrity is never auto-refreshed by installation;
errors distinguish reviewed development rebuilding from restoring unknown source
changes. Old release artifacts and original reference assets are not overwritten.

## Installation inventory repair — 0.1.3

The exact `bash scripts/install.sh install --dry-run` initially failed the
source-inventory check. The previous manifest listed 97 files; the reviewed
source boundary found 99. Added: `scripts/integration.py` and
`tests/test_powershell_completion.py`. Missing: none. The existing
`powershell/blastoff.psm1` also had an intentionally changed checksum.

Both new files belong in the existing source allowlist. The packaging boundary
was not widened: `.pi/tasks`, sessions, bytecode, top-level build output and
private/ambient files remain excluded. `.local/src` and `.local/logo` remain
explicit reference-only inclusions, not installed assets. Added fixture cases
to the existing packaging test cover installer/integration/PowerShell files and
private/build exclusions. The integration planner is included but is not yet
called by `scripts/install.py`; no profile-management feature is activated.

After rebuilding the reviewed manifest, the same dry-run exposed a second
blocker: the changed PowerShell module could not overwrite the already-installed
immutable 0.1.2 payload. Bumped VERSION/core/PowerShell manifest/manual and current
installation examples to 0.1.3 instead. Source verification and immutable-version
checks are unchanged. No installed file, live profile/PATH or config was modified;
all actual install/upgrade/uninstall testing used disposable fixture roots.

Native Termux evidence:

- `python3 -B scripts/package.py --output-dir "$temporary"` then
  `python3 -B scripts/verify.py`: 99 source files verified.
- `bash scripts/install.sh install --dry-run`: exit 0, proposes 0.1.3 under
  `/data/data/com.termux/files/home/.local`, prints the versioned PowerShell import
  path and preservation notice; performs no installation.
- `BLASTOFF_TEST_ARCHIVE="$temporary/blastoff-rebuild-0.1.3.zip" python3 -B -m
  unittest discover -s tests -v`: 110 tests in 61.564 s, 108 passed, 2 skipped.
  Includes the actual temporary installed-package upgrade/uninstall rehearsal,
  inventory exclusions, ownership/tamper checks, version consistency and five
  static PowerShell completion checks. Real-Starship opt-in and the unavailable
  PowerShell engine test were skipped; no native Windows verification is implied.
- Separate Bash syntax checks for launcher/installer/completion, Zsh/Fish
  completion syntax checks and `mandoc -Tlint man/blastoff.1`: exit 0.
  Ruff reports one pre-existing import-order warning in `tests/test_packaging.py`;
  the optional `ty` server remains unavailable.

The rebuilt 0.1.2 archives from the initial inventory-only repair are superseded
by 0.1.3; they are not an upgrade path for the installed immutable 0.1.2 payload.
Final deliverables use `blastoff-rebuild-0.1.3.{zip,tar.gz,SHA256SUMS}` in the
repository's parent directory. No release was tagged, published or installed.

## Shared branded help — 0.1.2

The user reports installed 0.1.1 welcome works but help was still plain argparse.
This slice shares one branded header across welcome, -h, --help and nested help.
It uses verbatim copies of the original 60-column compact / 96-column wide text
wordmarks when terminal width/encoding permit; narrow, redirected, dumb or
non-Unicode output falls back to ASCII. Original scripts, text, ANSI and image
assets are untouched. Cursor-controlling original ANSI assets are never replayed.
Optional runtime artwork is regular-file-only, bounded, validated block text;
missing, malformed or unsafe files fall back rather than breaking help.

Help colors headings and command/option names, keeps descriptions plain, and
groups commands by task without duplicated brace-enclosed lists. The complete
parser grammar (options, descriptions, aliases and subcommands) is now in the
lightweight shared `lib/cli.py`; application/safety logic remains in the core.
Help exits before importing subprocess/TOML/hash/application modules; no presets
are discovered and no application state is read/written. Color flags normalize
before help processing, so before/after and nested forms agree. NO_COLOR wins;
JSON never gains ANSI or block artwork. Native help with --json remains text.

0.1.2 permits a versioned upgrade from immutable installed 0.1.1. No live install,
config/profile/PATH or original asset was changed. Windows is still deferred.
See TERMINAL-UX.md and TERMUX-INSTALL-PLAN.md for source preview/update commands.
Focused native Termux evidence (Android 15 aarch64, Python 3.14.6):

| Command | Result |
|---|---|
| `python3 -m unittest discover -s tests -p test_help.py -v` | 8 passed, 8.377 s: order-independent root/nested color flags, NO_COLOR/JSON, complete grammar descriptions, 40/60/96-column headers, actual PTYs, missing/unsafe/FIFO assets and fast-path import tracing |
| `python3 -m unittest discover -s tests -p test_welcome.py -v` | 11 passed, 0.069 s; prior welcome behavior/JSON/color/read-only coverage retained |
| `python3 -m unittest discover -s tests -p test_everyday.py -v` | 3 passed, 2.613 s; safety regressions and nested help explanations |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k Contract -v` | 33 passed; one updated test had a bytes/string assertion error (34 tests, 13.398 s), not an application failure |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k version_consistency -v` | Corrected test passed, 0.514 s; all 34 distinct contract tests now pass across these runs |
| `python3 -m unittest discover -s tests -p test_assets.py -v` | 1 passed, 1.573 s; optional-original-asset independence and no bytecode writes |
| `BLASTOFF_TEST_ARCHIVE="$temporary/blastoff-rebuild-0.1.2.zip" python3 -m unittest discover -s tests -p test_installed_package.py -v` | 1 passed, 6.691 s; isolated version upgrade, installed artwork/header in a native PTY after source removal, helper/completion/manual resolution, data retention and uninstall |

The first new PTY assertion also needed to strip trusted gradient SGR between
characters before comparing visible artwork; subsequent actual PTY checks pass.
Original asset and WINDOWS-CHECKS.md hashes matched the preceding manifest
(21 preserved reference/handoff files). The artwork copies match their originals
byte-for-byte. Python compile checks and git diff --check pass. Manual wrapping
also resolves the two historical long-line mandoc notices.

Startup: 20 samples/3 warmups, isolated roots, redirected stdout, NO_COLOR.
Python welcome p50/p95 **104.927/126.455 ms**; Python help **154.885/162.335 ms**;
Bash help **170.177/224.972 ms**. See startup-termux-help.json for exact commands.
Concurrent checks may affect timing; this is not an idle comparison or speedup
claim. Help now derives from the shared parser, rather than a cached argparse
string. Import tracing confirms it exits before application/discovery imports.

58 distinct checks pass across these focused runs and corrected test reruns.
`python3 scripts/package.py --output-dir "$temporary"` regenerates 0.1.2 ZIP/tar.gz
and CHECKSUMS.json; `python3 scripts/verify.py` verifies the working tree and both
extracted **97-file** inventories. Outer SHA256SUMS are also checked. Temporary
archives are removed, not published. Original assets, live install/config and
profiles/PATH remain unchanged. Windows remains deferred.

Next: visually inspect source welcome and help at your normal width (compact
ASCII below 60 columns), then at 60+ for the actual artwork. Review the 0.1.2
install dry-run before upgrading the installed 0.1.1 copy. Exact commands are in
TERMINAL-UX.md and TERMUX-INSTALL-PLAN.md. Automated PTYs verify bytes/layout
bounds, not font quality or your terminal's visual appearance.

## Terminal UX slice — 0.1.1

The user reports that Blastoff is installed and working, 37 themes migrated, and
12 presets listed. These are user-reported live results, not a new agent-run
installation. This slice does not modify that installed copy or its data.

- Bare invocation now renders a compact ASCII BLASTOFF welcome/version/examples
  in purple/pink on capable terminals, without discovery or subprocesses. Width,
  NO_COLOR, forced/disabled color, redirection and no-command JSON are supported.
  Complete --help is retained. Shipped helper loading disables bytecode writes.
- Inspected the current `.local/logo` README/text branding for inspiration;
  assets were not executed, copied over or modified. No runtime image dependency.
- Fzf now has a deliberate palette, border/title, source labels and key guide.
  Alt-P toggles a configuration-only preview, below the list on narrow screens,
  initially hidden on short screens. Gum/numbered menus have labels/instructions
  but no pane. Inherited picker options remain stripped.
- `lib/preview.py` accepts an opaque numeric row ID, never a theme/path shell
  fragment. It sanitizes terminal controls and bounds local display/preset work;
  generated output and failures are cached only in a disposable picker session.
  No live prompt or theme custom command is rendered/executed. Config/storage
  cancellation snapshots and existing backup/symlink protections are retained.
- The source identity is 0.1.1 (core, VERSION, manifest and man). This deliberately
  avoids rewriting the installed immutable 0.1.0 payload. Use the explicit update
  commands in TERMUX-INSTALL-PLAN.md after reviewing dry-run scope. No live update,
  profile/PATH edit, commit/tag/push or publication was performed.

See TERMINAL-UX.md for exact safe source preview commands and remaining human
visual checks. Native Windows, PowerShell preview execution, terminal appearance
and Android Alt-P ergonomics remain unverified; no cross-platform claim is made.
Focused automated evidence on native Termux (Android 15 aarch64, Python 3.14.6):

| Command | Result |
|---|---|
| `python3 -m unittest discover -s tests -p test_welcome.py -v` | 11 tests passed, 0.063 s: widths/color/NO_COLOR/redirect/JSON and no rendering-time discovery, subprocess or file access |
| `python3 -m unittest discover -s tests -p test_preview.py -v` | Final 7 tests passed, 2.994 s: real fzf preview at 50x28, Alt-P opens hidden preview at 40x16, Ctrl-C preserves config/storage and removes the session; unsafe text, quoted paths, bounds, cache and symlink tests |
| `python3 -m unittest discover -s tests -p test_picker.py -v` | 10 tests passed, 8.233 s, across actual fzf/gum/numbered backends and cancellation |
| `python3 -m unittest discover -s tests -p test_discovery.py -v` | 6 tests passed, 2.769 s; graceful discovery and strict preset errors preserved |
| `python3 -m unittest discover -s tests -p test_assets.py -v` | Final 1 test passed, 1.373 s, without optional branding assets or runtime bytecode creation |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k version -k entry_point -k read_only -v` | 3 tests passed, 2.110 s; release identity, Bash/core output and read-only behavior |
| `BLASTOFF_TEST_ARCHIVE="$temporary/blastoff-rebuild-0.1.1.zip" python3 -m unittest discover -s tests -p test_installed_package.py -v` | 1 passed, 4.988 s: isolated synthetic-prior-version upgrade, installed welcome/preview helpers after source removal, installed completions/manual, data operations and uninstall retention |

39 distinct focused tests passed; settled broad suites were not rerun. The first
synthetic upgrade fixture copied __pycache__ and reused old same-size/timestamp
bytecode after its version edit; excluding bytecode from that temporary clone
fixed the harness. This was not a live installation failure or an installer
workaround. The prior identity is synthetic, not certification of a historical
binary. The actual installed helper preview ran via `python3 -I` from the versioned
payload, including paths with spaces/Unicode. Native Windows remains deferred.

Final ZIP/tar.gz packaging is regenerated with `python3 scripts/package.py
--output-dir "$temporary"`; working tree and both extracted inventories are
verified with `python3 scripts/verify.py`, plus outer SHA256SUMS. The final
0.1.1 inventory has **92 source files**. Only disposable archives are created,
then removed; CHECKSUMS.json remains. Python `compile()` and `git diff --check`
pass. `mandoc -Tlint man/blastoff.1` has no errors (two pre-existing long-line
style notices). No source assets or live installation/config/profile/PATH were
changed, and nothing was committed/tagged/pushed/published.

Startup (20 samples, 3 warmups, isolated roots, redirected stdout): Python welcome
p50/p95 **84.367/95.180 ms**, Bash welcome **103.307/129.571 ms**, cached Python
help **61.605/66.968 ms**. Commands/data are in startup-termux-welcome.json. Other
checks may have overlapped; this is not an idle-machine comparison or speedup
claim. No PowerShell timings or native Windows evidence are implied.

## Optional preset discovery fix — 2026-10-01

The previously recorded failed-Starship listing/picker limitation is resolved.
Combined list/aliases/theme-list retain local results and exit 0 when optional
preset discovery fails, even if both groups are empty. Human output warns once
on stderr and labels presets unavailable; JSON output includes an additive
`preset_discovery` status/error object and leaves stderr empty. Executable
presence (`starship_available`) is still distinct from successful discovery.
Successful empty preset output is `ok`, not a warning. Picker uses available
locals, cancels with 130, or returns 1 without opening a picker if no choices
remain. Explicit preset operations still fail with status 3 for discovery errors.
See CLI-CONTRACT.md for exact output/exit semantics.

The fix is confined to shared-core discovery, list and picker composition.
Missing/unlaunchable executable, nonzero exit, timeout, oversized output, invalid
UTF-8 and unusable/mixed/reserved-name list output are covered. All nonblank
lines must validate, rather than silently dropping invalid lines. Interruptions
are not caught by the optional fallback. Wrappers, completion scripts and
file-mutation protections are unchanged; Windows remains explicitly deferred.

Focused commands on native Termux (no broad preparation/full-suite rerun):

| Command | Result |
|---|---|
| `python3 -m unittest discover -s tests -p test_discovery.py -v` | 6 tests passed, 2.445 s; matrix covers 9 failure modes, aliases, JSON/human streams, strict preset requests, empty/success cases and real failing-process Bash/numbered-picker PTY |
| `python3 -m unittest discover -s tests -p test_picker.py -v` | 10 tests passed, 8.616 s; real fzf/gum/numbered selection and cancellation, snapshots, empty/invalid choices, redirects and ambient-option protection |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k list -k presets -k read_only -k entry_point -v` | 4 affected regressions passed, 2.886 s |
| `python3 -I lib/blastoff.py list --json` with an isolated executable that sleeps 30 seconds | Actual subprocess timeout after 10.216 s: exit 0, local theme retained, unavailable/timed-out JSON status, empty stderr and unchanged fixture files; no config/cache created |
| `python3 -I lib/blastoff.py list --json` compared to `starship preset --list` in temporary HOME/config/storage/cache roots | Real Starship 1.26.0: all 12 names accepted, status ok, no config/storage writes. Comparison ignores blank lines per contract; the initial raw comparison included Starship's trailing blank line |
| `compile()` on changed Python; `git diff --check`; comparison against previous CHECKSUMS.json | Passed; all 20 original reference files and WINDOWS-CHECKS.md retain their prior hashes |

Baseline: the new matrix failed before the fix (69 failed subcases, 9 errors;
6 tests, 1.312 s), including real Bash listing exiting 3 instead of returning
locals. Failure propagation from optional discovery and silent filtering of
invalid list lines were the causes. Regression tests now exercise these caller
boundaries directly. Most failure variants use mocked subprocess outcomes with
real temporary config/storage; the Bash/PTY failure probe uses an actual local
executable. Automated PTY evidence is not human visual approval.

Quickstart, contract, manual and install-plan behavior notes are updated,
including correcting the example preset to the actual `plain-text-symbols` name.
The real installation plan and its separate approval boundary are unchanged.
No live installation/config/profile/PATH/original asset was changed; no Git
commit/push/tag or publication. Earlier installation, real-preset, completion,
safety and startup evidence is reused rather than repeated.

`python3 scripts/package.py --output-dir "$temporary"` rebuilt ZIP and tar.gz;
`python3 scripts/verify.py` passed for the working tree and both extracted
**85-file** inventories. Outer SHA256SUMS matched. Only temporary archives were
created and removed; CHECKSUMS.json is retained. Final documentation-only edits
receive the same package/inventory verification. `mandoc -Tlint man/blastoff.1`
has no errors; the two previously recorded long-line style notices remain.

## Everyday Termux readiness — 2026-10-01

**Native Windows is explicitly deferred and nonblocking for Termux.** Preserve
`WINDOWS-CHECKS.md` for when native hardware is available; no Windows preparation
or substitute Linux PowerShell/WSL execution was repeated in this slice.

Review against the original preferences/contract found every requested command
family implemented. No new rename/editor command is needed. Remaining everyday
work is hardening and documentation, not a missing theme/module subsystem:

- Fixed deletion of a regular active config whose configured pathname is itself
  a stored theme/module. Both regular paths and active symlink targets now refuse
  deletion, even with `--force`, before creating a backup or unlinking content.
- Backup list/restore reject non-object JSON metadata with clean status-1 errors;
  restore leaves the config unchanged. Invalid JSON already used clean handling.
- Nested mutation help now describes prefixes, replacement/backup behavior,
  explicit-table module limitations and shared options. Cached root help and
  version fast paths are unchanged; no startup speedup is claimed.
- Corrected stale README integration guidance, shell syntax-check instructions
  and the manual's distinction between stored-theme and stored-module recovery.
- Added `TERMUX-QUICKSTART.md` (sandbox examples and smallest human check) and
  `TERMUX-INSTALL-PLAN.md` (approval-ready plan, **not performed**). The existing
  `~/dots/scripts/blastoff` wins PATH lookup; preserve it and invoke a future
  `~/.local/bin/blastoff` explicitly. No live config contents were read for the
  installation plan, and no real installation/profile/PATH/assets were changed.

Historical follow-up, now resolved by the optional-discovery slice above:
failed/timed-out Starship used to hide combined local listing/picker choices.
Explicit preset errors remain strict. Optional improvements:
compact branding, broader TOML editing, controlled performance budgets, durable
multi-file transaction recovery and additional plugin/version matrices. Missing
optional images do not block commands (previous asset-isolation evidence stands).

Focused native Termux evidence (same host/runtime versions as below):

| Command | Result |
|---|---|
| `python3 -m unittest discover -s tests -p test_everyday.py -v` | 3 tests passed, 3.509 s: regular active-path deletion refusal, metadata error handling, help with no state writes |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k delete -k backup -k read_only -k entry_point -v` | 9 affected regressions passed, 6.041 s, including existing symlink guards and Bash forwarding |
| Package rehearsal in INSTALLATION.md | Initial run passed, 1 test/4.024 s; changed-source archive run passed, 1 test/3.983 s, no missing-runtime PENDING lines |
| `mandoc -Tlint man/blastoff.1` | No errors; two pre-existing over-80-column style notices; installed UTF-8 rendering checked by rehearsal |
| `compile()` on changed Python sources; `git diff --check` | Passed |

Before fixes, the 3 new tests reproduced 10 failed subcases and 4 metadata
traceback/JSON-parse errors (3.010 s). After the fix, only a help test's literal
whitespace assertion failed when argparse wrapped a phrase; normalizing help
whitespace fixed that assertion, not production behavior. No broad full-suite
rerun was performed. Prior 67-test native suite, 12 real presets, editor/picker
PTYs, completions and startup measurements are reused.

Installed-package coverage used a disposable space/Unicode prefix and config/
storage roots. It verified dry-run creates no prefix; executable mode and actual
Termux Bash shebang; default Python and BLASTOFF_PYTHON selection; missing
interpreter status 127; child-only command resolution; and execution after the
extracted source was renamed away. Installed theme save/copy/apply, module
save/load and backup create/restore passed. Installed Bash/Zsh/Fish completion
callbacks ran with an empty child PATH, script bytes matched CLI completion
output, and the correctly placed manpage rendered with native mandoc. The
installed lifecycle script uninstalled all manifest-owned files while retaining
config/themes/modules/backups, shell-generated isolated state and an unrelated
prefix sentinel byte-for-byte. This is automated evidence, not human terminal
visual approval.

ZIP and tar.gz were rebuilt in temporary directories; both extracted inventories
verified **84 source files**, and outer SHA256SUMS matched. Disposable archives
were removed, not published. Final documentation-only updates are followed by
another package/checksum and extracted-inventory verification, not another full
suite. The retained CHECKSUMS.json describes the final working tree.

**Termux readiness:** implemented and sandbox-validated for everyday use; the
failed-Starship availability limitation is now resolved. Ready for the small
human check and a separately approved installation; not a cross-platform release
certification. Native Windows remains deferred. No live installation was done.

## Native Windows handoff preparation — 2026-10-01

**Native Windows execution remains pending.** This host still has neither native
Windows nor `pwsh`/`powershell`. No Linux PowerShell, WSL or mocked branch is
counted as Windows evidence. `WINDOWS-CHECKS.md` now supplies prerequisites,
exact isolated PowerShell commands, expected statuses, stream/argv assertions,
environment overrides, data operations, sharing/reparse probes, temporary-prefix
lifecycle checks and reporting/cleanup guidance.

Preparation changes:

- `tests/parity.ps1` now requires native Windows and a disposable PowerShell 7.2+
  process (native stderr behavior changed in 7.2). Start with 7.4+ per the guide.
  The module's declared 7.0+ range is unchanged and **not** certified. Older hosts,
  Legacy argument passing and binary stream semantics remain separate gates.
- Parity now isolates HOME/USERPROFILE and Starship/XDG caches as well as config/
  storage; checks import without Python startup; verifies empty/quoted/Unicode/
  trailing-backslash argv against an independent echo fixture; asserts expected
  0/1/2 statuses and separate text streams; and retains failed fixtures. The
  expanded PowerShell script was reviewed but **not parsed or executed by a
  PowerShell engine here**. Its 13-case summary is an expected result, not a pass.
- Python test fixes: compare JSON path fields directly rather than through escaped
  dictionary repr; preserve installed bytes during tamper recovery rather than
  translate LF to CRLF; require POSIX for POSIX shell tests even when Git Bash/WSL
  is discoverable; and test unowned-file refusal using the common manpage
  destination, not a Bash-only launcher. Shared-core/lifecycle tests still run
  on Windows. Existing privilege-dependent Windows skips remain explicit.
- One installer branch fix: fresh native Windows installs do not discover or
  create the top-level POSIX Bash launcher. A mocked NT selection with
  `C:\\Program Files\\Git\\bin\\bash.exe` reproduced an erroneous shebang-space
  refusal before the fix. The native PowerShell payload remains present; POSIX
  launcher behavior is unchanged. This is a branch regression, not a native
  Windows filesystem/installer validation.

Focused evidence on Termux only (full output: `test-windows-handoff-prep-termux.txt`):

| Command | Result |
|---|---|
| `python3 -m unittest discover -s tests -p test_windows_handoff.py -v` | 1 platform-branch unit test passed, 0.014 s; failed before the installer fix |
| `python3 -m unittest discover -s tests -p test_blastoff.py -k Lifecycle -v` | 3 isolated lifecycle tests passed, 2.095 s |
| `python3 -m unittest discover -s tests -p test_native.py -k empty_overrides_and_tilde_paths -v` | 1 affected path-assertion test passed, 1.438 s |

Affected Python files also passed `compile()` checks and `git diff --check`.
`python3 scripts/package.py --output-dir "$temporary"` regenerated ZIP/tar.gz;
both extracted inventories verified **80 source files**, and outer SHA256SUMS
matched. Only disposable archives were created, then removed. After this final
evidence-only entry, `python3 scripts/package.py --checksums-only` and
`python3 scripts/verify.py` refresh/verify the final working-tree inventory.

In-memory probes also demonstrated escaped-backslash repr containment failure
and LF→CRLF byte changes. No native Windows run is implied by either probe.
Settled Termux picker/completion/preset and startup checks were not repeated:
the shared core, PowerShell module, completions and original assets were not
changed in this slice. The earlier Termux evidence below remains historical.

## Interactive/completion slice — 2026-10-01

Same native Termux host/runtimes recorded below; actual optional tools:
**fzf 0.74.4 (a140afeb)** and **gum 2.0.0**. No tools were installed. Earlier
symlink-deletion and module-merge safety fixes remain intact and tested.

### Changes

- Bash/Zsh/Fish now dispatch completion by argument position. Global options
  and their values are consumed correctly before/after commands and operands;
  source/destination contexts differ. Added `local:`/`preset:` source prefixes,
  paired backup filename IDs, and space-safe import/directory path completion.
  Portable names/device names/symlinks/nonregular candidates are filtered.
  Free destination names, preset names and module-save routes do not trigger
  application lookup or TOML parsing. Backup metadata/kind/checksum remain
  unverified until an actual restore. See the CLI contract for exact coverage.
- Picker children ignore ambient `FZF_*`/`GUM_*` variables. A real fzf fixture
  previously auto-applied a theme via inherited `--filter`; that regression now
  cancels normally. No preview, binding or listener options are inherited.
- Numbered Escape+Enter cancels with 130. Replaced `input()` with a flushed prompt
  plus `sys.stdin.readline()`: a native standalone probe reproduced `input()`
  deferring Ctrl-C until another newline, while TextIO reacted immediately.
- Local discovery/picker now rejects reserved names such as CON/LPT1 consistently
  with apply/save validation. Existing files are never removed or rewritten.
- Added a disposable `scripts/interactive_check.py` helper and exact human-check
  instructions in `INTERACTIVE-CHECKS.md`. Optional branding remains unnecessary
  for runtime help/version/list/current/doctor/completion; originals are untouched.

### Commands and evidence

- `python3 -m unittest discover -s tests -p test_completions.py -v`:
  **10 tests passed in 7.452 s**, with a matrix of Bash/Zsh/Fish subcases covering
  commands/actions, flags, aliases, option positions, safe names, source prefixes,
  paired backup IDs, empty/missing stores, root overrides and space-containing
  paths. Empty child PATH prevents application startup. Snapshots confirm no
  completion-triggered HOME/storage changes. The local Fish build creates its
  own XDG scaffold even for `--no-config --private -c true`; the test initializes
  that empty-shell state before measuring completion writes.
- `python3 -m unittest discover -s tests -p test_shell_tty.py -v`:
  **three consecutive passes**, 1.077 / 0.730 / 0.738 s. Actual Bash Readline,
  Zsh ZLE and Fish editor Tab inserted `local:alpha` and a correctly quoted path
  containing spaces at 50 columns. The driver answers conservative terminal
  capability queries, uses an empty child PATH and a sentinel command, and
  never submits the completed application line. This is automated PTY evidence,
  not a human visual or fzf-tab/plugin approval.
- `python3 scripts/package.py --checksums-only`, then
  `BLASTOFF_TEST_STARSHIP=1 python3 -m unittest discover -s tests -v`:
  **67 tests passed in 44.476 s, no skips**; full output in
  `test-interactive-termux.txt`. This includes all previous safety/lifecycle and
  real Starship checks, the matrix above, optional-asset independence, and ten
  picker tests. Real fzf/gum and the numbered fallback selected correctly at
  40/50 columns, including 96-character names. Escape/Ctrl-C (Escape+Enter in the
  line-oriented fallback), EOF/blank fallback input, empty choices, invalid
  numbered input, JSON and one-/two-sided redirects were checked. Cancellation
  snapshots preserved config/storage contents and directories. Missing optional
  tools and fzf precedence were exercised with isolated per-child tool exposure.
- Human-check helper automated smoke: numbered `--expect select` returned PASS
  with child exit 0; `--expect cancel` returned PASS with child exit 130 and
  `config/storage unchanged=True`. Human appearance has **not** been checked.
- Separate `bash -n bin/blastoff`, `bash -n scripts/install.sh`,
  `bash -n completions/blastoff.bash`, `zsh -n completions/blastoff.zsh`, and
  `fish -n completions/blastoff.fish`: exit 0. All Python source compiled with
  `compile()` without writing bytecode; `git diff --check` passed.
- Ruff LSP on six new helper/test files: nine warnings (import ordering, explicit
  `check` suggestions, interpreter-invoked script mode), no errors. Optional
  `ty` remains unavailable; no native Windows/type-check coverage is claimed.

### Post-slice packaging

`python3 scripts/package.py --output-dir "$temporary/first"` and a second build
under `"$temporary/second"` produced byte-identical ZIP, tar.gz and SHA256SUMS.
Both extracted inventories passed `verify(extracted_root)` for **77 files**;
outer SHA256SUMS matched. Core bytes did not change during packaging. Archives
were generated/checked only in disposable roots, then removed; nothing was
installed, published or written over an existing release artifact. This final
evidence entry is documentation-only; checksums are refreshed and verified once
more afterward with `python3 scripts/package.py --checksums-only` and
`python3 scripts/verify.py`.

### Post-slice startup

`python3 scripts/benchmark.py`: 60 fresh-process samples per command after five
warmups, same Android 15/aarch64/Python 3.14.6 host. Output is retained in
`startup-termux-interactive.json`. Test suites had finished; documentation work
continued, so this is not a controlled idle-host comparison. No runtime/import
optimization was made or speedup claimed. PowerShell remains unmeasured.

| Entry | p50 ms | p95 ms |
|---|---:|---:|
| Python version | 74.425 | 93.828 |
| Python help | 75.096 | 83.530 |
| Bash version | 85.662 | 100.747 |
| Bash help | 87.239 | 96.040 |
| Python current JSON | 164.921 | 245.274 |
| Bash current JSON | 192.110 | 260.390 |
| Python module list JSON | 169.925 | 223.265 |
| Bash module list JSON | 189.497 | 263.233 |

Initial verification failures were investigated, not ignored: obsolete smoke
expectations were updated for the added `preset:` candidate; PTY Ctrl-X prefix
bindings were replaced by a single-key capture binding; Fish capability-query
handshakes are answered before waiting for a prompt. One early driver mistakenly
submitted a line and reached an ambient legacy command, which exited at the
missing **temporary-HOME** theme directory. Final tests prevent submission or
application startup with both an empty PATH and a sentinel. No live config or
real-prefix operation occurred.

## Native Termux verification — 2026-09-30

Host: Android 15, aarch64, kernel `5.4.274-qgki-30957850-abG996USQSJHZB1`;
Python 3.14.6, Bash 5.3.20, Zsh 5.9.2, Fish 4.9.3, Starship 1.26.0.
PowerShell and groff are unavailable. This is native Termux, not proot/WSL.

The initial `python3 -m unittest discover -s tests -v` ran 35 tests and failed
cached-help whitespace parity and source-inventory verification (14.792 s).
The inventory mismatch was investigated before refreshing checksums, not hidden
by copying the archive over the repository. Two additional data-safety bugs
were reproduced and fixed: deletion through linked storage subdirectories and
external config edits lost during module merging. See `TERMUX-AUDIT.md`.

Final commands and results:

- `python3 scripts/package.py --checksums-only`: refreshed the bounded source
  inventory after intentional edits. Packaging no longer captures `.pi/tasks`,
  sessions or arbitrary checkout files or rewrites Python core help.
- `BLASTOFF_TEST_STARSHIP=1 python3 -m unittest discover -s tests -v`:
  **45 tests passed in 34.398 s**, no skips; full output in `test-termux.txt`.
  Includes temporary-prefix install/dry-run/uninstall, installed absolute Bash
  shebang execution, ownership/tamper checks, literal quotes/spaces/Unicode and
  empty-argument forwarding, separate config/storage overrides, empty overrides,
  tilde expansion, relative-path refusal, safety regressions and prior tests.
- `bash -n bin/blastoff`, `bash -n scripts/install.sh`,
  `bash -n completions/blastoff.bash`, `zsh -n completions/blastoff.zsh`,
  `fish -n completions/blastoff.fish`: each exit 0, no diagnostics. Bash checks
  were run separately because `bash -n file1 file2` only parses the first file.
- Native completion tests: Bash function invocation with an empty child PATH;
  Zsh dispatch with captured `compadd` outside ZLE; Fish `--no-config` plus
  `complete -C "blastoff theme apply p"`. Local name smoke cases passed.
  These do not prove interactive completion, fzf-tab, or the full position matrix.
- Actual `starship preset --list` returned 12 presets. For every name,
  `starship preset NAME` parsed as TOML, and `preset save` / `preset apply`
  matched its exact bytes. Previous active bytes were backed up. Invalid names
  failed without changing config (Blastoff exit 1; direct Starship exit 2).
  HOME, storage, active config, XDG paths and Starship cache were sandboxed.
  Starship may create its own cache directory; Blastoff list created neither
  storage nor active-config directories. No prompt or custom command was run.
- Python `compile()` checks passed for all Python source files without writing
  bytecode. Ruff LSP reported 30 warnings, mainly existing style/import-order,
  explicit `check` and source executable-mode warnings. No blanket autofix was
  applied; moving core imports would undermine cheap help/version startup.
  The new merge-test closure warning is benign: it runs synchronously inside
  each iteration. Optional `ty` was unavailable; install it or adjust its
  configured command in `pi-lsp.json` before claiming type-check coverage.

### Packaging and final review

- `python3 scripts/package.py --output-dir "$temporary/first"` and the same
  command with `"$temporary/second"`: ZIP, tar.gz and SHA256SUMS were byte-identical
  across two builds. Both archives were extracted into temporary roots and
  `scripts/verify.py`'s `verify(extracted_root)` accepted all **68 source files**.
  Outer SHA256SUMS matched both archive bytes. Core bytes were unchanged by
  packaging. All generated archives were removed with their temporary root;
  nothing was published or written into a real installation prefix.
- After this final evidence entry, `python3 scripts/package.py --checksums-only`
  and `python3 scripts/verify.py` refresh/check the final documentation inventory.
  Archive reproducibility above was checked just before this evidence-only edit.
- `git diff --check`: passed. Existing README modifications remained unchanged;
  the only added tracked-file edit is `.pi/tasks/` in `.gitignore`. Rebuild
  sources are still untracked, as they were at the initial audit.

### Native startup evidence

`python3 scripts/benchmark.py` produced `startup-termux.json`: 60 fresh-process
samples per entry after five warmups, temporary config/storage/HOME, no writes
to config/storage. Verification tasks ran concurrently: this is a measured
working-load baseline, not an idle-host regression threshold or a comparison
with the historical Linux machine. Hardware identity beyond aarch64 was not
collected. PowerShell startup remains unmeasured.

| Entry | p50 ms | p95 ms |
|---|---:|---:|
| Python version | 80.769 | 118.287 |
| Python help | 82.907 | 106.126 |
| Bash version | 106.257 | 132.690 |
| Bash help | 93.878 | 128.510 |
| Python current JSON | 235.961 | 342.156 |
| Bash current JSON | 286.024 | 377.728 |
| Python module list JSON | 251.868 | 345.614 |
| Bash module list JSON | 286.307 | 376.501 |

No performance optimization or speedup is claimed from these noisy samples.
Repeat sequentially on an idle device before choosing budgets or profiling the
slower full-parser paths.

## Historical Linux package evidence (not rerun here)

Host: Linux x86_64, kernel 6.18.44, glibc 2.39, Python 3.12.14.
Bash and Zsh are present; PowerShell, Fish and Starship are absent.

- `python3 -m unittest discover -s tests -v`: 35 isolated tests passed in 3.740 seconds;
  the exact result is recorded in `test-linux.txt`. Tests cover core
  contracts, Bash forwarding, invalid TOML, collisions, backups/checksums,
  link/FIFO/parent refusal, file modes, stale locks, external edits, failed
  replacement, module layouts, preset fixtures and lifecycle ownership/tampering.
- `bash -n bin/blastoff scripts/install.sh completions/blastoff.bash`: passed.
- `zsh -n completions/blastoff.zsh`: passed.
- `groff -Tutf8 -man man/blastoff.1`: rendered without diagnostics.
- Project skill metadata/name/explicit-relative-link checks and pi settings-path
  checks: passed for four skill directories and all explicit resource links.
- Source inventory/checksums and deterministic ZIP/tar.gz packaging: verified
  in the final packaging step. See `CHECKSUMS.json` and the outer SHA256SUMS.
- Real pi startup/reload and real Starship preset behavior were not run. The
  preset tests use an offline fake executable; documentation was checked against
  official upstream pi/Starship pages on this date.

## Startup evidence

`startup-linux.json` contains 60 samples per command after five warmups.
It measures fresh command processes, with isolated config/storage and no writes.
The final cached-help/launcher sample recorded:

| Entry | p50 ms | p95 ms |
|---|---:|---:|
| Python version | 20.149 | 29.702 |
| Python help | 19.511 | 25.491 |
| Bash version | 20.878 | 24.558 |
| Bash help | 20.709 | 24.811 |

Small differences are scheduling noise, not proof that wrappers beat the core.
Before cached help, Bash help p50 was about 53 ms on this host. The final helper
avoids unrelated imports. This still has Python startup overhead and is not a
single-digit-millisecond compiled command. Nick selected this shared-core
architecture; collect native-host measurements before setting budgets or
revisiting the runtime. These historical files contain no native Termux/Windows
performance result; the new Termux measurements are reported separately above.

## Pending release gates

| Gate | Required evidence |
|---|---|
| Native Termux ARM64 | Core/Bash, temporary lifecycle/shebang, modes, picker cancellation and native editor PTYs verified; human terminal visual checks and controlled performance budgets pending |
| Native Windows PowerShell | Explicitly deferred; does not block Termux. Preserved WINDOWS-CHECKS.md handoff; all native execution, streams/argv, filesystem/reparse, lifecycle and version-range evidence remain pending |
| Fish | Native positional matrix and editor PTY checks passed; human terminal/plugin approval pending |
| Bash/Zsh completion UX | Positional matrix, backup IDs and real editor PTYs passed; fzf-tab/plugins and human narrow-terminal appearance pending |
| Picker | Real fzf/gum/fallback automated PTYs passed, including cancellation and 40/50 columns; human visual/touch-keyboard sessions pending |
| Starship | 1.26.0 list/all 12 presets/save/apply/invalid-name checks passed; timeout/interruption and supported minimum-version matrix pending |
| pi | Confirm skills/prompts/context discovery and `/reload` in Nick's installed version |
| Real repository | Audited in place; no integration needed. Two incoming images unmatched; see TERMUX-AUDIT.md |
| Lifecycle resilience | Additional interruption/upgrade tests; optional durable transaction journal decision |

## Known limits

- Requires Python 3.11+; shared behavior is implemented, native wrapper parity
  remains unproven until the Windows script runs.
- Module edits support explicit table forms and safely refuse unsupported
  inline/root-dotted forms. Comments in replaced table blocks may move/change;
  unrelated values are verified and unrelated block text is retained.
- Generic TOML validation is not full Starship schema/runtime validation. Module
  loading does not add missing palette/format dependencies or run custom commands.
- No symlink/reparse parent writes, even for intentional dotfile directory links.
  Use explicitly configured real paths. Active link conversion is opt-in.
- Per-file atomic replacement and cooperating locks do not provide malicious-race
  protection or full multi-file/power-loss transactions. Locks are not auto-broken.
- Completion is intentionally offline; no live preset lookup or active-config
  module-route parsing. Backup candidates are filenames, not validated restores.
  Automated native coverage does not establish plugin/human visual behavior.
- The supplied wide ANSI banner is archived, not replayed. Welcome/help use the
  supplied Braille logo with generated gradient colors; human font appearance
  remains a separate visual check.
- The actual repository has an MIT license; it was retained unchanged.

## Next bounded task

Review `bash install.sh --dry-run` from the source root. If its native-prefix
migration and integration plan is wanted, run `bash install.sh` yourself. This
agent has not performed that live installation or changed real profiles. See
TERMUX-INSTALL-PLAN.md for migration and data-preservation details. Human visual
checks in TERMINAL-UX.md remain separate from automated PTYs. Native Windows
stays deferred, with its original handoff retained.
