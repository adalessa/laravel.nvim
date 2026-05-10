local split = require("laravel.utils.init").split

---@class laravel.mappers.route_mapper
local route_mapper = {
  ---@param route table
  ---@return laravel.dto.artisan_routes
  map = function(route)
    local controller = ""
    local method = ""

    local parts = split(route.action, "@")
    if #parts == 2 then
      controller = parts[1]
      method = parts[2]
    end

    ---@type laravel.dto.artisan_routes
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
  end,
}

return route_mapper
