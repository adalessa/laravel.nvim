local config = require "laravel.config"
local environment = require "laravel.environment"
local history = require "laravel.history"
local Popup = require "nui.popup"
local Split = require "nui.split"

local ui_builders = {
  split = Split,
  popup = Popup,
}

---@param name string
---@param args string[]
---@param opts table|nil
return function(name, args, opts)
  opts = opts or {}
  local executable = environment.get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
    return
  end
  local cmd = vim.fn.extend(executable, args)

  local command_option = config.options.commands_options[args[1]] or {}

  opts = vim.tbl_extend("force", command_option, opts)

  local selected_ui = opts.ui or config.options.ui.default

  local instance = ui_builders[selected_ui](opts.nui_opts or config.options.ui.nui_opts[selected_ui])

  instance:mount()

  -- This returns thhe job id
  local jobId = vim.fn.termopen(table.concat(cmd, " "))

  history.add(jobId, name, args, opts)

  vim.cmd "startinsert"
end
