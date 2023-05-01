---@class LaravelRoute
---@field uri string
---@field action string
---@field domain string|nil
---@field methods string[]
---@field middlewares string[]
---@field name string|nil

local M = {}

local function check_nil(value)
  if value == vim.NIL then
    return nil
  end
  return value
end

--- Gets list of routes from the raw json
---@param json string
---@return LaravelRoute[]
M.from_json = function(json)
  local routes = {}
  if json == "" then
    return routes
  end
  for _, route in ipairs(vim.fn.json_decode(json)) do
    table.insert(routes, {
      uri = route.uri,
      action = route.action,
      domain = check_nil(route.domain),
      methods = vim.fn.split(route.method, "|"),
      middlewares = route.middleware,
      name = check_nil(route.name),
    })
  end

  return routes
end

return M
