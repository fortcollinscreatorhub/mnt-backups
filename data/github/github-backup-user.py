#!/usr/bin/env python3

from github import Github
import github_utils
import nestedlog.api as nlapi
import os
import sys
import backup_core

with nlapi.run_python_as_block("Enumerate repositories"):
    # To create the required access token, go to https://github.com/settings/tokens
    # The following scopes required: FIXME
    gh_auth_token = os.environ.get('GITHUB_TOKEN', None)
    if not gh_auth_token:
        with open('github-token', 'rt') as f:
            gh_auth_token = f.read().strip()
    gh_auth_user = os.environ.get('GITHUB_USER', None)
    if not gh_auth_user:
        gh_auth_user = 'swarren'
    if len(sys.argv) < 2:
        raise Exception('Github user name not provided on cmdline')
    gh_username = sys.argv[1]
    if len(sys.argv) < 3:
        clone_root='backups/github'
    else:
        clone_root=sys.argv[2]

    gh = Github(gh_auth_user, gh_auth_token)
    rs = github_utils.rate_limit_start(gh)
    if gh_auth_user == gh_username:
        gh_user = gh.get_user()
    else:
        gh_user = gh.get_user(gh_username)
    repos = []
    for gh_repo in gh_user.get_repos():
        if gh_repo.owner.login != gh_username:
            continue
        repo_name = gh_username + '/' + gh_repo.name
        repo_url = gh_repo.clone_url
        if repo_url.startswith('https://github.com/'):
            repo_url = repo_url.replace('https://github.com/', 'https://' + gh_auth_user + '@github.com/')
        repos.append((repo_name, repo_url))
    re = github_utils.rate_limit_end(gh, rs)
    github_utils.rate_limit_report(re)

failed = backup_core.backup(
    clone_root=clone_root,
    repos=repos,
    askpass_result=gh_auth_token
)
if failed:
    sys.exit(1)
