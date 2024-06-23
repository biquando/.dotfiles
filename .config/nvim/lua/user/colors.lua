M = {}

M.set_colors = function()
  local tokyonight_exists, _ = pcall(require, 'tokyonight')
  if tokyonight_exists then
      vim.cmd.colorscheme('tokyonight-night')
  end

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
end

return M
