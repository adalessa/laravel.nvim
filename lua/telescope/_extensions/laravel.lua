local app = require("laravel.app")

return require("telescope").register_extension({
  exports = {
    artisan = function(opts)
      app("artisan_picker")(opts)
    end,
    routes = function(opts)
      app("routes_picker")(opts)
    end,
    make = function(opts)
      app("make_picker")(opts)
    end,
    related = require("laravel.telescope.pickers.related"),
    history = require("laravel.telescope.pickers.history"),
    commands = require("laravel.telescope.pickers.commands"),
    resources = require("laravel.telescope.pickers.resources"),
  },
})
