-- Inglenook for Neovim: Inglenook Day when 'background' is light,
-- Inglenook Night when it is dark. Load it with :colorscheme inglenook.
-- The highlight groups are in lua/inglenook/day.lua and night.lua.
-- Inglenook 0.1.0, https://github.com/mookeyj79/Inglenook

local name = 'inglenook'
local function find(key)
  return vim.api.nvim_get_runtime_file('lua/' .. name .. '/' .. key .. '.lua', false)[1]
end

local key = vim.o.background == 'light' and 'day' or 'night'
local file = find(key)
if not file then
  -- Only one variant is installed: use it, and set 'background' to match.
  key = key == 'day' and 'night' or 'day'
  file = find(key)
  if not file then
    error(name .. ': neither lua/' .. name .. '/day.lua nor night.lua is installed')
  end
  vim.g.colors_name = nil
  vim.o.background = key == 'day' and 'light' or 'dark'
end

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end
vim.g.colors_name = name
dofile(file)
