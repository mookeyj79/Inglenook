" {{meta.name}} for Vim: {{meta.name}} Day when 'background' is light,
" {{meta.name}} Night when it is dark. Load it with :colorscheme {{meta.slug}}.
" The highlight groups are in autoload/{{meta.slug}}/day.vim and night.vim.
" {{meta.name}} {{meta.version}}, {{meta.repository}}

let s:name = '{{meta.slug}}'
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
