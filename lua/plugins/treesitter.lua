return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "rust", "javascript", "html",
          "css", "c", "cpp","json", "bash", "markdown", "typescript" 
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function() require("nvim-ts-autotag").setup() end,
  },
}

