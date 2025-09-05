
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- latest stable
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/ObsidianVault", -- change this to your vault
        },
      },
      completion = {
        nvim_cmp = true, -- integrate with cmp
      },
      daily_notes = {
        folder = "daily",
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- Keymaps
      local map = vim.keymap.set
      local wk_opts = { noremap = true, silent = true }

      map("n", "<leader>dn", "<cmd>ObsidianNew<CR>", { desc = "New Obsidian note", unpack(wk_opts) })
      map("n", "<leader>dt", "<cmd>ObsidianToday<CR>", { desc = "Today's daily note", unpack(wk_opts) })
      map("n", "<leader>dy", "<cmd>ObsidianYesterday<CR>", { desc = "Yesterday's daily note", unpack(wk_opts) })
      map("n", "<leader>ds", "<cmd>ObsidianSearch<CR>", { desc = "Search notes", unpack(wk_opts) })
      map("n", "<leader>do", "<cmd>ObsidianOpen<CR>", { desc = "Open note in Obsidian app", unpack(wk_opts) })
    end,
  },
}
