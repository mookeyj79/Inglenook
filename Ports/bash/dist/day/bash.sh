# Inglenook for the Bash completion list: Inglenook Day.
# Source this from ~/.bashrc, after anything else that sets LS_COLORS, such as dircolors.
# Palette 0.1.1, https://github.com/mookeyj79/Inglenook

# Readline colors the part every completion shares (colored-completion-prefix in
# bash.inputrc) from a key of its own in LS_COLORS. ls ignores that key.
# If LS_COLORS is already set, ls and the completion list keep its file colors and the
# key is added to it. If not, the completion list gets the theme's file colors, the
# same as eza's, in a shell variable that is not exported, so ls never sees it.
if [ -n "${LS_COLORS+set}" ]; then
  LS_COLORS="${LS_COLORS%:}${LS_COLORS:+:}*readline-colored-completion-prefix=38;2;73;84;93"
else
  LS_COLORS='di=01;38;2;50;104;147:ln=38;2;1;114;114:ex=01;38;2;64;113;53:pi=38;2;132;75;128:so=01;38;2;132;75;128:do=01;38;2;132;75;128:bd=01;38;2;145;80;35:cd=01;38;2;145;80;35:or=38;2;160;64;55:mi=38;2;160;64;55:su=01;38;2;132;75;128:sg=01;38;2;132;75;128:tw=01;04;38;2;50;104;147:ow=01;04;38;2;50;104;147:st=01;04;38;2;50;104;147:*.tar=38;2;126;46;57:*.tgz=38;2;126;46;57:*.gz=38;2;126;46;57:*.bz2=38;2;126;46;57:*.xz=38;2;126;46;57:*.zst=38;2;126;46;57:*.zip=38;2;126;46;57:*.7z=38;2;126;46;57:*.rar=38;2;126;46;57:*.png=38;2;132;75;128:*.jpg=38;2;132;75;128:*.jpeg=38;2;132;75;128:*.gif=38;2;132;75;128:*.webp=38;2;132;75;128:*.svg=38;2;132;75;128:*.bmp=38;2;132;75;128:*.tif=38;2;132;75;128:*.tiff=38;2;132;75;128:*.mp4=01;38;2;132;75;128:*.mkv=01;38;2;132;75;128:*.webm=01;38;2;132;75;128:*.mov=01;38;2;132;75;128:*.avi=01;38;2;132;75;128:*.mp3=38;2;94;90;154:*.m4a=38;2;94;90;154:*.ogg=38;2;94;90;154:*.opus=38;2;94;90;154:*.aac=38;2;94;90;154:*.flac=01;38;2;94;90;154:*.wav=01;38;2;94;90;154:*.alac=01;38;2;94;90;154:*.pdf=38;2;19;91;66:*.doc=38;2;19;91;66:*.docx=38;2;19;91;66:*.odt=38;2;19;91;66:*.epub=38;2;19;91;66:*.tmp=38;2;101;113;120:*.swp=38;2;101;113;120:*.bak=38;2;101;113;120:*readline-colored-completion-prefix=38;2;73;84;93'
fi
