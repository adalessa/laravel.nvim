local api = require "laravel.api"

---@class Route
---@field action string
---@field method string multiple splitted by |
---@field middleware string[]
---@field name string
---@field uri string
---@field domain string|nil

local routes_resolver = {};

---@param onSuccess fun(routes: Route[])|nil
---@param onFailure fun(errorMessage: string)|nil
function routes_resolver.resolve(
  onSuccess,
  onFailure
)
  api.async("artisan", { "route:list", "--json" }, function(response)
    if response:failed() then
      if onFailure then onFailure(response:prettyErrors()) end
    end

    ---@type Route[]|nil
    local routes = vim.json.decode(response:prettyContent(), {
      luanil = { object = true, array = true }
    })

    if not routes then
      if onFailure then onFailure("no routes found") end
      return
    end

    if onSuccess then onSuccess(routes) end
  end)
end

return routes_resolver
