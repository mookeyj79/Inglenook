# Inglenook for the Zsh line editor and completion list: Inglenook Night.
# Source this from ~/.zshrc, after anything else that sets zle_highlight or list-colors.
# Palette 0.1.0, https://github.com/mookeyj79/Inglenook

# The line editor. Colors written as #rrggbb need a terminal with 24-bit color.
#   region   text selected between the mark and the cursor
#   isearch  the match while searching history with Ctrl+R or Ctrl+S
#   paste    text just pasted, until the next key
#   suffix   a character completion adds and may take back, such as the slash after a folder
#   special  characters shown in a special way, such as ^[ for Escape
typeset -ga zle_highlight=(
  'region:bg=#463624'
  'isearch:fg=#12100e,bg=#f3a958,bold'
  'paste:bg=#312e2c'
  'suffix:fg=#b1aa9e'
  'special:fg=#da9f7c'
)

# The completion list, through compinit's list-colors style. File kinds and names match
# LS_COLORS for ls. The match picked in a selection menu (ma) has the same background
# as selected text.
zstyle ':completion:*:default' list-colors \
  'ma=38;2;209;201;188;48;2;70;54;36' \
  'di=01;38;2;137;179;216' \
  'ln=38;2;114;189;189' \
  'ex=01;38;2;145;188;136' \
  'pi=38;2;203;156;198' \
  'so=01;38;2;203;156;198' \
  'bd=01;38;2;218;159;124' \
  'cd=01;38;2;218;159;124' \
  'or=38;2;217;137;126' \
  'mi=38;2;217;137;126' \
  'su=01;38;2;203;156;198' \
  'sg=01;38;2;203;156;198' \
  'tw=01;04;38;2;137;179;216' \
  'ow=01;04;38;2;137;179;216' \
  'st=01;04;38;2;137;179;216' \
  'tc=38;2;177;170;158' \
  'hi=38;2;143;136;127' \
  'du=38;2;143;136;127' \
  '*.tar=38;2;182;111;117' \
  '*.tgz=38;2;182;111;117' \
  '*.gz=38;2;182;111;117' \
  '*.bz2=38;2;182;111;117' \
  '*.xz=38;2;182;111;117' \
  '*.zst=38;2;182;111;117' \
  '*.zip=38;2;182;111;117' \
  '*.7z=38;2;182;111;117' \
  '*.rar=38;2;182;111;117' \
  '*.png=38;2;203;156;198' \
  '*.jpg=38;2;203;156;198' \
  '*.jpeg=38;2;203;156;198' \
  '*.gif=38;2;203;156;198' \
  '*.webp=38;2;203;156;198' \
  '*.svg=38;2;203;156;198' \
  '*.bmp=38;2;203;156;198' \
  '*.tif=38;2;203;156;198' \
  '*.tiff=38;2;203;156;198' \
  '*.mp4=01;38;2;203;156;198' \
  '*.mkv=01;38;2;203;156;198' \
  '*.webm=01;38;2;203;156;198' \
  '*.mov=01;38;2;203;156;198' \
  '*.avi=01;38;2;203;156;198' \
  '*.mp3=38;2;165;165;217' \
  '*.m4a=38;2;165;165;217' \
  '*.ogg=38;2;165;165;217' \
  '*.opus=38;2;165;165;217' \
  '*.aac=38;2;165;165;217' \
  '*.flac=01;38;2;165;165;217' \
  '*.wav=01;38;2;165;165;217' \
  '*.alac=01;38;2;165;165;217' \
  '*.pdf=38;2;92;148;124' \
  '*.doc=38;2;92;148;124' \
  '*.docx=38;2;92;148;124' \
  '*.odt=38;2;92;148;124' \
  '*.epub=38;2;92;148;124' \
  '*.tmp=38;2;143;136;127' \
  '*.swp=38;2;143;136;127' \
  '*.bak=38;2;143;136;127'
