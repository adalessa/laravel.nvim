---@class laravel.providers.telescope_provider : laravel.providers.provider
local telescope_provider = { name = "laravel.providers.telescope_provider" }

function telescope_provider:register(app)
  app:singletonIf("pickers.telescope", function()
    return {
      check = function()
        local ok, _ = pcall(require, "telescope")

        return ok
      end,
      pickers = {
        artisan = "laravel.pickers.providers.telescope.artisan",
        composer = "laravel.pickers.providers.telescope.composer",
        routes = "laravel.pickers.providers.telescope.routes",
        make = "laravel.pickers.providers.telescope.make",
        related = "laravel.pickers.providers.telescope.related",
        resources = "laravel.pickers.providers.telescope.resources",
        commands = "laravel.pickers.providers.telescope.commands",
        history = "laravel.pickers.providers.telescope.history",
      },
    }
  end)
end

return telescope_provider
