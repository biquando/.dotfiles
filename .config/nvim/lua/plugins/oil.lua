local oil_exists, oil = pcall(require, 'oil')
if not oil_exists then
  return
end

oil.setup({
  skip_confirm_for_simple_edits = true,
  keymaps = {
    -- FIXME: it would be better to call some wrapper function instead of
    -- calling the harpoon functions directly
    ['<C-h>'] = function() oil.close(); require('harpoon.ui').nav_file(1) end,
    ['<C-j>'] = function() oil.close(); require('harpoon.ui').nav_file(2) end,
    ['<C-k>'] = function() oil.close(); require('harpoon.ui').nav_file(3) end,
    ['<C-l>'] = function() oil.close(); require('harpoon.ui').nav_file(4) end,
    ['<Esc>'] = 'actions.close',
  },
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set('n', '<leader>e', oil.toggle_float)
