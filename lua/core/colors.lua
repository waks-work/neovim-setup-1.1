-- core/colors.lua
-- Enable termguicolors
vim.opt.termguicolors = true

-- Load Catppuccin theme
vim.cmd([[colorscheme catppuccin]])

-- Fallback if Catppuccin not available
local ok, _ = pcall(vim.cmd, "colorscheme catppuccin")
if not ok then
  vim.notify("Catppuccin theme not found! Installing...", vim.log.levels.WARN)
  -- It will be installed via lazy.nvim
  vim.cmd([[colorscheme desert]])
end

-- Enable color highlights for hex/rgb codes
require("colorizer").setup()

-- Enhanced transparency setup
local function set_transparency()
  vim.cmd([[
    hi Normal guibg=NONE ctermbg=NONE
    hi NormalNC guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
    hi VertSplit guibg=NONE ctermbg=NONE
    hi StatusLine guibg=NONE ctermbg=NONE
    hi StatusLineNC guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi CursorLineNr guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
    hi TelescopeBorder guibg=NONE ctermbg=NONE
    hi TelescopeNormal guibg=NONE ctermbg=NONE
    hi NvimTreeNormal guibg=NONE ctermbg=NONE
    hi WhichKeyFloat guibg=NONE ctermbg=NONE
  ]])
end

set_transparency()

-- Optional: Iridescent cursorline effect (comment out if you don't want it)
-- vim.api.nvim_create_autocmd("CursorMoved", {
--   callback = function()
--     local hue = math.random(0, 360)
--     vim.cmd("hi CursorLine guibg=hsl(" .. hue .. ",70%,15%)")
--   end
-- })
