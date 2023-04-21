local Path = require "plenary.path"

local M = {}

M.open_filename = function(filename)
  if vim.api.nvim_buf_get_name(0) ~= filename then
    filename = Path:new(vim.fn.fnameescape(filename)):normalize(vim.loop.cwd())
    pcall(vim.cmd, string.format("%s %s", "edit", filename))
  end
end

return M
