-- TODO: make sure that all required plugins are installed

local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  local tele_builtin = require('telescope.builtin')

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', tele_builtin.lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>ds', tele_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('gl', vim.diagnostic.open_float, 'Open Diagnostic')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')

  -- Create a command `:Format` local to the LSP buffer
  -- vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
  --   vim.lsp.buf.format()
  -- end, { desc = 'Format current buffer with LSP' })
  -- NOTE: See plugins.conform for formatting
end

vim.diagnostic.config({ virtual_text = true })

-- SECTION: Servers

local servers = {
  lua_ls = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {
          'vim',
          'require'
        },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}

-- nvim-cmp supports additional completion capabilities, so broadcast to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- -- Ensure the servers above are installed
-- local mason_lspconfig = require('mason-lspconfig')
--
-- mason_lspconfig.setup({
--   ensure_installed = vim.tbl_keys(servers),
--   handlers = {
--     function(server_name)
--       require('lspconfig')[server_name].setup({
--         capabilities = capabilities,
--         on_attach = on_attach,
--         settings = servers[server_name],
--         filetypes = (servers[server_name] or {}).filetypes,
--       })
--     end,
--
--     ['clangd'] = function()
--       require('lspconfig').clangd.setup({
--         cmd = { 'clangd', '--clang-tidy' },
--         capabilities = capabilities,
--         on_attach = on_attach,
--       })
--     end
--   },
-- })

vim.lsp.config['luals'] = {
  cmd = { '/Users/biqua/.local/share/nvim/mason/bin/lua-language-server' },
  capabilities = capabilities,
  filetypes = { 'lua' },
  settings = servers.lua_ls,
  on_attach = on_attach,
}

vim.lsp.config['clangd'] = {
  cmd = { 'clangd', '--clang-tidy' },
  capabilities = capabilities,
  filetypes = { 'c', 'cpp' },
  on_attach = on_attach,
}

vim.lsp.config['pyright'] = {
  cmd = { '/Users/biqua/.local/share/nvim/mason/bin/pyright' },
  root_markers = { '.git' },
  capabilities = capabilities,
  filetypes = { 'python' },
  on_attach = on_attach,
}

vim.lsp.enable('luals')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
