--- Runs in a new terminal and can operate in the terminal
---@param cmd table
---@param opts table
---@return table
return function(cmd, opts)
  local options = require("laravel").app.options
  local default = {
    split = {
      cmd = options.split.cmd,
    },
  }

  opts = vim.tbl_deep_extend("force", default, opts or {})
  vim.cmd(string.format("%s new term://%s", opts.split.cmd, table.concat(cmd, " ")))
  vim.cmd "startinsert"

  return {
    buff = vim.api.nvim_win_get_buf(0),
  }
end
