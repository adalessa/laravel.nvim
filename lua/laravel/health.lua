local app = require("laravel").app

local M = {}

local report_start = vim.health.start
local report_ok = vim.health.ok
local report_info = vim.health.info
local report_warn = vim.health.warn
local report_error = vim.health.error

M.check = function()
  report_start("External Dependencies")
  if vim.fn.executable("rg") == 1 then
    report_ok("rg installed")
  else
    report_error("ripgrep is missing, is required for finding view usage", { "Installed from your package manager" })
  end

  if vim.fn.executable("jq") == 1 then
    report_ok("jq installed")
  else
    report_warn(
      "jq is missing, although it is not required, is a nice tool to have",
      { "Install it from your package manager or from `https://jqlang.org/download/`" }
    )
  end

  report_start("Plugin Dependencies")

  local ok_nui, _ = pcall(require, "nui.popup")
  if ok_nui then
    report_ok("Nui is installed")
  else
    report_error(
      "Nui is not installed, this is use to create the UI for the command",
      { "Install it from `https://github.com/MunifTanjim/nui.nvim`" }
    )
  end

  local ok_nio, _ = pcall(require, "nio")
  if ok_nio then
    report_ok("Nio is Installed")
  else
    report_error(
      "NIO is not installed, this is use to handle async functionalities",
      { "Install it from `https://github.com/nvim-neotest/nvim-nio`" }
    )
  end

  local ok_cmp, _ = pcall(require, "cmp")
  if ok_cmp then
    report_ok("CMP is installed")
  else
    report_warn(
      "CMP is not installed, completion source is available for it",
      { "Install it from `https://github.com/hrsh7th/nvim-cmp`" }
    )
  end

  report_start("Pickers")
  local enable = app("laravel.services.config").get("features.pickers.enable")
  report_info("Enabled: " .. (enable and "Yes" or "No"))
  if enable then
    local picker = app("laravel.services.config").get("features.pickers.provider")
    report_info("Selected Picker: " .. picker)
    local provider = app("pickers." .. picker)
    if provider.check() then
      report_ok("Picker check successfull")
    else
      report_error(
        "Picker check failed",
        { "Check your configuration change picker or install the required dependencies" }
      )
    end
  end

  report_start("Environment")

  if not app:isActive() then
    report_error(
      "Environment not configure for this directory, no more checks",
      { "Check project is laravel, current directory `:pwd` is the root of laravel project" }
    )
    return
  end

  report_ok("Environment setup successful")

  report_info("Name: " .. app("env").environment.name)
  report_info("Condition: ")
  report_info(vim.inspect(app("env").environment.condition))
  report_info("Commands: ")
  report_info(vim.inspect(app("env").environment.commands))

  report_start("Composer")

  if not app("env"):getExecutable("composer") then
    report_error("Composer executable not found can't check dependencies")
  else
    report_ok("Composer executable found")
  end
end

return M
