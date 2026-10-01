# Native terminal checks

Automated PTYs exercise real native executables, controlling terminals, keys and
exit status. They do **not** establish visual quality, touch-keyboard behavior,
or compatibility with a user's terminal/plugins. Windows remains a separate gate.
All commands below run from the repository. Nothing installs or edits live config,
profiles, PATH or reference assets.

## Automated checks

```sh
python3 -m unittest discover -s tests -p test_completions.py -v
python3 -m unittest discover -s tests -p test_shell_tty.py -v
python3 -m unittest discover -s tests -p test_picker.py -v
python3 -m unittest discover -s tests -p test_assets.py -v
```

Picker tests isolate optional tools using a **child-only** PATH in a temporary
root. They expose the actual installed fzf or gum, or neither; no executable is
installed and the caller's PATH is unchanged. PTY children restore normal SIGINT
handling rather than inherit a background launcher's ignored signal disposition.
The local Fish build creates its own temporary XDG scaffold even with
`--no-config --private -c true`; completion tests initialize that empty-shell
state first, then assert no completion-triggered changes. Shell-editor tests
use an empty child PATH and a sentinel `blastoff` function so an accidental
submitted line cannot launch an installed application.
No Starship executable is exposed in picker cancellation tests, so their byte/
directory snapshots measure Blastoff config/storage without Starship cache noise.

## Human picker check (still required)

Resize your terminal to 40 columns, then repeat at 50 columns. Run each available
backend with both outcomes:

```sh
python3 scripts/interactive_check.py --backend fzf --expect select
python3 scripts/interactive_check.py --backend fzf --expect cancel
python3 scripts/interactive_check.py --backend gum --expect select
python3 scripts/interactive_check.py --backend gum --expect cancel
python3 scripts/interactive_check.py --backend numbered --expect select
python3 scripts/interactive_check.py --backend numbered --expect cancel
```

Fzf in 0.1.1 includes a configuration-only TOML preview; Alt-P toggles it.
Confirm the pane moves below the list on narrow screens and starts hidden below
20 rows. See TERMINAL-UX.md for preview safety bounds and source/update commands.
Gum and numbered fallback have labels/instructions but no preview pane.

Select alpha or beta (number 1 or 2 in the fallback). For cancellation, repeat
with Escape and Ctrl-C in fzf/gum. In the numbered **line-oriented** menu, test
blank Enter, Escape **then Enter**, Ctrl-C, and Ctrl-D on an empty line.
The checker should print `PASS`, with child exit 0 for selection or 130 for
cancellation. Cancellation must report `config/storage unchanged=True`.
The helper checks outcomes and removes only its own temporary sandbox on exit.
It exposes no real Starship executable and does not render any prompt commands.

Report: backend/version, terminal app, column count, keys pressed, PASS/FAIL,
any clipped/unreadable labels, unexpected selection, cursor/echo problems after
exit, and whether the Android keyboard could send Escape/Ctrl-C. Screenshots are
optional; the fixtures contain no live configuration.

## Human shell completion check (still required)

From Bash or Zsh, create this disposable fixture:

```sh
repo=/data/data/com.termux/files/home/repos/blastoff
sandbox=$(mktemp -d)
mkdir -p "$sandbox/store/themes" "$sandbox/store/modules" "$sandbox/functions"
printf 'x=1\n' > "$sandbox/store/themes/alpha.toml"
printf '[directory]\nstyle="purple"\n' > "$sandbox/store/modules/compact.toml"
printf 'x=1\n' > "$sandbox/import with spaces.toml"
cp "$repo/completions/blastoff.zsh" "$sandbox/functions/_blastoff"
printf 'Sandbox: %s\n' "$sandbox"
```

Launch **one** isolated shell (exit it before choosing another):

```sh
env HOME="$sandbox" BLASTOFF_HOME="$sandbox/store" STARSHIP_CONFIG="$sandbox/active.toml" bash --noprofile --norc -i
env HOME="$sandbox" ZDOTDIR="$sandbox" BLASTOFF_HOME="$sandbox/store" STARSHIP_CONFIG="$sandbox/active.toml" zsh -f
env HOME="$sandbox" XDG_CONFIG_HOME="$sandbox/xdg" BLASTOFF_HOME="$sandbox/store" STARSHIP_CONFIG="$sandbox/active.toml" fish --no-config --private
```

Inside Bash:

```sh
source /data/data/com.termux/files/home/repos/blastoff/completions/blastoff.bash
```

Inside Zsh:

```zsh
fpath=("$HOME/functions" $fpath)
autoload -Uz compinit
compinit -D -u
```

Inside Fish:

```fish
source /data/data/com.termux/files/home/repos/blastoff/completions/blastoff.fish
```

Type these prefixes and press Tab; **do not press Enter to run them**:

- `blastoff --json th` → `theme`
- `blastoff theme --color never ap` → `apply`
- `blastoff theme apply local:al` → `local:alpha`, without duplicating `local:`
- `blastoff module load co` → `compact`
- `blastoff theme copy alpha ` → no existing-theme destination suggestion
- `blastoff theme import ` followed by the absolute sandbox path and `/imp`
  → one correctly quoted/escaped path containing spaces
- `blastoff --color ` → `auto`, `always`, `never`

Report shell/version, line before/after Tab, literal quoting inserted, unexpected
files/options, and 40/50-column readability. Use Ctrl-U to clear each trial line.
Exit to return to the original shell. Fixtures may be retained for inspection;
remove only the printed sandbox when finished. No live profile was sourced or
modified. fzf-tab/plugin integration is not covered by this clean-shell exercise.
