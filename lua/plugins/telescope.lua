return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          -- Layout configuration
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
            horizontal = {
              preview_width = 0.55,
            },
          },

          -- Sorting and filtering
          sorting_strategy = "ascending",
          file_ignore_patterns = {
            "node_modules",
            ".git/",
            "dist/",
            "build/",
            "target/",
            "*.lock",
          },

          -- Visual elements
          borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          prompt_prefix = "  ",
          selection_caret = " ",
          entry_prefix = "  ",

          -- Display options
          color_devicons = true,
          path_display = { "truncate" },
          winblend = 0,
          set_env = { COLORTERM = "truecolor" },

          -- Performance
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
          },

          -- Key mappings
          mappings = {
            i = {
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
              ["<C-q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
              ["<Esc>"] = require("telescope.actions").close,
            },
            n = {
              ["q"] = require("telescope.actions").close,
            },
          },
        },

        -- Picker-specific settings
        pickers = {
          find_files = {
            hidden = true,
            find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
          buffers = {
            previewer = false,
            initial_mode = "normal",
            theme = "dropdown",
            layout_config = {
              width = 0.5,
              height = 0.4,
            },
          },
          git_files = {
            hidden = true,
          },
        },
      })

      -- Custom highlight groups for darker UI
      local highlights = {
        TelescopeNormal = { bg = "#0d0d0d" },
        TelescopeBorder = { bg = "#0d0d0d", fg = "#3b3b3b" },
        TelescopePromptNormal = { bg = "#121212" },
        TelescopePromptBorder = { bg = "#121212", fg = "#4a4a4a" },
        TelescopePromptTitle = { bg = "#4a4a4a", fg = "#ffffff", bold = true },
        TelescopeResultsNormal = { bg = "#0d0d0d" },
        TelescopeResultsBorder = { bg = "#0d0d0d", fg = "#3b3b3b" },
        TelescopeResultsTitle = { bg = "#3b3b3b", fg = "#ffffff", bold = true },
        TelescopePreviewNormal = { bg = "#0d0d0d" },
        TelescopePreviewBorder = { bg = "#0d0d0d", fg = "#3b3b3b" },
        TelescopePreviewTitle = { bg = "#3b3b3b", fg = "#ffffff", bold = true },
        TelescopeSelection = { bg = "#1a1a1a", fg = "#ffffff", bold = true },
        TelescopeSelectionCaret = { fg = "#888888", bg = "#1a1a1a" },
        TelescopeMatching = { fg = "#888888", bold = true },
        TelescopePromptPrefix = { fg = "#6a6a6a" },
      }

      for group, settings in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, settings)
      end

      -- Useful keymaps
      local builtin = require("telescope.builtin")
      local keymap = vim.keymap.set

      keymap("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      keymap("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      keymap("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      keymap("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      keymap("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
      keymap("n", "<leader>fw", builtin.grep_string, { desc = "Find word under cursor" })
    end,
  },
  {
    "isak102/telescope-git-file-history.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "tpope/vim-fugitive" },
    config = function()
      require("telescope").load_extension("git_file_history")
      vim.keymap.set("n", "<leader>gf", "<cmd>Telescope git_file_history<CR>", { desc = "Git file history" })
    end,
  },
}
