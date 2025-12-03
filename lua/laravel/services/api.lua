local nio = require("nio")
local ApiResponse = require("laravel.dto.api_response")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

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
  local command = self.command_generator:generate(program, args)
  if not command then
    return {}, Error:new(string.format("Command %s not found", program))
  end
  local cmd = table.remove(command, 1)

  local process = nio.process.run({ cmd = cmd, args = command })
  if not process then
    local err = Error:new(string.format("Failed to run command cmd: %s args: %s", cmd, table.concat(args or {}, " ")))
    self.log:error(err)

    return {}, err
  end
  local output = process.stdout.read()
  local errors = process.stderr.read()
  local errs = {}
  if errors ~= "" then
    errs = vim.split(errors, "\n")
  end

  local exit_code = process.result(true)

  return ApiResponse:new(vim.split(output or "", "\n"), exit_code, errs)
end

return api
