-- Use cmd+s to toggle sidebar
-- rex.unbind("cmd+/", "client.sidebar.toggle")
rex.bind("cmd+s", "client.sidebar.toggle")

-- Use ctrl+cmd+hjkl to focus panes
-- rex.unbind("alt+cmd+left", "pane.focus.left")
-- rex.unbind("alt+cmd+down", "pane.focus.down")
-- rex.unbind("alt+cmd+up", "pane.focus.up")
-- rex.unbind("alt+cmd+right", "pane.focus.right")
rex.bind("ctrl+cmd+h", "pane.focus.left")
rex.bind("ctrl+cmd+j", "pane.focus.down")
rex.bind("ctrl+cmd+k", "pane.focus.up")
rex.bind("ctrl+cmd+l", "pane.focus.right")


-- Use ctrl+shift+cmd+hjkl to move panes
-- rex.unbind("alt+shift+cmd+left", "pane.move.left")
-- rex.unbind("alt+shift+cmd+up", "pane.move.up")
-- rex.unbind("alt+shift+cmd+down", "pane.move.down")
-- rex.unbind("alt+shift+cmd+right", "pane.move.right")
rex.bind("ctrl+shift+cmd+h", "pane.move.left")
rex.bind("ctrl+shift+cmd+j", "pane.move.up")
rex.bind("ctrl+shift+cmd+k", "pane.move.down")
rex.bind("ctrl+shift+cmd+l", "pane.move.right")


-- Use ctrl+cmd+= to balance panes
rex.bind("ctrl+cmd+=", "pane.balance")


-- Use ctrl+cmd+enter to zoom pane
-- rex.unbind("shift+cmd+enter", "pane.zoom")
rex.bind("ctrl+cmd+enter", "pane.zoom")






-- Use cmd+shift+t to switch to a new tab in session "Workspace"

local new_tab_in_session = function(session_name)
  return function(ctx, args)
    -- Plain rex follows ctx.server. Re-enter locally when viewing a remote tab.
    if ctx.server then
      local result = assert(rex.exec({
        "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex",
        "--autostart=false",
        "--server", "unix:///Users/biqua/Library/Application%20Support/rex/server.sock",
        "--client", "biquando-pro",
        "do", os.getenv("HOME") .. "/.config/rex/init.lua",
        "--action", "new_workspace_tab",
      }, {
        env = { REX_SESSION = false, REX_BLOCK = false, REX_SERVER = false,
          REX_CLIENT = false },
      }))
      if not result.ok then error(result.stderr, 0) end
      return assert(rex.json.decode(result.stdout))
    end

    local server = rex
    local session_id

    local listed = assert(server.call("session.list"))
    for _, session in ipairs(listed.sessions or {}) do
      if session.label == session_name then
        session_id = session.session_id
        break
      end
    end

    local tab = {
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
      },
    }

    local window_id
    if session_id then
      if rex.sleep then
        assert(server.session.attach{ session_id = session_id })
      end
      tab.session_id = session_id
      window_id = assert(server.session.new_window(tab)).window_id
    else
      local created = assert(server.call("session.create", {
        label = session_name,
        initial_windows = { tab },
      }))
      session_id = created.session_id
      window_id = created.initial_windows[1].window_id
    end

    -- Work around the app's race between receiving a new tab and selecting it.
    -- This yields through rex.exec; it is not a client-readiness guarantee.
    if rex.sleep then
      rex.sleep(0.1) -- The explicitly local CLI script can yield without a helper.
    else
      local settled = assert(rex.exec({ "/usr/bin/true" }))
      if not settled.ok then error(settled.stderr, 0) end
    end

    rex.client.queue("session.select", {
      session_id = session_id,
      window_id = window_id,
    })
    return { session_id = session_id, window_id = window_id }
  end
end


rex.action{
  name = "new_workspace_tab",
  title = "New Workspace Tab",
  run = new_tab_in_session("Workspace")
}
rex.bind("cmd+shift+t", "new_workspace_tab")
