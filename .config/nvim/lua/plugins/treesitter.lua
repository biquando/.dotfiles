if vim.g.vscode then return {} end

-- return {
--   'nvim-treesitter/nvim-treesitter',
--   branch = 'master',
--   build = ':TSUpdate',
--   main = 'nvim-treesitter.configs', -- Sets main module to use for opts
--
--   opts = {
--     auto_install = true,
--     highlight = {
--       enable = true,
--       additional_vim_regex_highlighting = { },
--     },
--     indent = { enable = true, disable = { } },
--   },
-- }


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
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    end
  end,
}
