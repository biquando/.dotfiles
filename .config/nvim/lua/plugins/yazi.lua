return {
  'mikavilpas/yazi.nvim',
  event = 'VeryLazy',
  keys = {
    {
      '<leader>e',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
  },

  opts = {
    open_for_directories = true,
    hooks = {
      ---@diagnostic disable-next-line: unused-local
      yazi_opened = function(_preselected_path, buffer, _config)
        -- vim.keymap.del('t', '<esc>', { buffer = true })
      end,
    },
  },
}
