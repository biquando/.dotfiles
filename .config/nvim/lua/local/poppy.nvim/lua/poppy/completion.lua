local path = require("poppy.path")

local M = {}

local function is_absolute(value)
  return value:sub(1, 1) == "/" or value:match("^%a:[/\\]") ~= nil
end

function M.omnifunc(findstart, base)
  if findstart == 1 then
    -- A Poppy menu line contains only a path, so completion replaces the
    -- whole portion of the line before the cursor.
    return 0
  end

  local root = vim.b.poppy_root
  if type(root) ~= "string" or root == "" or type(base) ~= "string" then
    return {}
  end

  local absolute = is_absolute(base)
  local separator = root:match("[/\\]$") and "" or "/"
  local query = absolute and base or (root .. separator .. base)
  local candidates = vim.fn.getcompletion(query, "file")
  local items = {}

  for _, candidate in ipairs(candidates) do
    local directory = vim.fn.isdirectory(candidate) == 1
    local word = absolute and candidate or path.to_value(candidate, root)
    if word then
      if directory and not word:match("[/\\]$") then
        word = word .. "/"
      end
      items[#items + 1] = {
        word = word,
        abbr = path.basename(candidate),
      }
    end
  end

  return items
end

return M
