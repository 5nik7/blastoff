"""Safe preview payloads, session caching and installed helper resolution."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parent.parent

def load(name):
    spec=importlib.util.spec_from_file_location(name,ROOT/'lib'/(name+'.py'))
    mod=importlib.util.module_from_spec(spec); spec.loader.exec_module(mod); return mod

preview=load('preview')
ui=load('picker_ui')

class Preview(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(prefix="blastoff preview ' space-")
        self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)
        self.themes=self.root/'themes'; self.themes.mkdir()
        self.session=self.root/'session'; self.session.mkdir()
        self.marker=self.root/'must-not-exist'
        self.config=self.root/'active.toml'; self.config.write_bytes(b'x=1\n')
        self.doc={'choices':['local:alpha'],'themes':str(self.themes),'color':False,'starship':None}
        self.write_doc()

    def write_doc(self):
        (self.session/'choices.json').write_text(json.dumps(self.doc))

    def test_control_filter_and_configuration_only(self):
        data=('[custom.bad]\ncommand="touch '+str(self.marker)+'"\n#\x1b]52;c;evil\x07\x1b[2J\r\u202ehidden\n').encode()
        (self.themes/'alpha.toml').write_bytes(data)
        out=preview.render(str(self.session),'0')
        self.assertIn('CONFIGURATION PREVIEW',out)
        self.assertIn('Source: local',out)
        for bad in ('\x1b','\x07','\r','\u202e'):
            self.assertNotIn(bad,out)
        self.assertFalse(self.marker.exists())
        self.assertEqual(self.config.read_bytes(),b'x=1\n')
        with patch.object(preview.subprocess,'Popen',side_effect=AssertionError('local must not launch')):
            self.assertEqual(preview.render(str(self.session),'0'),out)

    def test_bounds_colors_and_untrusted_index(self):
        out=preview.format_preview('local:alpha',b'[directory]\nstyle="purple"\n'+b'# x\n'*20000,True)
        self.assertIn('\x1b[',out)
        self.assertIn('truncated',out)
        self.assertLessEqual(len(out.splitlines()),207)
        for index in ('../x','0;touch marker','-1','999999999','\u0660'):
            with self.assertRaises(ValueError): preview.render(str(self.session),index)

    @unittest.skipUnless(os.name=='posix','POSIX executable fixture')
    def test_preset_cached_bounded_and_no_commands_executed(self):
        exe=self.root/'starship'
        count=self.root/'count'
        exe.write_text('#!'+sys.executable+'\nfrom pathlib import Path\np=Path('+repr(str(count))+')\np.write_text(p.read_text()+"x" if p.exists() else "x")\nprint("[custom.bad]\\ncommand=\\\"touch '+str(self.marker)+'\\\"")\n')
        exe.chmod(0o755)
        self.doc.update(choices=['preset:alpha'],starship=str(exe)); self.write_doc()
        first=preview.render(str(self.session),'0')
        self.assertEqual(preview.render(str(self.session),'0'),first)
        self.assertEqual(count.read_text(),'x')
        self.assertFalse(self.marker.exists())
        self.assertEqual(self.config.read_bytes(),b'x=1\n')
        exe.write_text('#!'+sys.executable+'\nimport sys\nsys.stdout.buffer.write(b"x"*2000000)\n')
        data=preview.preset_bytes(str(exe),'alpha',self.session)
        self.assertEqual(len(data),preview.LIMIT+1)
        exe.write_text('#!'+sys.executable+'\nimport time\ntime.sleep(30)\n')
        with self.assertRaises(ValueError): preview.preset_bytes(str(exe),'alpha',self.session)

    @unittest.skipUnless(os.name=='posix' and shutil.which('sh'),'POSIX shell required')
    def test_preview_command_quotes_paths_and_isolated_helper(self):
        (self.themes/'alpha.toml').write_text('[directory]\nstyle="purple"\n')
        shell, command=ui.preview_command(self.session)
        import shlex
        result=subprocess.run([*shlex.split(shell),command.replace('{1}',"'0'")],capture_output=True,timeout=10)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertIn(b'CONFIGURATION PREVIEW',result.stdout)
        self.assertFalse(self.marker.exists())

    def test_layout_and_color_policy(self):
        narrow=ui.fzf_args(40,18,False,'sh -c','fixed {1}')
        self.assertIn('--color=bw',narrow)
        self.assertIn('--preview-window=down,50%,border-top,hidden,wrap',narrow)
        self.assertIn('--bind=alt-p:toggle-preview',narrow)
        wide=ui.fzf_args(100,30,True,'sh -c','fixed {1}')
        self.assertIn('--preview-window=right,55%,border-left,wrap',wide)
        self.assertTrue(any('#ff43bf' in arg for arg in wide))

    @unittest.skipUnless(os.name=='posix' and shutil.which('fzf') and shutil.which('bash'), 'native fzf and PTY required')
    def test_actual_fzf_preview_then_cancel_without_config_writes(self):
        from pty_support import terminal
        bindir=self.root/'bin'; bindir.mkdir()
        (bindir/'fzf').symlink_to(shutil.which('fzf'))
        store=self.root/'store'; (store/'themes').mkdir(parents=True)
        (store/'themes/alpha.toml').write_text('[directory]\nstyle="purple"\n')
        temp=self.root/'tmp'; temp.mkdir()
        env=dict(os.environ, HOME=str(self.root), USERPROFILE=str(self.root),
                 BLASTOFF_HOME=str(store), STARSHIP_CONFIG=str(self.config),
                 BLASTOFF_PYTHON=sys.executable, PATH=str(bindir), TMPDIR=str(temp),
                 TERM='xterm-256color', NO_COLOR='1')
        before={str(p):p.read_bytes() for p in store.rglob('*') if p.is_file()}
        for columns,rows,keys,ready,followup in [
            (50,28,b'\x03',b'CONFIGURATION PREVIEW',None),
            (40,16,b'\x1bp',b'local:alpha',(b'CONFIGURATION PREVIEW',b'\x03')),
        ]:
            code,out=terminal([shutil.which('bash'),str(ROOT/'bin/blastoff'),'pick'],env,
                              keys,ready,columns=columns,rows=rows,followup=followup)
            self.assertEqual(code,130,repr(out[-2000:]))
            self.assertIn(b'CONFIGURATION PREVIEW',out)
            self.assertEqual(self.config.read_bytes(),b'x=1\n')
            self.assertEqual(before,{str(p):p.read_bytes() for p in store.rglob('*') if p.is_file()})
            self.assertEqual(list(temp.iterdir()),[])

    def test_symlink_source_refused(self):
        try: (self.themes/'alpha.toml').symlink_to(self.config)
        except OSError: self.skipTest('symlink unavailable')
        self.assertIn('Preview unavailable',preview.render(str(self.session),'0'))
        self.assertEqual(self.config.read_bytes(),b'x=1\n')
