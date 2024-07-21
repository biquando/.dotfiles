M = { 'stevearc/conform.nvim' }

local opts = {
  formatters_by_ft = {
    lua = { 'stylua' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    markdown = { 'prettier' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
  },
}

M.config = function()
  local conform = require('conform')
  conform.setup(opts)

  vim.keymap.set('n', '<Leader>f', conform.format, { desc = '[F]ormat' })

  vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*',
    callback = function(args)
      if SETTINGS.format_on_save then
        require('conform').format({ bufnr = args.buf })
      end
    end,
  })
end

return M
