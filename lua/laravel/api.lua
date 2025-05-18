local promise = require("promise")
local ApiResponse = require("laravel.dto.api_response")

---@class laravel.api
---@field command_generator laravel.services.command_generator
local api = {
  _inject = {
    command_generator = "laravel.services.command_generator",
  }
}

---@param command_generator laravel.services.command_generator
---@return laravel.api
function api:new(command_generator)
  local instance = {
    command_generator = command_generator,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
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
---@return Promise
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
