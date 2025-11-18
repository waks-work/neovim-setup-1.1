-- lua/plugins/django.lua
return {
  -- Treesitter for Python + Django templates
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "python", "htmldjango" })
      end
    end,
  },

  -- LSP Config (pyright + py_lsp)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "HallerPatrick/py_lsp.nvim",
    },
    opts = {
      servers = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
      },
    },
    config = function(_, opts)
      -- Setup py_lsp
      require("py_lsp").setup({
        source_strategies = { "default", "system" },
      })
      
      -- Setup pyright with the provided options
      require("lspconfig").pyright.setup(opts.servers.pyright)
    end,
  },

  -- Debugging (DAP for Django with Mason debugpy)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
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

  -- Formatter & Linter for Django templates
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
