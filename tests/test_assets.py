"""Optional reference branding is never a runtime dependency."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parent.parent

class OptionalAssets(unittest.TestCase):
    def test_runtime_without_any_branding_assets(self):
        with tempfile.TemporaryDirectory(prefix='blastoff-no-assets-') as directory:
            root = Path(directory)
            payload = root/'runtime'
            for name in ('lib','bin','completions'):
                shutil.copytree(ROOT/name,payload/name,ignore=shutil.ignore_patterns('__pycache__'))
            env = dict(os.environ, HOME=str(root/'home'), USERPROFILE=str(root/'home'),
                       BLASTOFF_HOME=str(root/'store'), STARSHIP_CONFIG=str(root/'config.toml'),
                       BLASTOFF_PYTHON=sys.executable, PATH='', NO_COLOR='1')
            for args in [[],['--help'],['--version'],['list'],['current'],['doctor'],
                         ['completion','bash'],['completion','zsh'],['completion','fish']]:
                p = subprocess.run([sys.executable,'-I',str(payload/'lib/blastoff.py'),*args],env=env,capture_output=True,check=False)
                self.assertEqual(p.returncode,0,p.stderr)
                self.assertNotIn(b'\x1b',p.stdout)
            self.assertFalse((payload/'lib/__pycache__').exists())
            self.assertFalse((root/'home').exists())
            self.assertFalse((root/'store').exists())
            self.assertFalse((root/'config.toml').exists())
