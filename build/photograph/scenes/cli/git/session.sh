#!/usr/bin/env bash
# Git's scene, started by the CLI scene's run.sh in its staged repo (main, one commit,
# palette.json changed). It adds a little fixed history around that, then runs real
# git commands under a staged prompt, so the port's colors are drawn by git itself.
# Fixed names and dates keep every hash, and so every take, the same.
set -euo pipefail
cd ~/Inglenook
export GIT_AUTHOR_NAME=Inglenook GIT_AUTHOR_EMAIL=inglenook@example.invalid GIT_AUTHOR_DATE='2026-11-24T12:00:00Z'
export GIT_COMMITTER_NAME=Inglenook GIT_COMMITTER_EMAIL=inglenook@example.invalid GIT_COMMITTER_DATE='2026-11-24T12:00:00Z'
export GIT_PAGER=cat

printf '# Glossary\n\n**Success**: shown in moss.\n' > GLOSSARY.md
git add GLOSSARY.md && git commit -q -m 'Add the screenshot terms to the glossary'
git tag v0.1.0
git config remote.origin.url https://example.invalid/Inglenook.git
git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
git update-ref refs/remotes/origin/main HEAD
git branch -q port/git
git branch -q -u origin/main main
printf '# Inglenook\n' > README.md
git add README.md && git commit -q -m 'Add the README'
mkdir -p docs Ports/git
printf 'Notes\n' > docs/notes.md && git add docs/notes.md
printf 'Git\n' > Ports/git/README.md

e=$'\e'
r="$e[0m" blue="$e[34m" magenta="$e[35m"
prompt() { printf '%s~/Inglenook%s on %smain%s $ %s' "$blue" "$r" "$magenta" "$r" "$1"; }
run() { prompt "$*"; printf '\n'; "$@"; }

printf '\e[H\e[2J'
run git log --oneline --decorate -3
run git status
run git diff
run git grep -n moss
run git branch -vv
prompt ''
exec sleep infinity
