local M = {}

M.app = {}

function M.setup(opts)
  require("laravel.utils.treesitter_queries")
  M.app = require("laravel.core.app"):start(opts)
end

return M
