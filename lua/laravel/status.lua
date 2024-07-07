local app = require "laravel.app"

local last_check = nil

local M = {}

local frequency = 120

local values = {
  php = nil,
  laravel = nil,
}

local function get_values()
  if last_check and (last_check + frequency > os.time()) then
    return
  end
  if app('env').get_executable "php" then
    app('api'):async(
      "php",
      { "-v" },
      ---@param response ApiResponse
      function(response)
        if response:successful() then
          values.php = response:first():match "PHP ([%d%.]+)"
        end
      end
    )
  end
  if app('env').get_executable "artisan" then
    app('api'):async(
      "artisan",
      { "--version" },
      ---@param response ApiResponse
      function(response)
        if response:successful() then
          values.laravel = response:first():match "Laravel Framework ([%d%.]+)"
        end
      end
    )
  end
  last_check = os.time()
end

local properties = {
  php = {
    has = function()
      return app('env').get_executable "php" ~= nil
    end,
    get = function()
      return values.php
    end,
  },
  laravel = {
    has = function()
      return app('env').get_executable "artisan" ~= nil
    end,
    get = function()
      return values.laravel
    end,
  },
}

function M.get(property)
  get_values()
  return properties[property].get()
end

function M.has(property)
  return properties[property].has()
end

function M.refresh()
  last_check = nil
end

return M
