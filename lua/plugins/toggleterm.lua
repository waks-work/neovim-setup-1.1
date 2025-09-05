
-- lua/config/lazygit.lua
return {
  "kdheepak/lazygit.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- Keymap to open LazyGit
    vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Open LazyGit" })
  end,
}


