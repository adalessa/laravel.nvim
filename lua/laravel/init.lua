local M = {}

M.app = {}

function M.setup(opts)
  M.app = require("laravel.core.app"):start(opts)
end

return M
