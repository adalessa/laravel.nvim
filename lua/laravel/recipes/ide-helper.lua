local api = require "laravel.api"

local M = {}

local function writeModels()
  api.async("artisan", { "ide-helper:models", "-n", "-W", "-M" }, function(_, exit_code)
    local level = vim.log.levels.INFO
    if exit_code ~= 0 then
      level = vim.log.levels.ERROR
    end
    vim.notify("Ide Helper Models Complete", level)
  end)
end

local function installIdeHelperAndWrite()
  api.async("composer", { "require", "--dev", "barryvdh/laravel-ide-helper" }, function(_, exit_code)
    if exit_code ~= 0 then
      error("Cant install ide-helper", vim.log.levels.ERROR)
    end
    require("laravel.commands").list = {}

    writeModels()
  end)
end

function M.run()
  if not api.is_composer_package_install "barryvdh/laravel-ide-helper" then
    writeModels()
    return
  end

  installIdeHelperAndWrite()
end

return M
