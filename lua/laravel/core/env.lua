local combine_tables = require("laravel.utils").combine_tables
local Environment = require("laravel.dto.environment")
local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local notify = require("laravel.utils.notify")
local health = require("laravel.core.health")

---@class laravel.core.env
---@field options laravel.core.options_manager
local env = Class({
  options = "laravel.core.options_manager",
}, {
  environment = nil,
  configuring = false,
})

function env:boot()
  health.reset()

  if vim.fn.filereadable("artisan") == 0 then
    -- not artisan should not do anything
    return
  end

  if not self.options.get("path") then
    if self.options.get("environments.ask_on_boot") then
      self:configure()
    elseif self.options.get("environments.default") then
      local default = self.options.get("environments.default")
      local envs = self.options.get("environments.definitions")
      local envConfig = vim.tbl_filter(function(env)
        return env.name == default
      end, envs)

      if #envConfig == 0 then
        notify.warn(string.format("Default environment '%s' not found in definitions", default))
        return
      end

      self.environment = Environment:new(envConfig[1])
    else
      notify.warn("Need to configure environment")
    end
  else
    self.environment = Environment:new(self.options.get())
  end
end

function env:configure()
  --- check if artisan exists
  if vim.fn.filereadable("artisan") == 0 then
    -- not artisan should not do anything
    return
  end

  -- Several boot events (for example a session restoring buffers) can fire in
  -- quick succession. Only keep one prompt open at a time so it does not get
  -- replaced and closed immediately.
  if self.configuring then
    return
  end
  self.configuring = true

  local ok, err = pcall(vim.ui.select, self.options.get("environments.definitions"), {
    prompt = "[Laravel.nvim] Select the type of environment to use",
    format_item = function(item)
      return item.name
    end,
  }, function(value)
    self.configuring = false

    if not value then
      return
    end

    self.environment = Environment:new(value)
    health.reset()

    local cwd = vim.uv.cwd()
    value.path = cwd
    local res = self.options.set(value)
    if not res then
      notify.error("Error saving config")
    end
  end)

  if not ok then
    self.configuring = false
    error(err)
  end
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
