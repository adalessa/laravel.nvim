local M = {}

function M.setup()
  local environment = require "laravel.environment"

  local group = vim.api.nvim_create_augroup("laravel", {})
  vim.api.nvim_create_autocmd({ "DirChanged" }, {
    group = group,
    callback = environment.setup,
  })
end

return M
