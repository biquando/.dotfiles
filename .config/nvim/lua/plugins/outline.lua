if vim.g.vscode then return {} end

return {
  'hedyhli/outline.nvim',
  cmd = { 'Outline', 'OutlineOpen' },
  keys = {
    { '<leader>o', '<cmd>Outline<CR>', desc = 'Toggle outline' },
  },
  opts = {
    symbol_folding = {
      autofold_depth = false,
    },
    symbols = {
      -- icon_fetcher = function() return '' end,
      filter = { 'Constant', 'Variable', exclude=true },
      -- icons = {
      --   File = { icon = '󰈔', hl = 'Identifier' },
      --   Module = { icon = '󰆧', hl = 'Include' },
      --   Namespace = { icon = '󰅪', hl = 'Include' },
      --   Package = { icon = '󰏗', hl = 'Include' },
      --   Class = { icon = '𝓒', hl = 'Type' },
      --   Method = { icon = 'ƒ', hl = 'Function' },
      --   Property = { icon = '', hl = 'Identifier' },
      --   Field = { icon = '󰆨', hl = 'Identifier' },
      --   Constructor = { icon = '', hl = 'Special' },
      --   Enum = { icon = 'ℰ', hl = 'Type' },
      --   Interface = { icon = '󰜰', hl = 'Type' },
      --   Function = { icon = '', hl = 'Function' },
      --   Variable = { icon = '', hl = 'Constant' },
      --   Constant = { icon = '', hl = 'Constant' },
      --   String = { icon = '𝓐', hl = 'String' },
      --   Number = { icon = '#', hl = 'Number' },
      --   Boolean = { icon = '⊨', hl = 'Boolean' },
      --   Array = { icon = '󰅪', hl = 'Constant' },
      --   Object = { icon = '⦿', hl = 'Type' },
      --   Key = { icon = '🔐', hl = 'Type' },
      --   Null = { icon = 'NULL', hl = 'Type' },
      --   EnumMember = { icon = '', hl = 'Identifier' },
      --   Struct = { icon = '𝓢', hl = 'Structure' },
      --   Event = { icon = '🗲', hl = 'Type' },
      --   Operator = { icon = '+', hl = 'Identifier' },
      --   TypeParameter = { icon = '𝙏', hl = 'Identifier' },
      --   Component = { icon = '󰅴', hl = 'Function' },
      --   Fragment = { icon = '󰅴', hl = 'Constant' },
      --   TypeAlias = { icon = ' ', hl = 'Type' },
      --   Parameter = { icon = ' ', hl = 'Identifier' },
      --   StaticMethod = { icon = ' ', hl = 'Function' },
      --   Macro = { icon = ' ', hl = 'Function' },
      -- },
    }
  },
}
