---@type LaravelApp
local app = require('laravel').app

local routes = {}

function routes:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes:commands()
  return { "routes" }
end

function routes:handle()
  if app:has('routes_picker') then
    app('routes_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

function routes:complete()
  return {}
end

return routes
