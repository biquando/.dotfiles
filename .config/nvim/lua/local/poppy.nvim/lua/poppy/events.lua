local M = {}

function M.changed(root)
  vim.api.nvim_exec_autocmds("User", {
    pattern = "PoppyChanged",
    modeline = false,
    data = { root = root },
  })
end

return M
