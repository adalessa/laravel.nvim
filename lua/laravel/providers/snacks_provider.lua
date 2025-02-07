---@class LaravelSnacksProvider : LaravelProvider
local snacks_provider = {}

function snacks_provider:register(app)
  local _, ok = pcall(require, "snacks")
  if not ok then
    return
  end

  app:singeltonIf("snacks.pickers", function()
    return {
      artisan = "laravel.pickers.snacks.pickers.artisan",
      commands = "laravel.pickers.snacks.pickers.commands",
      composer = "laravel.pickers.snacks.pickers.composer",
      history = "laravel.pickers.snacks.pickers.history",
      make = "laravel.pickers.snacks.pickers.make",
      related = "laravel.pickers.snacks.pickers.related",
      resources = "laravel.pickers.snacks.pickers.resources",
      routes = "laravel.pickers.snacks.pickers.routes",
    }
  end)
end

return snacks_provider
