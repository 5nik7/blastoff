# Nick's programming preferences

This guide records preferences that affect implementation. It distinguishes
what Nick asked for directly from patterns inferred across his projects.
New instructions and project-specific constraints always override this guide.
Do not apply one project's measured budgets or approval policy to every project.

## Direct requirements for Blastoff

| Area | Preference | Concrete consequence |
|---|---|---|
| Order of priorities | Fast and safe first | Protect existing data; benchmark common paths; avoid unnecessary process launches. |
| Output | Colorful output | Compact, readable human display; useful theme names and source labels. |
| Shells | Bash, Zsh and Fish completion | Ship all three and verify real completion behavior. |
| Documentation | Man page and good docs/planning | Help, man page, examples, architecture, contract, implementation plan and status. |
| Lifecycle | Install and uninstall | Versioned, explicit, per-user installation and owned-file removal. |
| Version | Versioned command/module | One release number, `--version`, changelog, package/checksum identity. |
| Parity | Bash and PowerShell do essentially the same thing | One shared core; wrappers only handle shell/runtime boundaries. |
| Storage | `~/.config/blastoff/themes` | Discover `example.toml` directly; no manual theme registration. |
| Active config | `~/.config/starship.toml` or `$STARSHIP_CONFIG` | Never move Starship into the Blastoff storage directory. |
| Listing | Local themes and `starship preset --list` | Separate source groups; preserve same-name local themes. |
| Interaction | Pretty listing, possibly fzf/gum picker | Optional interactive picker, with useful fallback. |
| Operations | Copy, save as, delete and back up | Explicit commands, collision rules, recoverable changes. |
| Modules | Save/load individual stored modules | Independent snippet directory; valid TOML and precise replacement. |
| Agent setup | Good pi planning, docs and skills | Repo instructions, workflow skills, prompts and tested handoff. |
| Architecture choice | Shared core selected in this conversation | Python 3.11+ standard library; Bash and PowerShell frontends. |

## Established preferences from earlier work

These reflect prior project requests and preserved context, rather than a new
claim about what every future project must use.

- **Native Termux first.** ARM64 Android is a real host, not a stand-in Linux
  environment. Avoid proot and keep dependencies/storage small. Validate Linux
  and native Windows separately; WSL does not establish native Windows support.
- **Fast startup and explicit measurements.** Help/version paths should avoid
  unrelated dependency discovery, services, expensive scans and network calls.
  Earlier dots budgets were project/host specific; measure Blastoff anew.
- **Modular, composable commands.** Discoverable subcommands, reusable helpers,
  clear interfaces, sensible defaults and useful diagnostics. Keep shell
  integration separate from application behavior.
- **Configuration over hardcoded personal paths.** Honor explicit environment
  overrides; show resolved paths in diagnostics. User settings should be editable.
- **Safe defaults and repeatable outcomes.** Validate inputs, preserve argument
  values, handle errors explicitly, back up changes and provide recovery.
  Avoid surprise changes to shell startup, PATH, credentials or other apps.
- **Color without breaking pipelines.** Respect `NO_COLOR`; omit escape codes,
  banners and interactive behavior from machine/forwarded output. Completion
  should not launch the application, start services or use the network.
- **Documentation that lets him verify the result.** Include exact commands,
  paths, expected output, dependency checks, limitations and recovery steps.
  Keep source/generated artifacts/help/manual/completions/release notes aligned.
- **Isolated, meaningful tests.** Temporary roots; offline fixtures; explicit
  safety boundaries; failure tests for permissions, symlinks and invalid input.
  Do not mutate the actual installation or active configuration during tests.
- **Git discipline.** Preserve unrelated changes, inspect remotes/refs, keep
  changes reviewable, and avoid force-pushing main or tags/history rewrites.
- **CLI ergonomics.** Useful help and diagnostics, completion, editor integration
  when warranted, and practical fallbacks. For future edit commands, established
  editor order is `$EDITOR`, then vim, vi, nano; do not invent an edit feature now.
- **Broad implementation comfort.** Bash/Zsh/PowerShell, Python, Go, Rust, C,
  JavaScript, Lua and other tools are familiar. Familiarity is not a requirement
  to use a particular language in every project.

## Inferred patterns, not mandatory preferences

Across dots, codex-termux, Battery and shell utilities, Nick tends to favor small,
scoped changes, automation/self-discovery, visible validation evidence and clear
separation of concerns. His CNC work suggests a preference for standards,
repeatability and root-cause fixes; this is an interpretation, not a software rule.

## Blastoff-specific visual continuity

Preserve supplied branding assets and wording. Earlier Blastoff work used
purple/pink gradients, compact terminal lettering and a rocket cutout in the O.
The supplied `b.png` is the Blastoff reference; `logo.png` says Starship and
`icon.png` is a rocket graphic. Do not mislabel Starship's wordmark as Blastoff.
The old ANSI banner is about 70 columns wide. Keep it as a reference; avoid
forcing it into narrow Termux terminals. Current human output uses purple and
magenta accents. A polished compact branded banner is a later design slice.

## Proposed engineering rules for this rebuild

The following are implementation choices made to support the preferences above:
copy-on-apply, per-file atomic replacement, checksummed backups, safe portable
names, explicit symlink conversion, cooperating-writer locks, conservative TOML
module-layout support, static completions and checksum-owned uninstallation.
Keep them reviewable; do not present them as preferences Nick explicitly stated.
