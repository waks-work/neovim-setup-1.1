return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "│", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        change       = { text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        delete       = { text = "󰍴", numhl = "GitSignsDeleteNr" },
        topdelete    = { text = "󰍴", numhl = "GitSignsDeleteNr" },
        changedelete = { text = "~", numhl = "GitSignsChangeNr" },
        untracked    = { text = "┆", numhl = "GitSignsUntrackedNr" },
      },

      signcolumn = true,
      numhl = true,
      linehl = false,
      show_deleted = true,

      -- Enhanced current line blame
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
        virt_text = true,
        virt_text_pos = "right_align",
        ignore_whitespace = true,
        virt_text_priority = 100,
      },

      current_line_blame_formatter_opts = {
        relative_time = true,
      },

      current_line_blame_formatter = function(name, blame_info, opts)
        if not blame_info.author then
          return "  󰊢 Not committed yet"
        end

        local author = blame_info.author:gsub(" <.*>", "")
        if #author > 15 then
          author = author:sub(1, 12) .. "..."
        end

        local time = ""
        if blame_info.author_time then
          local seconds = os.difftime(os.time(), blame_info.author_time)
          if seconds < 60 then
            time = "just now"
          elseif seconds < 3600 then
            time = math.floor(seconds / 60) .. "m ago"
          elseif seconds < 86400 then
            time = math.floor(seconds / 3600) .. "h ago"
          else
            time = math.floor(seconds / 86400) .. "d ago"
          end
        end

        local text = string.format(
          "  󰊛 %s · %s · %s",
          author,
          blame_info.summary,
          time
        )

        if #text > 100 then
          text = text:sub(1, 97) .. "..."
        end

        return text
      end,

      word_diff = true,
      diff_opts = {
        internal = true,
        algorithm = "histogram",
        indent_heuristic = true,
        linematch = 60,
      },

      watch_gitdir = {
        interval = 1000,
        follow_files = true,
      },

      update_debounce = 200,

      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 1,
        col = 1,
        title = " Git Hunk Preview ",
        title_pos = "center",
      },

      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        -- Navigation with better visual feedback
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function()
            gs.next_hunk()
            Snacks.notifier.info("➤ Next hunk")
          end)
        end, "Next Hunk")

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function()
            gs.prev_hunk()
            Snacks.notifier.info("⬅ Prev hunk")
          end)
        end, "Prev Hunk")

        -- Visual mode
        map("v", "<leader>gs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          Snacks.notifier.info("✓ Staged visual selection")
        end, "Stage visual hunk")

        map("v", "<leader>gr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          Snacks.notifier.info("↺ Reset visual selection")
        end, "Reset visual hunk")

        -- Actions with icons
        map("n", "<leader>gl", gs.preview_hunk, "🔍 Preview Git hunk")
        map("n", "<leader>gL", function() gs.preview_hunk_inline() end, "👀 Preview Git hunk inline")
        map("n", "<leader>gb", gs.blame_line, "📝 Blame line")
        map("n", "<leader>gB", function() gs.toggle_current_line_blame() end, "🔁 Toggle line blame")
        map("n", "<leader>gs", function()
          gs.stage_hunk()
          Snacks.notifier.info("✓ Staged hunk")
        end, "✓ Stage hunk")
        map("n", "<leader>gu", function()
          gs.undo_stage_hunk()
          Snacks.notifier.info("↶ Undid stage hunk")
        end, "↶ Undo stage hunk")
        map("n", "<leader>gr", function()
          gs.reset_hunk()
          Snacks.notifier.info("↺ Reset hunk")
        end, "↺ Reset hunk")
        map("n", "<leader>gU", gs.reset_buffer_index, "🗑️ Reset buffer index")

        -- Buffer operations
        map("n", "<leader>gS", function()
          gs.stage_buffer()
          Snacks.notifier.info("✓ Staged entire buffer")
        end, "✓ Stage buffer")
        map("n", "<leader>gR", function()
          gs.reset_buffer()
          Snacks.notifier.info("↺ Reset entire buffer")
        end, "↺ Reset buffer")
        map("n", "<leader>gp", gs.preview_buffer, "📋 Preview buffer changes")

        -- Diff operations
        map("n", "<leader>gd", gs.diffthis, "📊 Diff against index")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "📈 Diff against last commit")
        map("n", "<leader>gtd", gs.toggle_deleted, "👁️ Toggle deleted lines")

        -- Blame operations
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "🔁 Toggle line blame")
        map("n", "<leader>gbh", gs.blame_hunk, "📝 Blame hunk")

        -- Text object
        map({ "o", "x" }, "ih", function()
          vim.cmd("normal! :<C-U>Gitsigns select_hunk<CR>")
        end, "Select hunk")

        -- Snacks picker
        map("n", "<leader>gh", function()
          Snacks.picker.grep({
            search = "diff --git",
            cwd = vim.fn.getcwd(),
            prompt_title = "🔍 Git Hunks",
          })
        end, "🔍 Search Git Hunks")

        -- Toggle features
        map("n", "<leader>gtl", gs.toggle_linehl, "🌟 Toggle line highlight")
        map("n", "<leader>gtn", gs.toggle_numhl, "🔢 Toggle number highlight")
        map("n", "<leader>gts", gs.toggle_signs, "📌 Toggle signs")

        -- Status info
        map("n", "<leader>gI", function()
          local status = gs.get_status()
          Snacks.notifier.info(string.format(
            "📊 Git Status: +%d  ~%d  -%d",
            status.added or 0,
            status.changed or 0,
            status.removed or 0
          ))
        end, "📊 Show Git status")

        -- Quick operations
        map("n", "<leader>g+", function()
          local count = vim.v.count1
          for _ = 1, count do
            gs.next_hunk()
            gs.stage_hunk()
          end
          Snacks.notifier.info(string.format("✓ Staged %d hunks", count))
        end, "⏩ Stage next N hunks")

        map("n", "<leader>g-", function()
          local count = vim.v.count1
          for _ = 1, count do
            gs.next_hunk()
            gs.reset_hunk()
          end
          Snacks.notifier.info(string.format("↺ Reset %d hunks", count))
        end, "⏩ Reset next N hunks")

        -- Refresh
        map("n", "<leader>grf", function()
          gs.refresh()
          Snacks.notifier.info("🔄 Refreshed git signs")
        end, "🔄 Refresh git signs")
      end,
    })

    -- 🎨 Enhanced UI highlighting with better colors
    local colors = {
      -- Git colors
      green = "#56d364",
      green_dark = "#2ea043",
      yellow = "#e3b341",
      yellow_dark = "#cf9925",
      red = "#f85149",
      red_dark = "#da3633",
      blue = "#79c0ff",
      purple = "#d2a8ff",
      gray = "#6e7681",
      gray_dark = "#484f58",

      -- Background colors
      bg = "#0d1117",
      bg_light = "#161b22",
      bg_lighter = "#1c2128",
    }

    local highlights = {
      -- Sign column colors
      GitSignsAdd = { fg = colors.green, bg = "NONE", bold = true },
      GitSignsChange = { fg = colors.yellow, bg = "NONE", bold = true },
      GitSignsDelete = { fg = colors.red, bg = "NONE", bold = true },
      GitSignsUntracked = { fg = colors.blue, bg = "NONE", bold = true },

      -- Line number highlights
      GitSignsAddNr = { fg = colors.green, bg = colors.bg_light },
      GitSignsChangeNr = { fg = colors.yellow, bg = colors.bg_light },
      GitSignsDeleteNr = { fg = colors.red, bg = colors.bg_light },
      GitSignsUntrackedNr = { fg = colors.blue, bg = colors.bg_light },

      -- Line highlights (subtle)
      GitSignsAddLn = { bg = colors.bg_light },
      GitSignsChangeLn = { bg = colors.bg_light },
      GitSignsDeleteLn = { bg = colors.bg_light },

      -- Inline diff highlights
      GitSignsAddInline = { bg = "#1c2d1f", fg = colors.green },
      GitSignsChangeInline = { bg = "#2d2b16", fg = colors.yellow },
      GitSignsDeleteInline = { bg = "#2d1a1a", fg = colors.red },

      -- Current line blame (subdued)
      GitSignsCurrentLineBlame = { fg = colors.gray, italic = true },

      -- Preview window
      GitSignsAddPreview = { bg = "#1c2d1f", fg = colors.green },
      GitSignsDeletePreview = { bg = "#2d1a1a", fg = colors.red },

      -- Staged changes
      GitSignsStagedAdd = { fg = colors.green_dark },
      GitSignsStagedChange = { fg = colors.yellow_dark },
      GitSignsStagedDelete = { fg = colors.red_dark },
    }

    for group, settings in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, settings)
    end

    -- Auto commands for better UI behavior
    local group = vim.api.nvim_create_augroup("EnhancedGitSignsUI", { clear = true })

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = group,
      callback = function()
        -- Re-apply highlights when colorscheme changes
        for group, settings in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, settings)
        end
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "gitcommit", "gitrebase", "gitconfig" },
      callback = function()
        vim.opt_local.wrap = false
        vim.opt_local.list = false
        -- Add some git-specific styling
        vim.api.nvim_set_hl(0, "gitcommitHeader", { fg = colors.blue, bold = true })
        vim.api.nvim_set_hl(0, "gitcommitSummary", { fg = colors.green, bold = true })
      end,
    })

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
