if vim.g.vscode then return {} end

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    { 'j-hui/fidget.nvim',       config = true },
  },

  config = function()
    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
          }
        }
      }
    })

    -- See https://github.com/neovim/nvim-lspconfig/tree/master/lsp
    -- for a list of preconfigured lsp names from nvim-lspconfig.
    vim.lsp.enable({
      'bashls',                   -- bash
      'clangd',                   -- C/C++
      'fish_lsp',                 -- fish
      'html',                     -- html
      'jsonls',                   -- json
      'lua_ls',                   -- lua
      -- 'pyrefly',                  -- python
      'pyright',                  -- python
      'rust_analyzer',            -- rust
      'texlab',                   -- latex
      'vimls',                    -- vimscript
    })

    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local tele = require('telescope.builtin')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('gr', tele.lsp_references, '[G]oto [R]eferences')
          map('gI', tele.lsp_implementations, '[G]oto [I]mplementation')
          map('gd', tele.lsp_definitions, '[G]oto [d]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', tele.lsp_document_symbols, 'Open Document Symbols')
          map('gW', tele.lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('gl', vim.diagnostic.open_float, 'Open Diagnostic')
        end,
      })

      vim.diagnostic.config({ virtual_text = true })
  end,
}
