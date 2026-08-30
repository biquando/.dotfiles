local uv = vim.uv or vim.loop

local tests = {}
local failures = {}
local passed = 0
local sandbox_index = 0
local original_cwd = vim.fn.getcwd()
local original_tabline = vim.o.tabline
local original_showtabline = vim.o.showtabline
local original_click = rawget(_G, "PoppyTabClick")
local suite_root = vim.fn.tempname()

local function fail(message, level)
  error(message or "assertion failed", (level or 1) + 1)
end

local function inspect(value)
  return vim.inspect(value)
end

local function eq(expected, actual, message)
  if not vim.deep_equal(expected, actual) then
    fail(string.format(
      "%s\nexpected: %s\nactual:   %s",
      message or "values differ",
      inspect(expected),
      inspect(actual)
    ), 2)
  end
end

local function truthy(value, message)
  if not value then
    fail(message or ("expected truthy value, got " .. inspect(value)), 2)
  end
  return value
end

local function falsy(value, message)
  if value then
    fail(message or ("expected falsy value, got " .. inspect(value)), 2)
  end
end

local function contains(haystack, needle, message)
  if type(haystack) ~= "string" or not haystack:find(needle, 1, true) then
    fail(message or string.format("expected %s to contain %s", inspect(haystack), inspect(needle)), 2)
  end
end

local function test(name, callback)
  tests[#tests + 1] = { name = name, callback = callback }
end

local function mkdir(path)
  local result = vim.fn.mkdir(path, "p")
  truthy(result == 1 or vim.fn.isdirectory(path) == 1, "unable to create directory " .. path)
  return path
end

local function realpath(path)
  return uv.fs_realpath(path) or vim.fs.normalize(path)
end

local function write_file(filename, lines)
  mkdir(vim.fs.dirname(filename))
  eq(0, vim.fn.writefile(lines or { "" }, filename), "unable to write " .. filename)
  return realpath(filename)
end

local function make_sandbox(name)
  sandbox_index = sandbox_index + 1
  local base = vim.fs.joinpath(suite_root, string.format("%02d-%s", sandbox_index, name))
  local project = mkdir(vim.fs.joinpath(base, "project"))
  local storage = mkdir(vim.fs.joinpath(base, "storage"))
  return {
    base = realpath(base),
    project = realpath(project),
    storage = realpath(storage),
  }
end

local function edit(filename)
  vim.cmd.edit(vim.fn.fnameescape(filename))
  return vim.api.nvim_get_current_buf()
end

local function feed(keys)
  local encoded = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(encoded, "x", false)
end

local function current_file()
  return realpath(vim.api.nvim_buf_get_name(0))
end

local function values(list)
  local result = {}
  for _, item in ipairs(list.items) do
    result[#result + 1] = item.value
  end
  return result
end

local function setup(env, opts)
  opts = vim.tbl_deep_extend("force", {
    settings = {
      key = function()
        return env.project
      end,
    },
    storage = { path = env.storage },
    tabline = { enabled = false },
  }, opts or {})
  return require("poppy").setup(opts)
end

local function autocmd_count(group)
  local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { group = group })
  return ok and #autocmds or 0
end

local function reset_editor()
  local ok, poppy = pcall(require, "poppy")
  if ok then
    pcall(poppy.ui.close, { save = false })
    pcall(poppy.teardown)
  end

  pcall(vim.api.nvim_del_augroup_by_name, "PoppyMenuUI")
  pcall(vim.api.nvim_del_augroup_by_name, "PoppyTabline")
  pcall(vim.api.nvim_set_current_dir, original_cwd)
  pcall(vim.cmd, "silent! only")
  pcall(vim.cmd, "silent! %bwipeout!")
  pcall(vim.cmd, "enew!")

  vim.o.tabline = original_tabline
  vim.o.showtabline = original_showtabline
  _G.PoppyTabClick = original_click
end

test("setup and user commands load", function()
  local env = make_sandbox("commands")
  local file = write_file(vim.fs.joinpath(env.project, "commands.lua"), { "one", "two" })

  eq(1, vim.g.loaded_poppy, "plugin/poppy.lua was not loaded")
  for _, command in ipairs({
    "PoppyAdd",
    "PoppyToggle",
    "PoppySelect",
    "PoppyNext",
    "PoppyPrev",
  }) do
    eq(2, vim.fn.exists(":" .. command), command .. " is not defined")
  end

  local poppy = setup(env)
  truthy(poppy.is_setup(), "setup did not mark Poppy configured")
  edit(file)
  vim.cmd("PoppyAdd")
  eq({ "commands.lua" }, values(poppy:list()))

  vim.cmd("PoppyToggle")
  truthy(poppy.ui:is_open(), "PoppyToggle did not open the menu")
  vim.cmd("PoppyToggle")
  falsy(poppy.ui:is_open(), "PoppyToggle did not close the menu")
end)

test("Harpoon-style colon calls preserve optional arguments", function()
  local env = make_sandbox("colon-api")
  local file = write_file(vim.fs.joinpath(env.project, "colon.lua"), { "colon" })
  local outside = write_file(vim.fs.joinpath(env.project, "outside.lua"), { "outside" })
  local poppy = require("poppy")

  poppy:setup({
    settings = { key = function() return env.project end },
    storage = { path = env.storage },
    tabline = false,
  })
  edit(file)
  truthy(poppy:add())
  eq({ "colon.lua" }, values(poppy:list()), "colon add did not use the current file")

  poppy:toggle_menu()
  truthy(poppy.ui:is_open(), "colon toggle did not open the menu")
  poppy:toggle_menu()
  falsy(poppy.ui:is_open(), "colon toggle did not close the menu")

  edit(outside)
  truthy(poppy:next())
  eq(file, current_file(), "colon next did not navigate")
  truthy(poppy:prev())
  eq(file, current_file(), "colon prev did not navigate")
end)

test("add current file and deduplicate normalized paths", function()
  local env = make_sandbox("add-dedupe")
  local file = write_file(vim.fs.joinpath(env.project, "alpha.lua"), { "alpha", "beta", "gamma" })
  local poppy = setup(env)
  local list = poppy:list()

  edit(file)
  vim.api.nvim_win_set_cursor(0, { 2, 1 })
  local item, err = list:add()
  truthy(item, err)
  eq("alpha.lua", item.value)

  list:add(file)
  list:add("./alpha.lua")
  eq(1, list:length(), "equivalent paths were added more than once")
end)

test("persistence reloads and remains isolated by cwd", function()
  local env = make_sandbox("persistence")
  local project_a = mkdir(vim.fs.joinpath(env.base, "project-a"))
  local project_b = mkdir(vim.fs.joinpath(env.base, "project-b"))
  project_a = realpath(project_a)
  project_b = realpath(project_b)
  local file_a = write_file(vim.fs.joinpath(project_a, "a.lua"), { "a" })
  local file_b = write_file(vim.fs.joinpath(project_b, "b.lua"), { "b" })
  local poppy = require("poppy").setup({
    settings = { key = function() return vim.fn.getcwd() end },
    storage = { path = env.storage },
    tabline = false,
  })

  vim.api.nvim_set_current_dir(project_a)
  poppy:list():add(file_a)
  vim.api.nvim_set_current_dir(project_b)
  eq(0, poppy:list():length(), "a new cwd inherited another cwd's list")
  poppy:list():add(file_b)

  local storage = require("poppy.storage")
  local state_a = storage.file_for_root(project_a)
  local state_b = storage.file_for_root(project_b)
  falsy(state_a == state_b, "different roots resolved to one persistence file")
  truthy(uv.fs_stat(state_a), "project A was not persisted")
  truthy(uv.fs_stat(state_b), "project B was not persisted")

  poppy.setup({
    settings = { key = function() return vim.fn.getcwd() end },
    storage = { path = env.storage },
    tabline = false,
  })
  vim.api.nvim_set_current_dir(project_a)
  eq({ "a.lua" }, values(poppy:list()), "project A did not reload")
  vim.api.nvim_set_current_dir(project_b)
  eq({ "b.lua" }, values(poppy:list()), "project B did not reload")
end)

test("replace reorders, deduplicates, and deletes", function()
  local env = make_sandbox("replace")
  for _, name in ipairs({ "a.lua", "b.lua", "c.lua", "%literal.lua" }) do
    write_file(vim.fs.joinpath(env.project, name), { name })
  end
  local list = setup(env):list()

  list:replace({
    { value = "a.lua", row = 1, col = 0 },
    "b.lua",
    "c.lua",
  })
  list:replace({ "c.lua", "a.lua", "c.lua", "" })
  eq({ "c.lua", "a.lua" }, values(list), "replace did not reorder/delete/deduplicate")

  local removed, err = list:remove(1)
  truthy(removed, err)
  eq("c.lua", removed.value)
  eq({ "a.lua" }, values(list), "remove did not delete the requested entry")

  list:replace({ "%literal.lua" })
  eq({ "%literal.lua" }, values(list), "Vim expansion changed a literal special filename")
end)

test("corrupt JSON is tolerated as an empty list", function()
  local env = make_sandbox("corrupt-json")
  local poppy = setup(env)
  local root = realpath(env.project)
  local storage = require("poppy.storage")
  local filename = storage.file_for_root(root)
  write_file(filename, { "{not valid json" })

  poppy.setup({
    settings = { key = function() return root end },
    storage = { path = env.storage },
    tabline = false,
  })
  local list = poppy:list()
  eq(0, list:length(), "corrupt state produced list entries")
  contains(list.load_error, "decode", "corrupt state did not expose a useful load error")
end)

test("failed persistence remains dirty and retries without another edit", function()
  local env = make_sandbox("persistence-retry")
  write_file(vim.fs.joinpath(env.project, "retry.lua"), { "retry" })
  local blocked_path = vim.fs.joinpath(env.base, "blocked-storage")
  write_file(blocked_path, { "this is a file, not a directory" })

  local poppy = require("poppy").setup({
    settings = { key = function() return env.project end },
    storage = { path = blocked_path },
    tabline = false,
  })
  local list = poppy:list()
  local _, first_error = list:replace({ "retry.lua" })
  truthy(first_error, "failed persistence did not return an error")
  contains(first_error, "blocked-storage", "persistence error did not identify its target")

  eq(0, vim.fn.delete(blocked_path), "unable to remove the blocking test file")
  mkdir(blocked_path)
  local _, retry_error = list:replace({ "retry.lua" })
  falsy(retry_error, "an unchanged dirty list did not retry persistence")
  truthy(
    uv.fs_stat(require("poppy.storage").file_for_root(realpath(env.project))),
    "retry did not create the state file"
  )
end)

test("teardown preserves an unsaved menu unless force is requested", function()
  local env = make_sandbox("teardown-unsaved")
  write_file(vim.fs.joinpath(env.project, "unsaved.lua"), { "unsaved" })
  local blocked_path = vim.fs.joinpath(env.base, "blocked-storage")
  write_file(blocked_path, { "not a directory" })
  local poppy = require("poppy").setup({
    settings = { key = function() return env.project end },
    storage = { path = blocked_path },
    tabline = false,
  })
  local list = poppy:list()
  list:replace({ "unsaved.lua" })
  poppy.ui:open(list)

  local original_notify = vim.notify
  local notification
  vim.notify = function(message)
    notification = message
  end
  local torn_down, teardown_error = poppy:teardown()
  vim.notify = original_notify
  falsy(torn_down, "teardown discarded an unpersisted menu")
  contains(teardown_error, "unsaved", "teardown did not explain why it stopped")
  contains(notification, "could not persist", "menu did not report its persistence failure")
  truthy(poppy.is_setup(), "failed teardown marked Poppy unconfigured")
  truthy(poppy.ui:is_open(), "failed teardown closed the unsaved menu")

  truthy(poppy:teardown({ force = true }), "forced teardown failed")
  falsy(poppy.is_setup(), "forced teardown left Poppy configured")
  falsy(poppy.ui:is_open(), "forced teardown left the menu open")
end)

test("next and previous wrap and handle files outside the list", function()
  local env = make_sandbox("navigation")
  local files = {}
  for _, name in ipairs({ "a.lua", "b.lua", "c.lua", "outside.lua" }) do
    files[name] = write_file(vim.fs.joinpath(env.project, name), { name })
  end
  local list = setup(env):list()
  list:replace({ "a.lua", "b.lua", "c.lua" })

  edit(files["outside.lua"])
  truthy(list:next())
  eq(files["a.lua"], current_file(), "next from an unlisted file did not choose the first entry")

  edit(files["outside.lua"])
  truthy(list:prev())
  eq(files["c.lua"], current_file(), "prev from an unlisted file did not choose the last entry")

  truthy(list:next())
  eq(files["a.lua"], current_file(), "next did not wrap from last to first")
  truthy(list:prev())
  eq(files["c.lua"], current_file(), "prev did not wrap from first to last")
end)

test("editable UI reconciles on close and write", function()
  local env = make_sandbox("ui")
  for _, name in ipairs({ "a.lua", "b.lua", "c.lua" }) do
    write_file(vim.fs.joinpath(env.project, name), { name })
  end
  local poppy = setup(env)
  local list = poppy:list()
  list:replace({ "a.lua", "b.lua", "c.lua" })

  local winid, bufnr = poppy.ui:open(list, { width = 30, height = 5 })
  truthy(poppy.ui:is_open())
  eq("acwrite", vim.bo[bufnr].buftype)
  truthy(vim.wo[winid].number, "menu line numbers are disabled")
  contains(
    vim.wo[winid].winhighlight,
    "NormalFloat:Normal",
    "menu background does not inherit the editor background"
  )
  eq({ "a.lua", "b.lua", "c.lua" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "c.lua", "a.lua", "", "a.lua" })
  poppy.ui:close()
  eq({ "c.lua", "a.lua" }, values(list), "closing the menu did not reconcile edits")
  falsy(poppy.ui:is_open())

  _, bufnr = poppy.ui:open(list)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "b.lua", "c.lua" })
  vim.cmd("write")
  eq({ "b.lua", "c.lua" }, values(list), ":write did not reconcile edits")
  falsy(poppy.ui:is_open(), ":write did not close the menu")

  _, bufnr = poppy.ui:open(list)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "a.lua" })
  feed("q")
  eq({ "a.lua" }, values(list), "q did not save menu edits")
  falsy(poppy.ui:is_open(), "q did not close the menu")

  _, bufnr = poppy.ui:open(list)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "c.lua" })
  feed("<Esc>")
  eq({ "c.lua" }, values(list), "Esc did not save menu edits")
  falsy(poppy.ui:is_open(), "Esc did not close the menu")

  list:replace({ "a.lua", "b.lua" })
  edit(vim.fs.joinpath(env.project, "a.lua"))
  local previous_window = vim.api.nvim_get_current_win()
  _, bufnr = poppy.ui:open(list)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "b.lua", "a.lua" })
  vim.api.nvim_set_current_win(previous_window)
  eq({ "b.lua", "a.lua" }, values(list), "BufLeave did not save menu edits")
  falsy(poppy.ui:is_open(), "BufLeave did not close the menu")

  _, bufnr = poppy.ui:toggle_quick_menu(list)
  truthy(poppy.ui:is_open(), "toggle_quick_menu did not open the menu")
  poppy.ui:toggle_quick_menu(list)
  falsy(poppy.ui:is_open(), "toggle_quick_menu did not close the menu")

  list:replace({ "a.lua", "b.lua" })
  _, bufnr = poppy.ui:open(list)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "", "b.lua" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })
  feed("<CR>")
  eq({ "b.lua" }, values(list), "Enter did not reconcile the edited menu")
  eq(
    realpath(vim.fs.joinpath(env.project, "b.lua")),
    current_file(),
    "Enter selected the stale pre-reconciliation line number"
  )
  falsy(poppy.ui:is_open(), "Enter did not close the menu")
end)

test("menu offers root-relative filename completion through omnifunc", function()
  local env = make_sandbox("completion")
  write_file(vim.fs.joinpath(env.project, "build", "deep.lua"), { "deep" })
  write_file(vim.fs.joinpath(env.project, "bundle.lua"), { "bundle" })

  local poppy = setup(env)
  local list = poppy:list()
  local _, bufnr = poppy.ui:open(list)
  local completion = require("poppy.completion")

  eq("v:lua.PoppyMenuComplete", vim.bo[bufnr].omnifunc)
  eq(env.project, vim.b[bufnr].poppy_root)
  eq(0, vim.fn.luaeval("PoppyMenuComplete(_A[1], _A[2])", { 1, "bui" }))

  local empty_items = completion.omnifunc(0, "")
  eq({ "build/", "bundle.lua" }, { empty_items[1].word, empty_items[2].word })

  local root_items = completion.omnifunc(0, "bui")
  eq(1, #root_items)
  eq("build/", root_items[1].word)
  eq("build", root_items[1].abbr)
  eq(nil, root_items[1].kind)

  local nested_items = completion.omnifunc(0, "build/de")
  eq(1, #nested_items)
  eq("build/deep.lua", nested_items[1].word)
  eq(nil, nested_items[1].kind)
end)

test("tabline hides when empty and highlights the current item", function()
  local env = make_sandbox("tabline-visible")
  local first = write_file(vim.fs.joinpath(env.project, "first.lua"), { "first" })
  write_file(vim.fs.joinpath(env.project, "second.lua"), { "second" })
  local poppy = setup(env, { tabline = { enabled = true } })
  local list = poppy:list()
  local tabline = require("poppy.tabline")

  eq(0, vim.o.showtabline, "empty list did not hide the tabline")
  list:replace({ "first.lua", "second.lua" })
  eq(2, vim.o.showtabline, "nonempty list did not show the tabline")
  edit(first)
  local rendered = tabline.render()
  contains(rendered, "%1@v:lua.PoppyTabClick@", "first entry is not clickable")
  contains(rendered, "%2@v:lua.PoppyTabClick@", "second entry is not clickable")
  contains(rendered, "%#PoppyTablineCurrent# first.lua ", "current entry is not highlighted")
  falsy(rendered:find("1 first.lua", 1, true), "default tabline label includes an index")
  contains(
    rendered,
    " first.lua %X%#PoppyTabline# %2@",
    "tabline entries do not include the default padding and separator"
  )
  local current_highlight = vim.api.nvim_get_hl(0, {
    name = "PoppyTablineCurrent",
    link = false,
  })
  truthy(current_highlight.bold, "current tabline highlight is not bold")
  truthy(current_highlight.reverse, "current tabline highlight does not use reverse video")
end)

test("tabline clicks select files and labels are safe and unambiguous", function()
  local env = make_sandbox("tabline-labels")
  local first = write_file(vim.fs.joinpath(env.project, "one", "shared.lua"), { "one" })
  local second = write_file(vim.fs.joinpath(env.project, "two", "shared.lua"), { "two" })
  write_file(vim.fs.joinpath(env.project, "100%.lua"), { "percent" })
  local poppy = setup(env, { tabline = { enabled = true } })
  local list = poppy:list()
  list:replace({ "one/shared.lua", "two/shared.lua", "100%.lua" })

  local rendered = require("poppy.tabline").render()
  contains(rendered, "one/shared.lua", "duplicate basename did not retain its path")
  contains(rendered, "two/shared.lua", "second duplicate basename did not retain its path")
  contains(rendered, "100%%.lua", "percent sign was not escaped for statusline syntax")

  edit(first)
  truthy(type(_G.PoppyTabClick) == "function", "tabline click callback is missing")
  _G.PoppyTabClick(2, 1, "l", "")
  eq(second, current_file(), "clicking a tabline entry did not select it")
end)

test("tabline entries beyond fifty remain valid and clickable", function()
  local env = make_sandbox("large-tabline")
  local poppy = setup(env, { tabline = { enabled = true } })
  local list = poppy:list()
  local entries = {}
  for index = 1, 51 do
    entries[index] = string.format("file-%02d.lua", index)
  end
  list:replace(entries)

  local rendered = require("poppy.tabline").render()
  contains(rendered, "%@v:lua.PoppyTabClick_51@", "entry 51 has no extended click target")
  falsy(rendered:find("%%51@", 1, false), "entry 51 used Neovim's invalid minwid encoding")
  local parsed, parse_error = pcall(vim.api.nvim_eval_statusline, rendered, {
    use_tabline = true,
    maxwidth = 500,
  })
  truthy(parsed, parse_error)

  truthy(type(_G.PoppyTabClick_51) == "function", "extended click callback is missing")
  _G.PoppyTabClick_51(0, 1, "l", "")
  eq(
    vim.fs.joinpath(realpath(env.project), "file-51.lua"),
    current_file(),
    "extended click callback selected the wrong item"
  )

  poppy.teardown()
  eq(nil, rawget(_G, "PoppyTabClick_51"), "teardown leaked an extended click callback")
end)

test("setup is idempotent and teardown restores global options", function()
  local env = make_sandbox("teardown")
  local sentinel = function() return "sentinel" end
  vim.o.tabline = "original tabline"
  vim.o.showtabline = 1
  _G.PoppyTabClick = sentinel

  local poppy = setup(env, { tabline = { enabled = true } })
  local first_count = autocmd_count("PoppyTabline")
  truthy(first_count > 0, "tabline autocmds were not installed")
  contains(vim.o.tabline, "poppy.tabline", "Poppy did not install its tabline")

  setup(env, { tabline = { enabled = true } })
  eq(first_count, autocmd_count("PoppyTabline"), "repeated setup leaked autocmds")
  truthy(_G.PoppyTabClick ~= sentinel, "Poppy did not install its click callback")

  poppy.teardown()
  falsy(poppy.is_setup(), "teardown left Poppy configured")
  eq("original tabline", vim.o.tabline, "teardown did not restore tabline")
  eq(1, vim.o.showtabline, "teardown did not restore showtabline")
  eq(sentinel, _G.PoppyTabClick, "teardown did not restore the previous click callback")
  eq(0, autocmd_count("PoppyTabline"), "teardown left tabline autocmds behind")
end)

test("tabline reclaims and later restores a late external owner", function()
  local env = make_sandbox("late-tabline-owner")
  local poppy = setup(env, { tabline = { enabled = true } })
  local tabline = require("poppy.tabline")

  vim.o.tabline = "late owner"
  vim.o.showtabline = 1
  tabline.refresh()
  contains(vim.o.tabline, "poppy.tabline", "Poppy did not reclaim the tabline")

  poppy.teardown()
  eq("late owner", vim.o.tabline, "teardown did not restore the late tabline owner")
  eq(1, vim.o.showtabline, "teardown did not restore the late owner's visibility")
end)

test("invalid reconfiguration leaves Poppy consistently unconfigured", function()
  local env = make_sandbox("invalid-reconfigure")
  local poppy = setup(env, { tabline = { enabled = true } })
  local ok = pcall(poppy.setup, { storage = { path = "" } })
  falsy(ok, "an empty storage path was accepted")
  falsy(poppy.is_setup(), "failed reconfiguration left a stale configured flag")
  eq(0, autocmd_count("PoppyTabline"), "failed reconfiguration left tabline autocmds")
end)

mkdir(suite_root)

for _, case in ipairs(tests) do
  reset_editor()
  local ok, err = xpcall(case.callback, debug.traceback)
  local cleanup_ok, cleanup_err = xpcall(reset_editor, debug.traceback)
  if not cleanup_ok then
    ok = false
    err = tostring(err or "") .. "\ncleanup failed:\n" .. cleanup_err
  end

  if ok then
    passed = passed + 1
    vim.api.nvim_out_write("ok - " .. case.name .. "\n")
  else
    failures[#failures + 1] = { name = case.name, error = err }
    vim.api.nvim_err_writeln("not ok - " .. case.name)
  end
end

pcall(vim.fn.delete, suite_root, "rf")

if #failures > 0 then
  vim.api.nvim_err_writeln(string.format("\n%d/%d tests failed", #failures, #tests))
  for index, failure in ipairs(failures) do
    vim.api.nvim_err_writeln(string.format("\n%d) %s\n%s", index, failure.name, failure.error))
  end
  vim.cmd("cquit 1")
else
  vim.api.nvim_out_write(string.format("\n%d/%d tests passed\n", passed, #tests))
  vim.cmd("qa!")
end
