import nestedlog.api as nlapi
import os
import os.path
import subprocess
import sys
import time

_code_dir = os.path.dirname(os.path.abspath(__file__))

def _run(cmd, capture=False):
    extra_kwargs = {}
    if capture:
        extra_kwargs["stdout"] = subprocess.PIPE
    attempts = 3
    for attempt in range(attempts):
        first_attempt = (attempt == 0)
        last_attempt = (attempt == (attempts - 1))

        if not first_attempt:
            time.sleep(attempt * 5)
            retry_str = f'(retry {attempt}) '
        else:
            retry_str = ''
        print('+' + retry_str + ' '.join(cmd))

        try:
            sys.stdout.flush()
            sys.stderr.flush()
            cp = subprocess.run(
                cmd,
                stdin=subprocess.DEVNULL,
                check=True,
                **extra_kwargs)
        except subprocess.CalledProcessError as ex:
            if last_attempt:
                err_warn_str = 'ERROR'
            else:
                err_warn_str = 'WARNING'
            print(err_warn_str + ': Command failed; exit code', str(ex.returncode), file=sys.stderr)
            if last_attempt:
                raise nlapi.MarkBlockAsFailedException()
        else:
            if capture:
                return cp.stdout
            else:
                return

def _initial_clone(target_dir, repo_url):
    try:
        _run(['git', 'clone', '--mirror', repo_url, target_dir])
    except Exception as ex:
        _run(['rm', '-rf', target_dir])
        raise ex

def _head_ref_of_repo(target_dir):
    stdout = _run(['git', '-C', target_dir, 'ls-remote', '--symref', 'origin', 'HEAD'], True)
    stdout = stdout.decode('utf-8')
    for l in stdout.splitlines():
        if l.startswith('ref:'):
            return l.split()[1]
    return None

def _subsequent_fetch(target_dir, repo_url):
    _run(['git', '-C', target_dir, 'config', 'remote.origin.url', repo_url])
    _run(['git', '-C', target_dir, 'remote', 'update', '-p'])
    ref = _head_ref_of_repo(target_dir)
    if ref == None:
        print('Empty repo; skipping rest of backup operations', file=sys.stderr)
        return
    _run(['git', '-C', target_dir, 'symbolic-ref', 'HEAD', ref])
    _run(['git', '-C', target_dir, 'lfs', 'fetch', '--recent'])

def backup(clone_root, repos, askpass_result=None):
    if askpass_result:
        os.environ['GIT_ASKPASS'] = os.path.join(_code_dir, 'git-askpass.sh')
        os.environ['GIT_ASKPASS_RESULT'] = askpass_result
    def sortkey(repo):
        return (repo[0].lower(), repo[0])
    failed = False
    for repo in sorted(repos, key=sortkey):
        (repo_name, repo_url) = repo
        try:
            with nlapi.run_python_as_block(repo_name):
                target_dir = os.path.join(_code_dir, clone_root, repo_name, 'git')
                if not os.path.exists(target_dir):
                    _initial_clone(target_dir, repo_url)
                _subsequent_fetch(target_dir, repo_url)
        except nlapi.BlockFailedException:
            failed = True
    return failed
