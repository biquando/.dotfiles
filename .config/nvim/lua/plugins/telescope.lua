if vim.g.vscode then return {} end

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
    'debugloop/telescope-undo.nvim',
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
    pcall(require('telescope').load_extension, 'undo')

    local tele = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sh', tele.help_tags, { desc = '[s]earch [h]elp' })
    vim.keymap.set('n', '<leader>sk', tele.keymaps, { desc = '[s]earch [k]eymaps' })
    vim.keymap.set('n', '<leader>sf', tele.find_files, { desc = '[s]earch [f]iles' })
    vim.keymap.set('n', '<leader>ss', tele.builtin, { desc = '[s]earch [s]elect Telescope' })
    vim.keymap.set('n', '<leader>sw', tele.grep_string, { desc = '[s]earch current [w]ord' })
    vim.keymap.set('n', '<leader>sg', tele.live_grep, { desc = '[s]earch by [g]rep' })
    vim.keymap.set('n', '<leader>sd', tele.diagnostics, { desc = '[s]earch [d]iagnostics' })
    vim.keymap.set('n', '<leader>sr', tele.oldfiles, { desc = '[s]earch [r]ecent Files' })
    vim.keymap.set('n', '<leader><leader>', tele.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', tele.current_buffer_fuzzy_find, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>sa', function()
      tele.find_files({ hidden = true, no_ignore = true, no_ignore_parent = true })
    end, { desc = '[s]earch [a]ll files' })

    vim.keymap.set('n', '<leader>s/', function()
      tele.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
    end, { desc = '[s]earch [/] in Open Files' })

    -- telescope-undo extension
    vim.keymap.set('n', '<leader>su', require('telescope').extensions.undo.undo, { desc = '[S]earch [U]ndo tree' })
  end
}
