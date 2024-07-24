local app = require("laravel.app")

app():register("api", function()
  return require("laravel.api"):new(app("env"))
end)

app():register("options", function()
  return require("laravel.options"):new()
end)

app():register("env", function()
  return require("laravel.environment"):new(app("options"))
end)

app():register("history", function()
  return require("laravel.history"):new()
end)

app():register("commands", function()
  return require("laravel.providers.commands"):new(app("api"))
end)

app():register("configs", function()
  return require("laravel.providers.configs"):new(app("api"))
end)

app():register("views", function()
  return require("laravel.providers.views"):new(app("paths"))
end)

app():register("routes", function()
  return require("laravel.providers.routes"):new(app("api"))
end)

app():register("paths", function()
  return require("laravel.providers.paths"):new(app("api"))
end)

app():register("status", function()
  return require("laravel.services.status"):new(app("artisan"), app("php"), 120)
end)

app():register("artisan", function()
  return require("laravel.services.artisan"):new(app("api"), app("env"))
end)

app():register("php", function()
  return require("laravel.services.php"):new(app("api"), app("env"))
end)

app():register("composer", function()
  return require("laravel.services.composer"):new(app("api"))
end)

app():register("composer_command", function()
  return require("laravel.services.commands.composer"):new(app('runner'))
end)

app():register("cache_commands", function()
  return require("laravel.providers.cache_decorator"):new(app('commands'))
end)

app():register("artisan_command", function()
  return require("laravel.services.commands.artisan"):new(app('runner'), app('cache_commands'))
end)

app():register("user_commands", function()
  return {
    app('composer_command'),
    app('artisan_command'),
  }
end)

app():register('runner', function()
  return require("laravel.run")
end)

app():register('artisan_picker', function()
  return require("laravel.telescope.pickers.artisan"):new(app('cache_commands'))
end)
