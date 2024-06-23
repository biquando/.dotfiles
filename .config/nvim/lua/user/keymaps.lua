-- [[ Basic Keymaps ]]
-- NOTE: The leader key is set in user.options

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with soft wrap
vim.keymap.set({ 'n', 'v' }, 'k', "v:count == 0 ? 'gk' : 'k'",
  { expr = true, silent = true })
vim.keymap.set({ 'n', 'v' }, 'j', "v:count == 0 ? 'gj' : 'j'",
  { expr = true, silent = true })

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
vim.keymap.set('v', '<C-k>', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<C-j>', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', '<C-h>', '<gv')
vim.keymap.set('v', '<C-l>', '>gv')

-- SECTION: Option keymaps

local settingsLeader = '<C-,>'

vim.keymap.set('n', settingsLeader .. settingsLeader,
  function() vim.cmd('noh') end,
  { desc = 'Clear highlight' })

vim.keymap.set('n', settingsLeader .. 'w',
  function() vim.o.wrap = not vim.o.wrap end,
  { desc = 'Toggle [w]rap' })

vim.keymap.set('n', settingsLeader .. 'r',
  function() vim.wo.relativenumber = not vim.wo.relativenumber end,
  { desc = 'Toggle [r]elative numbers' })

vim.keymap.set('n', settingsLeader .. 'n',
  function() vim.wo.number = not vim.wo.number end,
  { desc = 'Toggle line [n]umbers' })

vim.keymap.set('n', settingsLeader .. 'm',
  function() vim.o.mouse = (vim.o.mouse == 'a') and '' or 'a' end,
  { desc = 'Toggle [m]ouse' })

vim.keymap.set('n', settingsLeader .. 'd',
  function()
    if not vim.diagnostic.is_enabled() then
      vim.diagnostic.enable()
    else
      vim.diagnostic.enable(false)
    end
  end,
  { desc = 'Toggle [d]iagnostics' })

vim.keymap.set('n', settingsLeader .. 'l',
  require('plugins.lint').toggle_lint,
  { desc = 'Toggle [l]inting hints' })


-- NOTE: See plugins.toggleterm for terminal keymaps

-- NOTE: See plugins.harpoon for harpoon keymaps
