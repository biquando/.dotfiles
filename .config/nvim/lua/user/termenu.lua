---@class Termenu
---@field width number
---@field height number
---@field buf number|nil
---@field win number|nil
---@field menu string[]
---@field terminals table<string, number>
---@field latest string|nil
---@field set_highlights function|nil
---@field open_terminal function|nil
---@field open_latest_terminal function|nil
---@field rename_terminal function|nil
---@field open_menu function|nil
---@field close_menu function|nil
---@field toggle_menu function|nil
---@field setup function|nil

---@type Termenu
local termenu = {
  width = 50,      -- columns in menu
  height = 5,      -- minimum lines in menu
  buf = nil,       -- menu buffer
  win = nil,       -- menu window
  menu = {},       -- list of menu items (trimmed, empty entries removed)
  terminals = {},  -- maps menu items to terminal buffers
  latest = nil,    -- latest menu item selected

  -- Exposed methods
  set_highlights = nil,        -- highlight menu based on active terminals
  open_terminal = nil,         -- open a terminal based on its name
  open_latest_terminal = nil,  -- open the latest terminal
  rename_terminal = nil,       -- rename a terminal
  open_menu = nil,             -- open the menu
  close_menu = nil,            -- close the menu
  toggle_menu = nil,           -- toggle the menu open/close
  setup = nil,
}


---@return boolean
local buf_valid = function()
  return termenu.buf ~= nil and vim.api.nvim_buf_is_valid(termenu.buf)
end

---@return boolean
local win_valid = function()
  return termenu.win ~= nil and vim.api.nvim_win_is_valid(termenu.win)
end


local read_buf = function()
  local lines = vim.api.nvim_buf_get_lines(termenu.buf, 0, -1, true)
  local trim = require('user.utils').trim
  local new_menu = {}
  for _, name in ipairs(lines) do
    name = trim(name)
    if name == '' then goto continue end
    table.insert(new_menu, name)
    ::continue::
  end
  termenu.menu = new_menu
end


local write_buf = function()
  vim.api.nvim_buf_set_lines(termenu.buf, 0, -1, true, {}) -- clear buffer
  vim.api.nvim_buf_set_lines(termenu.buf, 0, 0, true, termenu.menu)
  vim.api.nvim_buf_set_lines(termenu.buf, -2, -1, true, {}) -- remove newline
end


termenu.set_highlights = function()
  if not buf_valid() then return end

  vim.api.nvim_set_hl(0, 'TermenuInactive', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'TermenuActive', { link = 'Normal' })
  local TermenuInactive = vim.api.nvim_get_hl(0, { name = 'TermenuInactive', link = false })
  vim.api.nvim_set_hl(0, 'TermenuLatestInactive', {
    fg = TermenuInactive.fg,
    bg = TermenuInactive.bg,
    underline = true
  })
  local TermenuActive = vim.api.nvim_get_hl(0, { name = 'TermenuActive', link = false })
  vim.api.nvim_set_hl(0, 'TermenuLatestActive', {
    fg = TermenuActive.fg,
    bg = TermenuActive.bg,
    underline = true
  })

  vim.api.nvim_buf_call(termenu.buf, function()
    vim.cmd([[syntax match TermenuInactive "^.*$"]])
    for _, menu_item in ipairs(termenu.menu) do
      local terminal = termenu.terminals[menu_item]
      if terminal ~= nil and vim.api.nvim_buf_is_valid(terminal) then
        vim.cmd(string.format([[syntax match TermenuActive "^%s$"]], menu_item))
      end
    end
    local latest_term = termenu.terminals[termenu.latest]
    if latest_term ~= nil and vim.api.nvim_buf_is_valid(latest_term) then
      vim.cmd(string.format([[syntax match TermenuLatestActive "^%s$"]], termenu.latest))
    else
      vim.cmd(string.format([[syntax match TermenuLatestInactive "^%s$"]], termenu.latest))
    end
  end)
end


local open_win = function()
  if not buf_valid() or win_valid() then return end
  write_buf()
  termenu.win = vim.api.nvim_open_win(termenu.buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - termenu.height) / 2) - 3,
    col = math.floor((vim.o.columns - termenu.width) / 2) - 3,
    width = termenu.width,
    height = math.max(termenu.height, #termenu.menu),
    title = 'Terminals',
    title_pos = 'center',
    style = 'minimal',
  })
  vim.wo.number = true
  termenu.set_highlights()

  -- Put cursor on latest
  local latest_line = 1
  for i, name in ipairs(termenu.menu) do
    if name == termenu.latest then
      latest_line = i
      break
    end
  end
  vim.api.nvim_win_set_cursor(0, {latest_line, 0})
end


---@param read_menu? boolean
local close_win = function(read_menu)
  if not win_valid() then return end
  if read_menu == nil then read_menu = false end
  vim.api.nvim_win_close(termenu.win, false)
  termenu.win = nil
  if read_menu then
    read_buf()
  end
end


---@param name? string
termenu.open_terminal = function(name)
  if name == nil then name = 'default' end

  -- Make sure the menu contains the terminal name
  local name_in_menu = false
  for _, menu_name in ipairs(termenu.menu) do
    if menu_name == name then
      name_in_menu = true
      break
    end
  end
  if not name_in_menu then
    table.insert(termenu.menu, name)
  end

  -- Open terminal buffer
  termenu.latest = name
  local buf = termenu.terminals[name]
  if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_win_set_buf(0, buf)
  else
    buf = vim.api.nvim_create_buf(true, true)
    vim.api.nvim_win_set_buf(0, buf)
    vim.fn.jobstart(vim.o.shell, { term = true })
    termenu.terminals[name] = buf
  end
  vim.cmd.startinsert()
end


termenu.open_latest_terminal = function()
  termenu.open_terminal(termenu.latest)
end


---@param old_name string
termenu.rename_terminal = function(old_name, new_name)
  if new_name == nil or new_name == '' then return end
  vim.api.nvim_set_current_line(new_name)
  termenu.terminals[new_name] = termenu.terminals[old_name]
  termenu.terminals[old_name] = nil
  if termenu.latest == old_name then
    termenu.latest = new_name
  end
  termenu.set_highlights()
end


local open_buf = function()
  if buf_valid() then return end
  termenu.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = termenu.buf,
    callback = function() close_win(true) end
  })

  vim.keymap.set('n', '<esc>', close_win, { buffer = termenu.buf })
  vim.keymap.set('n', 'q', close_win, { buffer = termenu.buf })
  vim.keymap.set('n', '<cr>', function()
    local trim = require('user.utils').trim
    local terminal_name = trim(vim.api.nvim_get_current_line())
    close_win()
    if terminal_name ~= '' then
      termenu.open_terminal(terminal_name)
    end
  end, { buffer = termenu.buf })
  vim.keymap.set('n', '<leader>rn', function()
    local trim = require('user.utils').trim
    local old_name = trim(vim.api.nvim_get_current_line())
    local new_name = vim.fn.input('New Name: ', old_name)
    termenu.rename_terminal(old_name, new_name)
  end, { buffer = termenu.buf })
end


termenu.open_menu = function()
  open_buf()
  open_win()
end

termenu.close_menu = function()
  open_buf()
  close_win()
end

termenu.toggle_menu = function()
  if not win_valid() then
    termenu.open_menu()
  else
    termenu.close_menu()
  end
end


termenu.setup = function()
  open_buf()
end


-- Keymaps
vim.keymap.set({'n', 't'}, '<C-t>', termenu.toggle_menu)
vim.keymap.set('n', '<C-;>', termenu.open_latest_terminal)
vim.keymap.set('n', '<C-\\>', termenu.open_latest_terminal)

return termenu
