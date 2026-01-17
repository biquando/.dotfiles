if vim.g.vscode then return {} end

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  build = ':TSUpdate',
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts

  opts = {
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { },
    },
    indent = { enable = true, disable = { } },
  },
}
