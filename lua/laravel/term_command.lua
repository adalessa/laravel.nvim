local BaseCommand = require("laravel.base_command")

local TermCommand = setmetatable({}, { __index = BaseCommand })
TermCommand.__index = TermCommand

function TermCommand:execute()
  -- create buffer
  self.bufnr = vim.api.nvim_create_buf(false, true)

  vim.cmd("botright split")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, self.bufnr)

  self.job_id = vim.fn.jobstart(self.cmd, {
    term = true,
    on_exit = function()
      self.exited = true
    end,
  })

  -- hide window (background)
  vim.api.nvim_win_hide(win)
end

return TermCommand
