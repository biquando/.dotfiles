if vim.g.vscode then return {} end

return {
  'esmuellert/codediff.nvim',

  cmd = 'CodeDiff',

  keys = {
    { '<leader>cd', '<cmd>CodeDiff<CR>', desc = '[c]ode[d]iff' },
  },

  opts = {
    keymaps = {
      view = {
        focus_explorer = '<leader>v',
        next_hunk = '<C-n>',
        prev_hunk = '<C-p>',
      },
    },
    explorer = {
      view_mode = 'tree',
    },
  },
}
