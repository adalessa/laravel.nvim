return require("telescope").register_extension {
  exports = {
    commands = require "laravel.telescope.pickers.commands",
    routes = require "laravel.telescope.pickers.routes",
    related = require "laravel.telescope.pickers.related",
  },
}
