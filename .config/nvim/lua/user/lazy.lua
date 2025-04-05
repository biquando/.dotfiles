local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- SECTION: Simple plugins
  { 'numToStr/Comment.nvim', config = true },
  { 'folke/which-key.nvim', config = true },
  'tpope/vim-surround',
  'tpope/vim-sleuth', -- alternative: NMAC427/guess-indent.nvim
  { 'windwp/nvim-autopairs', config = true },

  -- SECTION: LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      {
        'folke/lazydev.nvim',
        ft = 'lua',
        opts = {},
      },

      -- Java !!!
      -- 'mfussenegger/nvim-jdtls',
    },
    lazy = true,
  },

  -- SECTION: Linting
  {
    'mfussenegger/nvim-lint',
    -- See plugins/lint.lua
  },

  -- SECTION: Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Adds LSP completion capabilities
      {
        'L3MON4D3/LuaSnip',
      },
      'saadparwaiz1/cmp_luasnip',

      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    lazy = true,
  },

  -- SECTION: Gitsigns
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', 'gH', require('gitsigns').prev_hunk, {
          buffer = bufnr,
          desc = '[G]o to Previous [H]unk',
        })
        vim.keymap.set('n', 'gh', require('gitsigns').next_hunk, {
          buffer = bufnr,
          desc = '[G]o to Next [h]unk',
        })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, {
          buffer = bufnr,
          desc = '[P]review [H]unk',
        })
      end,
    },
  },

  -- SECTION: Colorscheme
  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = require('user.colors').set_colors,
    opts = {
      transparent = true,
      styles = {
        sidebars = 'transparent',
        floats = 'transparent',
      },
    },
    lazy = true,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = require('user.colors').set_colors,
    lazy = false,
  },
  {
    'olivercederborg/poimandres.nvim',
    lazy = false,
    priority = 1000,
    config = require('user.colors').set_colors,
  },

  -- SECTION: Telescope
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
    },
  },

  -- SECTION: Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  -- SECTION: Todo-comments
  {
    'folke/todo-comments.nvim',
    config = function()
      require('todo-comments').setup({
        signs = false,
        keywords = {
          SECTION = { icon = '#', color = 'hint' },
        },
      })
    end,
  },

  -- SECTION: Toggleterm
  {
    'akinsho/toggleterm.nvim',
    -- See plugins/toggleterm.lua
  },

  -- SECTION: Oil
  -- {
  --   'stevearc/oil.nvim',
  --   dependencies = { 'nvim-tree/nvim-web-devicons' },
  --   -- See plugins/oil.lua
  -- },

  -- SECTION: Fugutive & Rhubarb
  {
    'tpope/vim-fugitive',
  },
  {
    'tpope/vim-rhubarb',
    config = function()
      vim.api.nvim_create_user_command('Browse', function(opts)
        vim.fn.system({ 'open', opts.fargs[1] })
      end, { nargs = 1 })
    end,
  },

  -- SECTION: Copilot
  -- {
  --   'github/copilot.vim',
  -- config = function()
  --   vim.cmd('Copilot disable')
  -- end,
  -- },

  -- SECTION: Zen Mode
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        options = {
          number = false,
          relativenumber = false,
        },
      },
    },
    lazy = true,
  },

  -- SECTION: Headlines (for markdown)
  -- {
  --   'lukas-reineke/headlines.nvim',
  --   dependencies = 'nvim-treesitter/nvim-treesitter',
  --   config = true,
  --   ft = 'markdown',
  -- },

  --SECTION: Yazi
  ---@type LazySpec
  {
    'mikavilpas/yazi.nvim',
    event = 'VeryLazy',
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        '<leader>e',
        mode = { 'n', 'v' },
        '<cmd>Yazi<cr>',
        desc = 'Open yazi at the current file',
      },
      -- {
      --   -- Open in the current working directory
      --   "<leader>cw",
      --   "<cmd>Yazi cwd<cr>",
      --   desc = "Open the file manager in nvim's working directory",
      -- },
      -- {
      --   -- NOTE: this requires a version of yazi that includes
      --   -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
      --   "<c-up>",
      --   "<cmd>Yazi toggle<cr>",
      --   desc = "Resume the last yazi session",
      -- },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      -- keymaps = {
      --   show_help = "<f1>",
      -- },
      hooks = {
        ---@diagnostic disable-next-line: unused-local
        yazi_opened = function(_preselected_path, buffer, _config)
          vim.keymap.del('t', '<esc>', { buffer = buffer })
        end,
      },
    },
  },

  -- SECTION: Separate plugins
  require('plugins.lualine'),
  require('plugins.harpoon'),
  require('plugins.conform'),
  require('plugins.markdown-preview'),
  require('plugins.nvim-tree'),
  require('plugins.leap'),
}, {})
