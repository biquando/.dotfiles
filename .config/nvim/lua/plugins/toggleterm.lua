-- SECTION: General terminal options
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- for only toggle term, use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')


local toggleterm_exists, toggleterm = pcall(require, 'toggleterm')
if not toggleterm_exists then
  return
end

-- SECTION: Options
toggleterm.setup({
  size = function(term)
    if term.direction == 'horizontal' then
      return 15
    elseif term.direction == 'vertical' then
      return vim.o.columns * 0.4
    else
      return 20
    end
  end,
  -- open_mapping = [[<c-\>]],
  -- direction = 'float',
  persist_mode = false,
})

-- SECTION: Keymaps
--
-- Default <C-\> (float)
vim.keymap.set({ 'n' }, '<C-\\>', ':ToggleTerm direction=float<CR>')
vim.keymap.set('t', '<C-\\>', '<C-\\><C-n>:ToggleTerm direction=float<CR>')
-- Float
vim.keymap.set({ 'n' }, '<M-3>', ':ToggleTerm direction=float<CR>')
vim.keymap.set('t', '<M-3>', '<C-\\><C-n>:ToggleTerm direction=float<CR>')
-- Horizontal
vim.keymap.set({ 'n' }, '<M-1>', ':ToggleTerm direction=horizontal<CR>')
vim.keymap.set('t', '<M-1>', '<C-\\><C-n>:ToggleTerm direction=horizontal<CR>')
-- Vertical
vim.keymap.set({ 'n' }, '<M-2>', ':ToggleTerm direction=vertical<CR>')
vim.keymap.set('t', '<M-2>', '<C-\\><C-n>:ToggleTerm direction=vertical<CR>')
