return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",     -- Required for gitsigns
  },
  config = function()
    require("gitsigns").setup({
      signs                        = {
        add          = { text = "┃", show_count = true },
        change       = { text = "┃", show_count = true },
        delete       = { text = "", show_count = true },
        topdelete    = { text = "", show_count = true },
        changedelete = { text = "", show_count = true },
        untracked    = { text = "┆", show_count = true },
      },

      -- Enhanced sign configuration
      signcolumn                   = true, -- Show sign column always
      numhl                        = true, -- Enable line number highlighting
      linehl                       = true, -- Enable line highlighting
      show_deleted                 = true, -- Show deleted lines

      -- Current line blame configuration
      current_line_blame           = true,
      current_line_blame_opts      = {
        delay = 400,
        virt_text = true,
        virt_text_pos = "eol",
        ignore_whitespace = true,
        virt_text_priority = 100,
      },

      -- Enhanced blame configuration
      current_line_blame_formatter = function(name, blame_info, opts)
        if not blame_info.author then
          return "Not Committed Yet"
        end

        local text = string.format(
          "%s • %s • %s",
          blame_info.author,
          os.date("%Y-%m-%d", blame_info.author_time),
          blame_info.summary
        )

        -- Truncate if too long
        if #text > 80 then
          text = text:sub(1, 77) .. "..."
        end

        return text
      end,

      -- Word diff configuration
      word_diff                    = true,
      diff_opts                    = {
        internal = true,
        linematch = 60,                  -- Enable line matching for better diffs
        algorithm = "histogram",         -- Better diff algorithm
      },

      -- Watch configuration for better performance
      watch_gitdir                 = {
        interval = 1000,
        follow_files = true,
      },

      -- Enhanced update configuration
      update_debounce              = 200,
      status_formatter             = nil, -- Use default status formatter

      -- Enhanced preview configuration
      preview_config               = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },

      -- Yank highlighting
      yadm                         = {
        enable = false,
      },

      -- Enhanced on_attach function
      on_attach                    = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Enhanced Navigation
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          gs.next_hunk()
          Snacks.notifier.info("Next hunk")
        end, "Next Hunk")

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          gs.prev_hunk()
          Snacks.notifier.info("Prev hunk")
        end, "Prev Hunk")

        -- Visual mode mappings
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage visual hunk")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset visual hunk")

        -- Enhanced Actions
        map("n", "<leader>gl", gs.preview_hunk, "Preview Git hunk")
        map("n", "<leader>gL", function() gs.preview_hunk_inline() end, "Preview Git hunk inline")
        map("n", "<leader>gb", gs.blame_line, "Blame line")
        map("n", "<leader>gB", function() gs.toggle_current_line_blame() end, "Toggle line blame")
        map("n", "<leader>gs", function() gs.stage_hunk() end, "Stage hunk")
        map("n", "<leader>gu", function() gs.undo_stage_hunk() end, "Undo stage hunk")
        map("n", "<leader>gr", function() gs.reset_hunk() end, "Reset hunk")
        map("n", "<leader>gU", gs.reset_buffer_index, "Reset buffer index")

        -- Whole buffer operations
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gp", gs.preview_buffer, "Preview buffer changes")

        -- Enhanced diff operations
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against last commit")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle deleted lines")

        -- Enhanced blame operations
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>gbh", gs.blame_hunk, "Blame hunk")

        -- Text object for hunks
        map({ "o", "x" }, "ih", function()
          vim.cmd("normal! :<C-U>Gitsigns select_hunk<CR>")
        end, "Select hunk")

        -- Enhanced Snacks picker for hunks
        map("n", "<leader>gh", function()
          Snacks.picker.grep({
            search = "diff --git",
            cwd = vim.fn.getcwd(),
            prompt_title = "Git Hunks",
          })
        end, "Search Git Hunks")

        -- Toggle features
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle deleted")
        map("n", "<leader>gtl", gs.toggle_linehl, "Toggle line highlight")
        map("n", "<leader>gtn", gs.toggle_numhl, "Toggle number highlight")
        map("n", "<leader>gts", gs.toggle_signs, "Toggle signs")

        -- Enhanced status information
        map("n", "<leader>gI", function()
          local status = gs.get_status()
          Snacks.notifier.info(string.format(
            "Added: %d, Changed: %d, Removed: %d",
            status.added or 0,
            status.changed or 0,
            status.removed or 0
          ))
        end, "Show Git status")

        -- Quick stage/reset with count support
        map("n", "<leader>g+", function()
          local count = vim.v.count1
          for _ = 1, count do
            gs.next_hunk()
            gs.stage_hunk()
          end
          Snacks.notifier.info(string.format("Staged %d hunks", count))
        end, "Stage next N hunks")

        map("n", "<leader>g-", function()
          local count = vim.v.count1
          for _ = 1, count do
            gs.next_hunk()
            gs.reset_hunk()
          end
          Snacks.notifier.info(string.format("Reset %d hunks", count))
        end, "Reset next N hunks")

        -- Enhanced buffer refresh
        map("n", "<leader>grf", function()
          gs.refresh()
          Snacks.notifier.info("Refreshed git signs")
        end, "Refresh git signs")
      end,
    })

    -- Auto commands for enhanced git experience
    local group = vim.api.nvim_create_augroup("EnhancedGitSigns", { clear = true })

    -- Highlight on yank
    vim.api.nvim_create_autocmd("TextYankPost", {
      group = group,
      callback = function()
        vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
      end,
    })

    -- Enhanced diff highlighting
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "git",
      callback = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
      end,
    })

    -- Auto toggle in diff mode
    vim.api.nvim_create_autocmd("OptionSet", {
      group = group,
      pattern = "diff",
      callback = function()
        local gs = package.loaded.gitsigns
        if gs then
          gs.toggle_signs(false)
          gs.toggle_numhl(false)
          gs.toggle_linehl(false)
        end
      end,
    })
  end,
}
