local M = {}

local defaults = {
  settings = {
    key = function()
      return vim.fn.getcwd()
    end,
  },
  storage = {
    path = vim.fs.joinpath(vim.fn.stdpath("data"), "poppy"),
  },
  menu = {
    width = 80,
    height = 8,
    border = "single",
    title = " Poppy ",
  },
  navigation = {
    wrap = true,
    restore_cursor = true,
  },
  tabline = {
    enabled = true,
    show_index = false,
    padding = 1,
    separator = " ",
    formatter = nil,
  },
}

M.values = vim.deepcopy(defaults)

function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
  return M.values
end

function M.get()
  return M.values
end

function M.root(explicit_root)
  local root = explicit_root
  if root == nil then
    local key = M.values.settings and M.values.settings.key
    if type(key) == "function" then
      root = key()
    else
      root = key
    end
  end

  if root == nil or root == "" then
    root = vim.fn.getcwd()
  end

  if root:sub(1, 1) ~= "/" and not root:match("^%a:[/\\]") then
    root = vim.fs.joinpath(vim.fn.getcwd(), root)
  end
  root = vim.fs.normalize(root)

  local real = vim.uv.fs_realpath(root)
  return real or root
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
