return {
  'folke/todo-comments.nvim',
  config = function()
    require('todo-comments').setup({
      signs = false,
      keywords = {
        SECTION = { icon = '#', color = 'hint' },
      },
    })
  end,
}
