local runners = {
  async = require "laravel.runners.async",
  buffer = require "laravel.runners.buffer",
  popup = require "laravel.runners.popup",
  split = require "laravel.runners.split",
  sync = require "laravel.runners.sync",
  terminal = require "laravel.runners.terminal",
  watch = require "laravel.runners.watch",
}

return runners
