return {
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      icons_enabled = false,
      theme = 'catppuccin',
      component_separators = '|',
      section_separators = '',
    },
    sections = {
      lualine_x = {
        function()
          if SETTINGS.format_on_save then
            return '󰁨'
          end
          return ''
        end,
        function()
          if vim.o.expandtab then
            return 'SP ' .. vim.o.tabstop
          else
            return 'TS ' .. vim.o.tabstop
          end
        end,
        'filetype',
      },
    },
  },
}
