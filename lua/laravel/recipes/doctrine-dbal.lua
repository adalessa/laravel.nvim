local api = require "laravel.api"

local M = {}

function M.run()
  if not api.is_composer_package_install "doctrine/dbal" then
    api.async(
      "composer",
      { "require", "--dev", "doctrine/dbal" },
      ---@param response ApiResponse
      function(response)
        if response:failed() then
          vim.notify("Cant install doctrine/dbal\n\r" .. response:prettyErrors(), vim.log.levels.ERROR)
        else
          vim.notify("Installation completed", vim.log.levels.INFO)
        end
      end
    )
  else
    vim.notify("Already Installed", vim.log.levels.INFO)
  end
end

return M
