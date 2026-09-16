-- Default Neovim palettes:
--  https://github.com/neovim/neovim/blob/82ea5a8aac40331579113b961b6cef88865ad5a9/src/nvim/highlight_group.c#L2957
--  https://chatgpt.com/share/6a93876e-81d4-83e8-9040-b78254b337c3


local set_default_colorscheme = function()
  -- color column := cursor line
  vim.api.nvim_set_hl(0, 'ColorColumn', { link = 'CursorLine' })

  -- float bg := normal bg
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NvimDarkGrey2' })
  vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'NvimDarkGrey2' })
end

set_default_colorscheme()

-- Set up autocmd
local group = vim.api.nvim_create_augroup('DefaultColors', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  pattern = 'default',
  callback = set_default_colorscheme,
})
