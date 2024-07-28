local app = require("laravel.app")

-- SERVICES
app():register_many({
  artisan = "laravel.services.artisan",
  commands = "laravel.services.commands",
  composer = "laravel.services.composer",
  configs = "laravel.services.configs",
  history = "laravel.services.history",
  paths = "laravel.services.paths",
  php = "laravel.services.php",
  routes = "laravel.services.routes",
  status = function()
    return require("laravel.services.status"):new(app("artisan"), app("php"), 120)
  end,
  views = "laravel.services.views",
  runner = "laravel.services.runner",
  ui_handler = "laravel.services.ui_handler",
  completion = "laravel.services.completion",
})

-- CACHE DECORATORS
app():register_many({
  cache_commands = function()
    return require("laravel.services.cache_decorator"):new(app("commands"))
  end,
  cache_routes = function()
    return require("laravel.services.cache_decorator"):new(app("routes"))
  end,
})

-- USER COMMANDS
app():register_many({
  composer_command = "laravel.services.commands.composer",
  artisan_command = function()
    return require("laravel.services.commands.artisan"):new(app("run"), app("cache_commands"))
  end,
})

app():register("user_commands", function()
  return {
    app("composer_command"),
    app("artisan_command"),
  }
end)

-- TELESCOPE PICKER
app():register_many({
  artisan_picker = "laravel.telescope.pickers.artisan",
  routes_picker = "laravel.telescope.pickers.routes",
  make_picker = "laravel.telescope.pickers.make",
})
