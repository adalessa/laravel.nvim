local split = require("laravel.utils.init").split
local Class = require("laravel.utils.class")

---@class laravel.dto.artisan_routes
---@field uri string
---@field action string
---@field controller string
---@field method string
---@field domain string
---@field methods string[]
---@field middlewares string[]
---@field name string

local function map_route(route)
  local controller = nil
  local method = nil

  local parts = split(route.action, "@")
  if #parts == 2 then
    controller = parts[1]
    method = parts[2]
  end

  return {
    uri = route.uri,
    action = route.action,
    controller = controller,
    method = method,
    domain = route.domain,
    methods = split(route.method, "|"),
    middlewares = route.middleware,
    name = route.name,
  }
end

---@class laravel.loaders.routes_loader
---@field api laravel.services.api
---@field new fun(self: laravel.loaders.routes_loader, api: laravel.services.api): laravel.loaders.routes_loader
local RoutesLoader = Class({ api = "laravel.services.api" })

---@return laravel.dto.artisan_routes[], string?
function RoutesLoader:load()
  local result = self.api:run("artisan route:list --json")

  if result:failed() then
    return {}, "Failed to load routes: " .. result:prettyErrors()
  end

  return vim.tbl_map(map_route, result:json() or {})
end

return RoutesLoader
