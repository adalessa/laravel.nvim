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

  if vim.fn.executable "rg" == 1 then
    vim.health.report_ok "rg installed"
  else
    vim.health.report_warn(
      "ripgrep is missing, is required for finding view usage",
      { "Installed from your package manager" }
    )
  end

  vim.health.report_start "Plugin Dependencies"
  local ok_null_ls, _ = pcall(require, "null-ls")
  if ok_null_ls then
    vim.health.report_ok "Null LS is installed"
  else
    vim.health.report_warn(
      "Null LS is not installed, this is use to add completion, diagnostic and Code actions",
      { "Install it from `https://github.com/nvimtools/none-ls.nvim`" }
    )
  end
  local ok_luannip, _ = pcall(require, "luasnip")
  if ok_luannip then
    vim.health.report_ok "luasnip is installed"
  else
    vim.health.report_warn(
      "Luasnip is not installed, this is use to snippets related to larevel",
      { "Install it from `https://github.com/L3MON4D3/LuaSnip`" }
    )
  end

  vim.health.report_start "Environment"

  if not environment.environment then
    vim.health.report_error(
      "Environment not configure for this directory, no more checks",
      { "Check project is laravel, current directory `:pwd` is the root of laravel project" }
    )
    return
  end

  vim.health.report_ok "Environment setup successful"

  vim.health.report_info("Name: " .. environment.environment.name)
  vim.health.report_info "Condition: "
  vim.health.report_info(vim.inspect(environment.environment.condition))
  vim.health.report_info "Commands: "
  vim.health.report_info(vim.inspect(environment.environment.commands))

  vim.health.report_start "Composer Dependencies"

  if not environment.get_executable "composer" then
    vim.health.report_error "Composer executable not found can't check dependencies"
  end

  local composer_dependencies = {
    {
      name = "doctrine/dbal",
      messages = "This is required for model:show, related model picker",
    },
    {
      name = "laravel/tinker",
      messages = "This is required for tinker repl",
    },
  }

  for _, dependency in pairs(composer_dependencies) do
    if api.is_composer_package_install(dependency.name) then
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
