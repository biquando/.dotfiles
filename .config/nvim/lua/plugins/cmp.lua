return {
  'saghen/blink.cmp',
  event = 'VimEnter',
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
      ['<C-x>'] = { 'cancel', 'fallback' },
    },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 0 },
    },

    sources = {
      default = { 'lazydev', 'lsp', 'snippets', 'path', 'buffer' },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
      },
    },

    fuzzy = { implementation = 'prefer_rust' },

    signature = { enabled = true },
  },
}
