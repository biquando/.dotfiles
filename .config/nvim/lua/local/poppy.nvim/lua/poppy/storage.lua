local M = {}

local VERSION = 1
local uv = vim.uv or vim.loop

local options = {
  path = vim.fs.joinpath(vim.fn.stdpath("data"), "poppy"),
}

local function expand_path(value)
  if value:sub(1, 1) ~= "/" and not value:match("^%a:[/\\]") then
    value = vim.fs.joinpath(vim.fn.getcwd(), value)
  end
  return vim.fs.normalize(value)
end

local function is_missing(err)
  return type(err) == "string" and err:match("ENOENT") ~= nil
end

local function is_list(value)
  local predicate = vim.islist
  return type(value) == "table" and predicate(value)
end

local function close(fd)
  if fd ~= nil then
    pcall(uv.fs_close, fd)
  end
end

local function read_file(filename)
  local fd, open_err = uv.fs_open(filename, "r", 438)
  if not fd then
    if is_missing(open_err) then
      return nil, nil
    end
    return nil, open_err or ("unable to open " .. filename)
  end

  local stat, stat_err = uv.fs_fstat(fd)
  if not stat then
    close(fd)
    return nil, stat_err or ("unable to stat " .. filename)
  end

  local contents, read_err = uv.fs_read(fd, stat.size, 0)
  close(fd)
  if contents == nil then
    return nil, read_err or ("unable to read " .. filename)
  end

  return contents, nil
end

local function ensure_directory(directory)
  local ok, result = pcall(vim.fn.mkdir, directory, "p")
  if not ok then
    return nil, result
  end

  local stat, stat_err = uv.fs_stat(directory)
  if not stat or stat.type ~= "directory" then
    return nil, stat_err or (directory .. " is not a directory")
  end

  return true
end

local function write_atomic(filename, contents)
  local directory = vim.fs.dirname(filename)
  local ok, mkdir_err = ensure_directory(directory)
  if not ok then
    return nil, mkdir_err
  end

  local temporary = string.format(
    "%s.tmp.%d.%s",
    filename,
    vim.fn.getpid(),
    tostring(uv.hrtime())
  )
  local fd, open_err = uv.fs_open(temporary, "w", 384)
  if not fd then
    return nil, open_err or ("unable to open temporary file " .. temporary)
  end

  local written, write_err = uv.fs_write(fd, contents, 0)
  if not written or written ~= #contents then
    close(fd)
    pcall(uv.fs_unlink, temporary)
    return nil, write_err or ("unable to write temporary file " .. temporary)
  end

  local synced, sync_err = uv.fs_fsync(fd)
  close(fd)
  if not synced then
    pcall(uv.fs_unlink, temporary)
    return nil, sync_err or ("unable to sync temporary file " .. temporary)
  end

  local renamed, rename_err = uv.fs_rename(temporary, filename)
  if not renamed then
    pcall(uv.fs_unlink, temporary)
    return nil, rename_err or ("unable to replace " .. filename)
  end

  return true
end

function M.setup(storage_options)
  if type(storage_options) == "string" then
    storage_options = { path = storage_options }
  end
  storage_options = storage_options or {}

  local configured_path = storage_options.path
    or vim.fs.joinpath(vim.fn.stdpath("data"), "poppy")
  assert(
    type(configured_path) == "string" and configured_path ~= "",
    "poppy storage.path must be a non-empty string"
  )

  options = vim.tbl_deep_extend("force", {}, storage_options)
  options.path = expand_path(configured_path)
  return vim.deepcopy(options)
end

function M.file_for_root(root)
  assert(type(root) == "string" and root ~= "", "poppy storage root must be a non-empty string")
  return vim.fs.joinpath(options.path, vim.fn.sha256(root) .. ".json")
end

function M.load(root)
  local ok, filename = pcall(M.file_for_root, root)
  if not ok then
    return {}, filename
  end

  local read_ok, contents, read_err = pcall(read_file, filename)
  if not read_ok then
    return {}, contents
  end
  if contents == nil then
    return {}, read_err
  end
  if contents == "" then
    return {}, "poppy state file is empty: " .. filename
  end

  local decoded_ok, decoded = pcall(vim.json.decode, contents)
  if not decoded_ok then
    return {}, string.format("unable to decode poppy state %s: %s", filename, decoded)
  end
  if type(decoded) ~= "table" then
    return {}, "invalid poppy state in " .. filename
  end
  if decoded.version ~= VERSION then
    return {}, string.format(
      "unsupported poppy state version in %s: %s",
      filename,
      tostring(decoded.version)
    )
  end
  if decoded.root ~= root then
    return {}, "poppy state root does not match requested root: " .. filename
  end
  if not is_list(decoded.items) then
    return {}, "invalid poppy item list in " .. filename
  end

  return decoded.items, nil
end

function M.save(root, items)
  local ok, filename = pcall(M.file_for_root, root)
  if not ok then
    return nil, filename
  end
  if not is_list(items) then
    return nil, "poppy storage items must be a list"
  end

  local encoded_ok, encoded = pcall(vim.json.encode, {
    version = VERSION,
    root = root,
    items = items,
  })
  if not encoded_ok then
    return nil, "unable to encode poppy state: " .. tostring(encoded)
  end

  local write_ok, result, write_err = pcall(write_atomic, filename, encoded .. "\n")
  if not write_ok then
    return nil, result
  end
  return result, write_err
end

return M
