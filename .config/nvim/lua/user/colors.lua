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
      flavour = 'mocha',
      transparent_background = false,
    })
    vim.cmd.colorscheme('catppuccin')
  end
end

M.set_colors = set_catppuccin

return M
