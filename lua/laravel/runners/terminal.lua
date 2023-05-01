--- Runs in a new terminal and can operate in the terminal
---@param cmd table
---@param opts table
---@return table
return function(cmd, opts)
  local options = require("laravel.application").get_options()
  local default = {
    focus = true,
    split = {
      cmd = options.split.cmd,
    },
  }

  local cur_window = vim.api.nvim_get_current_win()

  opts = vim.tbl_deep_extend("force", default, opts or {})
  vim.cmd(string.format("%s new term://%s", opts.split.cmd, table.concat(cmd, " ")))
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
  }
end
