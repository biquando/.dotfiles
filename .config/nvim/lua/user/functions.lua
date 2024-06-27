local M = {}

M.dump = function(tbl)
  if type(tbl) == 'table' then
    local s = '{ '
    for k, v in pairs(tbl) do
      if type(k) ~= 'number' then k = '"' .. k .. '"' end
      s = s .. '[' .. k .. '] = ' .. M.dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(tbl)
  end
end

M.basename = function(path)
  return string.gsub(path, '(.*/)(.*)', '%2')
end

M.ext = function(path)
  return string.gsub(path, '(.*)(%..+)', '%2')
end

M.link_img = function()
  local ATTACHMENTS_FOLDER = 'attachments'

  local orig_path = vim.api.nvim_get_current_line()
  local ext = M.ext(orig_path)
  local new_filename = os.date('%Y-%m-%d_%H-%M-%S', os.time()) .. ext
  local new_path = ATTACHMENTS_FOLDER .. '/' .. new_filename
  os.execute('mkdir -p ' .. ATTACHMENTS_FOLDER)
  os.execute('cp ' .. orig_path .. ' ' .. new_path)
  vim.api.nvim_set_current_line('![](' .. new_path .. ')')
end

return M
