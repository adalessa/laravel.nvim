local environment = require "laravel.environment"
local api = require "laravel.api"
local M = {}

local report_start = vim.health.start or vim.health.report_start
local report_ok = vim.health.ok or vim.health.report_ok
local report_info = vim.health.info or vim.health.report_info
local report_warn = vim.health.warn or vim.health.report_warn
local report_error = vim.health.error or vim.health.report_error

M.check = function()
  report_start "Laravel"

  report_start "External Dependencies"
  if vim.fn.executable "rg" == 1 then
    report_ok "rg installed"
  else
    report_warn(
      "ripgrep is missing, is required for finding view usage",
      { "Installed from your package manager" }
    )
  end

  report_start "Plugin Dependencies"
  local ok_null_ls, _ = pcall(require, "null-ls")
  if ok_null_ls then
    report_ok "Null LS is installed"
  else
    report_warn(
      "Null LS is not installed, this is use to add completion, diagnostic and Code actions",
      { "Install it from `https://github.com/nvimtools/none-ls.nvim`" }
    )
  end
  local ok_luannip, _ = pcall(require, "luasnip")
  if ok_luannip then
    report_ok "luasnip is installed"
  else
    report_warn(
      "Luasnip is not installed, this is use to snippets related to larevel",
      { "Install it from `https://github.com/L3MON4D3/LuaSnip`" }
    )
  end

  local ok_nui, _ = pcall(require, "nui.popup")
  if ok_nui then
    report_ok "Nui is installed"
  else
    report_warn(
      "Nui is not installed, this is use to create the UI for the command",
      { "Install it from `https://github.com/MunifTanjim/nui.nvim`" }
    )
  end

  local ok_telescope, _ = pcall(require, "telescope")
  if ok_telescope then
    report_ok "Telescope is installed"
  else
    report_warn(
      "Telescope is not installed, A lot of functions uses telescope for the pickers",
      { "Install it from `https://github.com/nvim-telescope/telescope.nvim`" }
    )
  end

  report_start "Environment"

  if not environment.environment then
    report_error(
      "Environment not configure for this directory, no more checks",
      { "Check project is laravel, current directory `:pwd` is the root of laravel project" }
    )
    return
  end

  report_ok "Environment setup successful"

  report_info("Name: " .. environment.environment.name)
  report_info "Condition: "
  report_info(vim.inspect(environment.environment.condition))
  report_info "Commands: "
  report_info(vim.inspect(environment.environment.commands))

  report_start "Composer Dependencies"

  if not environment.get_executable "composer" then
    report_error "Composer executable not found can't check dependencies"
  end

  local composer_dependencies = {
    {
      name = "laravel/tinker",
      messages = "This is required for tinker repl",
    },
  }

  for _, dependency in pairs(composer_dependencies) do
    if api.is_composer_package_install(dependency.name) then
      report_ok(string.format("Composer dependency `%s` is installed", dependency.name))
    else
      report_warn(
        string.format("Composer dependency `%s` is not installed", dependency.name),
        { dependency.messages }
      )
    end
  end
end

return M
