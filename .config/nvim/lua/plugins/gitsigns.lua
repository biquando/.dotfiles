return {
  'lewis6991/gitsigns.nvim',
  opts = {
    on_attach = function(bufnr)
      local git = require('gitsigns')
      local keymapPrefix = '<leader>g'
      local map = function(key, f, desc)
        vim.keymap.set('n', keymapPrefix .. key, f, {
          buffer = bufnr,
          desc = '[g]it: ' .. desc,
        })
      end

      map('n', git.next_hunk, '[n]ext hunk')
      map('N', git.prev_hunk, 'previous hunk')
      map('p', git.preview_hunk, '[p]review hunk')
      map('s', git.stage_hunk, '[s]tage hunk')
      map('r', git.reset_hunk, '[r]eset hunk')
      map('b', git.blame, '[b]lame')
    end,
  },
}
