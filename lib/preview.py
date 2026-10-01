"""Read-only configuration previews. Invoked by fzf with an opaque numeric row ID."""
import importlib.util
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
sys.dont_write_bytecode = True
import tempfile
import threading
import time
import unicodedata

LIMIT = 65536
LINES = 200
TIMEOUT = 2


def clean(text):
    # Remove ALL terminal controls (including OSC/CSI introducers), bidi and
    # other invisible format characters before adding our own SGR sequences.
    return ''.join(c for c in text if c in '\n\t' or not unicodedata.category(c).startswith('C'))


def format_preview(identity, data, color):
    source, name = identity.split(':', 1)
    text = clean(data[:LIMIT].decode('utf-8', errors='replace'))
    rows = text.splitlines()
    out = ['CONFIGURATION PREVIEW', 'Name: ' + name, 'Source: ' + source,
           'TOML only; no prompt commands run.', 'Snapshot; apply re-reads the source.', '']
    # Conservative lexical coloring, not TOML validation or prompt rendering.
    token = re.compile(r'("(?:[^"\\]|\\.)*"|\x27[^\x27]*\x27|#.*$|^\s*\[.*\]|^[\w.-]+(?=\s*=))')
    for row in rows[:LINES]:
        row = row.expandtabs(4)[:512]
        if color:
            row = token.sub(lambda m: '\x1b[' + ('90' if m[0].lstrip().startswith('#') else '95' if m[0].lstrip().startswith('[') else '36') + 'm' + m[0] + '\x1b[0m', row)
        out.append(row)
    if len(data) > LIMIT or len(rows) > LINES:
        out.append('[preview truncated: 64 KiB / 200 lines]')
    return '\n'.join(out) + '\n'


def preset_bytes(executable, name, root):
    env = dict(os.environ, STARSHIP_CACHE=str(root/'starship-cache'),
               XDG_CACHE_HOME=str(root/'xdg-cache'), STARSHIP_CONFIG=str(root/'unused.toml'))
    proc = subprocess.Popen([executable, 'preset', name], stdout=subprocess.PIPE,
                            stderr=subprocess.DEVNULL, env=env)
    chunks = []
    def receive():
        chunks.append(proc.stdout.read(LIMIT+1))
    reader = threading.Thread(target=receive, daemon=True)
    deadline = time.monotonic() + TIMEOUT
    try:
        reader.start()
        reader.join(TIMEOUT)
        if reader.is_alive():
            raise ValueError('preset preview timed out (2s)')
        if chunks and len(chunks[0]) > LIMIT:
            return chunks[0]  # bounded prefix; finally terminates producer
        if proc.wait(timeout=max(0.01, deadline-time.monotonic())) != 0:
            raise ValueError('preset preview failed')
        return chunks[0] if chunks else b''
    finally:
        if proc.poll() is None:
            proc.kill()
        proc.wait()
        reader.join(timeout=TIMEOUT)
        proc.stdout.close()


def render(session, index):
    if not index.isascii() or not index.isdigit() or len(index) > 8:
        raise ValueError('invalid preview selection')
    root = Path(session)
    cache = root/(index+'.txt')
    if cache.exists():
        return cache.read_text(encoding='utf-8')
    with (root/'choices.json').open('rb') as f:
        raw = f.read(1024*1024+1)
    if len(raw) > 1024*1024:
        raise ValueError('preview inventory too large')
    doc = json.loads(raw)
    identity = doc['choices'][int(index)]
    spec = importlib.util.spec_from_file_location('preview_core', Path(__file__).with_name('blastoff.py'))
    core = importlib.util.module_from_spec(spec); spec.loader.exec_module(core)
    source, name = identity.split(':',1); core.name(name)
    try:
        if source == 'local':
            data = core.read(Path(doc['themes'])/(name+'.toml'))
        elif source == 'preset' and doc['starship']:
            data = preset_bytes(doc['starship'], name, root)
        else:
            raise ValueError('source unavailable')
        output = format_preview(identity, data, doc['color'])
    except (core.Failure, OSError, ValueError, subprocess.TimeoutExpired):
        output = 'CONFIGURATION PREVIEW\nName: '+name+'\nSource: '+source+'\nPreview unavailable (unreadable, oversized, failed or timed out).\n'
    # Bound rendered-cache storage too; no unbounded per-session accumulation.
    if sum(p.stat().st_size for p in root.glob('*.txt')) + len(output.encode('utf-8')) > 16*1024*1024:
        return output
    # Cache successful and failed previews only within this disposable session.
    with tempfile.NamedTemporaryFile(dir=root, delete=False, mode='w', encoding='utf-8') as f:
        f.write(output); tmp = f.name
    os.replace(tmp, cache)
    return output


if __name__ == '__main__':
    # fzf terminates an old preview when focus moves; clean up a preset child.
    if hasattr(signal, 'SIGTERM'):
        def interrupted(*_):
            raise KeyboardInterrupt()
        signal.signal(signal.SIGTERM, interrupted)
    try:
        print(render(sys.argv[1], sys.argv[2]), end='')
    except KeyboardInterrupt:
        pass
    except (OSError, ValueError, KeyError, IndexError):
        print('Configuration preview unavailable.')
