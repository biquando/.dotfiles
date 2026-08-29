local path = require("poppy.path")

local M = {}

local augroup_name = "PoppyTabline"
local click_callback = "PoppyTabClick"
local tabline_expression = "%!v:lua.require'poppy.tabline'.render()"

local defaults = {
  enabled = true,
  formatter = nil,
  padding = 1,
  separator = " ",
  show_index = false,
}

local state = {
  configured = false,
  config = vim.deepcopy(defaults),
  rendering = false,
  previous = nil,
  extended_clicks = {},
}

local function options(config)
  local source = config
  if type(config) == "table" and config.tabline ~= nil then
    source = config.tabline
  end

  if source == false then
    return vim.tbl_extend("force", vim.deepcopy(defaults), { enabled = false })
  end
  if source == true or source == nil then
    source = {}
  end
  if type(source) ~= "table" then
    source = {}
  end

  return vim.tbl_extend("force", vim.deepcopy(defaults), source)
end

local function set_highlights()
  vim.api.nvim_set_hl(0, "PoppyTabline", { link = "TabLine" })
  vim.api.nvim_set_hl(0, "PoppyTablineCurrent", { bold = true, reverse = true })
  vim.api.nvim_set_hl(0, "PoppyTablineFill", { link = "TabLineFill" })
end

local function fallback_list()
  local ok_config, config = pcall(require, "poppy.config")
  local ok_list, list_module = pcall(require, "poppy.list")
  if not ok_config or not ok_list then
    return nil
  end

  local ok, list = pcall(function()
    return list_module.get(config.root(), config.get())
  end)
  return ok and list or nil
end

local function current_list()
  local ok, poppy = pcall(require, "poppy")
  if not ok or type(poppy) ~= "table" then
    return nil
  end

  -- Keep standalone tabline setup from recursively invoking poppy.setup().
  if type(poppy.is_setup) == "function" and not poppy.is_setup() then
    return fallback_list()
  end

  if type(poppy.list) ~= "function" then
    return nil
  end
  local list_ok, list = pcall(poppy.list)
  return list_ok and list or nil
end

local function items_for(list)
  return list and type(list.items) == "table" and list.items or {}
end

local function escape_statusline(value)
  value = tostring(value or "")
  value = value:gsub("[\r\n\t]", " ")
  return value:gsub("%%", "%%%%")
end

local function active_index(list)
  local current = path.current_buffer()
  if not current then
    return nil
  end

  local resolved = path.resolve(current, list.root)
  if type(list.index_of) == "function" then
    local ok, index = pcall(list.index_of, list, resolved)
    if ok and type(index) == "number" then
      return index
    end
  end

  for index, item in ipairs(items_for(list)) do
    if type(item) == "table"
      and path.resolve(item.value, list.root) == resolved
    then
      return index
    end
  end
  return nil
end

local function default_labels(items)
  local basenames = {}
  local counts = {}

  for index, item in ipairs(items) do
    local value = type(item) == "table" and item.value or item
    value = type(value) == "string" and value or ""
    local basename = path.basename(value)
    basenames[index] = basename
    counts[basename] = (counts[basename] or 0) + 1
  end

  local labels = {}
  for index, item in ipairs(items) do
    local value = type(item) == "table" and item.value or item
    value = type(value) == "string" and value or ""
    labels[index] = counts[basenames[index]] > 1 and value or basenames[index]
  end
  return labels
end

local function label_for(item, index, list, fallback)
  local label = fallback
  if type(state.config.formatter) == "function" then
    local ok, formatted = pcall(state.config.formatter, item, index, list.root)
    if ok and formatted ~= nil then
      label = tostring(formatted)
    end
  end

  if state.config.show_index then
    label = string.format("%d %s", index, label)
  end
  local padding = math.max(0, math.floor(tonumber(state.config.padding) or 0))
  if padding > 0 then
    local spaces = string.rep(" ", padding)
    label = spaces .. label .. spaces
  end
  return escape_statusline(label)
end

local function click_region(index)
  if index <= 50 then
    return string.format("%%%d@v:lua.%s@", index, click_callback)
  end

  local name = string.format("PoppyTabClick_%d", index)
  if state.extended_clicks[name] == nil then
    state.extended_clicks[name] = {
      existed = rawget(_G, name) ~= nil,
      value = rawget(_G, name),
    }
  end
  _G[name] = function(_minwid, clicks, button, mods)
    return M.click(index, clicks, button, mods)
  end
  return string.format("%%@v:lua.%s@", name)
end

local function restore_extended_clicks()
  for name, previous in pairs(state.extended_clicks) do
    if previous.existed then
      _G[name] = previous.value
    else
      _G[name] = nil
    end
  end
  state.extended_clicks = {}
end

local function render_impl()
  local list = current_list()
  local items = items_for(list)
  if #items == 0 then
    return "%#PoppyTablineFill#%="
  end

  local labels = default_labels(items)
  local selected = active_index(list)
  local separator = escape_statusline(state.config.separator)
  local result = {}

  for index, item in ipairs(items) do
    if index > 1 and separator ~= "" then
      result[#result + 1] = "%#PoppyTabline#" .. separator
    end

    local highlight = index == selected and "PoppyTablineCurrent" or "PoppyTabline"
    result[#result + 1] = string.format(
      "%s%%#%s#%s%%X",
      click_region(index),
      highlight,
      label_for(item, index, list, labels[index])
    )
  end

  result[#result + 1] = "%#PoppyTablineFill#%="
  return table.concat(result)
end

function M.render()
  if state.rendering then
    return "%#PoppyTablineFill#%="
  end

  state.rendering = true
  local ok, rendered = pcall(render_impl)
  state.rendering = false
  if not ok or type(rendered) ~= "string" then
    return "%#PoppyTablineFill#%="
  end
  return rendered
end

function M.refresh()
  if not state.configured then
    return
  end

  if vim.o.tabline ~= tabline_expression then
    state.previous = state.previous or {}
    state.previous.tabline = vim.o.tabline
    state.previous.showtabline = vim.o.showtabline
    vim.o.tabline = tabline_expression
  end

  local list = current_list()
  local visible = #items_for(list) > 0
  vim.o.showtabline = visible and 2 or 0
  pcall(vim.cmd, "redrawtabline")
end

function M.click(minwid, _clicks, button, _mods)
  if button ~= nil and button ~= "" and button ~= "l" then
    return
  end

  local index = tonumber(minwid)
  if not index or index < 1 or index ~= math.floor(index) then
    return
  end

  local ok, poppy = pcall(require, "poppy")
  if not ok or type(poppy.select) ~= "function" then
    return
  end

  local called, result, err = pcall(poppy.select, index)
  if not called then
    vim.notify(result, vim.log.levels.ERROR, { title = "Poppy" })
    return
  end
  if result == nil and err then
    vim.notify(err, vim.log.levels.WARN, { title = "Poppy" })
  end
  return result, err
end

function M.setup(config)
  local opts = options(config)
  if opts.enabled == false then
    M.teardown()
    state.config = opts
    return M
  end

  state.config = opts
  if not state.configured then
    state.previous = {
      tabline = vim.o.tabline,
      showtabline = vim.o.showtabline,
      click = rawget(_G, click_callback),
    }
    state.configured = true
  end

  _G[click_callback] = function(minwid, clicks, button, mods)
    return M.click(minwid, clicks, button, mods)
  end

  set_highlights()
  vim.o.tabline = tabline_expression

  local group = vim.api.nvim_create_augroup(augroup_name, { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "DirChanged", "VimEnter" }, {
    group = group,
    callback = M.refresh,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "PoppyChanged",
    callback = M.refresh,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      set_highlights()
      M.refresh()
    end,
  })

  M.refresh()
  return M
end

function M.teardown()
  if not state.configured then
    restore_extended_clicks()
    return M
  end

  pcall(vim.api.nvim_del_augroup_by_name, augroup_name)

  local previous = state.previous or {}
  vim.o.tabline = previous.tabline or ""
  vim.o.showtabline = previous.showtabline or 1
  _G[click_callback] = previous.click
  restore_extended_clicks()

  state.configured = false
  state.previous = nil
  state.rendering = false
  pcall(vim.cmd, "redrawtabline")
  return M
end

return M
