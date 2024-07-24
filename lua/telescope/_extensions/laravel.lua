local app = require("laravel.app")

return require("telescope").register_extension({
  exports = {
    artisan = function(opts)
      app("artisan_picker")(opts)
    end,
    routes = require("laravel.telescope.pickers.routes"),
    related = require("laravel.telescope.pickers.related"),
    history = require("laravel.telescope.pickers.history"),
    make = require("laravel.telescope.pickers.make"),
    commands = require("laravel.telescope.pickers.commands"),
    resources = require("laravel.telescope.pickers.resources"),
  },
})
