--TODO: add missing fields
---@class LaravelRoute

---@class LaravelRouteProvider
---@field api LaravelApi
local routes = {}

local function check_nil(value)
  if value == vim.NIL then
    return nil
  end
  return value
end

local parse = function(json)
  if json == "" or json == nil or #json == 0 then
    return {}
  end

  return vim.tbl_map(function(route)
    return {
      uri = route.uri,
      action = route.action,
      domain = check_nil(route.domain),
      methods = vim.fn.split(route.method, "|"),
      middlewares = route.middleware,
      name = check_nil(route.name),
    }
  end, vim.fn.json_decode(json))
end

function routes:new(api)
  local instance = setmetatable({}, { __index = routes })
  instance.api = api
  return instance
end

---@param callback fun(commands: Iter<LaravelRoute>)
function routes:get(callback)
  self.api:async("artisan", { "route:list", "--json" }, function(result)
    if result:failed() then
      vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
      return
    end
    callback(vim.iter(parse(result.stdout)))
  end)
end

return routes
