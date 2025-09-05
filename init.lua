
-- ============================
--  LAZY.NVIM BOOTSTRAP
-- =============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================
--  LEADER KEY
-- =============================
vim.g.mapleader = " "

-- =============================
--  BASIC SETTINGS
-- =============================
vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.env.PATH = vim.fn.stdpath('data') .. '/mason/bin:' .. vim.env.PATH

-- =============================
--  LOAD LAZY.NVIM WITH PLUGINS
-- =============================
require("lazy").setup("plugins")

-- =============================
--  LOAD CORE CONFIGURATIONS
-- =============================
require("core.options")
require("core.keymaps")
require("core.colors")

-- =============================
--  COMPLETION SETUP
-- =============================
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fallback() end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then luasnip.jump(-1)
      else fallback() end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' }, { name = 'luasnip' },
    { name = 'buffer' }, { name = 'path' }
  },
})

-- =============================
--  LIGHTWEIGHT AI CHAT (WAKS AI)
-- =============================
local ok, waks = pcall(require, "ai.ai_chat")
if ok then
  waks.setup_keymaps()
  
  local waks_ai = require("ai.waks_ai")
  local waks_ui = require("ai.ui")

  vim.keymap.set("n", "<leader>wo", function()
      waks_ui.open_chat()
  end, { desc = "Open Waks AI Chat" })

  vim.keymap.set("n", "<leader>wp", function()
      waks_ai.prompt()
  end, { desc = "Prompt Waks AI" })
else
  vim.notify("Waks AI not found", vim.log.levels.WARN)
end


