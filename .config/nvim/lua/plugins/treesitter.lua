if vim.g.vscode then return {} end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local languages = {
      'c',
      'cpp',
      'latex',
      'lua',
      'python',
      'markdown',
    }
    require('nvim-treesitter').install(languages)

    for _, lang in ipairs(languages) do
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { lang },
        callback = function()
          -- Highlight
          vim.treesitter.start()

          -- Fold
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'

          -- Indent
          if lang ~= 'latex' then
            vim.bo.indentexpr = 'v:lua.require("nvim-treesitter").indentexpr()'
          end
        end,
      }
    )
    end
  end,
}
