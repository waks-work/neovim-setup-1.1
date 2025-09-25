return {
  -- Mason manages DAP adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "codelldb", -- C, C++, Rust
          "python",   -- debugpy
          "node2",    -- JS/TS
        },
        automatic_setup = true,
      })

      local dap, dapui = require("dap"), require("dapui")

      dapui.setup()

      -- Auto open/close dap-ui
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps for debugging
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP Conditional Breakpoint" })
    end,
  },

  -- Hover diagnostics + inlay hints
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        ui = { border = "rounded" },
        diagnostic = { show_code_action = true },
        symbol_in_winbar = { enable = true },
      })

      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
      vim.keymap.set("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
      vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", opts)
      vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
      vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)

      -- Auto-enable inlay hints if supported
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end,
  },

  -- Fancy commandline + UI like LazyVim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        cmdline = {
          view = "cmdline_popup",
          format = {
            search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = "", lang = "regex" },
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
          lsp_doc_border = true,
        },
      })
    end,
  },
}
