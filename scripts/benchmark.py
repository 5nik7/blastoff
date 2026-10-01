#!/usr/bin/env python3
"""Offline warm startup sampling in isolated storage roots."""
import argparse
import json
import os
from pathlib import Path
import platform
import shutil
import statistics
import subprocess
import sys
import tempfile
import time
ROOT = Path(__file__).resolve().parent.parent
p = argparse.ArgumentParser()
p.add_argument('--samples', type=int, default=60)
a = p.parse_args()
if not 5 <= a.samples <= 10000:
    p.error('samples must be 5–10000')
commands = {'python-version':[sys.executable,'-I',str(ROOT/'lib/blastoff.py'),'--version'], 'python-help':[sys.executable,'-I',str(ROOT/'lib/blastoff.py'),'--help']}
if shutil.which('bash'):
    commands['bash-version'] = ['bash',str(ROOT/'bin/blastoff'),'--version']
    commands['bash-help'] = ['bash',str(ROOT/'bin/blastoff'),'--help']
for entry, launcher in [('python', [sys.executable,'-I',str(ROOT/'lib/blastoff.py')]),
                        ('bash', ['bash',str(ROOT/'bin/blastoff')])]:
    if entry == 'bash' and not shutil.which('bash'):
        continue
    for label, arguments in [('current',['current','--json']),
                             ('module-list',['module','list','--json'])]:
        commands[entry+'-'+label] = launcher + arguments
if shutil.which('pwsh'):
    # A fresh shell includes host startup and module import. Document separately.
    module = str(ROOT/'powershell/blastoff.psd1').replace("'", "''")
    commands['powershell-process-version'] = ['pwsh','-NoProfile','-Command',"Import-Module '"+module+"'; blastoff --version; exit $LASTEXITCODE"]
with tempfile.TemporaryDirectory() as root:
    env = dict(os.environ, HOME=root, USERPROFILE=root, XDG_CONFIG_HOME=str(Path(root)/'xdg'), XDG_CACHE_HOME=str(Path(root)/'cache'), STARSHIP_CACHE=str(Path(root)/'starship-cache'), BLASTOFF_HOME=str(Path(root)/'store'), STARSHIP_CONFIG=str(Path(root)/'config/starship.toml'), BLASTOFF_PYTHON=sys.executable, NO_COLOR='1')
    results = {}
    for label, command in commands.items():
        samples=[]
        for i in range(a.samples+5):
            start=time.perf_counter_ns()
            subprocess.run(command,env=env,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE,check=True,timeout=10)
            elapsed=(time.perf_counter_ns()-start)/1e6
            if i>=5: samples.append(elapsed)
        values=sorted(samples)
        results[label]={'p50_ms':round(statistics.median(values),3),'p95_ms':round(values[max(0,(95*len(values)+99)//100-1)],3),'max_ms':round(max(values),3)}
    assert not (Path(root)/'store').exists()
    assert not (Path(root)/'config').exists()
print(json.dumps({'host':platform.platform(),'machine':platform.machine(),'python':platform.python_version(),'samples':a.samples,'warmups':5,'results':results},indent=2,sort_keys=True))
