-- ui.lua
return {
  -- Theme + icons
  { "folke/tokyonight.nvim" },
  { "nvim-tree/nvim-web-devicons" },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight", icons_enabled = true },
      })
    end,
  },

  -- Color highlighting
  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },

  -- Rainbow parentheses
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      vim.g.rainbow_delimiters = {
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- Transparency
  {
    "xiyaowong/transparent.nvim",
    config = function()
      require("transparent").setup({
        enable = true,
        extra_groups = { "NormalFloat", "NvimTreeNormal" },
      })
    end,
  },

  --------------------------------------------------------------------
  -- 🔥 Debugger UI Enhancements (kept here, debug.lua untouched)
  --------------------------------------------------------------------
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        highlight_changed_variables = true,
        show_stop_reason = true,
        virt_text_pos = "eol", -- end of line like VSCode
      })
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")

      dapui.setup({
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⤵",
            step_over = "⤴",
            step_out = "⤶",
            step_back = "⬅",
            run_last = "↻",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
        icons = { expanded = "▾", collapsed = "▸" },
        layouts = {
          {
            elements = { "scopes", "breakpoints", "stacks", "watches" },
            size = 0.25,
            position = "left",
          },
          {
            elements = { "repl", "console" },
            size = 0.25,
            position = "bottom",
          },
        },
        floating = {
          max_height = 0.3,
          max_width = 0.5,
          border = "rounded",
          mappings = { close = { "q", "<Esc>" } },
        },
        render = { indent = 2, max_type_length = 60 },
      })

      -- Auto open/close dap-ui (kept here for smoothness)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Highlight groups for a smoother VSCode-like UI
      vim.api.nvim_set_hl(0, "DapUIVariable", { fg = "#82aaff" })
      vim.api.nvim_set_hl(0, "DapUIScope", { fg = "#c792ea" })
      vim.api.nvim_set_hl(0, "DapUIValue", { fg = "#c3e88d" })
      vim.api.nvim_set_hl(0, "DapUIStoppedThread", { fg = "#ffcb6b" })
      vim.api.nvim_set_hl(0, "DapUIType", { fg = "#89ddff" })
    end,
  },
}
