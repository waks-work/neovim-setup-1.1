return {
  {
    "rust-lang/rust.vim",
    ft = "rust",
    config = function()
      -- Autoformat Rust files on save
      vim.g.rustfmt_autosave = 1
      vim.g.rust_recommended_style = 1

      -- Keymap for manual formatting
      vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", { desc = "Format Rust code" })
    end,
  },
  {
    "simrat39/rust-tools.nvim", -- Adds extra Rust features
    ft = "rust",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local rt = require("rust-tools")
      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr, silent = true }
            vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, opts)            -- Run Rust code/tests
            vim.keymap.set("n", "<leader>rl", rt.inlay_hints.toggle_inlay_hints, opts) -- Toggle hints
          end,
        },
      })
    end,
  },
}
