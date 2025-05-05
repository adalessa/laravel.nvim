---@class LaravelUISelectProvider: laravel.providers.provider
local ui_select_provider = {}

function ui_select_provider:register(app)
  app:singeltonIf("pickers.us.select", function()
    return {
      check = function()
        return true
      end,
      pickers = {
        artisan = "laravel.pickers.ui_select.pickers.artisan",
        composer = "laravel.pickers.ui_select.pickers.composer",
        routes = "laravel.pickers.ui_select.pickers.routes",
        make = "laravel.pickers.ui_select.pickers.make",
        related = "laravel.pickers.ui_select.pickers.related",
        resources = "laravel.pickers.ui_select.pickers.resources",
        commands = "laravel.pickers.ui_select.pickers.commands",
        history = "laravel.pickers.ui_select.pickers.history",
      },
    }
  end)
end

return ui_select_provider
