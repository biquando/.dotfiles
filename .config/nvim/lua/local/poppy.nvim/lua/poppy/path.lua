local M = {}

local function is_absolute(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

function M.normalize(path, base)
  if type(path) ~= "string" or path == "" then
    return nil
  end

  if not is_absolute(path) then
    path = vim.fs.joinpath(base or vim.fn.getcwd(), path)
  end

  path = vim.fs.normalize(path)
  return vim.uv.fs_realpath(path) or path
end

function M.resolve(value, root)
  return M.normalize(value, root)
end

function M.to_value(path, root)
  local absolute = M.normalize(path, root)
  if not absolute then
    return nil
  end

  local normalized_root = M.normalize(root) or root
  local prefix = normalized_root == "/" and "/" or (normalized_root .. "/")
  if absolute:sub(1, #prefix) == prefix then
    return absolute:sub(#prefix + 1)
  end
  return absolute
end

function M.current_buffer()
  if vim.bo.buftype ~= "" then
    return nil
  end
  local name = vim.api.nvim_buf_get_name(0)
  return M.normalize(name)
end

function M.basename(value)
  local normalized = value:gsub("[/\\]+$", "")
  return normalized:match("([^/\\]+)$") or normalized
end

return M
