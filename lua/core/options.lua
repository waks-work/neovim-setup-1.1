-- core/options.lua
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"

-- Swap file configuration to prevent E325 errors
vim.opt.swapfile = false    -- Disable swap files entirely
vim.opt.backup = false      -- Disable backup files
vim.opt.writebackup = false -- Disable write backup

-- Or if you want to keep swap files but handle them better:
-- vim.opt.directory = vim.fn.stdpath("state") .. "/swap//"
-- vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"
-- vim.opt.undodir = vim.fn.stdpath("state") .. "/undo//"

-- Auto-commands to handle recovery
local swap_group = vim.api.nvim_create_augroup("SwapFileHandling", { clear = true })

-- Auto-delete swap files when properly closing files
vim.api.nvim_create_autocmd("VimLeave", {
  group = swap_group,
  callback = function()
    -- Clean up any remaining swap files
    vim.fn.delete(vim.fn.expand("%:p") .. ".swp")
  end,
})

-- Handle swap file warnings more gracefully
vim.api.nvim_create_autocmd("SwapExists", {
  group = swap_group,
  callback = function(args)
    local choice = vim.fn.confirm("Swap file exists for " .. args.file ..
      "\n(R)ecover, (D)elete, (Q)uit, (A)bort?", "RDQA", 1)
    if choice == 1 then
      vim.cmd("recover " .. args.file)
    elseif choice == 2 then
      vim.fn.delete(args.file .. ".swp")
      vim.cmd("edit " .. args.file)
    elseif choice == 3 then
      vim.cmd("quit")
    else
      vim.cmd("echo 'Aborted'")
    end
  end,
})
