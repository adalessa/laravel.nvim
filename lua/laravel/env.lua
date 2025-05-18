local combine_tables = require("laravel.utils").combine_tables
local Environment = require("laravel.dto.environment")

---@class laravel.env
---@field config laravel.config
---@field options laravel.services.options
local env = {
  _inject = {
    config = "laravel.config",
    options = "laravel.services.options",
  },
}

function env:new(config, options)
  local instance = {
    config = config,
    options = options,
    environment = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

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

  --- TODO: ask if want auto configure
  --- TODO: ask for custom

  vim.ui.select(self.options:get("environments.definitions"), {
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
      vim.notify("Error saving config", vim.log.levels.ERROR, {
        title = "Laravel.nvim",
      })
      vim.print(value)
    end
  end)
end

---@param name string
---@return string[]|nil
function env:getExecutable(name)
  if not self.environment then
    return nil
  end

  if name == "artisan" then
    local exec = self.environment:executable("php")
    if not exec then
      return nil
    end

    return combine_tables(exec, { "artisan" })
  end

  return self.environment:executable(name)
end

function env:isActive()
  return self.environment ~= nil
end

return env
