"""Lightweight shared CLI grammar and presentation; no application discovery."""
import argparse
import importlib.util
from pathlib import Path

class Failure(Exception):
    def __init__(self, message, code=1):
        super().__init__(message)
        self.code = code

_UI = None
def presentation():
    global _UI
    if _UI is None:
        spec = importlib.util.spec_from_file_location('blastoff_presentation', Path(__file__).with_name('welcome.py'))
        _UI = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(_UI)
    return _UI

def parser(version, color="auto", json_output=False):
    VERSION = version
    class Parser(argparse.ArgumentParser):
        def format_help(self):
            return presentation().format_help(self, VERSION, color, json_output)
        def error(self, message):
            raise Failure(message, 2)
    p = Parser(prog='blastoff', description='Starship themes and stored modules. Themes: ~/.config/blastoff/themes; active config: $STARSHIP_CONFIG or ~/.config/starship.toml.', epilog='Aliases: -l/--list = list; -t/--theme NAME = theme apply NAME; bare -t/--theme = current. Use a subcommand with --help for details.', allow_abbrev=False)
    p.add_argument('--version', action='version', version='blastoff ' + VERSION)
    p.add_argument('--json', action='store_true', help='machine-readable output (no decoration)')
    p.add_argument('--color', choices=['auto','always','never'], default='auto', help='color policy (default: auto); NO_COLOR always wins')
    p.add_argument('--force', action='store_true', help='back up and replace an existing stored file; required to delete')
    p.add_argument('--replace-link', action='store_true', help='back up and replace an active symlink; leave its target unchanged')
    subs = p.add_subparsers(dest='command')
    for cmd, desc in [('list','list local themes and Starship presets'),('current','show active config and exact theme matches'),('pick','choose and apply a theme'),('doctor','read-only paths and dependency diagnostics')]:
        subs.add_parser(cmd, help=desc, description=('Choose with fzf, gum, or a numbered menu. Requires terminal input/output; JSON is refused. Escape/Ctrl-C cancels in fzf/gum. In the numbered menu use an empty line, Escape then Enter, EOF or Ctrl-C. Cancellation returns 130 without config/storage changes. Fzf shows a safe configuration-only TOML preview; Alt-P toggles it. Narrow screens use a lower pane, short screens start with it hidden. Gum/numbered menus label sources but have no preview pane. Ambient FZF_* and GUM_* options are ignored. No theme commands are executed.' if cmd == 'pick' else None))
    t = subs.add_parser('theme', help='manage full themes').add_subparsers(dest='action', required=True)
    t.add_parser('list')
    t.add_parser('apply', description='Apply NAME (local first), local:NAME or preset:NAME to the active config. Changed content is backed up; identical content is unchanged. Use --replace-link to replace an active symlink without touching its target.').add_argument('name')
    t.add_parser('save', description='Save the active config as a local theme without changing it. Existing names refuse overwrite; --force backs up and replaces the stored file.').add_argument('name')
    cp = t.add_parser('copy', description='Copy NAME, local:NAME or preset:NAME to a local theme without applying it. Use --force for a backed-up replacement.'); cp.add_argument('source'); cp.add_argument('name')
    im = t.add_parser('import', description='Import valid UTF-8 TOML from an absolute file path without applying it. Quote paths containing spaces. Use --force for a backed-up replacement.'); im.add_argument('path'); im.add_argument('name')
    t.add_parser('delete', description='Delete a stored theme with --force after backing it up. Refuse the active config or its symlink target. Recover stored-theme backups with theme import.').add_argument('name')
    pr = subs.add_parser('preset', help='Starship built-in presets').add_subparsers(dest='action', required=True)
    pr.add_parser('list')
    pr.add_parser('apply', description='Generate a Starship preset and apply it, backing up changed active content. Requires Starship; --replace-link permits active symlink replacement.').add_argument('name')
    ps = pr.add_parser('save', description='Generate a Starship preset into a local theme without applying it. Requires Starship; --force backs up and replaces an existing destination.'); ps.add_argument('source'); ps.add_argument('name')
    mo = subs.add_parser('module', help='save/load TOML module tables').add_subparsers(dest='action', required=True)
    mo.add_parser('list')
    ms = mo.add_parser('save', description='Store an explicit TOML table and descendants, e.g. directory or custom.clock. NAME defaults to the module route with dots replaced by hyphens. Unsupported inline/dotted layouts are refused. --force backs up an existing destination.'); ms.add_argument('module'); ms.add_argument('name', nargs='?')
    mo.add_parser('load', description='Replace the saved module table and descendants in the active config, preserving unrelated settings. Back up changed active content. --replace-link permits active symlink replacement. Referenced palettes/formats must already exist.').add_argument('name')
    mo.add_parser('delete', description='Delete a stored snippet with --force after backing it up. Refuse the active config or its symlink target. Recover by inspecting/validating backup bytes and copying to a new module file.').add_argument('name')
    b = subs.add_parser('backup', help='snapshot or restore the active config').add_subparsers(dest='action', required=True)
    b.add_parser('create', description='Snapshot active config bytes, including invalid TOML for recovery.'); b.add_parser('list'); b.add_parser('restore', description='Restore a config backup ID after checksum and TOML validation; back up current content first. Stored-theme/module backups cannot be restored here. --replace-link permits active symlink replacement.').add_argument('id')
    mi = subs.add_parser('migrate', help='copy themes from an explicit legacy directory'); mi.add_argument('path')
    co = subs.add_parser('completion', help='print a static shell completion script', description='Print offline positional shell completion. Completes commands, options, local source names/prefixes, stored modules, paired backup filenames and import/migration paths. Never starts Blastoff or Starship. Preset names, destination names and module-save routes remain free text; backup candidates are unverified.'); co.add_argument('shell', choices=['bash','zsh','fish'])
    # Shared options are normalized at every command position, not redeclared.
    def help_options(parent):
        for action in parent._actions:
            if isinstance(action, argparse._SubParsersAction):
                for child in action.choices.values():
                    child.epilog = 'Global options before or after commands: --json, --color auto|always|never, --force, --replace-link. Mutating flags apply only where described. See blastoff --help.'
                    help_options(child)
    help_options(p)
    return p

def normalize(argv):
    # Global options can appear before or after subcommands. Normalize only known
    # flags; values after -- remain untouched. Legacy -t/-l use this same parser.
    opts, words = [], []
    i = 0
    while i < len(argv):
        a = argv[i]
        if a == '--':
            words.extend(argv[i:]); break
        if a in ('--json','--force','--replace-link'):
            opts.append(a)
        elif a == '--color':
            if i+1 >= len(argv):
                raise Failure('--color requires a value', 2)
            opts.extend(argv[i:i+2]); i += 1
        elif a.startswith('--color='):
            opts.append(a)
        else:
            words.append(a)
        i += 1
    if words and words[0] in ('-l','--list'):
        words[0] = 'list'
    elif words and words[0] in ('-t','--theme'):
        words = ['theme','apply', *words[1:]] if len(words)>1 else ['current']
    return opts + words

def parse(argv, version):
    words = normalize(argv)
    color, json_output = 'auto', False
    i = 0
    while i < len(words) and words[i] != '--':
        word = words[i]
        if word == '--color' and i+1 < len(words):
            i += 1
            color = words[i]
        elif word.startswith('--color='):
            color = word.split('=', 1)[1]
        elif word == '--json':
            json_output = True
        i += 1
    return parser(version, color, json_output).parse_args(words)
