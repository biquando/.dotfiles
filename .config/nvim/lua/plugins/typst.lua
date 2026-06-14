return {
  'chomosuke/typst-preview.nvim',
  ft = 'typst',
  version = '1.*',
  config = function()
    require('typst-preview').setup({
      invert_colors = '{"rest": "auto","image": "never"}',
    })

    vim.keymap.set(
      'n',
      '<Leader>typ',
      '<cmd>TypstPreview<CR>',
      { desc = '[ty]pst [p]review' }
    )
    vim.keymap.set('i', '<C-0>', ')<Esc>bi(<Esc>%i', {buf=0})
  end,
}
