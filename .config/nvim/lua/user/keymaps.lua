--[[===============]]
--[[ Basic Keymaps ]]
--[[===============]]

-- Set <space> to <nop>, because <space> is being used as leader
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Yank/Paste from system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["+d]])
vim.keymap.set({ 'n', 'v' }, '<leader>x', [["+x]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set('n', '<leader>D', [["+D]])
vim.keymap.set('n', '<leader>X', [["+X]])
vim.keymap.set({ 'n', 'v' }, '<leader>p', [["+p]])
vim.keymap.set('n', '<leader>P', [["+P]])

-- Center window on search
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Remap for dealing with soft wrap
vim.keymap.set(
  { 'n', 'v' },
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true }
)
vim.keymap.set(
  { 'n', 'v' },
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true }
)

-- Forward/backward in insert mode
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-b>', '<Left>')

-- Keep selection on indent
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Move lines up/down/left/right
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv")
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<C-h>', '<gv')
vim.keymap.set('v', '<C-l>', '>gv')

-- Use <esc> to clear search highlight
vim.keymap.set('n', '<Esc>', function()
  vim.cmd('noh')
end, { desc = 'Clear highlight' })

-- Terminal keymaps
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]])
vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]])
vim.keymap.set('t', '<C-w><C-w>', [[<C-\><C-n><C-w><esc>]])
vim.keymap.set('t', '<C-o>', [[<C-\><C-n><C-o>]])

-- Format current paragraph
vim.keymap.set('n', '<Leader>f', [[gqip]])

--[[=================]]
--[[ Setting Keymaps ]]
--[[=================]]

local settingsLeader = '<Leader>,'

local settingKeymap = function(key, desc, action)
  vim.keymap.set('n', settingsLeader .. key, action, { desc = desc })
end

settingKeymap('w', 'Toggle [w]rap', function()
  vim.o.wrap = not vim.o.wrap
end)

settingKeymap('r', 'Toggle [r]elative numbers', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end)

settingKeymap('n', 'Toggle line [n]umbers', function()
  vim.wo.number = not vim.wo.number
end)

settingKeymap('m', 'Toggle [m]ouse', function()
  vim.o.mouse = (vim.o.mouse == 'a') and '' or 'a'
end)

settingKeymap('d', 'Toggle [d]iagnostics', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end)

settingKeymap('v', 'Toggle [v]irtual text', function()
  SETTINGS.virtual_text = not SETTINGS.virtual_text
  vim.diagnostic.config({
    virtual_text = SETTINGS.virtual_text,
  })
end)


--[[==========================]]
--[[ Terminal Focusing Keymap ]]
--[[==========================]]

vim.keymap.set('n', '<C-n>', function()
  local tabpage = vim.api.nvim_get_current_tabpage()
  local local_wins = vim.api.nvim_tabpage_list_wins(tabpage)
  local found_terminal = false
  for _, win_id in ipairs(local_wins) do
    local buf_id = vim.api.nvim_win_get_buf(win_id)
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    if string.sub(buf_name, 1, 7) == 'term://' then
      vim.api.nvim_set_current_win(win_id)
      vim.cmd('startinsert')
      found_terminal = true
      break
    end
  end

  if not found_terminal then
    local buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_open_win(buf, true, { split = "right" })
    vim.fn.jobstart(vim.o.shell, { term = true })
    vim.cmd.startinsert()
  end
end)




--[[==================]]
--[[ External Keymaps ]]
--[[==================]]

-- See plugins/cmp.lua
-- See plugins/gitsigns.lua
-- See plugins/harpoon.lua
-- See plugins/lsp.lua
-- See plugins/markdownpreview.lua
-- See plugins/telescope.lua
-- See plugins/undotree.lua

-- TODO: toggle linting hints
-- TODO: toggle zen mode
-- TODO: toggle nvim tree
-- TODO: toggle format on save
