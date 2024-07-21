local app = require('laravel.app')

app():register('api', function ()
  return require('laravel.api'):new(app('env'))
end)

app():register('options', function()
  return require('laravel.options'):new()
end)

app():register('env', function()
  return require('laravel.environment'):new(app('options'))
end)

app():register('history', function()
  return require('laravel.history'):new()
end)

app():register('commands', function ()
  return require('laravel.providers.commands'):new(app('api'))
end)

app():register('configs', function ()
  return require('laravel.providers.configs'):new(app('api'))
end)

app():register('views', function ()
  return require('laravel.providers.views'):new(app('paths'))
end)

app():register('routes', function ()
  return require('laravel.providers.routes'):new(app('api'))
end)

app():register('paths', function ()
  return require('laravel.providers.paths'):new(app('api'))
end)

app():register('status', function()
  return require('laravel.services.status'):new(app('artisan'), app('php'), 120)
end)

app():register('artisan', function()
  return require('laravel.services.artisan'):new(app('api'), app('env'))
end)

app():register('php', function()
  return require('laravel.services.php'):new(app('api'), app('env'))
end)
