local environment = require "laravel.environment"
local run = require "laravel.run"
local M = {}

local properties = {
  php = {
    has = function()
      return environment.get_executable "php" ~= nil
    end,
    get = function()
      if not environment.get_executable "php" then
        return nil
      end
      local res, _ = run("php", { "-v" }, { runner = "sync" })
      --[[
PHP 8.1.23 (cli) (built: Aug 30 2023 08:23:26) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.1.23, Copyright (c) Zend Technologies
    with Zend OPcache v8.1.23, Copyright (c), by Zend Technologies
      --]]
      return res.out[1]:match "PHP ([%d%.]+)"
    end,
  },
  laravel = {
    has = function()
      return environment.get_executable "artisan" ~= nil
    end,
    get = function()
      if not environment.get_executable "artisan" then
        return nil
      end

      local res, _ = run("artisan", { "--version" }, { runner = "sync" })

      return res.out[1]:match "Laravel Framework ([%d%.]+)"
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
