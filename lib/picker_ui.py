"""Picker presentation and disposable preview-session wiring; no mutations."""
import json
import os
from pathlib import Path
import shlex
import shutil
import subprocess
import sys
import tempfile


def preview_command(root):
    args = [sys.executable, '-I', str(Path(__file__).with_name('preview.py')), str(root)]
    if os.name == 'nt':
        # A fixed PowerShell invocation, never cmd.exe interpolation of paths.
        shell = shutil.which('pwsh')
        if not shell:
            return None, None
        command = '& ' + ' '.join("'"+arg.replace("'", "''")+"'" for arg in args) + ' {1}'
        return subprocess.list2cmdline([shell, '-NoProfile', '-NonInteractive', '-Command']), command
    shell = shutil.which('sh') or shutil.which('bash')
    if not shell:
        # Termux test/launcher environments can intentionally omit PATH tools.
        for candidate in (Path(sys.executable).parent/'sh', Path('/bin/sh')):
            if candidate.is_file():
                shell = str(candidate); break
    return (shlex.join([shell, '-c']), shlex.join(args)+' {1}') if shell else (None,None)


def fzf_args(width, height, color, shell, command):
    args = ['fzf', '--prompt=Theme > ', '--height=90%', '--layout=reverse',
            '--border=rounded', '--border-label= BLASTOFF ', '--no-unicode',
            '--delimiter=\t', '--with-nth=2..',
            '--header=Enter apply | Esc/Ctrl-C cancel\nlocal: stored | preset: Starship',
            '--color=fg:#e6dcfa,bg:-1,hl:#ff43bf,fg+:#ffffff,bg+:#34204d,hl+:#ff43bf,border:#8955ff,prompt:#ff43bf,pointer:#ff43bf,header:#b08aff'
            if color else '--color=bw']
    if not color:
        args.append('--no-bold')
    if command:
        position = 'down,50%,border-top' if width < 80 else 'right,55%,border-left'
        if height < 20:
            position += ',hidden'
        args += ['--with-shell='+shell, '--preview='+command,
                 '--preview-window='+position+',wrap', '--bind=alt-p:toggle-preview',
                 '--header=Enter apply | Esc/Ctrl-C cancel\nAlt-P preview | local: / preset:']
    return args


def choose_fzf(values, themes, color, env):
    size = shutil.get_terminal_size((80,24))
    with tempfile.TemporaryDirectory(prefix='blastoff-preview-') as tmp:
        root = Path(tmp)
        doc = {'choices':values, 'themes':str(themes), 'color':color,
               'starship':shutil.which('starship')}
        (root/'choices.json').write_text(json.dumps(doc), encoding='utf-8')
        shell, command = preview_command(root)
        # Shell startup hooks must not sneak commands into the fixed preview.
        env = {k:v for k,v in env.items() if k not in ('BASH_ENV','ENV','ZDOTDIR')}
        proc = subprocess.run(fzf_args(size.columns,size.lines,color,shell,command),
                              input=''.join(str(i)+'\t'+v+'\n' for i,v in enumerate(values)),
                              text=True, stdout=subprocess.PIPE, env=env)
        selected = proc.stdout.rstrip('\r\n')
        if proc.returncode or '\t' not in selected:
            return None
        index, value = selected.split('\t',1)
        if not index.isascii() or not index.isdigit() or len(index)>8:
            return None
        n = int(index)
        return value if n<len(values) and values[n]==value else None
