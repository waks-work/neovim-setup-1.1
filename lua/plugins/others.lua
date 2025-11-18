return {
  { "mattn/emmet-vim" },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 500
    end,
    config = function()
      local wk = require("which-key")

      wk.setup({
        plugins = {
          marks = true,
          registers = true,
          spelling = {
            enabled = true,
            suggestions = 20,
          },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        -- LazyVim-style right-side UI
        window = {
          border = "single",
          position = "bottom",
          margin = { 0, 0, 0, 0 },
          padding = { 1, 1, 1, 1 },
          winblend = 5,
          zindex = 1000,
          relative = "editor",
          row = 1,
          col = vim.o.columns - 50,
          width = 48,
          height = 25,
        },
        layout = {
          height = { min = 4, max = 25 },
          width = { min = 48, max = 48 },
          spacing = 2,
          align = "left",
        },
        ignore_missing = true,
        show_help = false,
        triggers = { "<leader>" },
        triggers_blacklist = {
          i = { "j", "k" },
          v = { "j", "k" },
        },
        disable = {
          buftypes = {},
          filetypes = { "TelescopePrompt", "dashboard", "lazy" },
        },
      })

      -- Helper function to safely call Snacks functions - FIXED
      local function safe_snacks_call(func_name, ...)
        local args = { ... }
        return function()
          if Snacks and Snacks.picker and Snacks.picker[func_name] then
            Snacks.picker[func_name](unpack(args))
          else
            vim.notify("Snacks " .. func_name .. " not available", vim.log.levels.WARN)
          end
        end
      end

      -- Helper function for LSP operations - UPDATED for Neovim 0.13+
      local function lsp_action(action, desc)
        return function()
          local clients = vim.lsp.get_clients()
          if #clients > 0 and vim.lsp.buf[action] then
            vim.lsp.buf[action]()
          else
            vim.notify("LSP action " .. action .. " not available", vim.log.levels.WARN)
          end
        end
      end

      -- Updated diagnostic functions for Neovim 0.13+
      local function next_diagnostic()
        vim.diagnostic.jump(1)
      end

      local function prev_diagnostic()
        vim.diagnostic.jump(-1)
      end

      -- Register ALL your keymaps with proper implementations
      wk.register({
        ["<leader>"] = {
          -- 📁 FILE EXPLORER (NvimTree)
          e = { "<cmd>NvimTreeToggle<CR>", "Toggle Explorer" },
          E = { "<cmd>NvimTreeFocus<CR>", "Focus Explorer" },
          r = { "<cmd>NvimTreeRefresh<CR>", "Refresh Tree" },
          f = {
            t = { "<cmd>NvimTreeFindFile<CR>", "Find Current File" },
          },
          c = {
            l = { "<cmd>NvimTreeCollapse<CR>", "Collapse Tree" },
          },

          -- 🔍 FIND/SEARCH (Telescope & Snacks)
          f = {
            name = "Find",
            f = { "<cmd>Telescope find_files<CR>", "Find Files" },
            g = { "<cmd>Telescope live_grep<CR>", "Live Grep" },
            b = { "<cmd>Telescope buffers<CR>", "Open Buffers" },
            h = { "<cmd>Telescope git_file_history<CR>", "File History" },
            s = { "<cmd>Telescope lsp_document_symbols<CR>", "Document Symbols" },
            c = { "<cmd>Telescope find_files<CR>", "Find Files" },
          },
          w = {
            c = { "<cmd>Telescope lsp_workspace_symbols<CR>", "Workspace Symbols" },
          },

          -- Snacks pickers - FIXED with proper function calls
          ["<space>"] = { safe_snacks_call("smart"), "Smart Find Files" },
          [","] = { safe_snacks_call("buffers"), "Switch Buffers" },
          ["/"] = { safe_snacks_call("grep"), "Grep" },
          [":"] = { safe_snacks_call("command_history"), "Command History" },
          n = { safe_snacks_call("notifications"), "Notification History" },

          -- 💾 SAVE/QUIT
          w = {
            name = "Workspace",
            w = { "<cmd>w<CR>", "Save File" },
            v = { "Explain Code", "waksAI" },
          },
          q = { "<cmd>q<CR>", "Quit Window" },

          -- 🦀 RUST DEVELOPMENT
          r = {
            name = "Rust",
            f = { "<cmd>RustFmt<CR>", "Format Rust Code" },
            r = { "Rust Runnables" },
            l = { "Toggle Inlay Hints" },
            h = { "Hover Actions" },
            a = { "Code Actions" },
            p = { "Parent Module" },
            j = { "Join Lines" },
            c = { "Show Crate Info" },
            v = { "Show Versions" },
            F = { "Show Features" },
          },

          -- 💻 C++ DEVELOPMENT
          c = {
            name = "C++",
            f = { "<cmd>ClangFormat<CR>", "Format C++" },
            i = { "<cmd>ClangdSwitchSourceHeader<CR>", "Switch Header/Source" },
            b = { "<cmd>CMakeBuild<CR>", "CMake Build" },
            r = { "<cmd>CMakeRun<CR>", "CMake Run" },
            d = { "<cmd>CMakeDebug<CR>", "CMake Debug" },
            c = { "<cmd>CppCompile<CR>", "Compile C++ File" },
            g = { "<cmd>CMakeGenerate<CR>", "CMake Generate" },
          },

          -- 🐛 DEBUGGING (DAP) - FIXED with proper commands
          d = {
            name = "Debug",
            b = { function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint" },
            c = { function() require("dap").continue() end, "Continue Debug" },
            o = { function() require("dap").step_over() end, "Step Over" },
            i = { function() require("dap").step_into() end, "Step Into" },
            O = { function() require("dap").step_out() end, "Step Out" },
            t = { function() require("dap").terminate() end, "Terminate Debug" },
            l = { function() vim.diagnostic.open_float() end, "Line Diagnostics" },
            B = { function()
              local condition = vim.fn.input("Breakpoint condition: ")
              require("dap").set_breakpoint(condition)
            end, "Conditional Breakpoint" },
          },

          -- 🔧 GIT OPERATIONS (Gitsigns) - FIXED with proper function calls
          g = {
            name = "Git",
            l = { function() require("gitsigns").preview_hunk() end, "Preview Git Hunk" },
            b = { function() require("gitsigns").blame_line() end, "Blame Line" },
            s = { function() require("gitsigns").stage_hunk() end, "Stage Hunk" },
            u = { function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk" },
            r = { function() require("gitsigns").reset_hunk() end, "Reset Hunk" },
            S = { function() require("gitsigns").stage_buffer() end, "Stage Buffer" },
            R = { function() require("gitsigns").reset_buffer() end, "Reset Buffer" },
            h = { function()
              if Snacks and Snacks.picker and Snacks.picker.grep then
                Snacks.picker.grep({ search = "diff --git", cwd = vim.fn.getcwd() })
              else
                vim.notify("Snacks grep not available", vim.log.levels.WARN)
              end
            end, "Search Git Hunks" },
            L = { function() require("gitsigns").preview_hunk_inline() end, "Preview Hunk Inline" },
            B = { function() require("gitsigns").toggle_current_line_blame() end, "Toggle Line Blame" },
            U = { function() require("gitsigns").reset_buffer_index() end, "Reset Buffer Index" },
            p = { function() require("gitsigns").preview_buffer() end, "Preview Buffer Changes" },
            d = { function() require("gitsigns").diffthis() end, "Diff Against Index" },
            D = { function() require("gitsigns").diffthis("~") end, "Diff Against Last Commit" },
            I = { function()
              local status = require("gitsigns").get_status()
              vim.notify(string.format("Added: %d, Changed: %d, Removed: %d",
                status.added or 0, status.changed or 0, status.removed or 0))
            end, "Show Git Status" },
            ["+"] = { function()
              local count = vim.v.count1
              for _ = 1, count do
                require("gitsigns").next_hunk()
                require("gitsigns").stage_hunk()
              end
              vim.notify(string.format("Staged %d hunks", count))
            end, "Stage Next N Hunks" },
            ["-"] = { function()
              local count = vim.v.count1
              for _ = 1, count do
                require("gitsigns").next_hunk()
                require("gitsigns").reset_hunk()
              end
              vim.notify(string.format("Reset %d hunks", count))
            end, "Reset Next N Hunks" },
            r = {
              f = { function() require("gitsigns").refresh() end, "Refresh Git Signs" },
            },
          },

          -- 🎨 UI TOGGLES (Snacks) - These should work if Snacks is loaded
          u = {
            name = "UI/Toggle",
            s = { "Toggle Spelling" },
            w = { "Toggle Wrap" },
            L = { "Toggle Relative Number" },
            d = { "Toggle Diagnostics" },
            l = { "Toggle Line Number" },
            c = { "Toggle Conceal Level" },
            T = { "Toggle Treesitter" },
            b = { "Toggle Dark Background" },
            h = { "Toggle Inlay Hints" },
            g = { "Toggle Indent" },
            D = { "Toggle Dim" },
          },

          -- ❌ TROUBLE DIAGNOSTICS - FIXED
          x = {
            name = "Trouble",
            x = { "<cmd>TroubleToggle<CR>", "Toggle Trouble" },
            w = { "<cmd>TroubleToggle workspace_diagnostics<CR>", "Workspace Diagnostics" },
            d = { "<cmd>TroubleToggle document_diagnostics<CR>", "Document Diagnostics" },
            l = { "<cmd>TroubleToggle loclist<CR>", "Location List" },
            q = { "<cmd>TroubleToggle quickfix<CR>", "Quickfix List" },
          },

          -- 🧪 TESTING - FIXED
          t = {
            name = "Test",
            t = { "<cmd>TestFile<CR>", "Test File" },
            T = { "<cmd>TestLast<CR>", "Test Last" },
            a = { "<cmd>TestSuite<CR>", "Test Suite" },
            l = { "<cmd>TestNearest<CR>", "Test Nearest" },
          },

          -- LSP Operations - FIXED with proper function calls
          r = {
            n = { lsp_action("rename", "Rename"), "Rename" },
          },
          c = {
            a = { lsp_action("code_action", "Code Action"), "Code Action" },
          },
          d = {
            s = { lsp_action("document_symbol", "Document Symbols"), "Document Symbols" },
          },
        },
      })

      -- Non-leader mappings - FIXED with updated diagnostic functions
      wk.register({
        -- 🚀 LSP NAVIGATION
        g = {
          name = "Go",
          d = { lsp_action("definition", "Definition"), "Definition" },
          D = { lsp_action("declaration", "Declaration"), "Declaration" },
          R = { lsp_action("references", "References"), "References" },
          I = { lsp_action("implementation", "Implementation"), "Implementation" },
          d = {
            d = { lsp_action("definition", "Definition"), "Definition" },
            D = { lsp_action("declaration", "Declaration"), "Declaration" },
          },
        },
        K = { function() require("hover").hover() end, "Hover" },

        -- 📄 DIAGNOSTICS - UPDATED for Neovim 0.13+
        ["]"] = {
          name = "Next",
          d = { next_diagnostic, "Diagnostic" },
          c = { function() require("gitsigns").next_hunk() end, "Hunk" },
        },
        ["["] = {
          name = "Previous",
          d = { prev_diagnostic, "Diagnostic" },
          c = { function() require("gitsigns").prev_hunk() end, "Hunk" },
        },

        -- 🔄 BUFFER NAVIGATION
        ["<A-right>"] = { "<cmd>bnext<CR>", "Next Buffer" },
        ["<A-left>"] = { "<cmd>bprev<CR>", "Previous Buffer" },
        ["<A-l>"] = { "<cmd>ls<CR>", "List Buffers" },
        ["<A-c>"] = { "<cmd>bd<CR>", "Close Buffer" },

        -- ✨ EMMET
        ["<C-e>"] = { "Expand Emmet" },

        -- 🖱️ HOVER
        ["<MouseMove>"] = { function() require("hover").hover_mouse() end, "Hover Mouse" },
      })
    end,
  },
  {
    "lewis6991/hover.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "kevinhwang91/nvim-bqf", -- Better quickfix for some hover results
    },
    config = function()
      local hover = require("hover")

      -- Pre-load providers for better performance
      hover.setup({
        providers = {
          {
            name = "lsp",
            module = "hover.providers.lsp",
            priority = 1000,
            enabled = function()
              return #vim.lsp.get_active_clients() > 0
            end,
          },
          {
            name = "man",
            module = "hover.providers.man",
            priority = 900,
            enabled = function()
              return vim.fn.executable("man") == 1
            end,
          },
          {
            name = "dictionary",
            module = "hover.providers.dictionary",
            priority = 800,
            enabled = function()
              return vim.fn.executable("dict") == 1
            end,
          },
        },

        -- Enhanced preview window with better defaults
        preview_opts = {
          border = "single",
          relative = "cursor",
          zindex = 40,
          title = true,
          title_pos = "center",
          focusable = false,
          focus = false,
          max_width = math.min(80, vim.o.columns - 10),
          max_height = math.min(20, vim.o.lines - 10),
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        },

        -- Mouse configuration with better defaults
        mouse_providers = {
          "LSP",
        },
        mouse_delay = 680, -- Reduced for better responsiveness

        -- Enhanced preview window behavior
        preview_window = {
          winblend = 15,
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
          auto_close = true,
          close_on_move = true,
          close_on_escape = true,
          close_on_buf_leave = true,
          scrolloff = 2, -- Keep some context when scrolling
        },

        -- Extended keymaps with better ergonomics
        keymaps = {
          ["<C-f>"] = "scroll_down",
          ["<C-b>"] = "scroll_up",
          ["<C-d>"] = "scroll_down_half",
          ["<C-u>"] = "scroll_up_half",
          ["<PageDown>"] = "scroll_down_page",
          ["<PageUp>"] = "scroll_up_page",
          ["q"] = "close",
          ["<Esc>"] = "close",
          ["<CR>"] = function(bufnr)
            -- Allow opening links in markdown hovers
            local line = vim.api.nvim_get_current_line()
            if line:match("https?://") then
              vim.fn.jobstart({ "open", line }, { detach = true })
              hover.close()
            end
          end,
        },
      })

      -- Smart keymaps with better descriptions and fallbacks
      local keymap_opts = { silent = true, noremap = true }

      vim.keymap.set("n", "K", function()
        if vim.fn.reg_executing() == "" then -- Don't trigger during macros
          hover.hover()
        end
      end, vim.tbl_extend("force", keymap_opts, {
        desc = "Hover: Show smart documentation"
      }))

      vim.keymap.set("n", "gK", function()
        hover.hover_select()
      end, vim.tbl_extend("force", keymap_opts, {
        desc = "Hover: Select provider manually"
      }))

      -- Only enable mouse hover if user wants it
      if vim.g.hover_mouse_enabled ~= false then
        vim.keymap.set("n", "<MouseMove>", function()
          if vim.v.mouse_win == vim.api.nvim_get_current_win() then
            hover.hover_mouse()
          end
        end, vim.tbl_extend("force", keymap_opts, {
          desc = "Hover: Show on mouse movement"
        }))

        vim.o.mousemoveevent = true
      end

      -- Enhanced auto-group with better management
      local hover_group = vim.api.nvim_create_augroup("HoverEnhanced", { clear = true })

      -- Smart auto-hover with cooldown
      local last_hover_time = 0
      local hover_cooldown = 500 -- ms

      vim.api.nvim_create_autocmd("CursorHold", {
        group = hover_group,
        callback = function()
          -- Don't auto-hover during insert mode or if recently triggered
          if vim.fn.mode() == "i" then return end

          local current_time = vim.loop.now()
          if current_time - last_hover_time < hover_cooldown then return end

          -- Check if any floating windows are already open
          local has_float = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local config = vim.api.nvim_win_get_config(win)
            if config.relative ~= "" then
              has_float = true
              break
            end
          end

          if not has_float and vim.bo.buftype == "" then
            last_hover_time = current_time
            hover.hover()
          end
        end,
        desc = "Smart auto-hover on cursor hold"
      })

      -- Close hover when entering insert mode
      vim.api.nvim_create_autocmd("InsertEnter", {
        group = hover_group,
        callback = function()
          hover.close()
        end,
        desc = "Close hover when entering insert mode"
      })

      -- Enhanced user commands with better feedback
      vim.api.nvim_create_user_command("Hover", function()
        hover.hover()
      end, { desc = "Show hover documentation" })

      vim.api.nvim_create_user_command("HoverSelect", function()
        hover.hover_select()
      end, { desc = "Select hover provider manually" })

      vim.api.nvim_create_user_command("HoverDebug", function()
        local active_clients = vim.lsp.get_active_clients()

        print("=== Hover Debug Information ===")
        print("Active LSP clients: " .. #active_clients)
        for _, client in ipairs(active_clients) do
          print("  - " .. client.name)
        end

        -- Check available providers
        print("\nAvailable hover providers:")
        local providers_to_check = {
          lsp = function() return #vim.lsp.get_active_clients() > 0 end,
          man = function() return vim.fn.executable("man") == 1 end,
          dictionary = function() return vim.fn.executable("dict") == 1 end,
        }

        for name, check_fn in pairs(providers_to_check) do
          local status = check_fn() and "✅" or "❌"
          print("  " .. status .. " " .. name)
        end
      end, { desc = "Debug hover providers and LSP status" })

      -- Filetype-specific optimizations
      vim.api.nvim_create_autocmd("FileType", {
        group = hover_group,
        pattern = { "markdown", "help", "text" },
        callback = function()
          -- Wider preview for documentation files
          vim.keymap.set("n", "K", function()
            hover.hover({
              preview_opts = {
                max_width = 70,
                max_height = 30,
                border = "rounded",
              }
            })
          end, { buffer = true, desc = "Hover: Wide documentation preview" })
        end,
        desc = "Enhanced hover for documentation files"
      })

      -- Language-specific hover enhancements
      vim.api.nvim_create_autocmd("LspAttach", {
        group = hover_group,
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          if client then
            local enhancements = {
              ["rust_analyzer"] = {
                focusable = true,
                max_width = 85,
              },
              ["clangd"] = {
                max_width = 90,
              },
              ["tsserver"] = {
                max_width = 75,
              },
              ["gopls"] = {
                max_width = 80,
              },
              ["pylsp"] = {
                max_width = 78,
              },
            }

            local enhancement = enhancements[client.name]
            if enhancement then
              vim.keymap.set("n", "K", function()
                hover.hover({ preview_opts = enhancement })
              end, { buffer = bufnr, desc = "Hover: " .. client.name .. " enhanced" })
            end
          end
        end,
        desc = "Language-specific hover optimizations"
      })

      -- Performance optimization: preload on idle
      vim.defer_fn(function()
        require("hover.providers.lsp")
        vim.notify("Hover.nvim loaded and ready", vim.log.levels.INFO)
      end, 1000)
    end,
  },
}
