-- can I remove this setup ?
-- can it be initialize when it starts or runs a command ?

---@param opts? LaravelOptions
local function setup(opts)
  -- register all the clases
  require "laravel.bootstrap"

  local app = require('laravel.app')
  --- set the options by the user
  app('options'):set(opts)
  app('env'):boot()
end

return {
  setup = setup,
  routes = require("telescope").extensions.laravel.routes,
  artisan = require("telescope").extensions.laravel.artisan,
  history = require("telescope").extensions.laravel.history,
  make = require("telescope").extensions.laravel.make,
  commands = require("telescope").extensions.laravel.commands,
  resources = require("telescope").extensions.laravel.resources,
  recies = require("laravel.recipes").run,
  viewFinder = require("laravel.view_finder").auto,
}
