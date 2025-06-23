local M = {}

local set_poimandres = function()
  local poimandres_exists, poimandres = pcall(require, 'poimandres')

  local color_group = vim.api.nvim_create_augroup('PoimandresColors', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    command = 'highlight ColorColumn ctermbg=0 guibg=#282c38',
    group = color_group,
    pattern = '*',
  })

  if poimandres_exists then
    poimandres.setup()
    vim.cmd.colorscheme('poimandres')
  end
end

M.set_colors = set_poimandres

return M
