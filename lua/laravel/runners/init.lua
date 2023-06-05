local buffer = require "laravel.runners.buffer"
local sync = require "laravel.runners.sync"
local async = require "laravel.runners.async"
local persist = require "laravel.runners.persist"
local watch = require "laravel.runners.watch"
local terminal = require "laravel.runners.terminal"

local runners = {
  buffer = buffer,
  sync = sync,
  async = async,
  persist = persist,
  watch = watch,
  terminal = terminal,
}

return runners
