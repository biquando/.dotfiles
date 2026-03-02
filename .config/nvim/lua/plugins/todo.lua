if vim.g.vscode then return {} end

return {
  'folke/todo-comments.nvim',
  event = 'VeryLazy',
  config = function()
    require('todo-comments').setup({
      signs = false,
      keywords = {
        SECTION = { icon = '#', color = 'hint' },
      },
    })
  end,
}
