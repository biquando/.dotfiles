-- Alias W := w
vim.api.nvim_create_user_command(
  'W', [[w]], { nargs = '?' }
)


-- Indentation commands

SET_INDENT = function(new_width, use_spaces, should_retab)
  local prev_use_spaces = vim.bo.expandtab

  -- Convert current indentation to tabs
  if prev_use_spaces then
    vim.bo.tabstop = vim.bo.shiftwidth
    vim.bo.expandtab = false
  end
  if should_retab then vim.cmd([[retab!]]) end

  -- Set new indentation width
  vim.bo.tabstop = tonumber(new_width)
  vim.bo.shiftwidth = tonumber(new_width)

  -- Convert back to spaces if necessary
  if use_spaces then
    vim.bo.expandtab = true
    if should_retab then vim.cmd([[retab!]]) end
    vim.bo.tabstop = 8
  end
end

vim.api.nvim_create_user_command(
  'SP',
  [[lua SET_INDENT(<f-args>, true, false)]],
  { nargs = 1 }
)

vim.api.nvim_create_user_command(
  'SPT',
  [[lua SET_INDENT(<f-args>, true, true)]],
  { nargs = 1 }
)

vim.api.nvim_create_user_command(
  'TS',
  [[lua SET_INDENT(<f-args>, false, false)]],
  { nargs = 1 }
)

vim.api.nvim_create_user_command(
  'TST',
  [[lua SET_INDENT(<f-args>, false, true)]],
  { nargs = 1 }
)
