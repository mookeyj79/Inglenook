" Inglenook Day for Vim: the highlight groups of one variant.
" colors/inglenook.vim calls inglenook#day#load() when 'background' is light.
" Use it through :colorscheme inglenook, not on its own.
" Inglenook 0.1.0, https://github.com/mookeyj79/Inglenook

" Each color by name, for gVim and for 'termguicolors'.
let s:gui = {
  \ 'NONE': 'NONE',
  \ 'deeper': '#e0e2dc',
  \ 'deep': '#e9ebe5',
  \ 'base': '#f1f3ee',
  \ 'raised': '#f9fbf8',
  \ 'hover': '#dbded6',
  \ 'line': '#cfd2cb',
  \ 'faint': '#657178',
  \ 'dim': '#49545d',
  \ 'text': '#2d373f',
  \ 'steel': '#326893',
  \ 'accent': '#9b5a00',
  \ 'on_accent': '#f9fbf8',
  \ 'error': '#a04037',
  \ 'warning': '#706416',
  \ 'success': '#407135',
  \ 'info': '#326893',
  \ 'keyword': '#844b80',
  \ 'reference': '#017272',
  \ 'literal': '#915023',
  \ 'type': '#5e5a9a',
  \ 'tag': '#905560',
  \ 'accent_wash': '#e3dbc8',
  \ 'error_wash': '#e4d6d1',
  \ 'warning_wash': '#dcdccb',
  \ 'success_wash': '#d5ded0',
  \ 'steel_wash': '#d2dddf',
  \ }

" The same names as terminal color numbers, for a terminal without 'termguicolors'.
" They are exact in a terminal set to Inglenook. NONE is the terminal's own
" text or background. Colors with no terminal slot take the nearest slot by hue.
let s:cterm = {
  \ 'NONE': 'NONE',
  \ 'deeper': '15',
  \ 'deep': '15',
  \ 'base': 'NONE',
  \ 'raised': '15',
  \ 'hover': '15',
  \ 'line': '7',
  \ 'faint': '8',
  \ 'dim': '8',
  \ 'text': 'NONE',
  \ 'steel': '4',
  \ 'accent': 'NONE',
  \ 'on_accent': 'NONE',
  \ 'error': '1',
  \ 'warning': '3',
  \ 'success': '2',
  \ 'info': '4',
  \ 'keyword': '5',
  \ 'reference': '6',
  \ 'literal': '9',
  \ 'type': '12',
  \ 'tag': '13',
  \ 'accent_wash': 'NONE',
  \ 'error_wash': 'NONE',
  \ 'warning_wash': 'NONE',
  \ 'success_wash': 'NONE',
  \ 'steel_wash': 'NONE',
  \ }

" s:hi(group, fg, bg, attr, [extra]): fg and bg are names from s:gui. extra may hold
" sp (the underline color), and ctermfg, ctermbg and cterm for a terminal without
" 'termguicolors', where washes and the accent have no slot.
function! s:hi(group, fg, bg, attr, extra = {}) abort
  let sp = get(a:extra, 'sp', 'NONE')
  let cattr = s:truecolor ? a:attr : get(a:extra, 'cterm', a:attr)
  execute 'highlight' a:group
    \ 'guifg=' .. s:gui[a:fg] 'guibg=' .. s:gui[a:bg] 'guisp=' .. s:gui[sp] 'gui=' .. a:attr
    \ 'ctermfg=' .. get(a:extra, 'ctermfg', s:cterm[a:fg])
    \ 'ctermbg=' .. get(a:extra, 'ctermbg', s:cterm[a:bg])
    \ 'ctermul=' .. s:cterm[sp] 'cterm=' .. cattr
endfunction

function! inglenook#day#load() abort
  let s:truecolor = has('gui_running') || (has('termguicolors') && &termguicolors)

  " Normal first: Vim reads the others against it.
  call s:hi('Normal', 'text', 'base', 'NONE')

  " Editor surfaces and text
  call s:hi('ColorColumn', 'NONE', 'deep', 'NONE')
  call s:hi('Conceal', 'faint', 'NONE', 'NONE')
  call s:hi('Cursor', 'on_accent', 'accent', 'NONE', {'cterm': 'reverse'})
  call s:hi('lCursor', 'on_accent', 'accent', 'NONE', {'cterm': 'reverse'})
  call s:hi('CursorLine', 'NONE', 'raised', 'NONE')
  call s:hi('CursorColumn', 'NONE', 'raised', 'NONE')
  call s:hi('CursorLineNr', 'accent', 'NONE', 'bold')
  call s:hi('LineNr', 'faint', 'NONE', 'NONE')
  call s:hi('SignColumn', 'faint', 'NONE', 'NONE')
  call s:hi('FoldColumn', 'faint', 'NONE', 'NONE')
  call s:hi('Folded', 'dim', 'deep', 'NONE')
  call s:hi('NonText', 'line', 'NONE', 'NONE')
  call s:hi('EndOfBuffer', 'line', 'NONE', 'NONE')
  call s:hi('SpecialKey', 'faint', 'NONE', 'NONE')
  call s:hi('Directory', 'reference', 'NONE', 'NONE')
  call s:hi('Title', 'info', 'NONE', 'bold')
  call s:hi('MatchParen', 'accent', 'NONE', 'bold', {'cterm': 'bold,underline'})
  call s:hi('Visual', 'NONE', 'accent_wash', 'NONE', {'cterm': 'reverse'})
  call s:hi('Search', 'text', 'steel_wash', 'NONE', {'ctermfg': '4', 'cterm': 'reverse'})
  call s:hi('CurSearch', 'on_accent', 'accent', 'NONE', {'ctermfg': '4', 'cterm': 'bold,reverse'})
  call s:hi('QuickFixLine', 'NONE', 'hover', 'bold')
  call s:hi('VertSplit', 'line', 'NONE', 'NONE')

  " Status line, tabs, messages
  call s:hi('StatusLine', 'text', 'deeper', 'NONE', {'cterm': 'bold'})
  call s:hi('StatusLineNC', 'faint', 'deeper', 'NONE')
  call s:hi('TabLine', 'dim', 'deeper', 'NONE')
  call s:hi('TabLineFill', 'NONE', 'deeper', 'NONE')
  call s:hi('TabLineSel', 'accent', 'base', 'bold')
  call s:hi('TabPanel', 'dim', 'deeper', 'NONE')
  call s:hi('TabPanelFill', 'NONE', 'deeper', 'NONE')
  call s:hi('TabPanelSel', 'accent', 'base', 'bold')
  call s:hi('ToolbarLine', 'NONE', 'deeper', 'NONE')
  call s:hi('ToolbarButton', 'text', 'hover', 'bold')
  call s:hi('ModeMsg', 'text', 'NONE', 'bold')
  call s:hi('MoreMsg', 'info', 'NONE', 'NONE')
  call s:hi('Question', 'info', 'NONE', 'NONE')
  call s:hi('ErrorMsg', 'error', 'NONE', 'NONE')
  call s:hi('WarningMsg', 'warning', 'NONE', 'NONE')
  call s:hi('MessageWindow', 'text', 'raised', 'NONE')
  call s:hi('PopupNotification', 'text', 'raised', 'NONE')
  call s:hi('Terminal', 'text', 'base', 'NONE')

  " Popup menu and completion
  call s:hi('Pmenu', 'text', 'raised', 'NONE')
  call s:hi('PmenuSel', 'text', 'hover', 'bold', {'cterm': 'bold,reverse'})
  call s:hi('PmenuKind', 'type', 'raised', 'NONE')
  call s:hi('PmenuKindSel', 'type', 'hover', 'bold', {'cterm': 'bold,reverse'})
  call s:hi('PmenuExtra', 'faint', 'raised', 'NONE')
  call s:hi('PmenuExtraSel', 'faint', 'hover', 'bold', {'cterm': 'bold,reverse'})
  call s:hi('PmenuMatch', 'steel', 'raised', 'bold')
  call s:hi('PmenuMatchSel', 'on_accent', 'accent', 'bold', {'ctermfg': '4', 'cterm': 'bold,reverse'})
  call s:hi('PmenuSbar', 'NONE', 'raised', 'NONE')
  call s:hi('PmenuThumb', 'NONE', 'line', 'NONE')

  " Syntax (the groups every syntax file links to)
  call s:hi('Comment', 'faint', 'NONE', 'italic')
  call s:hi('Constant', 'keyword', 'NONE', 'NONE')
  call s:hi('String', 'success', 'NONE', 'NONE')
  call s:hi('Character', 'success', 'NONE', 'NONE')
  call s:hi('Number', 'literal', 'NONE', 'NONE')
  call s:hi('Float', 'literal', 'NONE', 'NONE')
  call s:hi('Boolean', 'keyword', 'NONE', 'NONE')
  call s:hi('Identifier', 'text', 'NONE', 'NONE')
  call s:hi('Function', 'info', 'NONE', 'NONE')
  call s:hi('Statement', 'keyword', 'NONE', 'NONE')
  call s:hi('Conditional', 'keyword', 'NONE', 'NONE')
  call s:hi('Repeat', 'keyword', 'NONE', 'NONE')
  call s:hi('Label', 'keyword', 'NONE', 'NONE')
  call s:hi('Operator', 'dim', 'NONE', 'NONE')
  call s:hi('Keyword', 'keyword', 'NONE', 'NONE')
  call s:hi('Exception', 'keyword', 'NONE', 'NONE')
  call s:hi('PreProc', 'keyword', 'NONE', 'NONE')
  call s:hi('Include', 'keyword', 'NONE', 'NONE')
  call s:hi('Define', 'keyword', 'NONE', 'NONE')
  call s:hi('Macro', 'tag', 'NONE', 'NONE')
  call s:hi('PreCondit', 'keyword', 'NONE', 'NONE')
  call s:hi('Type', 'type', 'NONE', 'NONE')
  call s:hi('StorageClass', 'keyword', 'NONE', 'NONE')
  call s:hi('Structure', 'type', 'NONE', 'NONE')
  call s:hi('Typedef', 'type', 'NONE', 'NONE')
  call s:hi('Special', 'reference', 'NONE', 'NONE')
  call s:hi('SpecialChar', 'literal', 'NONE', 'NONE')
  call s:hi('Tag', 'tag', 'NONE', 'NONE')
  call s:hi('Delimiter', 'dim', 'NONE', 'NONE')
  call s:hi('SpecialComment', 'faint', 'NONE', 'bold')
  call s:hi('Debug', 'tag', 'NONE', 'NONE')
  call s:hi('Underlined', 'reference', 'NONE', 'underline')
  call s:hi('Ignore', 'faint', 'NONE', 'NONE')
  call s:hi('Error', 'error', 'NONE', 'NONE')
  call s:hi('Todo', 'warning', 'NONE', 'bold')
  call s:hi('Added', 'success', 'NONE', 'NONE')
  call s:hi('Changed', 'warning', 'NONE', 'NONE')
  call s:hi('Removed', 'error', 'NONE', 'NONE')

  " Diff
  call s:hi('DiffAdd', 'NONE', 'success_wash', 'NONE', {'ctermfg': '2'})
  call s:hi('DiffChange', 'NONE', 'warning_wash', 'NONE', {'ctermfg': '3'})
  call s:hi('DiffDelete', 'error', 'error_wash', 'NONE')
  call s:hi('DiffText', 'NONE', 'warning_wash', 'bold,underline', {'sp': 'warning', 'ctermfg': '3'})
  call s:hi('DiffTextAdd', 'NONE', 'success_wash', 'bold,underline', {'sp': 'success', 'ctermfg': '2'})

  " Spelling
  call s:hi('SpellBad', 'NONE', 'NONE', 'undercurl', {'sp': 'error'})
  call s:hi('SpellCap', 'NONE', 'NONE', 'undercurl', {'sp': 'warning'})
  call s:hi('SpellLocal', 'NONE', 'NONE', 'undercurl', {'sp': 'info'})
  call s:hi('SpellRare', 'NONE', 'NONE', 'undercurl', {'sp': 'info'})

  " Groups that follow another. Each is cleared first, so it keeps no default attribute.
  for [group, target] in [
    \ ['CursorIM', 'Cursor'],
    \ ['VisualNOS', 'Visual'],
    \ ['IncSearch', 'CurSearch'],
    \ ['CursorLineSign', 'SignColumn'],
    \ ['CursorLineFold', 'FoldColumn'],
    \ ['StatusLineTerm', 'StatusLine'],
    \ ['StatusLineTermNC', 'StatusLineNC'],
    \ ['WildMenu', 'PmenuSel'],
    \ ['PopupSelected', 'PmenuSel'],
    \ ]
    execute 'highlight clear' group
    execute 'highlight! link' group target
  endfor

  " The built-in terminal (:terminal)
  if s:truecolor
    let g:terminal_ansi_colors = [
      \ '#2d373f', '#a04037', '#407135', '#706416',
      \ '#326893', '#844b80', '#017272', '#cfd2cb',
      \ '#657178', '#942a23', '#2d6420', '#615602',
      \ '#195a88', '#783a73', '#056262', '#f9fbf8',
      \ ]
  endif
endfunction
