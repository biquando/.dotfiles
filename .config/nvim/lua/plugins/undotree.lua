if vim.g.vscode then return {} end

return {
  'jiaoshijie/undotree',
  opts = {},
  keys = { -- load the plugin only when using it's keybinding:
    { '<leader>u', function() require('undotree').toggle() end },
  },
}
