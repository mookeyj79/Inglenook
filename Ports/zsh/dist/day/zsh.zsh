# Inglenook for the Zsh line editor and completion list: Inglenook Day.
# Source this from ~/.zshrc, after anything else that sets zle_highlight or list-colors.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook

# The line editor. Colors written as #rrggbb need a terminal with 24-bit color.
#   region   text selected between the mark and the cursor
#   isearch  the match while searching history with Ctrl+R or Ctrl+S
#   paste    text just pasted, until the next key
#   suffix   a character completion adds and may take back, such as the slash after a folder
#   special  characters shown in a special way, such as ^[ for Escape
typeset -ga zle_highlight=(
  'region:bg=#e3dbc8'
  'isearch:fg=#f9fbf8,bg=#9b5a00,bold'
  'paste:bg=#dbded6'
  'suffix:fg=#49545d'
  'special:fg=#915023'
)

# The completion list, through compinit's list-colors style. File kinds and names match
# LS_COLORS for ls. The match picked in a selection menu (ma) has the same background
# as selected text.
zstyle ':completion:*:default' list-colors \
  'ma=38;2;45;55;63;48;2;227;219;200' \
  'di=01;38;2;50;104;147' \
  'ln=38;2;1;114;114' \
  'ex=01;38;2;64;113;53' \
  'pi=38;2;132;75;128' \
  'so=01;38;2;132;75;128' \
  'bd=01;38;2;145;80;35' \
  'cd=01;38;2;145;80;35' \
  'or=38;2;160;64;55' \
  'mi=38;2;160;64;55' \
  'su=01;38;2;132;75;128' \
  'sg=01;38;2;132;75;128' \
  'tw=01;04;38;2;50;104;147' \
  'ow=01;04;38;2;50;104;147' \
  'st=01;04;38;2;50;104;147' \
  'tc=38;2;73;84;93' \
  'hi=38;2;101;113;120' \
  'du=38;2;101;113;120' \
  '*.tar=38;2;126;46;57' \
  '*.tgz=38;2;126;46;57' \
  '*.gz=38;2;126;46;57' \
  '*.bz2=38;2;126;46;57' \
  '*.xz=38;2;126;46;57' \
  '*.zst=38;2;126;46;57' \
  '*.zip=38;2;126;46;57' \
  '*.7z=38;2;126;46;57' \
  '*.rar=38;2;126;46;57' \
  '*.png=38;2;132;75;128' \
  '*.jpg=38;2;132;75;128' \
  '*.jpeg=38;2;132;75;128' \
  '*.gif=38;2;132;75;128' \
  '*.webp=38;2;132;75;128' \
  '*.svg=38;2;132;75;128' \
  '*.bmp=38;2;132;75;128' \
  '*.tif=38;2;132;75;128' \
  '*.tiff=38;2;132;75;128' \
  '*.mp4=01;38;2;132;75;128' \
  '*.mkv=01;38;2;132;75;128' \
  '*.webm=01;38;2;132;75;128' \
  '*.mov=01;38;2;132;75;128' \
  '*.avi=01;38;2;132;75;128' \
  '*.mp3=38;2;94;90;154' \
  '*.m4a=38;2;94;90;154' \
  '*.ogg=38;2;94;90;154' \
  '*.opus=38;2;94;90;154' \
  '*.aac=38;2;94;90;154' \
  '*.flac=01;38;2;94;90;154' \
  '*.wav=01;38;2;94;90;154' \
  '*.alac=01;38;2;94;90;154' \
  '*.pdf=38;2;19;91;66' \
  '*.doc=38;2;19;91;66' \
  '*.docx=38;2;19;91;66' \
  '*.odt=38;2;19;91;66' \
  '*.epub=38;2;19;91;66' \
  '*.tmp=38;2;101;113;120' \
  '*.swp=38;2;101;113;120' \
  '*.bak=38;2;101;113;120'
