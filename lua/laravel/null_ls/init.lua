local M = {}

function M.setup()
  require("laravel.null_ls.completion").setup()
  require("laravel.null_ls.diagnostic").setup()
end

return M
