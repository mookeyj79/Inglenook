" Inglenook for Vim: Inglenook Day when 'background' is light,
" Inglenook Night when it is dark. Load it with :colorscheme inglenook.
" The highlight groups are in autoload/inglenook/day.vim and night.vim.
" Inglenook 0.1.1, https://github.com/mookeyj79/Inglenook

let s:name = 'inglenook'
let s:key = &background ==# 'light' ? 'day' : 'night'
if empty(globpath(&runtimepath, 'autoload/' .. s:name .. '/' .. s:key .. '.vim'))
  " Only one variant is installed: use it, and set 'background' to match.
  let s:key = s:key ==# 'day' ? 'night' : 'day'
  if empty(globpath(&runtimepath, 'autoload/' .. s:name .. '/' .. s:key .. '.vim'))
    echoerr s:name .. ': neither autoload/' .. s:name .. '/day.vim nor night.vim is installed'
    finish
  endif
  unlet! g:colors_name
  let &background = s:key ==# 'day' ? 'light' : 'dark'
endif

highlight clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name = s:name
execute 'call ' .. s:name .. '#' .. s:key .. '#load()'
