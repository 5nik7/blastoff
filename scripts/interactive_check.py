#!/usr/bin/env python3
"""Disposable human visual picker check; never uses live config or installation."""
import argparse
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backend', choices=['numbered','fzf','gum'], required=True)
    parser.add_argument('--expect', choices=['select','cancel'], required=True)
    args = parser.parse_args()
    if not sys.stdin.isatty() or not sys.stdout.isatty():
        parser.error('Run from your real terminal, not a pipe.')
    bash = shutil.which('bash')
    picker = shutil.which(args.backend) if args.backend != 'numbered' else None
    if not bash or (args.backend != 'numbered' and not picker):
        parser.error('Requested Bash/picker executable is unavailable; nothing installed.')
    root = Path(__file__).resolve().parent.parent
    with tempfile.TemporaryDirectory(prefix='blastoff-visual-') as directory:
        home = Path(directory)
        store = home/'store'; themes = store/'themes'; themes.mkdir(parents=True)
        config = home/'starship.toml'; original = b'format="$all"\n'; config.write_bytes(original)
        for name, color in [('alpha','purple'),('beta','blue')]:
            (themes/(name+'.toml')).write_text('[directory]\nstyle="'+color+'"\n')
        tools = home/'bin'; tools.mkdir()
        if picker:
            (tools/args.backend).symlink_to(picker)
        env = dict(os.environ,HOME=str(home),USERPROFILE=str(home),PATH=str(tools),
                   XDG_CONFIG_HOME=str(home/'xdg'),XDG_CACHE_HOME=str(home/'cache'),
                   STARSHIP_CACHE=str(home/'starship-cache'),STARSHIP_CONFIG=str(config),
                   BLASTOFF_HOME=str(store),BLASTOFF_PYTHON=sys.executable)
        before = {str(p.relative_to(home)):hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in [config,*themes.glob('*.toml')]}
        print('Temporary sandbox:',home)
        print('Use a 40- or 50-column terminal. Select alpha/beta, or cancel as requested.')
        print('Numbered: blank line, Escape then Enter, EOF, or Ctrl-C cancels.')
        print('fzf/gum: Escape or Ctrl-C cancels. Report clipping, key behavior, and result.')
        print('fzf: Alt-P toggles configuration preview (hidden initially below 20 rows).')
        # Wait through terminal SIGINT so the child can return cancellation status.
        import signal
        old = signal.signal(signal.SIGINT, lambda *_: None)
        try:
            code = subprocess.call([bash,str(root/'bin/blastoff'),'pick'],env=env)
        finally:
            signal.signal(signal.SIGINT,old)
        after = {str(p.relative_to(home)):hashlib.sha256(p.read_bytes()).hexdigest()
                 for p in [config,*store.rglob('*')] if p.is_file()}
        if args.expect == 'cancel':
            okay = code == 130 and before == after
        else:
            okay = code == 0 and config.read_bytes() in [p.read_bytes() for p in themes.glob('*.toml')]
        print('PASS' if okay else 'FAIL', 'exit='+str(code), 'expected='+args.expect,
              'config/storage unchanged='+str(before == after))
        return 0 if okay else 1

if __name__ == '__main__':
    raise SystemExit(main())
