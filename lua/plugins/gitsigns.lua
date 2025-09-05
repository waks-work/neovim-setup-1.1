return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" }, -- lazy-load for speed
    config = function()
        require("gitsigns").setup({
            signs = {
                add          = { text = "┃" },
                change       = { text = "┃" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "" },
            },
            current_line_blame = true, -- show blame inline
            current_line_blame_opts = {
                delay = 400,
                virt_text_pos = "eol",
                ignore_whitespace = true,
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
                end

                -- Navigation
                map("n", "]c", function() gs.next_hunk() Snacks.notifier.info("Next hunk") end, "Next Hunk")
                map("n", "[c", function() gs.prev_hunk() Snacks.notifier.info("Prev hunk") end, "Prev Hunk")

                -- Actions
                map("n", "<leader>gl", gs.preview_hunk, "Preview Git hunk")
                map("n", "<leader>gb", gs.blame_line, "Blame line")
                map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
                map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")

                -- Whole buffer
                map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")

                -- Snacks picker for hunks
                map("n", "<leader>gh", function()
                    Snacks.picker.grep({ search = "diff --git", cwd = vim.fn.getcwd() })
                end, "Search Git Hunks")
            end,
        })
    end,
}
           
