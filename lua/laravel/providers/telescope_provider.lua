local telescope_provider = {}

---@param app LaravelApp
function telescope_provider:register(app)
  local _, ok = pcall(require, "telescope")
  if not ok then
    return
  end

  app:bindIf("artisan_picker", "laravel.telescope.pickers.artisan", { tags = { "picker" } })
  app:bindIf("routes_picker", "laravel.telescope.pickers.routes", { tags = { "picker" } })
  app:bindIf("make_picker", "laravel.telescope.pickers.make", { tags = { "picker" } })
  app:bindIf("related_picker", "laravel.telescope.pickers.related", { tags = { "picker" } })
  app:bindIf("resources_picker", "laravel.telescope.pickers.resources", { tags = { "picker" } })
  app:bindIf("commands_picker", "laravel.telescope.pickers.commands", { tags = { "picker" } })
  app:bindIf("history_picker", "laravel.telescope.pickers.history", { tags = { "picker" } })
end

return telescope_provider
