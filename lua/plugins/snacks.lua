return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = true },
    explorer = { 
      enabled = true,
      -- Add safe file opening
      open_file = function(path)
        -- Check for swap files before opening
        local swap_file = path .. ".swp"
        if vim.fn.filereadable(swap_file) == 1 then
          local choice = vim.fn.confirm("Swap file exists for " .. path .. 
                                      "\n(R)ecover, (D)elete, (O)pen read-only, (C)ancel?", "RDOC", 1)
          if choice == 1 then
            vim.cmd("recover " .. path)
          elseif choice == 2 then
            vim.fn.delete(swap_file)
            vim.cmd("edit " .. path)
          elseif choice == 3 then
            vim.cmd("view " .. path)
          else
            return -- Cancel
          end
        else
          vim.cmd("edit " .. path)
        end
      end
    },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = { 
      enabled = true,
      -- Safe file actions
      actions = {
        select = function(item)
          local path = item.path or item.value
          if path and vim.fn.filereadable(path) == 1 then
            -- Use safe file opening
            require("snacks.explorer").open_file(path)
          end
        end
      }
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      }
    }
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() 
        -- Safe smart find
        local ok, err = pcall(Snacks.picker.smart)
        if not ok then
          vim.notify("Snacks error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end, desc = "Smart Find Files" },
    { "<leader>,", function() 
        pcall(Snacks.picker.buffers) 
      end, desc = "Buffers" },
    { "<leader>/", function() 
        pcall(Snacks.picker.grep) 
      end, desc = "Grep" },
    { "<leader>:", function() 
        pcall(Snacks.picker.command_history) 
      end, desc = "Command History" },
    { "<leader>n", function() 
        pcall(Snacks.picker.notifications) 
      end, desc = "Notification History" },
    { "<leader>e", function() 
        pcall(Snacks.explorer) 
      end, desc = "File Explorer" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) 
          if Snacks and Snacks.debug then
            Snacks.debug.inspect(...) 
          else
            print(vim.inspect(...))
          end
        end
        _G.bt = function() 
          if Snacks and Snacks.debug then
            Snacks.debug.backtrace() 
          end
        end
        
        -- Safe print override
        if Snacks and Snacks.debug then
          vim.print = _G.dd
        end

        -- Create some toggle mappings with error handling
        local function safe_toggle(toggle_func, keymap)
          vim.keymap.set("n", keymap, function()
            local ok, err = pcall(toggle_func)
            if not ok then
              vim.notify("Toggle error: " .. tostring(err), vim.log.levels.ERROR)
            end
          end, { desc = "Toggle " .. keymap })
        end

        -- Safe toggle mappings
        if Snacks and Snacks.toggle then
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end
      end,
    })
  end,
}
