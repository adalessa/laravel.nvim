local split = require("laravel.utils").split
local Class = require("laravel.class")

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
---@field api laravel.api
local RoutesLoader = Class({ api = "laravel.api" })

function RoutesLoader:load()
  return self.api:send("artisan", { "route:list", "--format=json" }):thenCall(
    ---@param result laravel.dto.apiResponse
    function(result)
      return vim.iter(result:json() or {}):map(map_route):totable()
    end
  )
end

return RoutesLoader
