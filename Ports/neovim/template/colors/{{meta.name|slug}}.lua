-- {{meta.name}} for Neovim: {{meta.name}} Day when 'background' is light,
-- {{meta.name}} Night when it is dark. Load it with :colorscheme {{meta.name|slug}}.
-- The highlight groups are in lua/{{meta.name|slug}}/day.lua and night.lua.
-- {{meta.name}} {{meta.version}}, {{meta.repository}}

local name = '{{meta.name|slug}}'
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
