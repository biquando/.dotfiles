local lint_exists, lint = pcall(require, 'lint')
if lint_exists then
  lint.linters_by_ft = {
    markdown = { 'markdownlint' },
    python = { 'pylint' },
  }

  local pylint = require('lint').linters.pylint
  pylint.args = {
    '-f', 'json', '--disable=import-error,missing-module-docstring,missing-function-docstring'
  }

  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()
    end,
  })
end

local M = {}

M.lint_enabled = true

M.toggle_lint = function()
  if not lint_exists then
    return
  end

  local linters = {}
  for _, v in pairs(lint.linters_by_ft) do
    for _, linter in pairs(v) do
      linters[linter] = true
    end
  end

  M.lint_enabled = not M.lint_enabled
  for linter, _ in pairs(linters) do
    local ns = require('lint').get_namespace(linter)
    vim.diagnostic.config({ virtual_text = M.lint_enabled }, ns)
  end
end

return M
