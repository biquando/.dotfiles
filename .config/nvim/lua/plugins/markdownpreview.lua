if vim.g.vscode then return {} end

if vim.fn.executable('npm') == 0 then
  return {}
end

return {
  'iamcco/markdown-preview.nvim',

  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },

  build = 'cd app && npm install',

  init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
    vim.g.mkdp_auto_close = 0
  end,

  config = function()
    vim.keymap.set(
      'n',
      '<Leader>mdp',
      '<cmd>MarkdownPreview<CR>',
      { desc = '[m]ark[d]own [p]review' }
    )
  end,

  ft = { 'markdown' },
}
