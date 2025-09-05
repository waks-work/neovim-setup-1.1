return {
  { "folke/tokyonight.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({ options = { theme = "tokyonight", icons_enabled = true } })
    end,
  },
  {
    "norcalli/nvim-colorizer.lua",
    config = function() require("colorizer").setup() end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowDelimiterRed", "RainbowDelimiterYellow", "RainbowDelimiterBlue",
          "RainbowDelimiterOrange", "RainbowDelimiterGreen", "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "xiyaowong/transparent.nvim",
    config = function()
      require("transparent").setup({
        enable = true,
        extra_groups = { "NormalFloat", "NvimTreeNormal" },
      })
    end,
  },
}

