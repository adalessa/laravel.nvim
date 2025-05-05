---@class LaravelSnacksProvider : laravel.providers.provider
local snacks_provider = {}

function snacks_provider:register(app)
  app:singeltonIf("pickers.snacks", function()
    return {
      check = function()
        local ok, _ = pcall(require, "snacks")

        return ok
      end,
      pickers = {
        artisan = "laravel.pickers.snacks.pickers.artisan",
        commands = "laravel.pickers.snacks.pickers.commands",
        composer = "laravel.pickers.snacks.pickers.composer",
        history = "laravel.pickers.snacks.pickers.history",
        make = "laravel.pickers.snacks.pickers.make",
        related = "laravel.pickers.snacks.pickers.related",
        resources = "laravel.pickers.snacks.pickers.resources",
        routes = "laravel.pickers.snacks.pickers.routes",
      },
    }
  end)
end

return snacks_provider
