local nio = require("nio")
local ApiResponse = require("laravel.dto.api_response")
local Class = require("laravel.utils.class")

---@class laravel.services.api
---@field command_generator laravel.services.command_generator
local api = Class({
  command_generator = "laravel.services.command_generator",
})

---@async
---@param program string
---@param args string[]|nil
---@return laravel.dto.apiResponse, string?
function api:run(program, args)
  local command = self.command_generator:generate(program, args)
  if not command then
    return {}, string.format("Command %s not found", program)
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
  process.close()

  return ApiResponse:new(vim.split(output or "", "\n"), nil, errs)
end

---@param program string
---@param args string[]
---@return laravel.dto.apiResponse, string?
function api:runSync(program, args)
  local cmd = self.command_generator:generate(program, args)
  if not cmd then
    return {}, string.format("Command %s not found", program)
  end

  local out = vim.system(cmd, {}):wait()

  return ApiResponse:new({ out.stdout }, out.code, { out.stderr })
end

return api
