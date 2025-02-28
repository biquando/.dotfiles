M = {}

local set_tokyonight = function()
  local tokyonight_exists, _ = pcall(require, 'tokyonight')
  if tokyonight_exists then
    vim.cmd.colorscheme('tokyonight-night')
  end

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
end

local set_catppuccin = function()
  local catppuccin_exists, catppuccin = pcall(require, 'catppuccin')
  if catppuccin_exists then
    catppuccin.setup({
      flavour = 'macchiato',
      transparent_background = false,
    })
    vim.cmd.colorscheme('catppuccin')
  end
end

local set_poimandres = function()
  local poimandres_exists, poimandres = pcall(require, 'poimandres')

  local color_group = vim.api.nvim_create_augroup('PoimandresColors', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    command = 'highlight ColorColumn ctermbg=0 guibg=#282c38',
    group = color_group,
    pattern = '*',
  })
  -- vim.api.nvim_create_autocmd('BufEnter', {
  --   callback = function(args)
  --     local buf = vim.bo[args.buf]
  --     local ft = buf.filetype
  --     if ft == 'markdown' then
  --       vim.cmd('TSDisable highlight')
  --     end
  --   end,
  --   group = color_group,
  --   pattern = '*'
  -- })

  if poimandres_exists then
    poimandres.setup()
    vim.cmd.colorscheme('poimandres')
  end
end

local set_default = function()
  local color_group = vim.api.nvim_create_augroup('Transparency', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    command = 'highlight Normal ctermbg=NONE guibg=NONE',
    group = color_group,
    pattern = '*',
  })

  vim.cmd.colorscheme('default')
end

M.set_colors = set_poimandres

return M
