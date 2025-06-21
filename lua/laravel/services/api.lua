local nio = require("nio")
local ApiResponse = require("laravel.dto.api_response")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.api
---@field command_generator laravel.services.command_generator
local api = Class({
  command_generator = "laravel.services.command_generator",
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
    error(string.format("Failed to run command %s", program), vim.log.levels.ERROR)
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
