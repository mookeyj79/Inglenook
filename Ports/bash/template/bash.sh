# {{meta.name}} for the Bash completion list: {{variant.name}}.
# Source this from ~/.bashrc, after anything else that sets LS_COLORS, such as dircolors.
# Palette {{meta.version}}, {{meta.repository}}

# Readline colors the part every completion shares (colored-completion-prefix in
# bash.inputrc) from a key of its own in LS_COLORS. ls ignores that key.
# If LS_COLORS is already set, ls and the completion list keep its file colors and the
# key is added to it. If not, the completion list gets the theme's file colors, the
# same as eza's, in a shell variable that is not exported, so ls never sees it.
if [ -n "${LS_COLORS+set}" ]; then
  LS_COLORS="${LS_COLORS%:}${LS_COLORS:+:}*readline-colored-completion-prefix=38;2;{{dim|sgr}}"
else
  LS_COLORS='di=01;38;2;{{ansi.blue|sgr}}:ln=38;2;{{reference|sgr}}:ex=01;38;2;{{ansi.green|sgr}}:pi=38;2;{{heather|sgr}}:so=01;38;2;{{heather|sgr}}:do=01;38;2;{{heather|sgr}}:bd=01;38;2;{{clay|sgr}}:cd=01;38;2;{{clay|sgr}}:or=38;2;{{error|sgr}}:mi=38;2;{{error|sgr}}:su=01;38;2;{{heather|sgr}}:sg=01;38;2;{{heather|sgr}}:tw=01;04;38;2;{{ansi.blue|sgr}}:ow=01;04;38;2;{{ansi.blue|sgr}}:st=01;04;38;2;{{ansi.blue|sgr}}:*.tar=38;2;{{oxblood|sgr}}:*.tgz=38;2;{{oxblood|sgr}}:*.gz=38;2;{{oxblood|sgr}}:*.bz2=38;2;{{oxblood|sgr}}:*.xz=38;2;{{oxblood|sgr}}:*.zst=38;2;{{oxblood|sgr}}:*.zip=38;2;{{oxblood|sgr}}:*.7z=38;2;{{oxblood|sgr}}:*.rar=38;2;{{oxblood|sgr}}:*.png=38;2;{{heather|sgr}}:*.jpg=38;2;{{heather|sgr}}:*.jpeg=38;2;{{heather|sgr}}:*.gif=38;2;{{heather|sgr}}:*.webp=38;2;{{heather|sgr}}:*.svg=38;2;{{heather|sgr}}:*.bmp=38;2;{{heather|sgr}}:*.tif=38;2;{{heather|sgr}}:*.tiff=38;2;{{heather|sgr}}:*.mp4=01;38;2;{{heather|sgr}}:*.mkv=01;38;2;{{heather|sgr}}:*.webm=01;38;2;{{heather|sgr}}:*.mov=01;38;2;{{heather|sgr}}:*.avi=01;38;2;{{heather|sgr}}:*.mp3=38;2;{{dusk|sgr}}:*.m4a=38;2;{{dusk|sgr}}:*.ogg=38;2;{{dusk|sgr}}:*.opus=38;2;{{dusk|sgr}}:*.aac=38;2;{{dusk|sgr}}:*.flac=01;38;2;{{dusk|sgr}}:*.wav=01;38;2;{{dusk|sgr}}:*.alac=01;38;2;{{dusk|sgr}}:*.pdf=38;2;{{ivy|sgr}}:*.doc=38;2;{{ivy|sgr}}:*.docx=38;2;{{ivy|sgr}}:*.odt=38;2;{{ivy|sgr}}:*.epub=38;2;{{ivy|sgr}}:*.tmp=38;2;{{faint|sgr}}:*.swp=38;2;{{faint|sgr}}:*.bak=38;2;{{faint|sgr}}:*readline-colored-completion-prefix=38;2;{{dim|sgr}}'
fi
