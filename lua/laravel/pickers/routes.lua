local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.routes
---@field routes_loader laravel.loaders.routes_cache_loader
---@field log laravel.utils.log
local routes_picker = Class({
  routes_loader = "laravel.loaders.routes_cache_loader",
  log = "laravel.utils.log",
})

---@async
function routes_picker:run(picker, opts)
  local routes, err = self.routes_loader:load()
  if err then
    notify.error("Failed to load routes")
    self.log:error(err)
    return
  end

  vim.schedule(function()
    picker.run(opts, routes)
  end)
end

return routes_picker
