---@type LaravelApp
local app = require('laravel').app

local related = {}

function related:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related:commands()
  return { "related" }
end

function related:handle()
  if app:has('related_picker') then
    app('related_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return related
