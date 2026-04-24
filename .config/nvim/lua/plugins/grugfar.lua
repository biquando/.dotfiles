if vim.g.vscode then return {} end

return {
  'MagicDuck/grug-far.nvim',
  event = 'VeryLazy',
  config = function()
    require('grug-far').setup();
  end,
}
