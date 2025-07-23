-- Set <space> as the leader key
--  NOTE: Must happen before plugins are required (otherwise wrong leader will
--        be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set highlight on search
vim.opt.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = false

-- Enable mouse mode
vim.opt.mouse = 'a'

-- Visually indent wrapped lines
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.opt.completeopt = 'menuone,noselect'

-- NOTE: Make sure your terminal supports this
vim.opt.termguicolors = true

-- Scroll before cursor reaches bottom/top
vim.opt.scrolloff = 8

-- Default indent is 4 spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = -1 -- set equal to shiftwidth
vim.opt.expandtab = true

if not vim.g.vscode then
  -- Show columns at 81 and 101
  vim.opt.colorcolumn = '81,101'
end

-- Show unprintable characters as hex
vim.opt.display = 'lastline,msgsep,uhex'

-- Show trailing spaces and nbsp
vim.opt.list = true
vim.opt.listchars = { tab = '> ', trail = '~', nbsp = '+' }

-- Don't show e.g. INSERT in status bar
vim.opt.showmode = false

-- Enable soft wrap
vim.opt.whichwrap = '<,>,[,]'
vim.opt.wrap = true

-- Highlight current line
vim.opt.cursorline = true
