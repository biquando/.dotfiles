require("git"):setup {
  -- Order of status signs showing in the linemode
  order = 1500,
}

require("session"):setup({
  sync_yanked = true,
})

-- Keep mouse scrolling independent of the hovered file. Yazi's native folder
-- offset is read-only, so share a display window between the list and markers.
local list_scroll = {}

local function current_window(folder, tab, height)
  local tab_id, cwd = tab.id.value, tostring(folder.cwd)
  local count = #folder.files
  if list_scroll.tab ~= tab_id
    or list_scroll.cwd ~= cwd
    or list_scroll.cursor ~= folder.cursor
    or list_scroll.native_offset ~= folder.offset
    or list_scroll.count ~= count
  then
    list_scroll = {
      tab = tab_id,
      cwd = cwd,
      cursor = folder.cursor,
      native_offset = folder.offset,
      count = count,
      offset = folder.offset,
    }
  end

  list_scroll.offset = math.max(0, math.min(list_scroll.offset, count - height))
  local window = {}
  for i = list_scroll.offset + 1, math.min(count, list_scroll.offset + height) do
    window[#window + 1] = folder.files[i]
  end

  return setmetatable({ window = window, offset = list_scroll.offset }, {
    __index = function(_, key) return folder[key] end,
  })
end

local current_new = Current.new
function Current:new(area, tab)
  local me = current_new(self, area, tab)
  me._folder = current_window(tab.current, tab, area.h)
  return me
end

local markers_new = Markers.new
function Markers:new(chunks, tab)
  local me = markers_new(self, chunks, tab)
  me._children[2]._folder = current_window(tab.current, tab, chunks[2].h)
  return me
end

function Current:scroll(_, step)
  if step == 0 or self._area.h == 0 then
    return
  end

  local folder = cx.active.current
  current_window(folder, cx.active, self._area.h)
  local direction = step > 0 and 1 or -1
  list_scroll.offset = math.max(0, math.min(
    list_scroll.offset + direction,
    #folder.files - self._area.h
  ))
  ui.render()
end

function Preview:scroll(_, step)
  local hovered = cx.active.current.hovered
  if not hovered or step == 0 then
    return
  end

  local direction = step > 0 and 1 or -1

  -- Keep scrolling to one seek unit while respecting each previewer's handler.
  ya.emit("seek", { direction })
end
