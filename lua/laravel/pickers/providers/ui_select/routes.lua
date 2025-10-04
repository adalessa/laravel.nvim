local actions = require("laravel.pickers.ui_select.actions")
local Class = require("laravel.utils.class")
local nio = require("nio")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.ui_select.pickers.routes
---@field routes_loader laravel.loaders.routes_cache_loader
local routes_picker = Class({
  routes_loader = "laravel.loaders.routes_cache_loader",
})

function routes_picker:run()
  nio.run(function()
    local routes, err = self.routes_loader:load()
    if err then
      return notify.error("Error loading routes: " .. err:toString())
    end
    vim.schedule(function()
      vim.ui.select(routes, {
        prompt = "Laravel Routes",
        format_item = function(route)
          return route.name
        end,
        kind = "route",
      }, function(route)
        if route ~= nil then
          actions.open_route(route)
        end
      end)
    end)
  end)
end

return routes_picker
