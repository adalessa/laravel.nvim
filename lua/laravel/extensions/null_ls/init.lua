local M = {}

function M.setup()
  local ok, _ = pcall(require, "null-ls")
  if not ok then
    return
  end

  require("laravel.extensions.null_ls.completion").setup()
  require("laravel.extensions.null_ls.diagnostic").setup()
  require("laravel.extensions.null_ls.code_actions").setup()
end

return M
