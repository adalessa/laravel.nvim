local Job = require("plenary.job")
local ApiResponse = require("laravel.api.response")

---@class LaravelApi
---@field env LaravelEnvironment
local api = {}

---@return LaravelApi
function api:new(env)
  local instance = setmetatable({}, { __index = api })
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

--- Run the command sync
---@param program string
---@param args string[]
---@return ApiResponse
function api:sync(program, args)
  local cmd = self:generate_command(program, args)
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
---@param callback fun(response: ApiResponse)
---@return Job
function api:async(program, args, callback)
  local cmd = self:generate_command(program, args)
  local command = table.remove(cmd, 1)

  local job = Job:new({
    command = command,
    args = cmd,
    on_exit = function(j, exit_code)
      callback(ApiResponse:new(j:result(), exit_code, j:stderr_result()))
    end,
  })
  job:start()

  return job
end

---@return boolean
function api:is_composer_package_install(package)
  return self:sync("composer", { "info", package }):successful()
end

---@return ApiResponse
function api:tinker_execute(code)
  assert(code, "Code is required")
  return self:sync("artisan", { "tinker", "--execute", "echo " .. code })
end

---@param code string
---@param callback fun(response: ApiResponse)
---@return Job
function api:async_tinker(code, callback)
  return self:async("artisan", { "tinker", "--execute", "echo " .. code }, callback)
end

return api
