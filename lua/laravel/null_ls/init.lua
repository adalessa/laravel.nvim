local M = {}

function M.setup()
  require("laravel.null_ls.completion").setup()
  require("laravel.null_ls.diagnostic").setup()
  require("laravel.null_ls.code_actions").setup()
end

return M
