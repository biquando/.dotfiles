-- SECTION: Highlight on yank
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup(
  'YankHighlight',
  { clear = true }
)
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.hl.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- SECTION: Filetype actions
-- It's better to use after/ftplugin for individual filetypes
local ft_group = vim.api.nvim_create_augroup('Filetypes', { clear = true })

vim.filetype.add({ extension = { v = "verilog" } })
vim.filetype.add({ extension = { slq = "silq" } })
-- tex/plaintex/latex
vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = "tex",
  callback = function(_)
    vim.o.indentexpr = ''
  end
})


-- SECTION: Indentation


local ft_indents = {
  DEFAULT  = { 4, true },
  arm64    = { 8, true },
  asm      = { 8, true },
  bash     = { 2, true },
  c        = { 4, true },
  cmake    = { 2, true },
  cpp      = { 4, true },
  fish     = { 4, true },
  haskell  = { 2, true },
  json     = { 2, true },
  lua      = { 2, true },
  make     = { 8, false },
  markdown = { 2, true },
  ocaml    = { 2, true },
  plaintex = { 2, true },
  python   = { 4, true },
  rust     = { 4, true },
  sh       = { 2, true },
  tex      = { 2, true },
}

vim.api.nvim_create_autocmd('FileType', {
  group = ft_group,
  pattern = { '*' },
  callback = function(args)
    local buf = vim.bo[args.buf]
    local ft = buf.filetype

    local indentation = ft_indents[ft]
    if indentation then
        SET_INDENT(buf, indentation[1], indentation[2], false)
    else
        SET_INDENT(buf, ft_indents['DEFAULT'][1],
                        ft_indents['DEFAULT'][2], false)
    end
  end
})
