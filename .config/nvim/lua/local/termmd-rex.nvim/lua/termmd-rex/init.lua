local M = {}

function M.preview()
  local file = vim.api.nvim_buf_get_name(0)
  local rex = vim.fn.exepath("rex")
  local termmd = vim.fn.exepath("termmd")
  local session = vim.env.REX_SESSION
  if file == "" then
    return vim.notify("Save this buffer to a file first", vim.log.levels.ERROR)
  end
  if not session or rex == "" or termmd == "" then
    return vim.notify("Run Neovim inside Rex, with rex and termmd on PATH", vim.log.levels.ERROR)
  end

  vim.cmd.update()
  local request = {
    bounds = { 0, 0, 1, 1 },
    focus = true,
    layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = "Markdown preview",
        options = {
          shell = "none",
          cwd = vim.fn.fnamemodify(file, ":h"),
          command = { termmd, "--", file },
          exit = { on_completion = false },
        },
      },
    },
  }
  vim.system({
    rex, "api", "call", "-s", session,
    "session.new_layer", vim.json.encode(request),
  }, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("termmd: " .. result.stderr, vim.log.levels.ERROR)
      end)
      return
    end
    local created = vim.json.decode(result.stdout)
    -- Explicit cleanup also works when Rex's client does not auto-close exited terminals.
    vim.system({ rex, "wait", "-s", session, created.block_ids[1] }, { text = true }, function(exited)
      if exited.code ~= 0 then
        vim.schedule(function()
          vim.notify("termmd preview failed; see its Rex terminal for details", vim.log.levels.ERROR)
        end)
        return
      end
      vim.system({
        rex, "api", "call", "-s", session, "session.close_layer",
        vim.json.encode({ layer_id = created.layer_id }),
      }, { text = true })
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command("TermmdRexPreview", M.preview, {
    desc = "Preview current file with termmd in Rex",
  })
end

return M
