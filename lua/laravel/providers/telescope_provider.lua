---@class LaravelTelescopeProvider : LaravelProvider
local telescope_provider = {}

function telescope_provider:register(app)
  local _, ok = pcall(require, "telescope")
  if not ok then
    return
  end

  app:singeltonIf("telescope.pickers", function()
    return {
      artisan = "laravel.pickers.telescope.pickers.artisan",
      composer = "laravel.pickers.telescope.pickers.composer",
      routes = "laravel.pickers.telescope.pickers.routes",
      make = "laravel.pickers.telescope.pickers.make",
      related = "laravel.pickers.telescope.pickers.related",
      resources = "laravel.pickers.telescope.pickers.resources",
      commands = "laravel.pickers.telescope.pickers.commands",
      history = "laravel.pickers.telescope.pickers.history",
    }
  end)
end

return telescope_provider

