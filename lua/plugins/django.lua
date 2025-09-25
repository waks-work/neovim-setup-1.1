-- lua/plugins/django.lua
return {
  -- Treesitter for Python + Django templates
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "python", "htmldjango" },
      highlight = { enable = true },
    },
  },

  -- LSP Config (pyright + py_lsp)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "HallerPatrick/py_lsp.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")

      lspconfig.pyright.setup({
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic", -- change to "strict" if needed
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      require("py_lsp").setup({
        source_strategies = { "default", "system" },
      })
    end,
  },

  -- Debugging (DAP for Django with Mason debugpy)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- 🔥 REQUIRED dependency for dap-ui
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local dap_python = require("dap-python")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Get Mason's debugpy path
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      dap_python.setup(mason_path)

      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Django Runserver",
          program = "${workspaceFolder}/manage.py",
          args = { "runserver", "--noreload" },
          console = "integratedTerminal",
        },
      }
    end,
  },

  -- Formatter & Linter for Django templates (djlint + black + isort)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        htmldjango = { "djlint" },
        python = { "isort", "black" },
      },
    },
  },
}
