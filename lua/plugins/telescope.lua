return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
    end,
  },
  {
    "isak102/telescope-git-file-history.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "tpope/vim-fugitive" },
    config = function()
      require("telescope").load_extension("git_file_history")
    end,
  },
}

