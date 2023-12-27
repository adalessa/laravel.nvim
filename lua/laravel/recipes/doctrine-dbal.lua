local api = require "laravel.api"

local M = {}

function M.run()
  if not api.is_composer_package_install "doctrine/dbal" then
    api.async("composer", { "require", "--dev", "doctrine/dbal" }, function(_, exit_code)
      if exit_code ~= 0 then
        error("Cant install doctrine/dbal", vim.log.levels.ERROR)
      end
      vim.notify("Installation completed", vim.log.levels.INFO)
    end)
  else
    vim.notify("Already Installed", vim.log.levels.INFO)
  end
end

return M
