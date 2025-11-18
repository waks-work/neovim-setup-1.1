return {
  {
    "rust-lang/rust.vim",
    ft = "rust",
    config = function()
      -- Autoformat Rust files on save
      vim.g.rustfmt_autosave = 1
      vim.g.rust_recommended_style = 1

      -- Keymap for manual formatting
      vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", { desc = "Format Rust code" })
    end,
  },

  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap", -- Debug Adapter Protocol
      "nvim-lua/plenary.nvim", -- Required for some rust-tools features
    },
    config = function()
      local rt = require("rust-tools")
      local dap = require("dap")

      -- Configure rust-analyzer for large codebases
      rt.setup({
        tools = {
          executor = require("rust-tools/executors").termopen, -- Better execution
          reload_workspace_from_cargo_toml = true,             -- Auto-reload on Cargo.toml changes
          inlay_hints = {
            auto = true,
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "← ",
            other_hints_prefix = "→ ",
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
            highlight = "Comment",
          },
          hover_actions = {
            border = {
              { "╭", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╮", "FloatBorder" },
              { "│", "FloatBorder" },
              { "╯", "FloatBorder" },
              { "─", "FloatBorder" },
              { "╰", "FloatBorder" },
              { "│", "FloatBorder" },
            },
            max_width = 100,
            max_height = 30,
            auto_focus = true,
          },
        },

        server = {
          on_attach = function(_, bufnr)
            local opts = { buffer = bufnr, silent = true, desc = "Rust LSP" }

            -- Enhanced Rust specific keymaps - FIXED
            vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, opts)
            vim.keymap.set("n", "<leader>rl", rt.inlay_hints.toggle_inlay_hints, opts)
            vim.keymap.set("n", "<leader>rh", rt.hover_actions.hover_actions, opts)
            vim.keymap.set("n", "<leader>ra", rt.code_action_group.code_action_group, opts)
            -- Remove debuggables if it's causing issues
            vim.keymap.set("n", "<leader>rp", rt.parent_module.parent_module, opts)
            vim.keymap.set("n", "<leader>rj", rt.join_lines.join_lines, opts)

            -- Alternative LSP keymaps to avoid conflicts
            vim.keymap.set("n", "gdd", vim.lsp.buf.definition, opts)    -- Use gdd instead of gd
            vim.keymap.set("n", "gDD", vim.lsp.buf.declaration, opts)   -- Use gDD instead of gD
            vim.keymap.set("n", "gR", vim.lsp.buf.references, opts)     -- Use gR instead of gr
            vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts) -- Use gI instead of gi
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts)
            vim.keymap.set("n", "<leader>wc", vim.lsp.buf.workspace_symbol, opts) -- Use wc instead of ws

            -- Better diagnostics - FIXED
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts) -- Use open_float instead of setloclist
          end,

          settings = {
            ["rust-analyzer"] = {
              -- Cargo configuration for large projects
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = {
                  enable = true,
                },
              },

              -- Check configuration
              checkOnSave = {
                command = "clippy",
                allFeatures = true,
                extraArgs = { "--no-deps" },
              },

              -- Completion and suggestions
              completion = {
                autoimport = {
                  enable = true,
                },
                postfix = {
                  enable = true,
                },
              },

              -- Proc macros
              procMacro = {
                enable = true,
                ignored = {
                  -- Add any problematic proc macros here
                },
              },

              -- Files and modules handling
              files = {
                excludeDirs = { ".git", "target", "node_modules" },
                watcher = "client",
              },

              -- Diagnostics configuration
              diagnostics = {
                disabled = { "unresolved-import" }, -- Reduce noise in large codebases
                enable = true,
                experimental = {
                  enable = true,
                },
              },

              -- Lens configuration
              lens = {
                enable = true,
                implementations = {
                  enable = true,
                },
                run = {
                  enable = true,
                },
                debug = {
                  enable = true,
                },
              },

              -- Hover configuration
              hover = {
                actions = {
                  enable = true,
                  references = {
                    enable = true,
                  },
                },
              },

              -- Cache configuration for performance
              cachePriming = {
                enable = true,
                numThreads = 4,
              },

              -- Parallel processing
              parallel = {
                enable = true,
                numThreads = 4,
              },

              -- Import management for large codebases
              imports = {
                granularity = {
                  group = "module",
                },
                prefix = "self",
              },

              -- Semantic highlighting
              semanticHighlighting = {
                operator = {
                  enable = true,
                },
                punctuation = {
                  enable = true,
                },
              },
            },
          },

          -- Standalone file support (files outside Cargo workspace)
          standalone = true,
        },
      })

      -- Debugger configuration (optional - remove if not needed)
      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode', -- or adjust for your system
        name = "lldb"
      }

      dap.configurations.rust = {
        {
          name = "Launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }

      -- Additional standalone keymaps that work without LSP attachment
      vim.keymap.set("n", "<leader>rf", ":RustFmt<CR>", { desc = "Format Rust code" })
    end,
  },

  -- Additional plugins for better Rust development experience
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function()
      require("crates").setup({
        smart_insert = true,
        insert_closing_quote = true,
        avoid_prerelease = true,
        autoload = true,
        loading_indicator = true,
        date_format = "%Y-%m-%d",
        thousands_separator = ".",
        text = {
          loading = "   Loading",
          version = "   %s",
          prerelease = "   %s",
          yanked = "   %s",
          nomatch = "   No match",
          upgrade = "   %s",
          error = "   Error fetching versions",
        },
        highlight = {
          latest = "@string.special",
          prerelease = "@exception",
          yanked = "@text.danger",
        },
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "rust" })
      end
    end,
  },

  -- Telescope integration for better navigation
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")

      -- 🕶️ Custom highlights for Telescope
      vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "#131313" })
      vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = "#0f0f14", bold = true })

      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Search document symbols" })
      vim.keymap.set("n", "<leader>wf", builtin.lsp_workspace_symbols, { desc = "Search workspace symbols" })
      vim.keymap.set("n", "<leader>fc", builtin.find_files, { desc = "Find files" })
    end,
  },
}
