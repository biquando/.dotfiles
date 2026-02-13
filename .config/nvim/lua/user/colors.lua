local M = {}

local set_poimandres = function()
  local poimandres_exists, poimandres = pcall(require, 'poimandres')
  if not poimandres_exists then
    return
  end

  local color_group = vim.api.nvim_create_augroup('PoimandresColors', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      vim.api.nvim_set_hl(0, 'ColorColumn', { bg = '#282c38' })

      -- Markdown heading highlights
      vim.api.nvim_set_hl(0, 'Title', { bold = true, underline = true, fg = '#5de4c7' })
      vim.api.nvim_set_hl(0, 'Subtitle', { bold = true, underline = true, fg = '#add7ff' })
      vim.api.nvim_set_hl(0, 'Subheading', { bold = true, underline = true })
      vim.api.nvim_set_hl(0, '@markup.heading.1.markdown', { link = 'Title' })
      vim.api.nvim_set_hl(0, '@markup.heading.2.markdown', { link = 'Subtitle' })
      vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { link = 'Subheading' })
      vim.api.nvim_set_hl(0, '@markup.heading.4.markdown', { link = 'Subheading' })
      vim.api.nvim_set_hl(0, '@markup.heading.5.markdown', { link = 'Subheading' })
      vim.api.nvim_set_hl(0, '@markup.heading.6.markdown', { link = 'Subheading' })
    end,
    group = color_group,
    pattern = '*',
  })

  poimandres.setup()
  vim.cmd.colorscheme('poimandres')
end

M.set_colors = set_poimandres

return M
