return {
  -- Mason core
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = true,
  },

  -- Mason LSP + core LSP config
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local border_style = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" } -- 🔹 Box border style
      local icons = {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = " ",
      }

      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#101010" })
      vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#6b6b6b", bg = "#101010" })

      -- 🔹 Global diagnostic appearance
      vim.diagnostic.config({
        underline = true,
        update_in_insert = true,
        severity_sort = true,
        virtual_text = false, -- disable inline spam
        float = {
          border = border_style,
          focusable = false,
          source = "always",
          header = { "  Diagnostics", "Title" },
          prefix = function(diagnostic, i)
            return string.format("%s%d. ", icons[diagnostic.severity], i)
          end,
          max_width = 80,
        },
      })

      -- 🔹 Diagnostic signs in gutter
      for type, icon in pairs({ Error = " ", Warn = " ", Hint = " ", Info = " " }) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      local on_attach = function(_, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }

        -- LSP keymaps
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        -- Diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        vim.keymap.set("n", "<leader>fe", function()
          vim.diagnostic.open_float(nil, {
            focus = false,
            scope = "cursor",
            border = border_style,
            header = { "  Diagnostics", "Title" },
            prefix = function(diagnostic, i)
              return string.format("%s%d. ", icons[diagnostic.severity], i)
            end,
          })
        end, opts)

        -- 🔹 Auto-popup diagnostics (like VSCode hover)
        vim.api.nvim_create_autocmd("CursorHold", {
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(nil, {
              focus = false,
              scope = "cursor",
              border = border_style,
              header = { "  Diagnostics", "Title" },
              prefix = function(diagnostic, i)
                return string.format("%s%d. ", icons[diagnostic.severity], i)
              end,
            })
          end,
        })

        -- Autoformat before save
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ async = false })
          end,
        })
      end

      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls", "html", "cssls", "jsonls",
          "rust_analyzer", "ts_ls", "pyright",
          "bashls", "clangd", "marksman",
        },
      })

      local servers = {
        "lua_ls", "pyright", "rust_analyzer", "ts_ls",
        "html", "cssls", "jsonls", "clangd", "bashls", "marksman",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          on_attach = on_attach,
          capabilities = capabilities,
        })
      end
    end,
  },

  -- Debugger (DAP + UI + Mason)
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
        ensure_installed = { "codelldb", "python", "node2" },
        automatic_setup = true,
      })

      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      -- Auto open/close UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      -- Debug keymaps
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
    end,
  },

  -- LSP UI improvements (hover, peek, diagnostics)
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    config = function()
      require("lspsaga").setup({
        ui = { border = "rounded", winblend = 10 },
        diagnostic = { show_code_action = true, show_source = true },
      })

      vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover Docs" })
      vim.keymap.set("n", "gl", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Line Diagnostics" })
      vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek Definition" })
    end,
  },

  -- VSCode-like polished UI for LSP docs & commandline
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        lsp = { hover = { enabled = true }, signature = { enabled = true } },
        presets = {
          lsp_doc_border = true,
          command_palette = true,
        },
      })
    end,
  },

  -- Optional: LSP progress like VSCode
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach",
    config = true,
  },
}
