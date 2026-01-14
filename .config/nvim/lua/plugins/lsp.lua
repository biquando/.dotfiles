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

    vim.lsp.config('texlab', {
      settings = {
        texlab = {
          build = {
            executable = 'tectonic',
            args = { '-X', 'build', '--keep-logs', '--keep-intermediates' },
            onSave = false,
          },
        },
      },
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
      'ocamllsp',                 -- ocaml
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

          map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction')
          map('gr', tele.lsp_references, '[g]oto [r]eferences')
          map('gI', tele.lsp_implementations, '[g]oto [I]mplementation')
          map('gd', tele.lsp_definitions, '[g]oto [d]efinition')
          map('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')
          -- map('gs', tele.lsp_document_symbols, '[g]oto document [s]ymbols')
          map('gl', vim.diagnostic.open_float, 'Open Diagnostic')

          map('<leader>sF', function() tele.lsp_document_symbols({symbols='function'}) end, '[s]earch [F]unctions')
          map('<leader>sW', tele.lsp_dynamic_workspace_symbols, '[s]earch [W]orkspace Symbols')
        end,
      })

      vim.diagnostic.config({ virtual_text = true })
  end,
}
