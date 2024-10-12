---@class LaravelTelescopeProvider : LaravelProvider
local telescope_provider = {}

function telescope_provider:register(app)
  local _, ok = pcall(require, "telescope")
  if not ok then
    return
  end

  app:singeltonIf("telescope.pickers", function()
    return {
      artisan = "laravel.telescope.pickers.artisan",
      routes = "laravel.telescope.pickers.routes",
      make = "laravel.telescope.pickers.make",
      related = "laravel.telescope.pickers.related",
      resources = "laravel.telescope.pickers.resources",
      commands = "laravel.telescope.pickers.commands",
      history = "laravel.telescope.pickers.history",
    }
  end)
end

return telescope_provider
