---@class LaravelComposerService
---@field api LaravelApi
local composer = {}

function composer:new(api)
  local instance = {
    api = api
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param package string
---@param callback fun(installed: boolean)
---@return vim.SystemObj
function composer:is_installed(package, callback)
  return self.api:async("composer", { "info", package }, function(response)
    callback(response:successful())
  end)
end

---@param package string
---@param callback fun(response: ApiResponse)
function composer:update(package, callback)
  return self.api:async("composer", { "update", package }, callback)
end

---@param package string
---@param callback fun(response: ApiResponse)
function composer:require(package, callback)
  return self.api:async("composer", { "require", package }, callback)
end

---@param callback fun(response: ApiResponse)
function composer:install(callback)
  return self.api:async("composer", { "install" }, callback)
end

return composer
