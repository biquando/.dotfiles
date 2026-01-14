if vim.g.vscode then return {} end

return {
  'olivercederborg/poimandres.nvim',
  priority = 1000,
  config = require('user.colors').set_colors,
}
