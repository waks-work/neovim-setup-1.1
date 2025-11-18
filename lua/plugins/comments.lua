return {
  "numToStr/Comment.nvim",
  event = "VeryLazy",
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring", -- For context-aware commenting
  },
  config = function()
    local comment = require("Comment")
    local commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    comment.setup({
      -- Enable keybindings
      mappings = {
        -- Basic commenting operations
        basic = true,
        -- Extra operations (gcb, gcO, etc.)
        extra = true,
        -- Extended operations (gb, gbc, etc.)
        extended = false, -- Set to true if you want more mappings
      },

      -- Context-aware commenting (knows JSX, TSX, Vue templates, etc.)
      pre_hook = commentstring.create_pre_hook(),

      -- Toggle options
      toggler = {
        -- Toggle comment for current line
        line = "gcc",
        -- Toggle comment for selection
        block = "gbc",
      },

      -- Operator-pending mappings
      opleader = {
        -- Line comment
        line = "gc",
        -- Block comment
        block = "gb",
      },

      -- Extra mappings
      extra = {
        -- Add comment above current line
        above = "gcO",
        -- Add comment below current line
        below = "gco",
        -- Add comment at end of line
        eol = "gcA",
      },

      -- Enable commenting in visual mode
      padding = true,

      -- Don't create empty comments
      sticky = true,

      -- Ignore certain filetypes
      ignore = "^$",

      -- Language-specific configurations
      -- (Comment.nvim usually handles this automatically)
    })

    -- Enhanced keymaps for better commenting workflow
    local map = vim.keymap.set

    -- Basic commenting (already provided by setup, but we can customize)
    map("n", "<leader>cc", "gcc", { desc = "Comment: Toggle current line" })
    map("n", "<leader>cb", "gbc", { desc = "Comment: Toggle block comment" })

    -- Visual mode commenting
    map("v", "<leader>cc", "gc", { desc = "Comment: Toggle selection" })
    map("v", "<leader>cb", "gb", { desc = "Comment: Toggle block selection" })

    -- Comment motions
    map("n", "<leader>c$", "gc$", { desc = "Comment: To end of line" })
    map("n", "<leader>c^", "gc^", { desc = "Comment: To start of line" })
    map("n", "<leader>ca", "gcA", { desc = "Comment: Add at end of line" })
    map("n", "<leader>co", "gco", { desc = "Comment: Add below current line" })
    map("n", "<leader>cO", "gcO", { desc = "Comment: Add above current line" })

    -- Comment objects (comment inside/around)
    map("n", "<leader>cic", "gcic", { desc = "Comment: Inner comment object" })
    map("n", "<leader>cac", "gcac", { desc = "Comment: Around comment object" })

    -- Comment with count support
    map("n", "<leader>c2", "2gcc", { desc = "Comment: Toggle 2 lines" })
    map("n", "<leader>c5", "5gcc", { desc = "Comment: Toggle 5 lines" })

    -- Smart commenting based on context
    local function smart_comment()
      local mode = vim.fn.mode()

      if mode == "v" or mode == "V" then
        -- Visual mode - use appropriate comment type
        local filetype = vim.bo.filetype
        if filetype == "javascript" or filetype == "typescript" or filetype == "jsx" or filetype == "tsx" then
          -- In JS/TS, prefer block comments for multi-line selections
          vim.cmd("normal! gb")
        else
          vim.cmd("normal! gc")
        end
      else
        -- Normal mode - toggle current line
        vim.cmd("normal! gcc")
      end
    end

    map({ "n", "v" }, "<leader>cm", smart_comment, { desc = "Comment: Smart toggle" })

    -- Auto-comment commands for documentation
    vim.api.nvim_create_user_command("CommentFunction", function()
      local line = vim.fn.line(".")
      local indent = string.rep(" ", vim.fn.indent(line))

      -- Add function comment based on language
      local filetype = vim.bo.filetype
      local comment_chars = "//"

      if filetype == "python" then
        comment_chars = "#"
      elseif filetype == "lua" then
        comment_chars = "--"
      elseif filetype == "vim" then
        comment_chars = "\""
      end

      local comment_text = comment_chars .. " TODO: Add function documentation"
      vim.fn.append(line - 1, indent .. comment_text)
    end, { desc = "Add function documentation comment" })

    vim.api.nvim_create_user_command("CommentTodo", function(opts)
      local line = vim.fn.line(".")
      local indent = string.rep(" ", vim.fn.indent(line))
      local filetype = vim.bo.filetype
      local comment_chars = "//"

      if filetype == "python" then
        comment_chars = "#"
      elseif filetype == "lua" then
        comment_chars = "--"
      elseif filetype == "vim" then
        comment_chars = "\""
      end

      local todo_text = opts.args ~= "" and opts.args or "TODO: Implement this"
      local comment_text = comment_chars .. " " .. todo_text
      vim.fn.append(line, indent .. comment_text)
    end, { nargs = "?", desc = "Add TODO comment with optional text" })

    -- Auto-comment for specific patterns
    local comment_group = vim.api.nvim_create_augroup("CommentEnhancements", { clear = true })

    -- Auto-add comment headers for new files
    vim.api.nvim_create_autocmd("BufNewFile", {
      group = comment_group,
      callback = function(args)
        local filename = vim.fn.expand("%:t")
        local filetype = vim.bo.filetype
        local comment_char = "//"

        if filetype == "python" then
          comment_char = "#"
        elseif filetype == "lua" then
          comment_char = "--"
        elseif filetype == "vim" then
          comment_char = "\""
        end

        local header = {
          comment_char .. " File: " .. filename,
          comment_char .. " Description: ",
          comment_char .. " Created: " .. os.date("%Y-%m-%d"),
          comment_char,
        }

        vim.fn.append(0, header)
      end,
      desc = "Auto-add file header comment"
    })

    -- Language-specific commenting enhancements
    vim.api.nvim_create_autocmd("FileType", {
      group = comment_group,
      pattern = { "python", "lua", "javascript", "typescript", "rust", "cpp" },
      callback = function(args)
        local bufnr = args.buf
        local filetype = vim.bo.filetype

        -- Add language-specific commenting shortcuts
        if filetype == "python" then
          map("n", "<leader>cd", "## ", { buffer = bufnr, desc = "Comment: Python docstring marker" })
        elseif filetype == "lua" then
          map("n", "<leader>cd", "--- ", { buffer = bufnr, desc = "Comment: LuaDoc marker" })
        elseif filetype == "rust" then
          map("n", "<leader>cd", "/// ", { buffer = bufnr, desc = "Comment: Rust doc comment" })
        end
      end,
      desc = "Language-specific commenting shortcuts"
    })

    -- Debug command to check comment configuration
    vim.api.nvim_create_user_command("CommentDebug", function()
      local ft = vim.bo.filetype
      local commentstring = vim.bo.commentstring
      print("Filetype: " .. ft)
      print("Comment string: " .. (commentstring or "not set"))
      print("Available mappings:")
      print("  gcc - Toggle current line")
      print("  gbc - Toggle block comment")
      print("  gc{motion} - Comment with motion")
      print("  gb{motion} - Block comment with motion")
    end, { desc = "Debug comment configuration" })
  end,
}
