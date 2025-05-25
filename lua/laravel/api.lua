local nio = require("nio")
local promise = require("promise")
local ApiResponse = require("laravel.dto.api_response")
local Class = require("laravel.class")

---@class laravel.api
---@field command_generator laravel.services.command_generator
local api = Class({
  command_generator = "laravel.services.command_generator",
})

function api:run(program, args)
  local command = self.command_generator:generate(program, args)
  if not command then
    error(string.format("Command %s not found", program), vim.log.levels.ERROR)
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
---@param callback fun(response: laravel.dto.apiResponse)
---@param opts table|nil
---@return vim.SystemObj
function api:async(program, args, callback, opts)
  opts = opts or {}

  local cmd = self.command_generator:generate(program, args)
  if not cmd then
    error(string.format("Command %s not found", program), vim.log.levels.ERROR)
  end

  local cb = function(out)
    callback(ApiResponse:new({ out.stdout }, out.code, { out.stderr }))
  end

  if opts.wrap then
    cb = vim.schedule_wrap(cb)
  end

  local sysObj = vim.system(cmd, {}, cb)

  return sysObj
end

---@param program string
---@param args string[]
---@return Promise<laravel.dto.apiResponse>
function api:send(program, args)
  return promise:new(function(resolve, reject)
    self:async(program, args, function(result)
      if result:failed() then
        reject(result:prettyErrors())
        return
      end
      resolve(result)
    end)
  end)
end

return api
