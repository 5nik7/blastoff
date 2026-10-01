# Implementation and continuation plan

The 0.1.0 review build is already in the actual repository; no staging copy,
archive integration or branch change is needed. Native verification evidence
and remaining platform gates are recorded in STATUS.md and TERMUX-AUDIT.md.
Follow the contract and use old implementations as references, never as an
automatic migration.

| Slice | Deliverable | Acceptance | Current state |
|---|---|---|---|
| 0. Audit | Preserve sources, inspect local repo, preferences, contract and architecture | Path/behavior differences recorded; unrelated work protected | Actual repo inspected; incoming inventory differences recorded in TERMUX-AUDIT.md |
| 1. Read-only core | Help/version/list/current/doctor | No writes; no required Starship for local paths; missing dirs usable | Implemented; Linux and native Termux checks |
| 2. Theme mutations | Apply/save/copy/import/delete/backup/restore/migrate | Safe names, TOML validation, backup, staging, collisions, links and locks | Implemented; native Termux regression fixes verified |
| 3. Modules | Save/load/list/delete explicit tables | Nested tables, custom modules, strings, unrelated settings and failure recovery | Implemented; unsupported layouts refused |
| 4. Frontends | Bash and PowerShell module, old aliases | Same shared arguments/results; native stream/TTY/exit tests | Implemented; native PowerShell gate pending |
| 5. UX | Purple/magenta output, JSON, optional fzf/gum/number picker, completions | Clean pipes/NO_COLOR; cancellation; actual shell completion cases | Native positional matrix and real editor/picker PTYs verified; human visual/plugin checks pending |
| 6. Lifecycle | Battery-style public wrappers, native discovery, owned integration, legacy migration, immutable runtime | No-write dry-run; conflicts block; target commit before resumable cleanup; profile backups/data retained | 0.1.4 implemented; current verification results recorded separately in STATUS.md |
| 7. Release | Native evidence, changelog, docs, reproducible packaging and performance | Termux ARM64 + native Linux + native Windows gates; honest evidence | Historical Linux and native Termux evidence; Windows and interactive gates open |

## Continuation in the real repository

1. Recheck Git status and current guidance before each slice. Preserve unrelated
   working-tree changes and `.local/src` / `.local/logo` references.
2. The moved package has already been audited; see TERMUX-AUDIT.md for renamed
   references and unmatched images. Do not repeat integration or assume missing
   assets can be reconstructed.
3. Reuse recorded native evidence; run focused regressions for changed behavior
   and concrete gaps, not an automatic repeat of settled suites. Keep storage,
   config and installation fixtures isolated.
4. Follow TERMUX-QUICKSTART.md for everyday operations and the smallest useful
   remaining human check. Review TERMUX-INSTALL-PLAN.md and `bash install.sh
   --dry-run` before any live install. Native Termux now defaults to `$PREFIX`;
   verified legacy `~/.local` ownership migrates when the target differs. Preserve
   unrelated dots commands and resolve shadowing without overwriting them.
   No live installation or real-profile change is authorized by this plan.
5. Native Windows is explicitly deferred while unavailable; preserve
   WINDOWS-CHECKS.md unchanged for a future native run. It does not block Termux
   development or the separately approved Termux installation. Linux PowerShell
   or WSL must not substitute for native Windows evidence.
6. Update `docs/STATUS.md` with exact commands, versions and observations.
7. Fix real findings in bounded changes. Do not merely mark unchecked items done.

## 0.1.6 linked-storage slice

Support configured storage-root symlinks/junctions by pinning their canonical
existing target; allow ordinary missing non-linked paths without read-only writes.
Keep child-directory, leaf-file, active-config and lifecycle guards strict.
Verify alias lock contention, recovery, retargeting, broken/looping links and
offline completion in isolated roots. Record native Termux evidence in STATUS.md;
Windows junction/PowerShell execution remains a separate gate. Versioned upgrade
rehearsals use temporary prefixes, never the live installation.

## 0.1.4 lifecycle acceptance focus

Public install/uninstall need no action word or `--yes`; legacy entry points remain
available with manual activation unless already owning integration. Review native
Bash/Fish/man discovery and both Zsh completion destinations: canonical
site-functions and Termux's compiled Completion/Unix autoload directory. Custom
prefix hooks must preserve unrelated profile bytes/encoding; linked profiles and
targets must remain untouched on refusal. Check retained profile backups, Fish
conf.d and absolute versioned PowerShell imports without claiming Windows evidence.

Verify source-integrity refusal, no-write/no-probe dry-run, NO_COLOR, support-file
repair, immutable runtime rejection, no downgrade, conflict-before-write behavior
and resumable legacy cleanup after target commit. Use isolated fixture roots only.
These are acceptance requirements, not new test-pass claims. Documentation-only
work does not refresh checksums; reviewed deliberate source changes use
`bash scripts/build.sh` in the separate build/verification step.

## Before public release

- Measure warm startup for core/Bash/PowerShell separately, record sample count,
  hardware, runtime and p50/p95. Set realistic budgets from those measurements.
- Establish verified Starship minimum version rather than inventing a version
  from memory. Exercise supported preset output and command failure/timeout.
- Positional completion, source/destination contexts and paired backup IDs now
  have native coverage without invoking Starship. Continue human/plugin checks
  from INTERACTIVE-CHECKS.md; do not infer visual approval from automated PTYs.
- Assess abrupt-kill backup/install/migration recovery. Current implementation
  is per-file atomic, not multi-file crash transactional. Decide whether to add
  a durable transaction journal based on evidence.
- Review the module scanner against quoted keys, arrays-of-tables, multiline
  strings and inline/dotted layouts. Expand conservatively or adopt a tested TOML
  editing library through a documented dependency decision.
- Improve picker presentation and compact branding without expensive startup or
  command-executing previews. Keep supplied logo assets intact.
- Add CI for Linux, Bash/Zsh/Fish and native Windows PowerShell/core checks; keep
  Termux evidence separate. Do not claim an unrun CI configuration is passing.
- Preserve the repository's existing MIT license. Release version changes must
  remain consistent; do not invent a new license.
- Rebuild source checksums/package, verify archives and review installation scope
  before running a real install. Only create tags/push/publish when instructed.

## Definition of done

Every requested command and path works in the documented native environments;
frontends agree; file failures/cancellation preserve data; common paths meet
measured budgets; completions and manual match help; install/uninstall preserve
user configs; source/assets and unrelated work remain intact; open limitations
are explicit; release identity and verification artifacts agree.
