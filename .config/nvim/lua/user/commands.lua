-- SECTION: Indentation

local set_width = function(buf_opts, w)
  buf_opts.shiftwidth = tonumber(w)
  buf_opts.tabstop = tonumber(w)
end

local set_et = function(buf_opts, et)
  buf_opts.expandtab = et
end

local retab = function(should_retab)
  if should_retab then
    vim.cmd [[ retab! ]]
  end
end

SET_INDENT = function(buf_opts, w, et, should_retab)
  local curr_et = buf_opts.expandtab
  if curr_et and should_retab then
    set_et(buf_opts, false)
    retab(true)
    set_width(buf_opts, w)
    if et then
      set_et(buf_opts, true)
      retab(true)
    end
    return
  end

  if curr_et then
    set_et(buf_opts, et)
    set_width(buf_opts, w)
  else
    set_width(buf_opts, w)
    set_et(buf_opts, et)
  end
  retab(should_retab)
end


vim.api.nvim_create_user_command('SP',
  [[lua SET_INDENT(vim.opt, <f-args>, true, true)]], { nargs = 1 })

vim.api.nvim_create_user_command('TS',
  [[lua SET_INDENT(vim.opt, <f-args>, false, true)]], { nargs = 1 })
