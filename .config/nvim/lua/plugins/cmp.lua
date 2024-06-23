local cmp_exists, cmp = pcall(require, 'cmp')
local luasnip_exists, luasnip = pcall(require, 'luasnip')
if not (cmp_exists and luasnip_exists) then
  return
end

luasnip.config.setup({})

cmp.setup({

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = 'menu,menuone,noinsert' },

  mapping = cmp.mapping.preset.insert {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.confirm({ select = false }),

    -- Jump left in completion fields
    ['<C-h>'] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { 'i', 's' }),

    -- Jump right in completion fields
    ['<C-l>'] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { 'i', 's' }),
  },

  sources = {
    { name = 'nvim_lsp' },
    { name = 'path' },
  },

})
