if vim.g.loaded_poppy == 1 then
  return
end
vim.g.loaded_poppy = 1

local function poppy()
  return require("poppy")._ensure_setup()
end

local function warn_on_error(result, err)
  if result == nil and err then
    vim.notify(err, vim.log.levels.WARN, { title = "Poppy" })
  end
end

vim.api.nvim_create_user_command("PoppyAdd", function()
  local _, err = poppy().add()
  if err then
    vim.notify(err, vim.log.levels.WARN, { title = "Poppy" })
  end
end, { desc = "Add the current file to Poppy" })

vim.api.nvim_create_user_command("PoppyToggle", function()
  poppy().toggle_menu()
end, { desc = "Open or close the editable Poppy menu" })

vim.api.nvim_create_user_command("PoppySelect", function(args)
  local index = tonumber(args.args)
  if not index or index < 1 or index % 1 ~= 0 then
    vim.notify("PoppySelect expects a positive integer", vim.log.levels.ERROR, { title = "Poppy" })
    return
  end
  warn_on_error(poppy().select(index))
end, {
  nargs = 1,
  desc = "Open file N from Poppy",
})

vim.api.nvim_create_user_command("PoppyNext", function()
  warn_on_error(poppy().next())
end, { desc = "Open the next Poppy file" })

vim.api.nvim_create_user_command("PoppyPrev", function()
  warn_on_error(poppy().prev())
end, { desc = "Open the previous Poppy file" })
