if vim.g.vscode then return {} end

return {
  dir = vim.fn.stdpath('config') .. '/lua/local/poppy.nvim',
  config = function()
    local poppy = require('poppy').setup({
      menu = {
        width = 80,
      },
    })

    -- Add current file
    vim.keymap.set('n', '<leader>a', function() poppy:list():add() end)

    -- List files
    vim.keymap.set({'n', 't'}, '<C-e>', function() poppy.ui:toggle_quick_menu(poppy:list()) end)

    -- Goto file
    vim.keymap.set({'n', 't'}, '<C-h>', function() poppy:list():select(1) end)
    vim.keymap.set({'n', 't'}, '<C-j>', function() poppy:list():select(2) end)
    vim.keymap.set({'n', 't'}, '<C-k>', function() poppy:list():select(3) end)
    vim.keymap.set({'n', 't'}, '<C-l>', function() poppy:list():select(4) end)

    -- Left / right
    vim.keymap.set({'n', 't'}, '<S-h>', function() poppy:list():prev() end)
    vim.keymap.set({'n', 't'}, '<S-l>', function() poppy:list():next() end)
  end,
}
