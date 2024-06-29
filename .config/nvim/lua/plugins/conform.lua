M = { 'stevearc/conform.nvim' }

local opts = {
	formatters_by_ft = {
		lua = { 'stylua' },
		c = { 'clang-format' },
		cpp = { 'clang-format' },
	},
}

M.config = function()
	local conform = require('conform')
	conform.setup(opts)

	vim.keymap.set('n', '<Leader>f', conform.format, { desc = '[F]ormat' })
end

return M
