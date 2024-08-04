local telescope_provider = {}

---@param app LaravelApp
function telescope_provider:register(app)
  app:bindIf("artisan_picker", "laravel.telescope.pickers.artisan")
  app:bindIf("routes_picker", "laravel.telescope.pickers.routes")
  app:bindIf("make_picker", "laravel.telescope.pickers.make")
  app:bindIf("related_picker", "laravel.telescope.pickers.related")
  app:bindIf("resources_picker", "laravel.telescope.pickers.resources")

    -- history = require("laravel.telescope.pickers.history"),
    -- commands = require("laravel.telescope.pickers.commands"),
    -- resources = require("laravel.telescope.pickers.resources"),
end

-- ---@param app LaravelApp
-- function telescope_provider:boot(app)
-- end

return telescope_provider
