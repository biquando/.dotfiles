if vim.g.vscode then return {} end

if not vim.fn.executable('npm') then
  return
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
      ':MarkdownPreview<CR>',
      { desc = '[M]ark[d]own [p]review' }
    )
  end,

  ft = { 'markdown' },
}
