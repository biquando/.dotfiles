if vim.g.vscode then return {} end

return {
  'olivercederborg/poimandres.nvim',
  priority = 1000,
  event = 'VeryLazy',

  config = function()
    local function set_poimandres_highlights()
      local p = require('poimandres.palette')

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

      -- Make LSP highlights more readable
      vim.api.nvim_set_hl(0, 'LspReferenceText', { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspReferenceRead', { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspReferenceWrite', { link = 'Visual' })
      vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { link = 'Visual' })

      -- Float colors
      vim.api.nvim_set_hl(0, 'NormalFloat', { bg = p.background2 })
      vim.api.nvim_set_hl(0, 'FloatBorder', { bg = p.background2, fg = p.blueGray1 })
    end

    local group = vim.api.nvim_create_augroup('PoimandresColors', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = group,
      pattern = 'poimandres',
      callback = set_poimandres_highlights,
    })

    require('poimandres').setup()
  end
}
