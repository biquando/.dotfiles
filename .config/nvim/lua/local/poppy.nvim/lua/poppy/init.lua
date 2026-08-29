local Config = require("poppy.config")
local List = require("poppy.list")
local Storage = require("poppy.storage")
local Tabline = require("poppy.tabline")
local UI = require("poppy.ui")

local M = {
  ui = UI,
}

local configured = false

local function optional_argument(first, second)
  if first == M then
    return second
  end
  return first
end

local function normalize_options(opts)
  opts = vim.deepcopy(opts or {})

  if opts.storage_path ~= nil then
    opts.storage = opts.storage or {}
    opts.storage.path = opts.storage_path
    opts.storage_path = nil
  end

  if type(opts.tabline) == "boolean" then
    opts.tabline = { enabled = opts.tabline }
  end

  return opts
end

function M.setup(self_or_opts, maybe_opts)
  local opts = optional_argument(self_or_opts, maybe_opts)
  if configured then
    if UI.is_open() and not UI.close({ save = true }) then
      error("poppy.nvim: cannot reconfigure while menu changes are unsaved", 0)
    end
    local synced, sync_err = List.sync_all()
    if not synced then
      error("poppy.nvim: cannot reconfigure with unsaved list changes: " .. sync_err, 0)
    end
    configured = false
    Tabline.teardown()
    List.reset()
  end

  local config = Config.setup(normalize_options(opts))
  Storage.setup(config.storage)
  configured = true
  local ok, err = pcall(Tabline.setup, config)
  if not ok then
    pcall(Tabline.teardown)
    configured = false
    error(err, 0)
  end

  return M
end

function M._ensure_setup()
  if not configured then
    M.setup()
  end
  return M
end

function M.is_setup()
  return configured
end

function M.list(self_or_root, maybe_root)
  M._ensure_setup()
  local explicit_root
  if self_or_root == M then
    explicit_root = maybe_root
  else
    explicit_root = self_or_root
  end
  return List.get(Config.root(explicit_root), Config.get())
end

function M.add(self_or_value, maybe_value)
  local value = optional_argument(self_or_value, maybe_value)
  return M:list():add(value)
end

function M.toggle_menu(self_or_opts, maybe_opts)
  local opts = optional_argument(self_or_opts, maybe_opts)
  return UI.toggle(M:list(), opts)
end

function M.select(self_or_index, index_or_opts, maybe_opts)
  local index = self_or_index
  local opts = index_or_opts
  if self_or_index == M then
    index = index_or_opts
    opts = maybe_opts
  end
  return M:list():select(index, opts)
end

function M.next(self_or_opts, maybe_opts)
  local opts = optional_argument(self_or_opts, maybe_opts)
  return M:list():next(opts)
end

function M.prev(self_or_opts, maybe_opts)
  local opts = optional_argument(self_or_opts, maybe_opts)
  return M:list():prev(opts)
end

function M.teardown(self_or_opts, maybe_opts)
  local opts = optional_argument(self_or_opts, maybe_opts) or {}
  if not configured then
    return true
  end

  if UI.is_open() then
    local closed = UI.close({ save = opts.force ~= true })
    if not closed then
      return nil, "poppy.nvim: cannot teardown while menu changes are unsaved"
    end
  end
  if opts.force ~= true then
    local synced, sync_err = List.sync_all()
    if not synced then
      return nil, "poppy.nvim: cannot teardown with unsaved list changes: " .. sync_err
    end
  end
  Tabline.teardown()
  List.reset()
  configured = false
  return true
end

return M
