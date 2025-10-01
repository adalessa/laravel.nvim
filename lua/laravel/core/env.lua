local combine_tables = require("laravel.utils").combine_tables
local Environment = require("laravel.dto.environment")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local notify = require("laravel.utils.notify")

---@class laravel.core.env
---@field config laravel.core.config
---@field options laravel.services.config
local env = Class({
  config = "laravel.core.config",
  options = "laravel.services.config",
}, {
  environment = nil,
})

function env:boot()
  local cwd = vim.uv.cwd()
  assert(cwd, "cwd is nil")

  local config = self.config:get(cwd)

  if not config then
    self:configure()
  else
    self.environment = Environment:new(config)
  end
end

function env:configure()
  --- check if artisan exists
  if vim.fn.filereadable("artisan") == 0 then
    -- not artisan should not do anything
    return
  end

  vim.ui.select(self.options.get("environments.definitions"), {
    prompt = "[Laravel.nvim] Select the type of environment to use",
    format_item = function(item)
      return item.name
    end,
  }, function(value)
    if not value then
      return
    end

    self.environment = Environment:new(value)

    local cwd = vim.uv.cwd()
    value.path = cwd
    local res = self.config:set(value)
    if not res then
      notify.error("Error saving config")
    end
  end)
end

---@param name string
---@return string[], laravel.error
function env:getExecutable(name)
  if not self.environment then
    return {}, Error:new("Environment is not configured")
  end

  if name == "artisan" then
    local exec, err = self.environment:executable("php")
    if err then
      return {}, Error:new("Executable 'php' not found needed for artisan"):wrap(err)
    end

    return combine_tables(exec, { "artisan" })
  end

  return self.environment:executable(name)
end

function env:isActive()
  return self.environment ~= nil
end

return env
