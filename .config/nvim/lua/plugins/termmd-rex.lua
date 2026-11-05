if vim.g.vscode then return {} end

return {
  dir = vim.fn.stdpath('config') .. '/lua/local/termmd-rex.nvim',
  main = 'termmd-rex',
  cmd = 'TermmdRexPreview',
  keys = {
    {
      '<leader>mdr',
      '<cmd>TermmdRexPreview<CR>',
      desc = 'Preview [m]ark[d]own with termmd in [r]ex',
    },
  },
  config = true,
}
