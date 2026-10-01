# Changelog

## 0.1.6 — linked dotfiles storage

- Allow the storage root and its ancestors to be directory links, including
  Windows symlinks/junctions, without changing the link or moving existing data.
  Resolve storage once; canonical aliases share the operation lock.
- Refuse dangling/looping/non-directory targets and unsupported reparse types.
  Retain linked-child, stored-file, active-config and installer/profile guards.
- Report canonical storage paths without changing JSON schemas; support root
  links in offline Bash/Zsh/Fish and PowerShell name completion.
- Add isolated mutation/recovery/locking/redirect/completion regressions and
  Windows-path fixtures. Native Windows/PowerShell verification remains pending.
- Bump the immutable runtime identity; no automatic live upgrade or migration.

## 0.1.5 — gradient header and readable status

- Use `lib/artwork/logo` unchanged as the shared welcome/root/nested-help artwork.
  Its 37-column, 13-row Braille wordmark fits narrow Termux screens and receives
  the existing left-to-right purple-to-pink gradient at rendering time.
- Keep NO_COLOR, JSON, redirected/non-Unicode/dumb-terminal and too-narrow
  fallbacks, bounded regular-file-only artwork reads and ANSI resets.
- Make `current` (including bare `-t`/`--theme`) and `doctor` human-readable by
  default, with purple titles, pink labels and plain redirected/NO_COLOR output.
  Preserve explicit `--json` schemas and escape controls in human path values.
  Status commands remain read-only and never launch discovered tools.
- Preserve older reference assets and use a new immutable runtime identity.

## 0.1.4 — Battery-style lifecycle review build

- Add public `bash install.sh` / `bash uninstall.sh`, with `--dry-run` and
  `--prefix`, no action word or `--yes`; retain legacy shell/PowerShell entry points.
- Default to native Termux `$PREFIX`, other POSIX `~/.local`, and Windows
  `$LOCALAPPDATA/Programs/Blastoff` (fallback `~/.local`). Migrate verified legacy
  `~/.local` ownership when the public target differs, committing the target before
  resumable legacy cleanup. Never automatically downgrade or replace conflicts.
- Prefer native completion/man discovery, including Termux Zsh's actual autoload
  directory alongside canonical site-functions. Add minimal owned hooks where
  required, Fish conf.d integration, and versioned PowerShell imports when available.
- Preserve linked profiles/targets by refusing unsafe edits with manual instructions;
  retain regular-profile encoding, unrelated content and recoverable backups on
  uninstall. Keep immutable runtimes and repair missing/unmodified support output.
- Show compact colored lifecycle plans respecting NO_COLOR. Dry-run performs no
  writes, probes or profile execution. Source integrity stays mandatory; only
  reviewed deliberate changes warrant `bash scripts/build.sh`, never auto-refresh.
- Current verification results are recorded separately in `docs/STATUS.md`; native
  Windows remains unverified. No live installation or profile change is implied.

## 0.1.3 — reviewed inventory and PowerShell completion build

- Register offline PowerShell completion on module import for `blastoff` and
  `Invoke-Blastoff`, retaining argument forwarding and native exit status.
  Complete static grammar/options and safe stored names without runtime launches.
- Include the reviewed integration planner and PowerShell completion tests in
  the source inventory. The planner is not yet wired into the lifecycle driver;
  installation still does not edit profiles or PATH.
- Refresh source checksums and archives after intentional additions. Use a new
  release identity rather than overwrite the installed immutable 0.1.2 payload.
  PowerShell runtime/native Windows validation remains unavailable and pending.

## 0.1.2 — branded help review build

- Share the actual terminal wordmark/header between welcome and all help paths;
  ship verbatim compact/wide text copies, with safe narrow/redirected fallbacks.
- Group commands by task and color headings/names without duplicating argparse's
  brace-enclosed command lists; preserve parser options, descriptions and aliases.
- Keep the shared grammar lightweight so help exits before application imports;
  normalize color flags before help, independent of their argument position.
- Retain undecorated JSON, NO_COLOR precedence, read-only behavior and existing
  picker/file protections. Native Windows remains deferred.

## 0.1.1 — terminal UX review build

- Add a fast, width-aware ASCII welcome with version/examples, purple/pink
  accents and explicit color/JSON policy; retain complete --help.
- Style fzf with source labels, border, guide and an Alt-P configuration-preview
  toggle; improve gum/numbered instructions without requiring optional tools.
- Ship a bounded, sanitized TOML preview helper with session-local preset caching;
  never apply themes or execute their custom commands during preview.
- Verify helper resolution in the installed layout and synthetic version upgrades.
  The new identity permits updating immutable 0.1.0 installations without deleting
  their payload or user data. Native Windows execution remains deferred.

## 0.1.0 — 2026-09-30 — review build

- Rebuild Bash and native PowerShell entry points around one Python 3.11+ core.
- Separate Blastoff theme/module storage from the active Starship config.
- Make listing read-only and keep local/preset names distinct.
- Add theme save/copy/import/delete, backup/restore and explicit legacy migration.
- Add conservative TOML module save/load with unrelated-value preservation.
- Add optional fzf/gum/numbered selection, JSON and NO_COLOR support.
- Add Bash/Zsh/Fish completion, man page and versioned owned-file lifecycle.
- Add pi instructions, preference guide, workflow skills/prompts, source audit,
  implementation plan, isolated safety tests and startup measurement tooling.
- Preserve existing original source and branding assets; record incoming inventory
  discrepancies in `docs/TERMUX-AUDIT.md` rather than assume a lossless move.
- Refuse deletion through linked storage subdirectories and detect external
  config edits during module merging, with regression coverage.
- Bound source packaging to explicit paths, exclude agent/runtime state, and
  support temporary archive destinations and checksum-only refreshes.
- Keep cached-help wording checks portable across Python argparse wrapping changes;
  add isolated native shell, literal-argument and opt-in real Starship tests.

- Expand offline Bash/Zsh/Fish completion by argument position, safe source
  prefixes/names, paired backup IDs and space-containing paths; avoid suggesting
  existing names for free destination operands.
- Isolate picker options from ambient fzf/gum configuration; recognize numbered
  Escape+Enter cancellation and use responsive TextIO input for Termux Ctrl-C.
- Filter reserved portable names from local discovery/picker choices; add native
  PTY tests and a disposable human visual-check helper. Optional branding remains
  independent of runtime help and commands.

- Prepare the native Windows validation handoff and isolated literal-argv/status
  parity checks; correct test-only Windows path/newline/POSIX assumptions.
- Omit the top-level POSIX launcher on fresh Windows installs, regardless of
  Git Bash/WSL discovery. Native Windows execution remains pending.

See `docs/STATUS.md` for native Termux evidence and remaining Windows,
interactive shell/picker and release gates. This is not production certification.

- Refuse deleting a stored theme/module when its regular path is the active
  config; reject non-object backup metadata with clean errors.
- Explain mutation/recovery semantics and shared options in nested command help.
- Add an opt-in installed-package Termux lifecycle rehearsal, everyday quickstart
  and approval-ready real-install plan; explicitly defer native Windows.

- Keep local list/picker choices when optional preset discovery fails, with
  concise human warnings and structured JSON discovery status. Distinguish a
  successful empty list; retain strict failures for explicit preset requests.
- Validate complete preset-list output and classify launch/UTF-8 failures as
  preset errors. No completion, wrapper or file-mutation logic was changed.
