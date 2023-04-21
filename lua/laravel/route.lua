local utils = require "laravel.utils"
local lsp = require "laravel._lsp"

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

---@param route LaravelRoute
M.open = function(route)
  if route.action == "Closure" then
    if vim.tbl_contains(route.middlewares, "api") then
      vim.cmd "edit routes/api.php"
      vim.fn.search(route.uri:gsub("api", "") .. "")
    elseif vim.tbl_contains(route.middlewares, "web") then
      vim.cmd "edit routes/web.php"
      if route.uri == "/" then
        vim.fn.search "['\"]/['\"]"
      else
        vim.fn.search("/" .. route.uri)
      end
    else
      utils.notify("Route", { msg = "Could not open the route location", level = "WARN" })
      return
    end

    vim.cmd "normal zt"
    return
  end

  local action = vim.fn.split(route.action, "@")
  lsp.go_to(action[1], action[2])
end

return M
