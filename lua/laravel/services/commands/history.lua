---@type LaravelApp
local app = require('laravel').app

local history = {}

function history:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function history:commands()
  return { "history" }
end

function history:handle()
  if app:has('history_picker') then
    app('history_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return history
