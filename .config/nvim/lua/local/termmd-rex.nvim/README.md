# termmd-rex.nvim

Preview the current file with `termmd` in a Rex layer. The buffer is saved
before opening the preview, and the layer closes when `termmd` exits successfully.

Requires Neovim 0.10+, `rex` and `termmd` on PATH, and Neovim running inside Rex
with `REX_SESSION` set.

```lua
require('termmd-rex').setup()
```

Run `:TermmdRexPreview` to open a preview. The plugin does not set any keymaps.
To choose a mapping in your Neovim config:

```lua
vim.keymap.set('n', '<leader>mp', '<cmd>TermmdRexPreview<CR>', {
  desc = 'Preview current file with termmd in Rex',
})
```

The Lua API is also available as `require('termmd-rex').preview()`.
