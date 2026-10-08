"""Install ait-app/ait nightly into the user's Applications."""
import fcntl
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import subprocess
import tempfile

HOME = Path.home()
APPS = HOME / 'Applications'
DEST = APPS / 'Ait.app'
STATE = HOME / '.local/state/ait-update'
REPOSITORY = 'ait-app/ait'
RELEASE_API = f'https://api.github.com/repos/{REPOSITORY}/releases/tags/nightly'
REPO = f'https://github.com/{REPOSITORY}/releases/download/'


def nightly_asset(release):
    if release['draft'] or release['tag_name'] != 'nightly':
        raise RuntimeError('Unexpected nightly release')
    # Select by app, platform and archive type; nightly versions are opaque.
    candidates = [asset for asset in release['assets']
                  if re.fullmatch(r'Ait(?:-[^/\\]+)?-macos-arm64\.zip', asset['name'])]
    if len(candidates) != 1:
        raise RuntimeError('Expected exactly one Apple silicon nightly ZIP')
    asset = candidates[0]
    if asset['browser_download_url'] != f'{REPO}nightly/{asset["name"]}':
        raise RuntimeError('Unexpected nightly asset URL')
    digest = asset.get('digest', '')
    if not re.fullmatch(r'sha256:[0-9a-f]{64}', digest):
        raise RuntimeError('Missing or invalid GitHub asset checksum')
    return asset


def fetch(url, output):
    subprocess.run(['/usr/bin/curl', '--fail', '--silent', '--show-error',
                    '--location', '--proto', '=https', '--proto-redir', '=https',
                    '--retry', '3', '--connect-timeout', '30', '--max-time', '1800',
                    '--output', str(output), url], check=True)


def app_info(app):
    with (app / 'Contents/Info.plist').open('rb') as f:
        return plistlib.load(f)


def running():
    processes = subprocess.check_output(['/bin/ps', '-axo', 'command='], text=True)
    return any('/Ait.app/Contents/' in p or '/Ait desktop.app/Contents/' in p
               for p in processes.splitlines())


def main():
    if os.uname().machine != 'arm64':
        raise RuntimeError('This configuration supports Apple silicon only')
    APPS.mkdir(exist_ok=True)
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / 'lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            print('Ait update already in progress', flush=True)
            return
        with tempfile.TemporaryDirectory(prefix='.ait-update-', dir=APPS) as tmp:
            stage = Path(tmp)
            fetch(RELEASE_API, stage / 'release.json')
            release = json.loads((stage / 'release.json').read_text())
            asset = nightly_asset(release)
            name = asset['name']
            identity = {'repository': REPOSITORY, 'asset_id': asset['id'],
                        'digest': asset['digest']}
            receipt = STATE / 'installed.json'
            try:
                installed = json.loads(receipt.read_text())
            except (FileNotFoundError, json.JSONDecodeError):
                installed = None
            # Identify builds by their assets, regardless of app version changes.
            if (installed == identity and DEST.exists()
                    and app_info(DEST).get('CFBundleIdentifier') == 'dev.ait.desktop'):
                print(f'Ait nightly is current ({name})', flush=True)
                return
            if running():
                print('Ait is running; update deferred until the next check', flush=True)
                return
            assets = {a['name']: a for a in release['assets']}
            for filename in (name, 'SHA256SUMS'):
                if assets[filename]['browser_download_url'] != f'{REPO}nightly/{filename}':
                    raise RuntimeError('Unexpected upstream asset URL')
            fetch(assets['SHA256SUMS']['browser_download_url'], stage / 'SHA256SUMS')
            matches = [line.split()[0] for line in (stage / 'SHA256SUMS').read_text().splitlines()
                       if len(line.split()) == 2 and line.split()[1].lstrip('*') == name]
            if len(matches) != 1 or not re.fullmatch('[0-9a-f]{64}', matches[0]):
                raise RuntimeError('Missing or invalid upstream checksum')
            if matches[0] != asset['digest'].removeprefix('sha256:'):
                raise RuntimeError('Nightly changed during update; retry on the next check')
            print(f'Downloading Ait nightly ({name})', flush=True)
            fetch(assets[name]['browser_download_url'], stage / name)
            with (stage / name).open('rb') as f:
                digest = hashlib.file_digest(f, 'sha256').hexdigest()
            if digest != matches[0]:
                raise RuntimeError('Ait checksum mismatch; existing installation retained')
            subprocess.run(['/usr/bin/ditto', '-x', '-k', str(stage / name), str(stage / 'unpacked')], check=True)
            app = stage / 'unpacked/Ait.app'
            info = app_info(app)
            if info.get('CFBundleIdentifier') != 'dev.ait.desktop':
                raise RuntimeError('Unexpected application identity')
            subprocess.run(['/usr/bin/codesign', '--verify', '--deep', '--strict', str(app)], check=True)
            if running():
                print('Ait started during download; update deferred', flush=True)
                return
            backup = stage / 'previous.app'
            if DEST.exists():
                DEST.rename(backup)
            try:
                app.rename(DEST)
            except BaseException:
                if backup.exists():
                    backup.rename(DEST)
                raise
            subprocess.run(['/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister', '-f', str(DEST)], check=True)
            pending_receipt = STATE / 'installed.json.tmp'
            pending_receipt.write_text(json.dumps(identity) + '\n')
            pending_receipt.replace(receipt)
            print(f'Installed Ait nightly ({name}) at {DEST}', flush=True)


if __name__ == '__main__':
    main()
