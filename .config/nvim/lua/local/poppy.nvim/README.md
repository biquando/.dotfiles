# poppy.nvim

Poppy is a small, dependency-free Neovim file switcher inspired by
[Harpoon](https://github.com/ThePrimeagen/harpoon/tree/harpoon2). It keeps one
ordered file list per working directory and shows that list as a clickable
tabline.

## Features

- An editable floating menu: reorder, remove, or type paths directly.
- Add the current file and jump by number, next, or previous.
- Automatic JSON persistence, isolated by working directory.
- A clickable tabline that is hidden for empty lists.
- A distinct highlight for the current file.
- No dependencies.

## Requirements

- Neovim 0.12 or newer

## Setup

Add the plugin with your package manager, then call `setup()`.

With lazy.nvim:

```lua
{
  dir = vim.fn.stdpath('config') .. '/lua/local/poppy.nvim',
  config = function()
    local poppy = require('poppy')
    poppy.setup()

    vim.keymap.set("n", "<leader>a", function()
      poppy:list():add()
    end, { desc = "Add file to Poppy" })

    vim.keymap.set("n", "<C-e>", function()
      poppy.ui:toggle_quick_menu(poppy:list())
    end, { desc = "Toggle Poppy menu" })

    for index, key in ipairs({ "h", "j", "k", "l" }) do
      vim.keymap.set("n", "<C-" .. key .. ">", function()
        poppy:list():select(index)
      end, { desc = "Open Poppy file " .. index })
    end

    vim.keymap.set("n", "<S-h>", function()
      poppy:list():prev()
    end, { desc = "Previous Poppy file" })

    vim.keymap.set("n", "<S-l>", function()
      poppy:list():next()
    end, { desc = "Next Poppy file" })
  end,
}
```

## Menu

The menu is a normal editable buffer. Each nonblank line is a path relative to
the list's working directory, or an absolute path for files outside it.

| Key / command | Action |
| --- | --- |
| `<CR>` | Save edits and open the entry under the cursor |
| `q` or `<Esc>` | Save edits and close |
| `:write` | Save edits and close |

Deleting lines removes entries; moving lines reorders them. Duplicate and blank
lines are discarded when the menu is saved.

The menu sets a root-aware `omnifunc` for filename completion. Use
`<C-x><C-o>` with Neovim's built-in completion, or enable the generic omni
source in your completion plugin.

## Commands

| Command | Action |
| --- | --- |
| `:PoppyAdd` | Add the current file |
| `:PoppyToggle` | Open or close the menu |
| `:PoppySelect {n}` | Open entry `{n}` |
| `:PoppyNext` | Open the next entry, wrapping at the end |
| `:PoppyPrev` | Open the previous entry, wrapping at the start |

Calling a command before `setup()` lazily applies the defaults.

## Configuration

These are the defaults:

```lua
require("poppy").setup({
  settings = {
    -- The exact working directory is the project/list key by default.
    key = function()
      return vim.fn.getcwd()
    end,
  },
  storage = {
    path = vim.fs.joinpath(vim.fn.stdpath("data"), "poppy"),
  },
  menu = {
    width = 80,
    height = 8,
    border = "rounded",
    title = " Poppy ",
  },
  navigation = {
    wrap = true, -- :PoppyNext and :PoppyPrev wrap
    restore_cursor = true, -- restore cursor location when opening file
  },
  tabline = {
    enabled = true,
    show_index = false,
    padding = 1,
    separator = " ",
    formatter = nil,
  },
})
```

`menu.width` and `menu.height` accept an absolute cell count; values in `(0, 1]`
are treated as a fraction of the editor size. A tabline formatter can return any
label text:

```lua
require("poppy").setup({
  tabline = {
    formatter = function(item, index, root)
      return string.format("%d %s", index, item.value)
    end,
  },
})
```

Poppy owns Neovim's global `tabline` and `showtabline` options while it is set
up. It sets `showtabline` to `2` for a nonempty list and `0` for an empty list;
`require("poppy").teardown()` restores the previous values. If an edited menu
cannot be persisted, teardown stops and leaves it open; pass `{ force = true }`
to discard those edits explicitly.

## Persistence

Each directory is stored in its own SHA-256-named JSON file below
`stdpath("data")/poppy`. Writes happen immediately after list or menu changes.
Change `settings.key` to group directories differently, such as by Git root.

## Highlights

- `PoppyTabline` links to `TabLine`.
- `PoppyTablineCurrent` uses bold reverse video so it remains visible across
  colorschemes.
- `PoppyTablineFill` links to `TabLineFill`.

The menu maps its floating-window background to `Normal`, so it follows the
current editor background.

Use `:help poppy` for the complete API reference.
