local environment = require "laravel.environment"
local api = require "laravel.api"
local M = {}

M.check = function()
  vim.health.report_start "Laravel"

  if vim.fn.executable "fd" == 1 then
    vim.health.report_ok "fd installed"
  else
    vim.health.report_warn(
      "fd is missing, is required for opening the migration",
      { "Installed from your package manager or source https://github.com/sharkdp/fd" }
    )
  end

  if vim.tbl_isempty(environment.environment) then
    vim.health.report_error(
      "Environment not configure for this directory, no more checks",
      { "Check project is laravel, current directory `:pwd` is the root of laravel project" }
    )
    return
  end
  vim.health.report_ok "Environment setup complete"

  vim.health.report_start "Environment"

  if vim.tbl_isempty(environment.environment.executables) then
    vim.health.report_error "No executables found in the environment, check the environment config"
    return
  end

  for name, command in pairs(environment.environment.executables) do
    if vim.fn.executable(command[1]) == 1 then
      vim.health.report_ok(string.format("%s: executable %s exists", name, command[1]))
    else
      vim.health.report_error(string.format("%s: executable %s does not exists", name, command[1]))
    end
  end

  if not environment.get_executable "composer" then
    vim.health.report_error "Composer executable not found can't check dependencies"
  end

  local composer_dependencies = {
    {
      name = "doctrine/dbal",
      messages = "This is required for model:show, related model picker and autocomplete",
    },
    {
      name = "laravel/tinker",
      messages = "This is required for tinker repl",
    },
  }

  vim.health.report_start "Composer dependencies"

  for _, dependency in pairs(composer_dependencies) do
    local res = api.sync("composer", { "info", dependency.name })
    if res.exit_code == 0 then
      vim.health.report_ok(string.format("Composer dependency `%s` is installed", dependency.name))
    else
      vim.health.report_warn(
        string.format("Composer dependency `%s` is not installed", dependency.name),
        { dependency.messages }
      )
    end
  end
end

return M
