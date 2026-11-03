#!/usr/bin/env python3
"""Exercise the real native installer in an isolated, unprivileged root."""
import functools
import http.server
import importlib.util
import json
import os
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys
import tempfile
import threading

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('builder', HERE / 'build.py')
builder = importlib.util.module_from_spec(spec); spec.loader.exec_module(builder)
artifact = Path(sys.argv[1]).resolve()
base = json.loads((artifact / 'scripts/manifest.json').read_text())
helper = artifact / 'scripts/aym-runtime-installer'
runtime_source = Path(json.loads((artifact / 'build.json').read_text())['runtimeDirectory'])
root = Path(tempfile.mkdtemp(prefix='aym-runtime-test-')).resolve()
(root / '.aym-runtime-test-root').touch()
requests = []
class Handler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        requests.append(self.path); super().do_GET()
    def log_message(self, *_): pass
server = http.server.ThreadingHTTPServer(('127.0.0.1', 0), functools.partial(Handler, directory=str(runtime_source.parent)))
threading.Thread(target=server.serve_forever, daemon=True).start()
url = f'http://127.0.0.1:{server.server_port}/{base["runtimeID"]}.zip'

def invoke(action, manifest, test_root=root, success=True):
    p = subprocess.run([str(helper), action, str(manifest), '--test-root', str(test_root)], capture_output=True, text=True)
    if success and p.returncode: raise AssertionError(p.stderr)
    if not success and not p.returncode: raise AssertionError('Expected a rejected installation')
    return p.stdout + p.stderr

def fixture(label):
    bundle = f'AYM Runtime Test {label}.app'
    bundle_id = f'app.aymdevkit.runtime-test.{label.lower()}'
    dest = root / 'fixtures' / bundle
    shutil.copytree(artifact / 'payload' / base['appBundle'], dest, symlinks=True)
    info_path = dest / 'Contents/Info.plist'
    info = plistlib.loads(info_path.read_bytes()); info['CFBundleIdentifier'] = bundle_id; info['CFBundleDisplayName'] = bundle[:-4]
    info_path.write_bytes(plistlib.dumps(info))
    for helper_info in (dest / 'Contents/Frameworks').glob('*.app/Contents/Info.plist'):
        data = plistlib.loads(helper_info.read_bytes())
        data['CFBundleIdentifier'] = bundle_id + '.helper.' + str(abs(hash(helper_info.parent.parent.name)))
        helper_info.write_bytes(plistlib.dumps(data))
    resources = dest / 'Contents/Resources'; (resources / 'app.asar').unlink()
    app = resources / 'app'; app.mkdir()
    (app / 'package.json').write_text(json.dumps(dict(name='aym-runtime-proof-' + label.lower(), version='1.0.0', main='main.cjs')))
    profile = root / 'profiles' / label
    (app / 'main.cjs').write_text('const {app,BrowserWindow}=require("electron");\n'
        + 'app.setName(' + json.dumps(bundle[:-4]) + ');\n'
        + 'app.setPath("userData",' + json.dumps(str(profile)) + ');\n'
        + 'app.whenReady().then(()=>{const w=new BrowserWindow({show:false,width:1180,height:820,webPreferences:{sandbox:true,contextIsolation:true,nodeIntegration:false}});w.loadFile(require("node:path").join(__dirname,"dist/index.html"));});\n'
        + 'app.on("window-all-closed",()=>app.quit());\n')
    shutil.copytree(HERE.parent / 'dist', app / 'dist')
    builder.sign_tree(dest, '-')
    for name in base['frameworks']: builder.project(runtime_source / name, dest / 'Contents/Frameworks' / name)
    builder.run('codesign', '--force', '--sign', '-', dest)
    builder.run('codesign', '--verify', '--deep', '--strict', dest)
    for name in base['frameworks']: shutil.rmtree(dest / 'Contents/Frameworks' / name)
    archive = runtime_source.parent / f'{root.name}-{label}.zip'
    builder.run('ditto', '-c', '-k', '--keepParent', dest, archive)
    manifest = {**base, 'appBundle': bundle, 'bundleID': bundle_id, 'archiveURL': url,
                'appArchiveURL': f'http://127.0.0.1:{server.server_port}/{archive.name}',
                'appArchiveSHA256': builder.digest(archive), 'developmentPreview': True}
    path = root / f'manifest-{label}.json'; path.write_text(json.dumps(manifest))
    return dest, path, manifest

try:
    a, am, ma = fixture('A'); b, bm, mb = fixture('B')
    assert 'DOWNLOADED' in invoke('prepare', am)
    assert len(requests) == 1
    suite = root / 'Applications/Andy Yu'
    for source, manifest in [(a, am), (b, bm)]:
        assert 'INSTALLED' in invoke('install', manifest)
    assert 'REUSED' in invoke('prepare', bm)
    assert len(requests) == 3, 'Existing runtime caused another download'
    shared = suite / 'Runtime' / base['runtimeID']
    linked = 0
    for item in base['files']:
        if 'sha256' not in item or item['path'].split('/')[0] not in base['frameworks']: continue
        original = (shared / item['path']).stat()
        for source in [a,b]:
            projected = (suite / source.name / 'Contents/Frameworks' / item['path']).stat()
            assert (original.st_dev, original.st_ino) == (projected.st_dev, projected.st_ino)
        linked += 1
    for source in [a,b]: builder.run('codesign', '--verify', '--deep', '--strict', suite / source.name)
    badroot = root / 'bad-download'; badroot.mkdir(); (badroot / '.aym-runtime-test-root').touch()
    bad = root / 'bad.json'; bad.write_text(json.dumps({**ma, 'archiveSHA256': '0'*64}))
    assert 'checksum mismatch' in invoke('prepare', bad, badroot, success=False)
    assert not (badroot / 'Applications/Andy Yu/Runtime' / base['runtimeID']).exists()
    assert 'Test root marker missing' in invoke('prepare', am, root / 'unmarked', success=False)
    # Refuse a changed installed cache rather than treating mere existence as validity.
    receipt = next(x for x in base['files'] if 'sha256' in x and x['path'].endswith('Info.plist'))
    file = shared / receipt['path']; saved = file.read_bytes(); mode = file.stat().st_mode
    file.chmod(0o644); file.write_bytes(saved + b'\n')
    assert 'hash mismatch' in invoke('prepare', bm, success=False)
    file.write_bytes(saved); file.chmod(mode)
    assert 'VERIFIED' in invoke('verify', bm)
    before = (suite / a.name / 'Contents/MacOS/AYM DevKit').stat().st_ino
    bad_app = root / 'bad-app.json'; bad_app.write_text(json.dumps({**ma, 'appArchiveSHA256': '0'*64}))
    assert 'checksum mismatch' in invoke('install', bad_app, success=False)
    assert (suite / a.name / 'Contents/MacOS/AYM DevKit').stat().st_ino == before
    builder.run('codesign', '--verify', '--deep', '--strict', suite / a.name)
    config = dict(root=str(root), executableA=str(suite / a.name / 'Contents/MacOS/AYM DevKit'), executableB=str(suite / b.name / 'Contents/MacOS/AYM DevKit'))
    config_path = root / 'launch.json'; config_path.write_text(json.dumps(config))
    result = builder.run('node', HERE / 'test-launch.mjs', config_path)
    print(result)
    # Removing one app's projection must leave the runtime and the other app intact.
    shutil.rmtree(suite / a.name)
    assert 'VERIFIED' in invoke('verify', bm)
    builder.run('codesign', '--verify', '--deep', '--strict', suite / b.name)
    server.shutdown()
    assert 'REUSED' in invoke('prepare', bm), 'Offline runtime reuse failed'
    report = dict(root=str(root), sharedFiles=linked, initialDownloads=1, reuseDownloads=0, offlineReuse=True,
                  checksumRejection=True, appChecksumPreservesExistingInstall=True, appDownloads=2, corruptCacheRejection=True, unsafeRootRejection=True,
                  strictSignatures=True, uninstallIsolation=True, twoAppLaunch=True)
    (artifact / 'test-report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))
finally:
    server.shutdown()
