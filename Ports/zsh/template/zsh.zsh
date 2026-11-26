# {{meta.name}} for the Zsh line editor and completion list: {{variant.name}}.
# Source this from ~/.zshrc, after anything else that sets zle_highlight or list-colors.
# Palette {{meta.version}}, {{meta.repository}}

# The line editor. Colors written as #rrggbb need a terminal with 24-bit color.
#   region   text selected between the mark and the cursor
#   isearch  the match while searching history with Ctrl+R or Ctrl+S
#   paste    text just pasted, until the next key
#   suffix   a character completion adds and may take back, such as the slash after a folder
#   special  characters shown in a special way, such as ^[ for Escape
typeset -ga zle_highlight=(
  'region:bg={{accent|wash}}'
  'isearch:bg={{accent|wash}},bold'
  'paste:bg={{hover}}'
  'suffix:fg={{dim}}'
  'special:fg={{literal}}'
)

# The completion list, through compinit's list-colors style. File kinds and names match
# LS_COLORS for ls. The match picked in a selection menu (ma) has the same background
# as selected text, turned from #rrggbb into the r;g;b the list's escape codes take.
() {
  local wash={{accent|wash}}
  local pick="38;2;{{text|sgr}};48;2;$((16#${wash[2,3]}));$((16#${wash[4,5]}));$((16#${wash[6,7]}))"
  zstyle ':completion:*:default' list-colors \
    "ma=$pick" \
    'di=01;38;2;{{ansi.blue|sgr}}' \
    'ln=38;2;{{reference|sgr}}' \
    'ex=01;38;2;{{ansi.green|sgr}}' \
    'pi=38;2;{{heather|sgr}}' \
    'so=01;38;2;{{heather|sgr}}' \
    'bd=01;38;2;{{clay|sgr}}' \
    'cd=01;38;2;{{clay|sgr}}' \
    'or=38;2;{{error|sgr}}' \
    'mi=38;2;{{error|sgr}}' \
    'su=01;38;2;{{heather|sgr}}' \
    'sg=01;38;2;{{heather|sgr}}' \
    'tw=01;04;38;2;{{ansi.blue|sgr}}' \
    'ow=01;04;38;2;{{ansi.blue|sgr}}' \
    'st=01;04;38;2;{{ansi.blue|sgr}}' \
    'tc=38;2;{{dim|sgr}}' \
    'hi=38;2;{{faint|sgr}}' \
    'du=38;2;{{faint|sgr}}' \
    '*.tar=38;2;{{oxblood|sgr}}' \
    '*.tgz=38;2;{{oxblood|sgr}}' \
    '*.gz=38;2;{{oxblood|sgr}}' \
    '*.bz2=38;2;{{oxblood|sgr}}' \
    '*.xz=38;2;{{oxblood|sgr}}' \
    '*.zst=38;2;{{oxblood|sgr}}' \
    '*.zip=38;2;{{oxblood|sgr}}' \
    '*.7z=38;2;{{oxblood|sgr}}' \
    '*.rar=38;2;{{oxblood|sgr}}' \
    '*.png=38;2;{{heather|sgr}}' \
    '*.jpg=38;2;{{heather|sgr}}' \
    '*.jpeg=38;2;{{heather|sgr}}' \
    '*.gif=38;2;{{heather|sgr}}' \
    '*.webp=38;2;{{heather|sgr}}' \
    '*.svg=38;2;{{heather|sgr}}' \
    '*.bmp=38;2;{{heather|sgr}}' \
    '*.tif=38;2;{{heather|sgr}}' \
    '*.tiff=38;2;{{heather|sgr}}' \
    '*.mp4=01;38;2;{{heather|sgr}}' \
    '*.mkv=01;38;2;{{heather|sgr}}' \
    '*.webm=01;38;2;{{heather|sgr}}' \
    '*.mov=01;38;2;{{heather|sgr}}' \
    '*.avi=01;38;2;{{heather|sgr}}' \
    '*.mp3=38;2;{{dusk|sgr}}' \
    '*.m4a=38;2;{{dusk|sgr}}' \
    '*.ogg=38;2;{{dusk|sgr}}' \
    '*.opus=38;2;{{dusk|sgr}}' \
    '*.aac=38;2;{{dusk|sgr}}' \
    '*.flac=01;38;2;{{dusk|sgr}}' \
    '*.wav=01;38;2;{{dusk|sgr}}' \
    '*.alac=01;38;2;{{dusk|sgr}}' \
    '*.pdf=38;2;{{ivy|sgr}}' \
    '*.doc=38;2;{{ivy|sgr}}' \
    '*.docx=38;2;{{ivy|sgr}}' \
    '*.odt=38;2;{{ivy|sgr}}' \
    '*.epub=38;2;{{ivy|sgr}}' \
    '*.tmp=38;2;{{faint|sgr}}' \
    '*.swp=38;2;{{faint|sgr}}' \
    '*.bak=38;2;{{faint|sgr}}'
}
