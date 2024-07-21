---@class LaravelComposerService
---@field api LaravelApi
local composer = {}

function composer:new(api)
  local instance = setmetatable({}, { __index = composer })
  instance.api = api
  return instance
end

---@param package string
---@param callback fun(installed: boolean)
---@return Job
function composer:is_installed(package, callback)
  return self.api:async("composer", { "info", package }, function(response)
    callback(response:successful())
  end)
end
