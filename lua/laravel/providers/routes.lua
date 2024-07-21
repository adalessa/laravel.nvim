--TODO: add missing fields
---@class LaravelRoute

---@class LaravelRouteProvider
---@field api LaravelApi
local routes = {}

local function split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

local parse = function(json)
  if json == "" or json == nil or #json == 0 then
    return {}
  end

  return vim.tbl_map(function(route)
    return {
      uri = route.uri,
      action = route.action,
      domain = route.domain,
      methods = split(route.method, "|"),
      middlewares = route.middleware,
      name = route.name,
    }
  end, vim.json.decode(json, { luanil = { object = true } }))
end

function routes:new(api)
  local instance = setmetatable({}, { __index = routes })
  instance.api = api
  return instance
end

---@param callback fun(commands: Iter)
---@return Job
function routes:get(callback)
  return self.api:async("artisan", { "route:list", "--json" }, function(result)
    if result:failed() then
      vim.notify(result:prettyErrors(), vim.log.levels.ERROR)
      return
    end
    callback(vim.iter(parse(result:prettyContent())))
  end)
end

return routes
