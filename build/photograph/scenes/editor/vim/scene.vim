" Stages the Vim editor scene (see run.sh). Finds its places by text, so the content
" can change without touching this file. Sets display options only, never a color.
let s:file = 'build/lib/Contrast.psm1'
let s:search = 'Get-Luminance'  " every match gets the search highlight
let s:select_from = '$rgb = '   " the selection is this line and the next, whole,
" on lines the diff leaves alone, so the selection is not drawn over a diff line

function! s:find(text) abort
  let lnum = search('\V' .. escape(a:text, '\'), 'cnw')
  if lnum == 0
    throw 'vim-scene: "' .. a:text .. '" is not in ' .. s:file
  endif
  return [lnum, stridx(getline(lnum), a:text) + 1]
endfunction

set number
set signcolumn=number
set numberwidth=3
set diffopt+=foldcolumn:0
set cursorline
set cursorlineopt=number
set showmode
set laststatus=2
set noruler
set shortmess+=I

let s:newwin = win_getid()
let s:ft = &filetype

" The committed copy on the left, in diff mode with the working file on the right.
leftabove vnew
call setline(1, systemlist('git show ' .. shellescape('HEAD:' .. s:file)))
setlocal buftype=nofile nomodifiable
execute 'file' fnameescape('HEAD:' .. s:file)
let &l:filetype = s:ft
diffthis
call win_gotoid(s:newwin)
diffthis
wincmd =

" Every match of the search, as after a search the reader typed.
set hlsearch
let @/ = '\V' .. s:search

" The selection, made once Vim has drawn its first screen, so the mode message stays.
let [s:lnum, s:col] = s:find(s:select_from)
call cursor(s:lnum, s:col)
autocmd VimEnter * ++once call timer_start(200, {-> feedkeys('Vj', 'n')})
