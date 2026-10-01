# Terminal UX — 0.1.5

Bare `blastoff`, `-h`, `--help` and nested help share the supplied
`lib/artwork/logo`: a 37-column, 13-row Braille wordmark. Its bytes remain unchanged;
the renderer applies the left-to-right purple (`101,30,255`) to pink (`255,67,191`)
gradient at display time. It fits terminals at least 37 columns wide, including
40-column Termux screens. Older artwork and `.local/logo` originals are retained
unchanged but no longer selected for the header. No logo scripts or ANSI assets
are executed/replayed. Reads are bounded to 8 KiB/16 rows and a safe character
allowlist; missing/invalid artwork cannot break help. Narrow/dumb/non-Unicode
terminals and redirected output use a compact ASCII fallback. No Nerd Font is
required; Braille patterns use ordinary Unicode terminal glyphs.

Welcome and help never discover presets, read application configuration or launch
subprocesses. Help now has task-based command groups, colored headings and names,
readable plain descriptions, and no duplicated brace-enclosed command list.
All grammar/options/descriptions/aliases remain sourced from the actual parser.
Color follows the existing policy: auto only on TTYs, NO_COLOR always wins, and
`--color always` may force ANSI when redirected. Both `-h --color always` and
`--color always -h` work, including nested help. `--json` suppresses decoration;
help remains text, while no-command JSON remains the welcome object.

Fzf shows `local:` and `preset:` choices in a bordered selector. Enter applies;
Escape/Ctrl-C cancels. **Alt-P toggles the configuration preview.** At widths
below 80 columns it is below the list; below 20 terminal rows it starts hidden.
Gum and numbered fallbacks show comparable source labels and instructions, but
have no preview pane. Missing or broken Starship still leaves locals usable.

`blastoff current` and `blastoff doctor` use compact human-readable status panels,
without repeating the large header: purple titles, pink labels and plain values.
Current shows local byte-identical matches, the config path and regular/link state.
Doctor shows runtime, paths and tool availability, not a config validation result.
Use `--json` explicitly for their unchanged machine schemas. NO_COLOR and ordinary
redirects remove color; status checks never execute tools or modify state.

## What a preview means

The pane is syntax-colored **TOML configuration**, not a rendered prompt. It
shows name/source and never runs `[custom.*].command` or theme-defined commands.
Only the installed Starship binary may be invoked, with `preset NAME` arguments,
for a preset configuration. Config/storage are never mutated by previewing.

A shipped `lib/preview.py` helper resolves beside the core under isolated Python.
Fzf receives numeric row IDs; filenames and contents never form shell commands.
Fixed interpreter/helper/session paths are shell-quoted. Preview data is sanitized
before trusted color escapes are added (including removal of terminal control,
bidi and invisible format characters). Display limits are 64 KiB, 200 lines and
512 characters per line. Local files retain the 4 MiB regular-file/symlink guard.
Preset subprocess pipe reads are bounded to 64 KiB plus a truncation byte and a
two-second deadline. The rendered session cache is capped at 16 MiB; unreadable, failed or timed-out
previews show an unavailable message, never raw subprocess diagnostics.

A private OS temporary directory caches both successful and failed previews
within one session, with Starship cache paths redirected there. Normal exit and
cancellation remove it; forced process death can leave temporary cache files.
Preview snapshots are not an authorization or validation shortcut: applying
always re-reads/validates through the existing backup/lock/symlink protections.
Ambient FZF_*/GUM_* settings and shell startup-hook variables cannot add previews,
auto-selection, bindings or listeners. The only added binding toggles the pane.

## Preview the source without changing the installed copy

```sh
cd /data/data/com.termux/files/home/repos/blastoff
bash bin/blastoff
bash bin/blastoff -h
bash bin/blastoff --help --color always
bash bin/blastoff --color always theme apply --help
NO_COLOR=1 bash bin/blastoff -h
python3 scripts/interactive_check.py --backend fzf --expect select
python3 scripts/interactive_check.py --backend fzf --expect cancel
```

The helper uses **source code and disposable alpha/beta themes**, not the live
configuration or migrated theme library. In the first run, inspect the TOML pane,
try Alt-P twice, then Enter. In the second, Ctrl-C or Escape. Expect PASS and
unchanged config/storage for cancellation. Also try `--backend gum` or
`--backend numbered` if you use those fallbacks. Running `bash bin/blastoff pick`
directly uses your normal configuration: selecting there would apply a theme.

## Human visual checks still required

For welcome/help, compare bare invocation, `-h` and `--help`. Below 37 columns
expect the compact ASCII header; at 37+ expect the supplied Braille logo with the
purple-to-pink gradient. Confirm readable glyphs/spacing and that colors reset
before descriptions. `NO_COLOR=1 bash bin/blastoff -h` should retain the fitting
logo without color; redirected help should be plain ASCII. Native PTYs check
bytes, not actual font quality.

At roughly 40 columns and again at normal width, confirm the welcome is readable,
the picker and source labels are clear, the lower/right preview layout is useful,
Alt-P works with your Android keyboard, and the cursor/echo recover after exit.
At a short terminal height, confirm Alt-P opens the initially hidden pane.
Report terminal app, dimensions, backend, clipping and keyboard issues.
Automated pseudo-terminals check behavior, not visual quality or plugin approval.
Native Windows is still deferred; its preview shell path has not been executed.

## Update the installed copy yourself

The 0.1.5 source adds the supplied gradient logo and readable current/doctor
status while retaining immutable versioned runtimes.
On native Termux, the default destination is now `$PREFIX`:

```sh
bash install.sh --dry-run
# After reviewing the scope:
bash install.sh
"$PREFIX/bin/blastoff"
```

Use `--prefix /absolute/path` for a custom destination. Public install migrates
verified legacy `~/.local` ownership when the target differs, preserving application
data. Native discovery is preferred; custom prefixes can require minimal owned
profile hooks. Linked profiles/targets are not rewritten. Review every planned
change and stop on ownership/integrity failures. Source integrity is mandatory;
only reviewed deliberate source changes warrant `bash scripts/build.sh`.

Lifecycle output groups runtime files and shows version, prefix, migration,
profile changes and activation instructions. `--color auto|always|never` and
`NO_COLOR` apply; dry-run writes nothing and runs no profiles or probes. No live
installation/update or real-profile change was performed by this documentation
update. See INSTALLATION.md for repair, removal and compatibility commands.
