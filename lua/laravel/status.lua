local environment = require "laravel.environment"
local api = require "laravel.api"

local M = {}

local counters = {
  php = 0,
  laravel = 0,
}

local values = {
  php = nil,
  laravel = nil,
}

local properties = {
  php = {
    has = function()
      return environment.get_executable "php" ~= nil
    end,
    get = function()
      counters.php = counters.php + 1
      if values.php and counters.php < 60 then
        return values.php
      end
      counters.php = 0
      if not environment.get_executable "php" then
        return nil
      end
      local res = api.sync("php", { "-v" })
      values.php = res.stdout[1]:match "PHP ([%d%.]+)"

      return values.php
    end,
  },
  laravel = {
    has = function()
      return environment.get_executable "artisan" ~= nil
    end,
    get = function()
      counters.laravel = counters.laravel + 1
      if values.laravel and counters.laravel < 60 then
        return values.laravel
      end
      counters.laravel = 0
      if not environment.get_executable "artisan" then
        return nil
      end

      local res = api.sync("artisan", { "--version" })

      values.laravel = res.stdout[1]:match "Laravel Framework ([%d%.]+)"
      return values.laravel
    end,
  },
}

function M.get(property)
  return properties[property].get()
end

function M.has(property)
  return properties[property].has()
end

return M
