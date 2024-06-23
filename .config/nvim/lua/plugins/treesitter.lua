local treesitter_exists, _ = pcall(require, 'nvim-treesitter')
if not treesitter_exists then
  return
end

-- [[ Configure Treesitter ]]
---@diagnostic disable: missing-fields
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'bash',
    'c',
    'cpp',
    'fish',
    'go',
    'haskell',
    'javascript',
    'lua',
    'markdown',
    'python',
    'rust',
    'tsx',
    'typescript',
    'vimdoc',
    'vim',
  },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Autoinstall languages that are not installed.
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = {},

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    -- keymaps = {
    --   init_selection = '<c-space>',
    --   node_incremental = '<c-space>',
    --   scope_incremental = '<c-s>',
    --   node_decremental = '<M-space>',
    -- },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Jump forward to textobj, similar to targets.vim
      -- keymaps = {
      --   -- You can use the capture groups defined in textobjects.scm
      --   ['aa'] = '@parameter.outer',
      --   ['ia'] = '@parameter.inner',
      --   ['af'] = '@function.outer',
      --   ['if'] = '@function.inner',
      --   ['ac'] = '@class.outer',
      --   ['ic'] = '@class.inner',
      -- },
    },
    -- move = {
    --   enable = true,
    --   set_jumps = true, -- whether to set jumps in the jumplist
    --   goto_next_start = {
    --     [']m'] = '@function.outer',
    --     [']]'] = '@class.outer',
    --   },
    --   goto_next_end = {
    --     [']M'] = '@function.outer',
    --     [']['] = '@class.outer',
    --   },
    --   goto_previous_start = {
    --     ['[m'] = '@function.outer',
    --     ['[['] = '@class.outer',
    --   },
    --   goto_previous_end = {
    --     ['[M'] = '@function.outer',
    --     ['[]'] = '@class.outer',
    --   },
    -- },
    -- swap = {
    --   enable = true,
    --   swap_next = {
    --     ['<leader>a'] = '@parameter.inner',
    --   },
    --   swap_previous = {
    --     ['<leader>A'] = '@parameter.inner',
    --   },
    -- },
  },
}

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev,
--   { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next,
--   { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float,
--   { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist,
--   { desc = 'Open diagnostics list' })
