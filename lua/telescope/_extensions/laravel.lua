return require("telescope").register_extension {
  exports = {
    artisan = require "laravel.telescope.pickers.artisan",
    routes = require "laravel.telescope.pickers.routes",
    related = require "laravel.telescope.pickers.related",
    history = require "laravel.telescope.pickers.history",
    make = require "laravel.telescope.pickers.make",
    commands = require "laravel.telescope.pickers.commands",
    resources = require "laravel.telescope.pickers.resources",
  },
}
