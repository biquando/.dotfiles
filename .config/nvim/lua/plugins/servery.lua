if vim.g.vscode then return {} end

return {
  'wurli/servery.nvim',
  opts = {
    dirs = {},
    ui = {
      provider = 'telescope',
    }
  },
}
