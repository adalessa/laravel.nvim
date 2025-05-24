local M = {}

M.app = {}

function M.setup(opts)
  M.app = require("laravel.app"):new(opts):start()
  -- Idea from Snacks have a global variable for easy use
  _G.Laravel = M.app
end

return M
