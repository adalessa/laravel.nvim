local config = require "laravel.config"
--- Runs in a new terminal and can operate in the terminal
---@param cmd table
---@param opts table
---@return table, boolean
return function(cmd, opts)
  local default = {
    focus = true,
    split = {
      cmd = config.options.split.cmd,
    },
  }

  local cur_window = vim.api.nvim_get_current_win()

  opts = vim.tbl_deep_extend("force", default, opts or {})
  vim.cmd(string.format("vertical new term://%s", table.concat(cmd, " ")))
  vim.cmd "startinsert"

  local buff = vim.api.nvim_get_current_buf()
  local term_id = vim.b.terminal_job_id

  if not opts.focus then
    vim.api.nvim_set_current_win(cur_window)
    vim.cmd "stopinsert"
  end

  return {
    buff = buff,
    term_id = term_id,
  }, true
end
