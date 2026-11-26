# shellcheck shell=bash
# The rcfile of eza's interactive shell in the CLI/TUI scene (see stage.sh). It loads
# ~/.bashrc, grows the staged repo from run.sh into a small Inglenook checkout with
# fixed names, sizes, dates and Git states, then runs real eza and ls on it. The
# prompt is plain text, so the colors on screen are eza's and LS_COLORS' alone.
# shellcheck source=/dev/null
source ~/.bashrc
cd ~/Inglenook
export TZ=UTC
export GIT_AUTHOR_NAME=Inglenook GIT_AUTHOR_EMAIL=inglenook@example.invalid GIT_AUTHOR_DATE='2026-11-24T12:00:00Z'
export GIT_COMMITTER_NAME=Inglenook GIT_COMMITTER_EMAIL=inglenook@example.invalid GIT_COMMITTER_DATE='2026-11-24T12:00:00Z'

mkdir -p Ports/eza/dist Ports/preview build docs wallpapers
sized() { mkdir -p "$(dirname "$1")"; head -c "$2" /dev/zero | tr '\0' '#' > "$1"; }
sized README.md 3412
sized LICENSE 1069
sized Makefile 214
sized build/build.ps1 8120
sized docs/glossary.md 2210
sized Ports/eza/theme.yml 2980
sized Ports/eza/eza.sh 1320
sized Ports/preview/index.html 15360
sized wallpapers/candlelight.jpg 2482176
sized install.sh 640 && chmod 755 install.sh
printf 'dist.tar.gz\n' > .gitignore
git add -A && git commit -q -m 'Add the eza port'
sized CONTRIBUTING.md 9210
sized dist.tar.gz 1843200
echo '#' >> README.md
ln -s Ports/preview/index.html preview.html
ln -s old-theme.css theme.css
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL GIT_COMMITTER_DATE
find . -path ./.git -prune -o -exec touch -h -d '2026-11-24 12:00' {} +

PS1='~/Inglenook $ '
__scene_run() { printf '%s%s\n' "$PS1" "$1"; eval "$1"; }
printf '\e[H\e[2J'
__scene_run 'eza -l --git --icons --group-directories-first --time-style=long-iso'
__scene_run 'eza --tree --icons=always Ports'
__scene_run 'ls'
unset -f sized __scene_run
true
