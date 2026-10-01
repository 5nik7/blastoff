"""Opt-in POSIX rehearsal of a locally built ZIP; never touches a real prefix."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
import zipfile


@unittest.skipUnless(os.name == 'posix' and os.environ.get('BLASTOFF_TEST_ARCHIVE'),
                     'Set BLASTOFF_TEST_ARCHIVE to a locally built ZIP on POSIX')
class InstalledPackage(unittest.TestCase):
    def test_installed_lifecycle(self):
        with tempfile.TemporaryDirectory(prefix='blastoff-installed-') as tmp:
            root = Path(tmp)
            home = root/'home ü'
            home.mkdir()
            prefix = root/'prefix space ü'
            config = home/'config space/starship.toml'
            store = home/'storage space'
            env = dict(os.environ, HOME=str(home), USERPROFILE=str(home),
                       STARSHIP_CONFIG=str(config), BLASTOFF_HOME=str(store),
                       XDG_CONFIG_HOME=str(home/'xdg'), XDG_CACHE_HOME=str(home/'cache'),
                       STARSHIP_CACHE=str(home/'starship-cache'), NO_COLOR='1',
                       BLASTOFF_PYTHON=sys.executable)

            def run(argv, code=0, environment=None):
                result = subprocess.run([str(a) for a in argv], env=environment or env,
                                        capture_output=True, timeout=30)
                self.assertEqual(result.returncode, code, result.stderr.decode(errors='replace'))
                return result.stdout

            with zipfile.ZipFile(os.environ['BLASTOFF_TEST_ARCHIVE']) as archive:
                for name in archive.namelist():
                    self.assertFalse(Path(name).is_absolute() or '..' in Path(name).parts)
                archive.extractall(root/'source')
            source = root/'source/blastoff-rebuild'
            run([sys.executable, source/'scripts/verify.py', source])
            installer = source/'scripts/install.py'
            run([sys.executable, installer, 'install', '--prefix', prefix, '--dry-run'])
            self.assertFalse(prefix.exists())
            version = (source/'VERSION').read_text().strip()
            # Synthetic prior identity tests the immutable-version upgrade path,
            # not compatibility certification of a historical release binary.
            prior = root/'prior source'
            shutil.copytree(source, prior, ignore=shutil.ignore_patterns('__pycache__'))
            (prior/'VERSION').write_text('0.0.0\n')
            prior_core = prior/'lib/blastoff.py'
            prior_core.write_text(prior_core.read_text().replace("VERSION = '"+version+"'", "VERSION = '0.0.0'"))
            run([sys.executable, prior/'scripts/package.py', '--checksums-only'])
            run([sys.executable, prior/'scripts/install.py', 'install', '--prefix', prefix, '--yes'])
            old_core = prefix/'share/blastoff/versions/0.0.0/lib/blastoff.py'
            old_bytes = old_core.read_bytes()
            run([sys.executable, installer, 'install', '--prefix', prefix, '--yes'])
            self.assertEqual(old_core.read_bytes(), old_bytes)
            payload = prefix/'share/blastoff/versions'/version
            command = prefix/'bin/blastoff'
            self.assertTrue(os.access(command, os.X_OK))
            self.assertEqual(command.read_text().splitlines()[0], '#!'+shutil.which('bash'))
            # Installed command must not depend on the extracted source tree.
            source.rename(root/'unused source')
            self.assertIn(version.encode(), run([command, '--version']))
            default_env = dict(env)
            default_env.pop('BLASTOFF_PYTHON')
            self.assertIn(version.encode(), run([command, '--version'], environment=default_env))
            # Resolve only in this child; do not change the caller's PATH.
            lookup_env = dict(env, PATH=str(prefix/'bin')+os.pathsep+env['PATH'])
            self.assertEqual(run([shutil.which('bash'), '-c', 'command -v blastoff'],
                                 environment=lookup_env).decode().strip(), str(command))
            run([command, '--version'], code=127,
                environment=dict(env, BLASTOFF_PYTHON=str(root/'missing python')))
            doctor = json.loads(run([command, 'doctor', '--json']))
            self.assertEqual(doctor['config'], str(config))
            self.assertEqual(doctor['blastoff_home'], str(store))
            self.assertFalse(config.exists())
            self.assertFalse(store.exists())
            config.parent.mkdir(parents=True)
            original = b'[directory]\nstyle="purple"\n'
            config.write_bytes(original)
            # Both fast welcome and fzf preview helpers resolve from installed
            # siblings after the extracted source tree has been moved away.
            self.assertIn(b'BLASTOFF', run([command]).upper())
            artwork = payload/'lib/artwork/logo'
            self.assertEqual(artwork.read_bytes(), (root/'unused source/lib/artwork/logo').read_bytes())
            from pty_support import terminal
            code, screen = terminal([str(command), '-h'], dict(env, COLUMNS='60'), columns=60, rows=30)
            self.assertEqual(code, 0)
            self.assertIn('⣴⣦⣄'.encode(), screen)
            self.assertNotIn(b'{list,current', screen)
            run([command, 'theme', 'save', 'daily'])
            session = root/'preview session'; session.mkdir()
            (session/'choices.json').write_text(json.dumps({'choices':['local:daily'],
                'themes':str(store/'themes'), 'color':False, 'starship':None}))
            preview = run([sys.executable, '-I', payload/'lib/preview.py', session, '0'])
            self.assertIn(b'CONFIGURATION PREVIEW', preview)
            self.assertIn(b'purple', preview)
            self.assertEqual(config.read_bytes(), original)
            run([command, 'theme', 'copy', 'daily', 'spare'])
            run([command, 'module', 'save', 'directory', 'directory-style'])
            run([command, 'backup', 'create'])
            backups = sorted((store/'backups').glob('*.json'))
            self.assertTrue(backups)
            backup_id = backups[0].stem
            config.write_bytes(b'[directory]\nstyle="blue"\n')
            run([command, 'theme', 'apply', 'spare'])
            self.assertEqual(config.read_bytes(), original)
            run([command, 'module', 'load', 'directory-style'])
            run([command, 'backup', 'restore', backup_id])
            self.assertEqual(config.read_bytes(), original)

            locations = {
                'bash': 'share/bash-completion/completions/blastoff',
                'zsh': 'share/zsh/site-functions/_blastoff',
                'fish': 'share/fish/vendor_completions.d/blastoff.fish',
            }
            scripts = {
                'bash': ['-c', 'source "$1"; COMP_WORDS=(blastoff theme apply da); COMP_CWORD=3; _blastoff; printf "%s\\n" "${COMPREPLY[@]}"', 'check'],
                'zsh': ['-f', '-c', 'compadd() { [[ $1 == -S ]] && shift 2; print -rl -- "${(@P)2}"; }; words=(blastoff theme apply da); CURRENT=4; source "$1"; _blastoff', 'check'],
                'fish': ['--no-config', '--private', '-c', 'source $argv[1]; complete -C "blastoff theme apply da"'],
            }
            for shell, relative in locations.items():
                installed = prefix/relative
                self.assertEqual(installed.read_bytes(), (payload/'completions'/('blastoff.'+shell)).read_bytes())
                self.assertEqual(run([command, 'completion', shell]), installed.read_bytes())
                executable = shutil.which(shell)
                if executable:
                    self.assertIn(b'daily', run([executable, *scripts[shell], installed],
                                                environment=dict(env, PATH='')).splitlines())
                else:
                    print('PENDING installed completion runtime:', shell)
            manual = prefix/'share/man/man1/blastoff.1'
            self.assertEqual(manual.read_bytes(), (payload/'man/blastoff.1').read_bytes())
            if shutil.which('mandoc'):
                self.assertIn(b'blastoff', run([shutil.which('mandoc'), '-Tutf8', manual]).lower())
            else:
                print('PENDING installed man rendering: mandoc unavailable')
            sentinel = prefix/'unowned.txt'
            sentinel.write_bytes(b'keep me')
            manifest = prefix/'share/blastoff/install.json'
            owned = list(json.loads(manifest.read_bytes())['files'])
            def snapshot():
                return {str(p.relative_to(home)): hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in home.rglob('*') if p.is_file()}
            before = snapshot()
            installed_installer = payload/'scripts/install.py'
            run([sys.executable, installed_installer, 'uninstall', '--prefix', prefix, '--dry-run'])
            self.assertTrue(command.exists())
            run([sys.executable, installed_installer, 'uninstall', '--prefix', prefix, '--yes'])
            self.assertFalse(manifest.exists())
            self.assertTrue(all(not Path(p).exists() for p in owned))
            self.assertEqual(sentinel.read_bytes(), b'keep me')
            self.assertEqual(snapshot(), before)


if __name__ == '__main__':
    unittest.main()
