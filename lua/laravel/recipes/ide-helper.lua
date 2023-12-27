local api = require "laravel.api"

local M = {}

local function writeModels()
  api.async(
    "artisan",
    { "ide-helper:models", "-n", "-W", "-M" },
    ---@param response ApiResponse
    function(response)
      if response:failed() then
        error(response:errors(), vim.log.levels.ERROR)
      end

      vim.notify("Ide Helper Models Complete", vim.log.levels.INFO)
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
        error({ "Cant install ide-helper", response:errors() }, vim.log.levels.ERROR)
      end

      require("laravel.commands").list = {}
      writeModels()
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
