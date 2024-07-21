local Job = require("plenary.job")
local ApiResponse = require("laravel.api_response")

---@class LaravelApi
---@field env LaravelEnvironment
---@field wrap boolean
local api = {}

---@return LaravelApi
function api:new(env, wrap)
  local instance = setmetatable({}, { __index = api })
  instance.wrap = wrap or true
  instance.env = env
  return instance
end

---@return string[]
function api:generate_command(name, args)
  local executable = self.env:get_executable(name)
  if not executable then
    error(string.format("Executable %s not found", name), vim.log.levels.ERROR)
  end

  return vim.fn.extend(executable, args)
end

---@param program string
---@param args string[]
---@return ApiResponse
function api:sync(program, args)
  local res = {}
  self
      :async(program, args, function(result)
        res = result
      end)
      :wait()

  return res
end

---@param program string
---@param args string[]
---@param callback fun(response: ApiResponse)
---@return Job
function api:async(program, args, callback)
  local cmd = self:generate_command(program, args)
  local command = table.remove(cmd, 1)

  local on_exit = function(j, exit_code)
    callback(ApiResponse:new(j:result(), exit_code, j:stderr_result()))
  end

  if self.wrap then
    on_exit = vim.schedule_wrap(on_exit)
  end

  local job = Job:new({
    command = command,
    args = cmd,
    on_exit = on_exit,
  })
  job:start()

  return job
end

---@param code string
---@param callback fun(response: ApiResponse)
---@return Job
function api:tinker(code, callback)
  assert(code, "Code is required")
  return self:async("artisan", { "tinker", "--execute", "echo " .. code }, callback)
end

return api
