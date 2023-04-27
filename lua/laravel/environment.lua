local user_defined = require "laravel.environments.user_defined"
local M = {}

M.load = function(options)
  ---@class laravel.environment
  ---@field environment table|nil
  ---@field has_phpstan boolean
  ---@field is_laravel_project boolean
  local project_properties = {}

  local order = { "sail", "docker_compose", "local" }

  if options.environment == "custom" and user_defined.is_valid(options.environment_settings) then
    project_properties.environment = user_defined:new(options.environment_settings)
  elseif options.environment == "auto" then
    project_properties.environment = require("laravel.environments.detector").get_environment(order, options.environment_settings)
  elseif vim.tbl_contains(options.environment, order) then
    project_properties.environment =
      require("laravel.environments." .. options.environment):new(options.environment_settings)
  end

  project_properties.is_laravel_project = vim.fn.filereadable "artisan" == 1
  project_properties.has_phpstan = vim.fn.filereadable "vendor/bin/phpstan" == 1

  return project_properties
end

return M
