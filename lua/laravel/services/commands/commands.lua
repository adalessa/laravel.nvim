---@type LaravelApp
local app = require('laravel').app

local commands = {}

function commands:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function commands:commands()
  return {"commands"}
end

function commands:handle()
  if app:has('commands_picker') then
    app('commands_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

function commands:complete()
  return {}
end

return commands