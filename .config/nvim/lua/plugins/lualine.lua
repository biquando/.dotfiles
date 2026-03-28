if vim.g.vscode then return {} end

return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
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
            return 'SP ' .. vim.o.shiftwidth
          else
            return 'TS ' .. vim.o.shiftwidth
          end
        end,
        function()
          if vim.api.nvim_buf_get_name(0):find('^term://') then
            return SETTINGS.termenu.latest
          end
          return ''
        end,
        'filetype',
      },
    },
  },
}
