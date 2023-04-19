local M = {}

M.load = function()
  ---@class laravel.environment
  ---@field uses_sail boolean
  ---@field has_phpstan boolean
  ---@field is_laravel_project boolean
  local project_properties = {}

  local has_custom_cmd = require("laravel").app.options.default_exec ~= require("laravel.defaults").exec
  local has_sail_cmd = vim.fn.filereadable "vendor/bin/sail" == 1
  local has_docker_compose_config = vim.fn.filereadable "docker-compose.yml" == 1

  project_properties.is_laravel_project = vim.fn.filereadable "artisan" == 1
  project_properties.has_phpstan = vim.fn.filereadable "vendor/bin/phpstan" == 1
  project_properties.uses_sail = has_custom_cmd or has_sail_cmd and has_docker_compose_config

  return project_properties
end

return M
