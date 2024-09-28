---@type LaravelApp
local app = require('laravel').app

local resources = {}

function resources:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function resources:commands()
  return { "resources" }
end

function resources:handle()
  if app:has('resources_picker') then
    app('resources_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return resources
