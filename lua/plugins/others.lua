
return {
  { "mattn/emmet-vim" },

  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "folke/which-key.nvim",
    config = function()
      local wk = require("which-key")

      wk.setup({
        -- new API: explicitly say what triggers should open which-key
        triggers = {
          { "<leader>", mode = { "n", "v" } }, -- leader mappings in normal/visual
          { "<C-Y>",    mode = "i" },          -- insert mode prefix
        },
      })
    end,
  },

  {
    "lewis6991/hover.nvim",
    config = function()
      require("hover").setup({
        init = function()
          require("hover.providers.lsp")
        end,
        preview_opts = { border = "single" },
        title = true,
        mouse_providers = { "LSP" },
        mouse_delay = 1000,
      })

      vim.keymap.set("n", "K", require("hover").hover, { desc = "hover.nvim" })
      vim.keymap.set("n", "<MouseMove>", require("hover").hover_mouse, { desc = "hover.nvim (mouse)" })
      vim.o.mousemoveevent = true
    end,
  },
}
 


