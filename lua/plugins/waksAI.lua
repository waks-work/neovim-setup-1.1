return {
  dir = vim.fn.stdpath("config") .. "/waksAI",

  cmd = {
    "WaksAIChat",
    "WaksAIAsk",
    "WaksUndoLast", -- undo last AI edit
  },

  keys = {
    { "<leader>wa", function() require("waksAI").open() end,                     mode = "n", desc = "waksAI: Open chat" },
    { "<leader>ws", function() require("waksAI").prompt() end,                   mode = "n", desc = "waksAI: Send prompt" },
    { "<leader>wv", function() require("waksAI").explain_visual() end,           mode = "v", desc = "waksAI: Explain selection" },
    { "<leader>wm", function() require("waksAI").toggle_model() end,             mode = "n", desc = "waksAI: Toggle model" },
    { "<leader>wu", function() vim.cmd("WaksUndoLast") end,                      mode = "n", desc = "waksAI: Undo last AI edit" },
    { "<leader>we", function() require("waksAI.edit").show_diff_and_apply() end, mode = "v", desc = "waksAI: Apply AI edit" },
    { "<leader>wl", function() require("waksAI.history").open_log() end,         mode = "n", desc = "waksAI: Open AI edit log" },
  },

  config = function()
    require("waksAI").setup()

    -- Safe registration of undo command
    vim.api.nvim_create_user_command("WaksUndoLast", function()
      local ok, history = pcall(require, "waksAI.history")
      if ok then
        history.undo_last()
      else
        vim.notify("waksAI.history not found", vim.log.levels.WARN)
      end
    end, { desc = "Undo last AI edit" })
  end,
}
