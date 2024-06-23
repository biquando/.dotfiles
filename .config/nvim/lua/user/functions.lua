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

return M
