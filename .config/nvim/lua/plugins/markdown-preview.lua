if not vim.fn.executable('npm') then
	return
end

return {
	'iamcco/markdown-preview.nvim',

	cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },

	build = 'cd app && npm install',

	init = function()
		vim.g.mkdp_filetypes = { 'markdown' }
	end,

	config = function()
		vim.keymap.set('n', '<Leader>mdp',
			':MarkdownPreviewToggle<CR>',
			{ desc = '[M]ark[d]own [p]review' })

		vim.keymap.set('n', '<Leader>mdi',
			require('user.functions').link_img,
			{ desc = '[M]ark[d]own [i]mage link' })
	end,

	ft = { 'markdown' },
}
