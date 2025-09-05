return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

        -- Diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>b", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>m", vim.diagnostic.setloclist, opts)

        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end



      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "html", "cssls", "jsonls",
          "pyright", "rust_analyzer", "ts_ls",

          "bashls", "clangd", "marksman",
        }
      })

      local servers = {
        "lua_ls", "pyright", "rust_analyzer", "ts_ls",
        "html", "cssls", "jsonls", "clangd", "bashls", "marksman",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
}
