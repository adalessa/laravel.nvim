---@class LaravelArtisanService
---@field api LaravelApi
---@field env LaravelEnvironment
local artisan = {}

function artisan:new(api, env)
  local instance = setmetatable({}, { __index = artisan })
  instance.api = api
  instance.env = env

  return instance
end

function artisan:version(callback)
  self.api:async("artisan", { "--version" }, function(response)
    if response:successful() then
      callback(response:first():match("Laravel Framework ([%d%.]+)"))
    else
      callback(nil)
    end
  end)
end

function artisan:available(callback)
  callback(self.env:get_executable("artisan") ~= nil)
end

return artisan
