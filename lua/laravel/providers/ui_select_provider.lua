---@class LaravelUISelectProvider: LaravelProvider
local ui_select_provider = {}

function ui_select_provider:register(app)
  app:bindIf("artisan_picker", "laravel.pickers.ui_select.pickers.artisan", { tags = { "picker" } })
  app:bindIf("routes_picker", "laravel.pickers.ui_select.pickers.routes", { tags = { "picker" } })
  app:bindIf("make_picker", "laravel.pickers.ui_select.pickers.make", { tags = { "picker" } })
  app:bindIf("related_picker", "laravel.pickers.ui_select.pickers.related", { tags = { "picker" } })
  app:bindIf("resources_picker", "laravel.pickers.ui_select.pickers.resources", { tags = { "picker" } })
  app:bindIf("commands_picker", "laravel.pickers.ui_select.pickers.commands", { tags = { "picker" } })
  app:bindIf("history_picker", "laravel.pickers.ui_select.pickers.history", { tags = { "picker" } })
end

return ui_select_provider
