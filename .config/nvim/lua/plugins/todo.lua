if vim.g.vscode then return {} end

return {
  'folke/todo-comments.nvim',
  event = 'VeryLazy',
  opts = {
    signs = false,
    keywords = {
      SECTION = { icon = '#', color = 'hint' },
    },
  }
}
