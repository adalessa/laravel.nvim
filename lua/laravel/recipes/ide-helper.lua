local api = require "laravel.api"

local M = {}

local function writeModels()
  api.async(
    "artisan",
    { "ide-helper:models", "-n", "-W", "-M" },
    ---@param response ApiResponse
    function(response)
      if response:failed() then
        vim.notify(response:prettyErrors(), vim.log.levels.ERROR)
      else
        vim.notify("Ide Helper Models Complete", vim.log.levels.INFO)
      end
    end
  )
end

local function installIdeHelperAndWrite()
  api.async(
    "composer",
    { "require", "--dev", "barryvdh/laravel-ide-helper" },
    ---@param response ApiResponse
    function(response)
      if response:failed() then
        vim.notify("Cant install ide-helper\n\r" .. response:prettyErrors(), vim.log.levels.ERROR)
      else
        require("laravel.commands").list = {}
        writeModels()
      end
    end
  )
end

function M.run()
  if not api.is_composer_package_install "barryvdh/laravel-ide-helper" then
    writeModels()
    return
  end

  installIdeHelperAndWrite()
end

return M
