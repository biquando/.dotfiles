if vim.g.vscode then return {} end

return {
  'ThePrimeagen/harpoon',
  commit = '1bc17e3',

  config = function()
    -- SECTION: Options
    require('harpoon').setup({
      menu = {
        width = math.min(80, vim.api.nvim_win_get_width(0) - 10),
      },
      tabline = true,
    })

    -- need to call this because tabline messes with the colors
    require('user.colors').set_colors()

    -- SECTION: Keymaps

    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')
    local term = require('harpoon.term')

    -- Add / list files
    vim.keymap.set('n', '<leader>a', function()
      mark.add_file()
      vim.cmd('redrawtabline')
    end, { desc = '[A]dd file to harpoon' })
    vim.keymap.set({ 'n', 't' }, '<C-e>', ui.toggle_quick_menu)

    -- Goto file
    vim.keymap.set({ 'n', 't' }, '<C-h>', function() ui.nav_file(1) end)
    vim.keymap.set({ 'n', 't' }, '<C-j>', function() ui.nav_file(2) end)
    vim.keymap.set({ 'n', 't' }, '<C-k>', function() ui.nav_file(3) end)
    vim.keymap.set({ 'n', 't' }, '<C-l>', function() ui.nav_file(4) end)

    -- Left / right
    vim.keymap.set('n', '<S-h>', function() ui.nav_prev() end)
    vim.keymap.set('n', '<S-l>', function() ui.nav_next() end)

    -- Terminals
    local enterTerm = function(id)
      term.gotoTerminal(id)
      vim.cmd('startinsert')
      vim.o.scrolloff = 8 -- HACK: For some reason opening the terminal *twice*
                          -- sets the scrolloff to zero. See user/options.lua.
    end
    vim.keymap.set('n', '<C-n>', function()
      local count = vim.v.count
      if count == 0 then
        count = SETTINGS.termid
      else
        SETTINGS.termid = count
      end
      enterTerm(count)
    end)
  end,
}
