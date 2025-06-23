return {
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable('make') == 1
      end,
    },
    'nvim-telescope/telescope-ui-select.nvim',
  },

  config = function()
    require('telescope').setup({
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    })
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local tele = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sh', tele.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', tele.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', tele.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', tele.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', tele.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', tele.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', tele.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', tele.oldfiles, { desc = '[S]earch [R]ecent Files' })
    vim.keymap.set('n', '<leader><leader>', tele.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', tele.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>sa', function()
      tele.find_files({ hidden = true, no_ignore = true, no_ignore_parent = true })
    end, { desc = '[S]earch [A]ll files' })

    vim.keymap.set('n', '<leader>s/', function()
      tele.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
    end, { desc = '[S]earch [/] in Open Files' })
  end
}
