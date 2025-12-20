---@type laravel.providers.provider
local snacks_provider = { name = "laravel.providers.snacks_provider" }

function snacks_provider.register(app)
  app:singletonIf("pickers.snacks", function()
    return {
      check = function()
        local ok, _ = pcall(require, "snacks")

        return ok
      end,
      pickers = {
        artisan = "laravel.pickers.providers.snacks.artisan",
        commands = "laravel.pickers.providers.snacks.commands",
        composer = "laravel.pickers.providers.snacks.composer",
        history = "laravel.pickers.providers.snacks.history",
        make = "laravel.pickers.providers.snacks.make",
        related = "laravel.pickers.providers.snacks.related",
        resources = "laravel.pickers.providers.snacks.resources",
        routes = "laravel.pickers.providers.snacks.routes",
        laravel = "laravel.pickers.providers.snacks.laravel",
      },
    }
  end)
end

return snacks_provider
