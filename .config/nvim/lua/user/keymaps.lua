-- [[ Basic Keymaps ]]
-- NOTE: The leader key is set in user.options

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Yank/Paste from system clipboard
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

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
-- vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')
-- vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
-- vim.keymap.set('v', '<A-k>', ':m \'<-2<CR>gv=gv')
-- vim.keymap.set('v', '<A-j>', ':m \'>+1<CR>gv=gv')
-- vim.keymap.set('n', '<A-h>', '<<')
-- vim.keymap.set('n', '<A-l>', '>>')
-- vim.keymap.set('v', '<A-h>', '<gv')
-- vim.keymap.set('v', '<A-l>', '>gv')
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv")
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<C-h>', '<gv')
vim.keymap.set('v', '<C-l>', '>gv')

vim.keymap.set('n', '<Esc>', function()
  vim.cmd('noh')
end, { desc = 'Clear highlight' })

-- SECTION: Option keymaps

local settingsLeader = '<Leader>,'

vim.keymap.set('n', settingsLeader .. 'w', function()
  vim.o.wrap = not vim.o.wrap
end, { desc = 'Toggle [w]rap' })

vim.keymap.set('n', settingsLeader .. 'r', function()
  vim.wo.relativenumber = not vim.wo.relativenumber
end, { desc = 'Toggle [r]elative numbers' })

vim.keymap.set('n', settingsLeader .. 'n', function()
  vim.wo.number = not vim.wo.number
end, { desc = 'Toggle line [n]umbers' })

vim.keymap.set('n', settingsLeader .. 'm', function()
  vim.o.mouse = (vim.o.mouse == 'a') and '' or 'a'
end, { desc = 'Toggle [m]ouse' })

vim.keymap.set('n', settingsLeader .. 'd', function()
  if not vim.diagnostic.is_enabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.enable(false)
  end
end, { desc = 'Toggle [d]iagnostics' })

vim.keymap.set(
  'n',
  settingsLeader .. 'l',
  require('plugins.lint').toggle_lint,
  { desc = 'Toggle [l]inting hints' }
)

vim.keymap.set('n', settingsLeader .. 'z', function()
  local zen_exists, zen = pcall(require, 'zen-mode')
  if not zen_exists then
    return
  end
  zen.toggle()
end, { desc = 'Toggle [z]en mode' })

vim.keymap.set('n', settingsLeader .. 'e', function()
  local nvim_tree_exists, nvim_tree_api = pcall(require, 'nvim-tree.api')
  if not nvim_tree_exists then
    return
  end
  nvim_tree_api.tree.toggle({
    find_file = true,
    update_root = false,
    focus = true,
  })
end, { desc = 'Toggle Nvim Tr[e]e' })

vim.keymap.set('n', settingsLeader .. 'f', function()
  SETTINGS.format_on_save = not SETTINGS.format_on_save
end, { desc = 'Toggle [f]ormatting' })

-- NOTE: See plugins.toggleterm for terminal keymaps
-- NOTE: See plugins.harpoon for harpoon keymaps
-- NOTE: See plugins.conform for conform keymaps
-- NOTE: See plugins.markdown-preview for markdown-preview keymaps
-- NOTE: See plugins.nvim-tree for nvim-tree keymaps
-- NOTE: See plugins.leap for leap keymaps
