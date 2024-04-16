local api = require "laravel.api"

local M = {}

local function writeModels()
  api.async("artisan", { "ide-helper:models", "-n", "-W", "-M" }, function()
    vim.notify("Ide Helper Models Complete", vim.log.levels.INFO)
  end, function(errResponse)
    vim.notify(errResponse:prettyErrors(), vim.log.levels.ERROR)
  end)
end

local function installIdeHelperAndWrite()
  api.async("composer", { "require", "--dev", "barryvdh/laravel-ide-helper" }, function()
    vim.cmd [[doautocmd User LaravelComposerRunned]]
    writeModels()
  end, function(errResponse)
    vim.notify("Cant install ide-helper\n\r" .. errResponse:prettyErrors(), vim.log.levels.ERROR)
  end)
end

function M.run()
  if api.is_composer_package_install "barryvdh/laravel-ide-helper" then
    writeModels()
    return
  end

  installIdeHelperAndWrite()
end

return M
