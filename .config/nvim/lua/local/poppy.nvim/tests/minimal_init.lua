local source = debug.getinfo(1, "S").source
local this_file = vim.fn.fnamemodify(source:sub(2), ":p")
local repository = vim.fn.fnamemodify(this_file, ":h:h")

vim.opt.runtimepath:prepend(repository)
vim.opt.packpath:prepend(repository)

vim.o.shadafile = "NONE"
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.hidden = true

