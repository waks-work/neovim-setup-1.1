return {
  -- C++ Language Server and Tools
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- Enable for both normal C++ and game development
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--all-scopes-completion",
            "--cross-file-rename",
          },
          filetypes = { "c", "cpp", "objc", "objcpp" },
          root_dir = function(fname)
            -- Support for various build systems
            local util = require("lspconfig.util")
            return util.root_pattern(
              "CMakeLists.txt",
              "configure.ac", "configure.in", "config.h.in",
              "meson.build", "meson_options.txt",
              "build.ninja",
              "Makefile",
              ".git",
              "*.uproject", -- Unreal Engine
              "*.sln", -- Visual Studio
              "compile_commands.json"
            )(fname) or util.find_git_ancestor(fname) or util.path.dirname(fname)
          end,
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          single_file_support = true,
        },
      },
    },
  },

  -- Enhanced C++ Syntax and Semantic Highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "c", "cpp", "cmake", "glsl", "hlsl"
        })
      end
    end,
  },

  -- CMake Tools for Build System Integration
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        cmake_build_directory = "build",
        cmake_build_directory_prefix = "build/", -- when cmake_build_directory is ""
        cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_build_options = {},
        cmake_console_size = 10, -- cmake output window height
        cmake_show_console = "always", -- "always", "only_on_error"
        cmake_dap_configuration = { -- debug settings for cmake
          name = "cpp",
          type = "codelldb",
          request = "launch",
          stopOnEntry = false,
          runInTerminal = true,
          console = "integratedTerminal",
        },
        cmake_variants_message = {
          short = { show = true },
          long = { show = true, max_length = 40 }
        }
      })

      -- Keymaps for CMake
      vim.keymap.set("n", "<leader>cg", "<cmd>CMakeGenerate<CR>", { desc = "CMake Generate" })
      vim.keymap.set("n", "<leader>cb", "<cmd>CMakeBuild<CR>", { desc = "CMake Build" })
      vim.keymap.set("n", "<leader>cr", "<cmd>CMakeRun<CR>", { desc = "CMake Run" })
      vim.keymap.set("n", "<leader>cd", "<cmd>CMakeDebug<CR>", { desc = "CMake Debug" })
      vim.keymap.set("n", "<leader>cc", "<cmd>CMakeClean<CR>", { desc = "CMake Clean" })
    end,
  },

  -- C++ Specific Debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- C++ Debugging with lldb-vscode or codelldb
      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode', -- or 'codelldb' if installed
        name = "lldb"
      }

      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = 'codelldb',
          args = { '--port', '${port}' },
        }
      }

      dap.configurations.cpp = {
        {
          name = "Launch (lldb)",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
          env = function()
            local variables = {}
            for k, v in pairs(vim.fn.environ()) do
              table.insert(variables, k .. "=" .. v)
            end
            return variables
          end,
        },
        {
          name = "Attach to process (lldb)",
          type = "lldb",
          request = "attach",
          pid = require('dap.utils').pick_process,
          args = {},
        },
        {
          name = "Launch (codelldb)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          terminal = "integrated",
        },
      }

      -- Also for C language
      dap.configurations.c = dap.configurations.cpp
    end,
  },

  -- Enhanced C++ Snippets
  {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },

  -- C++ Specific Tools and Utilities
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nt-cpp-tools").setup({
        preview = {
          quit = "q", -- optional keymapping for quit preview
          accept = "<tab>" -- optional keymapping for accept preview
        },
        header_extension = "h", -- optional
        source_extension = "cxx", -- optional
        custom_define_class_function_commands = { -- optional
          TSCppDefineClass = {
            output_handle = require("nt-cpp-tools.output_handlers").get_prepend_output_handler(
              { "#include <iostream>", "" }, 
              { "std::cout", "std::endl" }
            ),
          },
          -- Other commands here
        }
      })
    end,
  },

  -- Game Development Specific Plugins
  {
    "ThePrimeagen/vim-be-good", -- Fun but useful for game dev debugging
    cmd = "VimBeGood",
  },

  -- GLSL/HLSL Shader Support
  {
    "tikhomirov/vim-glsl",
    ft = { "glsl", "vert", "frag", "geom", "tesc", "tese", "comp", "hlsl" },
  },

  -- Unreal Engine Specific Support
  {
    "aca/emmet-ls", -- Useful for Unreal's UI systems
    config = function()
      require("lspconfig").emmet_ls.setup({
        filetypes = { "html", "css", "javascriptreact", "typescriptreact", "xml" },
      })
    end,
  },

  -- C++ Test Integration
  {
    "klen/nvim-test",
    config = function()
      require("nvim-test").setup({
        run = true, -- run tests (using for debug)
        commands_create = true, -- create commands (TestFile, TestLast, ...)
        filename_modifier = ":.", -- modify filenames before tests run(:h filename-modifiers)
        silent = false, -- less notifications
        term = "terminal", -- a terminal to run ("terminal"|"toggleterm")
        termOpts = {
          direction = "vertical", -- terminal's direction ("horizontal"|"vertical"|"float")
          width = 96, -- terminal's width (for vertical|float)
          height = 24, -- terminal's height (for horizontal|float)
          go_back = false, -- return focus to original window after executing
          stopinsert = "auto", -- exit from insert mode (true|false|"auto")
          keep_one = true, -- keep only one terminal for testing
        },
        runners = {
          cpp = "nvim-test.runners.gtest",
        }
      })

      -- Test keymaps
      vim.keymap.set("n", "<leader>tt", "<cmd>TestFile<CR>", { desc = "Test File" })
      vim.keymap.set("n", "<leader>tT", "<cmd>TestLast<CR>", { desc = "Test Last" })
      vim.keymap.set("n", "<leader>ta", "<cmd>TestSuite<CR>", { desc = "Test Suite" })
      vim.keymap.set("n", "<leader>tl", "<cmd>TestNearest<CR>", { desc = "Test Nearest" })
    end,
  },

  -- C++ Enhanced Diagnostics
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup({
        position = "bottom", -- position of the list can be: bottom, top, left, right
        height = 10, -- height of the trouble list when position is top or bottom
        width = 50, -- width of the list when position is left or right
        icons = true, -- use devicons for filenames
        mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
        severity = nil, -- nil (ALL) or vim.diagnostic.severity.ERROR | WARN | INFO | HINT
        fold_open = "", -- icon used for open folds
        fold_closed = "", -- icon used for closed folds
        group = true, -- group results by file
        padding = true, -- add an extra new line on top of the list
        action_keys = { -- key mappings for actions in the trouble list
          close = "q", -- close the list
          cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
          refresh = "r", -- manually refresh
          jump = {"<cr>", "<tab>"}, -- jump to the diagnostic or open / close folds
          open_split = { "<c-x>" }, -- open buffer in new split
          open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
          open_tab = { "<c-t>" }, -- open buffer in new tab
          jump_close = {"o"}, -- jump to the diagnostic and close the list
          toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
          toggle_preview = "P", -- toggle auto_preview
          hover = "K", -- opens a small popup with the full multiline message
          preview = "p", -- preview the diagnostic location
          close_folds = {"zM", "zm"}, -- close all folds
          open_folds = {"zR", "zr"}, -- open all folds
          toggle_fold = {"zA", "za"}, -- toggle fold of current file
          previous = "k", -- previous item
          next = "j" -- next item
        },
        indent_lines = true, -- add an indent guide below the fold icons
        auto_open = false, -- automatically open the list when you have diagnostics
        auto_close = false, -- automatically close the list when you have no diagnostics
        auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
        auto_fold = false, -- automatically fold a file trouble list at creation
        auto_jump = {"lsp_definitions"}, -- for the given modes, automatically jump if there is only a single result
        signs = {
          -- icons / text used for a diagnostic
          error = "",
          warning = "",
          hint = "",
          information = "",
          other = "﫠"
        },
        use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
      })

      -- Trouble keymaps
      vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<CR>", { desc = "Trouble Toggle" })
      vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
      vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<CR>", { desc = "Document Diagnostics" })
      vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<CR>", { desc = "Location List" })
      vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<CR>", { desc = "Quickfix List" })
    end,
  },

  -- C++ Enhanced Keymaps and LSP Setup
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "cmake",
      },
    },
  },
}
