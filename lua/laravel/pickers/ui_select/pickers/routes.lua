local actions = require("laravel.pickers.ui_select.actions")

---@class LaravelUISelectRoutesPicker
---@field routes_repository RoutesRepository
local routes_picker = {}

function routes_picker:new(cache_routes_repository)
  local instance = {
    routes_repository = cache_routes_repository,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes_picker:run(opts)
  opts = opts or {}

  self.routes_repository:all():thenCall(function(routes)
    vim.ui.select(routes, {
      prompt = "Laravel Routes",
      format_item = function(route)
        return route.name
      end,
      kind = "route",
    }, function(route)
      if route == nil then
        actions.open_route(route)
      end
    end)
  end)
end

return routes_picker
