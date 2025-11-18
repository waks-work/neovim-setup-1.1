-- ======================
--  KEY MAPS
-- ======================
local map = vim.keymap.set
vim.g.mapleader = " " -- Make sure this is early!

-- ======================
-- File Explorer (NvimTree)
-- ======================
-- Remove 'if has()' — just define mappings
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle File Explorer", silent = true })
map("n", "<leader>E", "<cmd>NvimTreeFocus<CR>", { desc = "Focus File Explorer", silent = true })
map("n", "<leader>r", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh Tree", silent = true })
map("n", "<leader>ft", "<cmd>NvimTreeFindFile<CR>", { desc = "Find Current File", silent = true })
map("n", "<leader>cl", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse Tree", silent = true })

-- ======================
-- Telescope
-- ======================
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files", silent = true })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live Grep", silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Open Buffers", silent = true })
map("n", "<leader>gf", "<cmd>Telescope git_file_history<CR>", { desc = "File History (Git)", silent = true })

-- ======================
-- Quick Save / Quit
-- ======================
map("n", "<leader>ww", "<cmd>w<CR>", { desc = "Save File" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Window" })

-- ======================
-- Buffer Navigation
-- ======================
map("n", "<A-right>", "<cmd>bnext<CR>", { desc = "Next Buffer", silent = true })
map("n", "<A-left>", "<cmd>bprev<CR>", { desc = "Previous Buffer", silent = true })
map("n", "<A-l>", "<cmd>ls<CR>", { desc = "List Buffers", silent = true })
map("n", "<A-c>", "<cmd>bd<CR>", { desc = "Close Buffer", silent = true })

-- ======================
-- C++ Specific Keymaps (Buffer-local)
-- ======================
-- These will only be set when working with C++ files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    -- Set C++ specific options
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
    vim.opt_local.cindent = true
    vim.opt_local.smartindent = true

    -- Enhanced keymaps for C++
    map("n", "<leader>cf", "<cmd>ClangFormat<CR>", { buffer = true, desc = "Format C++" })
    map("n", "<leader>ci", "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = true, desc = "Switch Header/Source" })

    -- Debug keymaps
    map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { buffer = true, desc = "Toggle Breakpoint" })
    map("n", "<leader>dc", "<cmd>DapContinue<CR>", { buffer = true, desc = "Continue Debug" })
    map("n", "<leader>do", "<cmd>DapStepOver<CR>", { buffer = true, desc = "Step Over" })
    map("n", "<leader>di", "<cmd>DapStepInto<CR>", { buffer = true, desc = "Step Into" })
    map("n", "<leader>dO", "<cmd>DapStepOut<CR>", { buffer = true, desc = "Step Out" })
    map("n", "<leader>dt", "<cmd>DapTerminate<CR>", { buffer = true, desc = "Terminate Debug" })

    -- Build and compile keymaps
    map("n", "<leader>cb", "<cmd>CMakeBuild<CR>", { buffer = true, desc = "CMake Build" })
    map("n", "<leader>cr", "<cmd>CMakeRun<CR>", { buffer = true, desc = "CMake Run" })
    map("n", "<leader>cd", "<cmd>CMakeDebug<CR>", { buffer = true, desc = "CMake Debug" })
  end,
})

-- Global C++ compile command (available everywhere)
vim.api.nvim_create_user_command("CppCompile", function()
  local file = vim.fn.expand("%:p")
  local output = vim.fn.expand("%:p:r")
  vim.cmd("terminal g++ -std=c++20 -Wall -Wextra -g " .. file .. " -o " .. output)
end, { desc = "Compile current C++ file" })

-- Optional: Add a global keymap for C++ compilation
map("n", "<leader>cc", "<cmd>CppCompile<CR>", { desc = "Compile C++ File" })

-- ======================
-- Emmet
-- ======================
vim.g.user_emmet_expandabbr_key = '<C-e>'

map({ "n", "v" }, "<leader>wv", function()
  local mode = vim.fn.mode()
  if mode:find("[vV]") then
    require("waksAI").explain_visual()
  else
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local code = table.concat(lines, "\n")
    local prompt = "Explain this file:\n" .. code

    local ui = require("waksAI.ui")
    local api = require("waksAI.api")

    ui.open_chat()
    ui.render_user(prompt)

    api.send(prompt, function(ai_text, code_blocks)
      ui.render_ai(ai_text)
      if code_blocks and #code_blocks > 0 then
        for _, cb in ipairs(code_blocks) do
          ui.render_ai(cb.code, { is_code = true, lang = cb.lang })
        end
      end
    end)
  end
end, { desc = "waksAI: Explain code (selection or file)" })

-- ======================
-- Rust Specific Keymaps (Global - for WhichKey)
-- ======================
-- These are global keymaps that show in WhichKey but only work in Rust files
map("n", "<leader>rr", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Open runnables (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Runnables" })

map("n", "<leader>rl", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Toggle inlay hints (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Toggle inlay hints" })

map("n", "<leader>rh", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Hover actions (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Hover actions" })

map("n", "<leader>ra", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Code actions (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Code actions" })

map("n", "<leader>rp", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Parent module (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Parent module" })

map("n", "<leader>rj", function()
  if vim.bo.filetype == "rust" then
    vim.notify("Rust: Join lines (requires LSP)", vim.log.levels.INFO)
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Join lines" })

-- Format keymap (always works)
map("n", "<leader>rf", function()
  if vim.bo.filetype == "rust" then
    vim.cmd("RustFmt")
  else
    vim.notify("Not a Rust file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Format code" })

-- Cargo.toml keymaps for crates.nvim
map("n", "<leader>rc", function()
  if vim.bo.filetype == "toml" then
    require("crates").show_crate_popup()
  else
    vim.notify("Not a Cargo.toml file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Show crate info" })

map("n", "<leader>rv", function()
  if vim.bo.filetype == "toml" then
    require("crates").show_versions_popup()
  else
    vim.notify("Not a Cargo.toml file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Show versions" })

map("n", "<leader>rF", function()
  if vim.bo.filetype == "toml" then
    require("crates").show_features_popup()
  else
    vim.notify("Not a Cargo.toml file", vim.log.levels.WARN)
  end
end, { desc = "Rust: Show features" })

-- ======================
-- BETTER NAVIGATION
-- ======================
