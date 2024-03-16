local M = {}

---@type LaravelOptions
M.defaults = require "laravel.config.default"

--- @type LaravelOptions
M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})
end

return M
