if vim.g.vscode then return {} end

return {
  'esmuellert/codediff.nvim',

  cmd = 'CodeDiff',

  init = function()
    -- CodeDiff only supports left/bottom placement; move its explorer after opening.
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = vim.api.nvim_create_augroup('CodeDiffExplorerRight', { clear = true }),
      callback = function(event)
        if vim.bo[event.buf].filetype ~= 'codediff-explorer' then return end
        vim.schedule(function()
          for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
            vim.api.nvim_win_call(win, function()
              vim.cmd('wincmd L')
              vim.api.nvim_win_set_width(win, require('codediff.config').options.explorer.width)
              vim.cmd('wincmd =')
            end)
          end
        end)
      end,
    })
  end,

  keys = {
    { '<leader>cd', '<cmd>CodeDiff<CR>', desc = '[c]ode[d]iff' },
  },

  opts = {
    keymaps = {
      view = {
        focus_explorer = '<leader>v',
        next_hunk = '<C-n>',
        prev_hunk = '<C-p>',
      },
    },
    explorer = {
      view_mode = 'tree',
    },
  },
}
