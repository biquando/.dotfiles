local Config = require("poppy.config")

local M = {}

local state = {
  bufnr = nil,
  winid = nil,
  list = nil,
  augroup = nil,
  closing = false,
  saving = false,
}

local function valid_buffer(bufnr)
  return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

local function valid_window(winid)
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

local function method_args(first, second, third)
  if first == M then
    return second, third
  end
  return first, second
end

local function reset_state()
  state.bufnr = nil
  state.winid = nil
  state.list = nil
  state.augroup = nil
  state.closing = false
  state.saving = false
end

local function delete_augroup()
  if state.augroup ~= nil then
    pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
    state.augroup = nil
  end
end

local function displayed_lines(list)
  local lines = {}
  for _, item in ipairs(list.items or {}) do
    lines[#lines + 1] = type(item) == "table" and tostring(item.value or "") or tostring(item)
  end

  if #lines == 0 then
    lines[1] = ""
  end
  return lines
end

local function resolve_dimension(value, available, fallback)
  if type(value) == "function" then
    value = value()
  end
  value = tonumber(value) or fallback
  if value > 0 and value <= 1 then
    value = math.floor(available * value)
  else
    value = math.floor(value)
  end
  return math.max(1, math.min(value, available))
end

local function window_config(list, opts)
  local configured = Config.get().menu or {}
  local list_menu = (list.config and list.config.menu) or {}
  local supplied = opts or {}
  if type(supplied.menu) == "table" then
    supplied = vim.tbl_deep_extend("force", {}, supplied, supplied.menu)
    supplied.menu = nil
  end

  local menu = vim.tbl_deep_extend("force", {}, configured, list_menu, supplied)
  local columns = math.max(vim.o.columns, 1)
  local lines = math.max(vim.o.lines - vim.o.cmdheight, 1)
  local max_width = math.max(columns - 2, 1)
  local max_height = math.max(lines - 2, 1)
  local width = resolve_dimension(menu.width, max_width, math.floor(max_width * 0.62))
  local height = resolve_dimension(menu.height, max_height, 8)

  return {
    relative = "editor",
    style = "minimal",
    row = math.max(math.floor((lines - height) / 2), 0),
    col = math.max(math.floor((columns - width) / 2), 0),
    width = width,
    height = height,
    border = menu.border or "single",
    title = menu.title or " Poppy ",
    title_pos = menu.title_pos or "left",
  }
end

function M.is_open(_)
  return valid_window(state.winid) and valid_buffer(state.bufnr)
end

function M.save(_)
  if state.saving or state.list == nil or not valid_buffer(state.bufnr) then
    return false
  end

  state.saving = true
  local lines = vim.api.nvim_buf_get_lines(state.bufnr, 0, -1, false)
  local values = {}
  for _, line in ipairs(lines) do
    if line ~= "" and not line:match("^%s+$") then
      values[#values + 1] = line
    end
  end

  local sync_err
  local ok, thrown = xpcall(function()
    local _
    _, sync_err = state.list:replace(values)
  end, debug.traceback)
  state.saving = false

  if not ok then
    vim.notify("poppy.nvim: could not save menu\n" .. thrown, vim.log.levels.ERROR)
    return false
  end
  if sync_err then
    vim.notify("poppy.nvim: could not persist menu\n" .. sync_err, vim.log.levels.ERROR)
    return false
  end

  if valid_buffer(state.bufnr) then
    vim.api.nvim_set_option_value("modified", false, { buf = state.bufnr })
  end
  return true
end

function M.close(first, second)
  local opts
  if first == M then
    opts = second
  else
    opts = first
  end
  opts = opts or {}

  if state.closing then
    return false
  end
  if state.bufnr == nil and state.winid == nil then
    return false
  end

  state.closing = true
  if opts.save ~= false and valid_buffer(state.bufnr) then
    if not M.save() then
      state.closing = false
      return false
    end
  end

  local bufnr = state.bufnr
  local winid = state.winid
  delete_augroup()

  -- Clear the public state before closing either object so callbacks caused by
  -- window teardown cannot act on a half-closed menu.
  state.bufnr = nil
  state.winid = nil
  state.list = nil

  if valid_window(winid) then
    pcall(vim.api.nvim_win_close, winid, true)
  end
  if valid_buffer(bufnr) then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
  end

  reset_state()
  return true
end

local function select_current_line(bufnr)
  if state.bufnr ~= bufnr or state.list == nil then
    return
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local selected_value = vim.api.nvim_buf_get_lines(bufnr, line_number - 1, line_number, false)[1]
  local list = state.list
  if not M.save() then
    return
  end

  local index
  if selected_value and not selected_value:match("^%s*$") then
    if type(list.index_of) == "function" then
      index = list:index_of(selected_value)
    else
      index = line_number
    end
  end

  M.close({ save = false })
  if index then
    local _, err = list:select(index)
    if err then
      vim.notify(err, vim.log.levels.WARN, { title = "Poppy" })
    end
  end
end

local function setup_buffer(bufnr, winid)
  if vim.api.nvim_buf_get_name(bufnr) == "" then
    vim.api.nvim_buf_set_name(bufnr, string.format("poppy://menu/%d", bufnr))
  end
  vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = bufnr })
  vim.api.nvim_set_option_value("swapfile", false, { buf = bufnr })
  vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
  vim.api.nvim_set_option_value("filetype", "poppy", { buf = bufnr })
  vim.api.nvim_set_option_value("number", true, { win = winid })
  vim.api.nvim_set_option_value("relativenumber", false, { win = winid })
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:Normal,NormalNC:Normal,NormalFloat:Normal,EndOfBuffer:Normal",
    { win = winid }
  )

  local map_opts = { buffer = bufnr, silent = true, nowait = true }
  vim.keymap.set("n", "q", function()
    M.close()
  end, vim.tbl_extend("force", map_opts, { desc = "Close Poppy menu" }))
  vim.keymap.set("n", "<Esc>", function()
    M.close()
  end, vim.tbl_extend("force", map_opts, { desc = "Close Poppy menu" }))
  vim.keymap.set("n", "<CR>", function()
    select_current_line(bufnr)
  end, vim.tbl_extend("force", map_opts, { desc = "Open Poppy item" }))

  state.augroup = vim.api.nvim_create_augroup("PoppyMenuUI", { clear = true })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = state.augroup,
    buffer = bufnr,
    callback = function()
      if state.bufnr == bufnr then
        if M.save() then
          M.close({ save = false })
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufLeave", {
    group = state.augroup,
    buffer = bufnr,
    callback = function()
      if state.bufnr == bufnr and not state.closing then
        M.close()
      end
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = state.augroup,
    pattern = tostring(winid),
    callback = function()
      if state.winid == winid and not state.closing then
        M.close()
      end
    end,
  })
end

function M.open(first, second, third)
  local list, opts = method_args(first, second, third)
  if type(list) ~= "table" then
    error("poppy.nvim: ui.open requires a list", 2)
  end

  if M.is_open() then
    if state.list == list then
      return state.winid, state.bufnr
    end
    M.close()
  elseif state.bufnr ~= nil or state.winid ~= nil then
    M.close()
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, displayed_lines(list))
  vim.api.nvim_set_option_value("modified", false, { buf = bufnr })

  local ok, winid = pcall(vim.api.nvim_open_win, bufnr, true, window_config(list, opts))
  if not ok then
    pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
    error(winid, 2)
  end

  state.bufnr = bufnr
  state.winid = winid
  state.list = list
  setup_buffer(bufnr, winid)
  return winid, bufnr
end

function M.toggle(first, second, third)
  local list, opts = method_args(first, second, third)
  if M.is_open() or state.bufnr ~= nil or state.winid ~= nil then
    return M.close()
  end
  return M.open(list, opts)
end

M.toggle_quick_menu = M.toggle

return M
