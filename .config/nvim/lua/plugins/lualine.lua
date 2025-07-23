if vim.g.vscode then return {} end

return {
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      icons_enabled = false,
      theme = 'poimandres',
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_x = {
        function()
          if vim.o.expandtab then
            return 'SP ' .. vim.o.tabstop
          else
            return 'TS ' .. vim.o.tabstop
          end
        end,
        function()
          if vim.api.nvim_buf_get_name(0):find('^term://') then
            return 'Term ' .. tostring(SETTINGS.termid)
          end
          return ''
        end,
        'filetype',
      },
    },
  },
}
