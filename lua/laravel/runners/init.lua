local runners = {
  buffer = require "laravel.runners.buffer",
  popup = require "laravel.runners.popup",
  split = require "laravel.runners.split",

  terminal = require "laravel.runners.terminal",

  watch = require "laravel.runners.watch",
}

-- sync and async are differente from this
-- The rest are base on how to show in the split
-- want to be able to trace the open terminals in the split
-- can re-use the same, or create a new one if necessary

return runners
