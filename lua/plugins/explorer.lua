return {
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { group_empty = true },
        hijack_netrw = true,
        update_focused_file = { enable = true, update_root = true },
      })
    end,
  },
}

