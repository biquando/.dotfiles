return {
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
}
