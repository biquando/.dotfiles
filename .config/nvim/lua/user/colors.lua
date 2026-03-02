local M = {}

local set_poimandres = function()
  local poimandres_exists, poimandres = pcall(require, 'poimandres')
  if not poimandres_exists then
    return
  end

  local p = require('poimandres.palette')

  local color_group = vim.api.nvim_create_augroup('PoimandresColors', {})
  vim.api.nvim_create_autocmd('BufEnter', {
    callback = function()
      -- Make the color column darker
      vim.api.nvim_set_hl(0, 'ColorColumn', { bg = p.background1 })

      -- Markdown heading highlights
      vim.api.nvim_set_hl(0, 'MdH1', { bold = true, underline = true, fg = p.teal1 })
      vim.api.nvim_set_hl(0, 'MdH2', { bold = true, underline = true, fg = p.blue2 })
      vim.api.nvim_set_hl(0, 'MdH3', { bold = true, underline = true })
      vim.api.nvim_set_hl(0, '@markup.heading.1.markdown', { link = 'MdH1' })
      vim.api.nvim_set_hl(0, '@markup.heading.2.markdown', { link = 'MdH2' })
      vim.api.nvim_set_hl(0, '@markup.heading.3.markdown', { link = 'MdH3' })
      vim.api.nvim_set_hl(0, '@markup.heading.4.markdown', { link = 'MdH3' })
      vim.api.nvim_set_hl(0, '@markup.heading.5.markdown', { link = 'MdH3' })
      vim.api.nvim_set_hl(0, '@markup.heading.6.markdown', { link = 'MdH3' })

      -- Make lsp highlights more readable
      vim.api.nvim_set_hl(0, 'LspReferenceText',  { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspReferenceRead',  { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { link = 'Visual' })

      -- Float colors
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = p.background2 })
      -- vim.api.nvim_set_hl(0, 'FloatBorder', { bg = p.background2, fg = p.blueGray1 })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = p.background2, fg = p.blueGray1 })
    end,
    group = color_group,
    pattern = '*',
  })

  poimandres.setup()
  vim.cmd.colorscheme('poimandres')
end

M.set_colors = set_poimandres

return M
