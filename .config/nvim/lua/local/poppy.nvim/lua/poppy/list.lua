local config_module = require("poppy.config")
local events = require("poppy.events")
local path = require("poppy.path")
local storage = require("poppy.storage")

local M = {}
local List = {}
List.__index = List

local lists = {}

local function position(value, minimum)
  if type(value) ~= "number" or value ~= value then
    return nil
  end
  value = math.floor(value)
  if value < minimum then
    return nil
  end
  return value
end

local function context_from(source, previous)
  local source_context = type(source.context) == "table" and source.context or {}
  local previous_context = previous
    and (type(previous.context) == "table" and previous.context or previous)
    or {}

  return {
    row = position(source_context.row, 1)
      or position(source.row, 1)
      or position(previous_context.row, 1),
    col = position(source_context.col, 0)
      or position(source.col, 0)
      or position(previous_context.col, 0),
  }
end

local function item_from(value, root, previous)
  local source = type(value) == "table" and value or { value = value }
  local raw_value = source.value or source.filename
  if type(raw_value) ~= "string" or raw_value == "" then
    return nil
  end

  local absolute = path.resolve(raw_value, root)
  if not absolute then
    return nil
  end

  local item = {
    value = path.to_value(absolute, root),
    context = context_from(source, previous),
  }
  return item, absolute
end

local function same_items(left, right)
  if #left ~= #right then
    return false
  end
  for index, item in ipairs(left) do
    local other = right[index]
    local context = item.context or {}
    local other_context = other and other.context or {}
    if not other
      or item.value ~= other.value
      or context.row ~= other_context.row
      or context.col ~= other_context.col
    then
      return false
    end
  end
  return true
end

local function normalize_items(values, root, previous_items)
  local result = {}
  local seen = {}
  local previous = {}

  for _, item in ipairs(previous_items or {}) do
    local absolute = path.resolve(item.value, root)
    if absolute then
      previous[absolute] = item
    end
  end

  if type(values) ~= "table" then
    return result
  end

  for _, value in ipairs(values) do
    local raw = type(value) == "table" and (value.value or value.filename) or value
    local absolute = type(raw) == "string" and path.resolve(raw, root) or nil
    local item = absolute and item_from(value, root, previous[absolute]) or nil
    if item and not seen[absolute] then
      seen[absolute] = true
      result[#result + 1] = item
    end
  end

  return result
end

local function current_position_for(absolute)
  if path.current_buffer() ~= absolute then
    return nil, nil
  end

  local ok, cursor = pcall(vim.api.nvim_win_get_cursor, 0)
  if not ok then
    return nil, nil
  end
  return cursor[1], cursor[2]
end

local function restore_cursor(list, opts)
  if opts and opts.restore_cursor ~= nil then
    return opts.restore_cursor
  end
  local navigation = list.config.navigation or {}
  return navigation.restore_cursor ~= false
end

local function should_wrap(list, opts)
  if opts and opts.wrap ~= nil then
    return opts.wrap
  end
  local navigation = list.config.navigation or {}
  return navigation.wrap ~= false
end

function List:length()
  return #self.items
end

function List:index_of(value)
  local raw = type(value) == "table" and (value.value or value.filename) or value
  if raw == nil then
    raw = path.current_buffer()
  end
  local absolute = type(raw) == "string" and path.resolve(raw, self.root) or nil
  if not absolute then
    return nil
  end

  for index, item in ipairs(self.items) do
    if path.resolve(item.value, self.root) == absolute then
      return index
    end
  end
  return nil
end

function List:sync()
  local ok, err = storage.save(self.root, self.items)
  if ok then
    self._dirty = false
  end
  local emitted, event_err = pcall(events.changed, self.root)
  if not ok then
    return nil, err
  end
  if not emitted then
    return nil, event_err
  end
  return ok, err
end

function List:add(value)
  local raw = value
  if raw == nil then
    raw = path.current_buffer()
    if not raw then
      return nil, "the current buffer is not a file"
    end
  end

  local item, absolute = item_from(raw, self.root)
  if not item then
    return nil, "poppy items must contain a non-empty file path"
  end

  local existing = self:index_of(absolute)
  if existing then
    local existing_item = self.items[existing]
    if self._dirty then
      local _, err = self:sync()
      return existing_item, err
    end
    return existing_item
  end

  if type(raw) ~= "table" then
    item.context.row, item.context.col = current_position_for(absolute)
  end
  self.items[#self.items + 1] = item
  self._dirty = true

  local ok, err = self:sync()
  if not ok then
    return item, err
  end
  return item
end

function List:replace(values)
  local replacement = normalize_items(values, self.root, self.items)
  if same_items(self.items, replacement) then
    if self._dirty then
      local _, err = self:sync()
      return self.items, err
    end
    return self.items
  end

  self.items = replacement
  self._dirty = true
  local _, err = self:sync()
  return self.items, err
end

function List:remove(value)
  local index
  if type(value) == "number" then
    index = value == math.floor(value) and value or nil
  else
    index = self:index_of(value)
  end

  if not index or index < 1 or index > #self.items then
    return nil, "poppy item not found"
  end

  local removed = table.remove(self.items, index)
  self._dirty = true
  local ok, err = self:sync()
  if not ok then
    return removed, err
  end
  return removed
end

function List:_store_current_position()
  local absolute = path.current_buffer()
  local index = absolute and self:index_of(absolute) or nil
  if not index then
    return true
  end

  local row, col = current_position_for(absolute)
  if not row then
    return true
  end

  local item = self.items[index]
  item.context = item.context or {}
  if item.context.row == row and item.context.col == col then
    return true
  end

  item.context.row = row
  item.context.col = col
  self._dirty = true
  return self:sync()
end

function List:select(index, opts)
  if type(index) ~= "number" or index ~= math.floor(index) then
    return nil, "poppy item index must be an integer"
  end
  local item = self.items[index]
  if not item then
    return nil, "poppy item index is out of range"
  end

  local _, position_err = self:_store_current_position()

  local absolute = path.resolve(item.value, self.root)
  if not absolute then
    return nil, "poppy item does not have a valid file path"
  end

  local bufnr = vim.fn.bufadd(absolute)
  if bufnr == 0 then
    return nil, "unable to create a buffer for " .. absolute
  end

  vim.bo[bufnr].buflisted = true
  local winid = opts and (opts.winid or opts.win) or 0
  local switched, switch_err = pcall(vim.api.nvim_win_set_buf, winid, bufnr)
  if not switched then
    return nil, switch_err
  end

  local context = item.context or {}
  if restore_cursor(self, opts) and context.row then
    local row = math.max(1, math.min(context.row, vim.api.nvim_buf_line_count(bufnr)))
    local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""
    local col = math.max(0, math.min(context.col or 0, #line))
    pcall(vim.api.nvim_win_set_cursor, winid, { row, col })
  end

  return bufnr, position_err
end

function List:next(opts)
  if #self.items == 0 then
    return nil, "poppy list is empty"
  end

  local index = self:index_of(path.current_buffer())
  if not index then
    return self:select(1, opts)
  end
  if index == #self.items then
    if not should_wrap(self, opts) then
      return nil
    end
    index = 1
  else
    index = index + 1
  end
  return self:select(index, opts)
end

function List:prev(opts)
  if #self.items == 0 then
    return nil, "poppy list is empty"
  end

  local index = self:index_of(path.current_buffer())
  if not index then
    return self:select(#self.items, opts)
  end
  if index == 1 then
    if not should_wrap(self, opts) then
      return nil
    end
    index = #self.items
  else
    index = index - 1
  end
  return self:select(index, opts)
end

function M.get(root, config)
  config = config or config_module.get()
  root = path.normalize(root or config_module.root())
  assert(root, "poppy list root must be a valid path")

  local list = lists[root]
  if list then
    list.config = config
    return list
  end

  local loaded, load_err = storage.load(root)
  list = setmetatable({
    root = root,
    config = config,
    items = normalize_items(loaded, root),
    load_error = load_err,
    _dirty = false,
  }, List)
  lists[root] = list
  return list
end

function M.reset()
  lists = {}
end

function M.sync_all()
  for _, list in pairs(lists) do
    if list._dirty then
      local ok, err = list:sync()
      if not ok then
        return nil, err
      end
    end
  end
  return true
end

return M
