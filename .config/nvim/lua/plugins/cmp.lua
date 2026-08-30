if vim.g.vscode then return {} end

return {
  'saghen/blink.cmp',
  event = 'VeryLazy',
  version = '1.*',

  dependencies = {
    {
      'folke/lazydev.nvim',
      ft = 'lua',
      config = true,
    },
  },

  opts = {
    keymap = {
      preset = 'none',

      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },

      ['<C-space>'] = { 'accept', 'show', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'accept', 'fallback' },
      -- ['<Enter>'] = { 'accept', 'fallback' },

      ['<C-x>'] = { 'cancel', 'fallback' },
      -- ['<Esc>'] = { 'cancel', 'fallback' },

      -- ['<C-u>'] = { 'scroll_signature_up', 'fallback' },
      -- ['<C-d>'] = { 'scroll_signature_down', 'fallback' },
      -- ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
    },

    sources = {
      default = { 'lazydev', 'lsp', 'snippets', 'path', 'buffer' },
      per_filetype = { poppy = { 'omni' } }, -- poppy path autocompletion
      providers = {
        -- lazydev completions
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },

        -- poppy: trigger blink on '/' (ends of directory paths)
        omni = {
          override = {
            get_trigger_characters = function() return { '/' } end,
          },
        },
      },
    },

    fuzzy = { implementation = 'prefer_rust' },

    signature = { enabled = true },
  },

  config = function(_, opts)
    local blink = require('blink.cmp')
    blink.setup(opts)

    -- In the poppy menu, trigger blink on an empty line
    local group = vim.api.nvim_create_augroup('BlinkCmpPoppy', { clear = true })
    vim.api.nvim_create_autocmd('InsertEnter', {
      group = group,
      callback = function(event)
        if vim.bo[event.buf].filetype ~= 'poppy' then return end

        vim.schedule(function()
          if vim.api.nvim_get_current_buf() == event.buf
            and vim.api.nvim_get_mode().mode == 'i'
            and vim.api.nvim_get_current_line() == ''
          then
            blink.show({ providers = { 'omni' } })
          end
        end)
      end,
    })
  end,
}
