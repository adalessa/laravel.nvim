local M = {}

M.app = {}

function M.setup(opts)
  M.app = require("laravel.app"):new(opts):start()
end

return M
