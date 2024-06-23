-- [[ Setting options ]]
-- See `:help vim.o`

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will
--        be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true
vim.wo.relativenumber = false

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.o.scrolloff = 8

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = -1  -- set equal to shiftwidth
vim.opt.expandtab = true

vim.opt.colorcolumn = '81,101'
vim.opt.display = 'lastline,msgsep,uhex'
vim.opt.list = true
vim.opt.listchars = { tab = '  ', trail = '~', nbsp = '+' }

vim.opt.whichwrap = '<,>,[,]'
vim.opt.wrap = true

vim.o.cursorline = true
