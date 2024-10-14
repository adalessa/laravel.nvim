local app = require("laravel").app

local M = {}

local report_start = vim.health.start
local report_ok = vim.health.ok
local report_info = vim.health.info
local report_warn = vim.health.warn
local report_error = vim.health.error

M.check = function()
  report_start("Laravel")

  report_start("External Dependencies")
  if vim.fn.executable("rg") == 1 then
    report_ok("rg installed")
  else
    report_error("ripgrep is missing, is required for finding view usage", { "Installed from your package manager" })
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

  local ok_telescope, _ = pcall(require, "telescope")
  if ok_telescope then
    report_ok("Telescope is installed")
  else
    report_warn(
      "Telescope is not installed, A lot of functions uses telescope for the pickers",
      { "Install it from `https://github.com/nvim-telescope/telescope.nvim`" }
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

  report_start("Environment")

  if not app("env"):is_active() then
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

  report_start("Composer Dependencies")

  if not app("env"):get_executable("composer") then
    report_error("Composer executable not found can't check dependencies")
  end
end

return M
