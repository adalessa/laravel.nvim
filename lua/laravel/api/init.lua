local Job = require "plenary.job"
local environment = require "laravel.environment"
local ApiResponse = require "laravel.api.response"

local M = {}

function M.generate_command(name, args)
  local executable = environment.get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
  end

  return vim.fn.extend(executable, args)
end

--- Run the command sync
---@param program string
---@param args string[]
---@return ApiResponse
function M.sync(program, args)
  local cmd = M.generate_command(program, args)
  local command = table.remove(cmd, 1)
  local stderr = {}

  local stdout, ret = Job:new({
    command = command,
    args = cmd,
    on_stderr = function(_, data)
      table.insert(stderr, data)
    end,
  }):sync()

  return ApiResponse:new(stdout, ret, stderr)
end

--- Run the command async
---@param program string
---@param args string[]
---@param callback function
function M.async(program, args, callback)
  local cmd = M.generate_command(program, args)
  local command = table.remove(cmd, 1)

  Job:new({
    command = command,
    args = cmd,
    on_exit = vim.schedule_wrap(function(j, exit_code)
      callback(ApiResponse:new(j:result(), exit_code, j:stderr_result()))
    end),
  }):start()
end

function M.is_composer_package_install(package)
  return M.sync("composer", { "info", package }):successful()
end

function M.php_execute(code)
  return M.sync("artisan", { "tinker", "--execute", "echo " .. code })
end

return M
