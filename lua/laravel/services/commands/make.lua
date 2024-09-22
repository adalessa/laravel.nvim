---@type LaravelApp
local app = require('laravel').app

local make = {}

function make:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make:commands()
  return { "make" }
end

function make:handle()
  if app:has('make_picker') then
    app('make_picker'):run()
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return make
