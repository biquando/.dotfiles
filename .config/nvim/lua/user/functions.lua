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

M.cwd_rel_to_buf = function()
  local buf_rel = string.gsub(vim.api.nvim_buf_get_name(0), vim.loop.cwd() .. '/', '')
  local _, depth = string.gsub(buf_rel, '/', '')
  local rel_path = ''
  for _ = 1,depth do
    rel_path = rel_path .. '../'
  end
  return rel_path
end

M.link_img = function()
  local ATTACHMENTS_FOLDER = 'attachments'

  local orig_path = vim.api.nvim_get_current_line()
  local ext = M.ext(orig_path)
  local new_filename = os.date('%Y-%m-%d_%H-%M-%S', os.time()) .. ext
  local new_path = ATTACHMENTS_FOLDER .. '/' .. new_filename
  local cwd_rel = M.cwd_rel_to_buf()
  os.execute('mkdir -p ' .. ATTACHMENTS_FOLDER)

  local status = os.execute('test 1>/dev/null 2>&1 -f \'' .. orig_path .. '\'')
  if status ~= 0 then
    print('Error ' .. status .. ': file ' .. orig_path .. ' does not exist')
    return
  end

  local cp_status = os.execute('cp 1>/dev/null 2>&1 \'' .. orig_path .. '\' ' .. new_path)
  if cp_status ~= 0 then
    print('Error ' .. status .. ' linking image:\n' .. orig_path .. '\n' .. new_path)
    return
  end

  vim.api.nvim_set_current_line('![](' .. cwd_rel .. new_path .. ')')
end

return M
