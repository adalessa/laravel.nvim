local nio = require("nio")
local ApiResponse = require("laravel.dto.api_response")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local health = require("laravel.core.health")

-- Programs that run against the Laravel application. Their exit code is a
-- useful signal to know whether the environment (php/container) is available.
local APP_PROGRAMS = {
  artisan = true,
  php = true,
  composer = true,
}

local function is_app_program(program)
  local name = vim.split(program or "", " ")[1]
  return APP_PROGRAMS[name] == true
end

---@class laravel.services.api
---@field command_generator laravel.services.command_generator
---@field log laravel.utils.log
local api = Class({
  command_generator = "laravel.services.command_generator",
  log = "laravel.utils.log",
})

---@async
---@param program string
---@param args string[]|nil
---@return laravel.dto.apiResponse, laravel.error
function api:run(program, args)
  local command, command_err = self.command_generator:generate(program, args)
  if not command then
    local err = Error:new(string.format("Command %s not found", program))
    if command_err then
      err:wrap(command_err)
    end

    if is_app_program(program) then
      health.markUnavailable(err:toString())
    end

    return {}, err
  end
  local cmd = table.remove(command, 1)

  local process, process_err = nio.process.run({ cmd = cmd, args = command })
  if not process then
    local message = string.format("Failed to run command cmd: %s args: %s", cmd, table.concat(args or {}, " "))
    if process_err and process_err ~= "" then
      message = message .. ": " .. process_err
    end

    local err = Error:new(message)
    self.log:error(err)

    if is_app_program(program) then
      health.markUnavailable(err:toString())
    end

    return {}, err
  end
  local output = process.stdout.read()
  local errors = process.stderr.read()
  local errs = {}
  if errors ~= "" then
    errs = vim.split(errors, "\n")
  end

  local exit_code = process.result(true)

  if is_app_program(program) then
    if exit_code == 0 then
      health.markHealthy()
    else
      health.recordFailure(errors)
    end
  end

  return ApiResponse:new(vim.split(output or "", "\n"), exit_code, errs)
end

return api
