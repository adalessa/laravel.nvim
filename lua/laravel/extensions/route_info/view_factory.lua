---@class ViewFactory
---@field views table<string, table>
---@field options table
local view_factory = {}

function view_factory:new(options, views)
  local instance = {
    options = options,
    views = views,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function view_factory:get(route, method)
  local view_name = self.options.view

  if type(view_name) == "function" then
    return view_name(route, method)
  end

  if type(view_name) == "table" then
    return view_name:get(route, method)
  end

  if type(view_name) ~= "string" then
    error("Invalid view name")
  end

  if self.views[view_name] then
    return self.views[view_name]:get(route, method)
  end

  local ok, view = pcall(require, view_name)
  if not ok then
    error("View not found: " .. view_name)
  end

  return view:get(route, method)
end

return view_factory
