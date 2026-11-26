-- Stages the Neovim editor scene (see run.sh). Finds its places by text, so the content
-- can change without touching this file. Sets display options only, never a color.
local FILE = 'build/lib/Contrast.psm1'
local ERROR = 'Get-Luminence'
local ERROR_MESSAGE = "The term 'Get-Luminence' is not recognized as a name of a cmdlet or function."
local SELECT_FROM = '$rgb = ' -- the selection is this line and the next, whole,
-- on lines the diff leaves alone, so the selection is not drawn over a diff line

local function find(buf, text)
  for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local at = line:find(text, 1, true)
    if at then return i - 1, at - 1 end
  end
  error('neovim-scene: "' .. text .. '" is not in ' .. FILE)
end

vim.o.number = true
vim.o.signcolumn = 'number'
vim.o.numberwidth = 3
vim.opt.diffopt:append('foldcolumn:0')
vim.o.cursorline = true
vim.o.cursorlineopt = 'number'
vim.o.showmode = true
vim.o.laststatus = 2
vim.o.guicursor = 'a:block-blinkon0'

local new = vim.api.nvim_get_current_buf()
local newwin = vim.api.nvim_get_current_win()

-- The committed copy on the left, in diff mode with the working file on the right.
vim.cmd('leftabove vnew')
local old = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(old, 0, -1, false, vim.fn.systemlist({ 'git', 'show', 'HEAD:' .. FILE }))
vim.bo[old].buftype = 'nofile'
vim.bo[old].modifiable = false
vim.api.nvim_buf_set_name(old, 'HEAD:' .. FILE)
vim.bo[old].filetype = vim.bo[new].filetype
vim.cmd('diffthis')
vim.api.nvim_set_current_win(newwin)
vim.cmd('diffthis')

-- The error, as a language server would report it.
local ns = vim.api.nvim_create_namespace('inglenook-scene')
local elnum, ecol = find(new, ERROR)
vim.diagnostic.config({ virtual_text = true, signs = true, underline = true, update_in_insert = false })
vim.diagnostic.set(ns, new, { {
  lnum = elnum, col = ecol, end_col = ecol + #ERROR,
  severity = vim.diagnostic.severity.ERROR, message = ERROR_MESSAGE, source = 'PowerShell',
} })

vim.api.nvim_create_autocmd('VimEnter', { once = true, callback = function()
  vim.schedule(function()
    vim.cmd('wincmd =')
    -- The selection. The error's message shows as virtual text: in 110 columns a float
    -- would cover the lines around it.
    local slnum, scol = find(new, SELECT_FROM)
    vim.api.nvim_win_set_cursor(newwin, { slnum + 1, scol })
    vim.api.nvim_feedkeys('Vj', 'n', false)
  end)
end })
