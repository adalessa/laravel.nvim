local app = require("laravel.core.app")
local notify = require("laravel.utils.notify")
local nio = require("nio")

---@class laravel.managers.pickers_manager
---@field _enable boolean
---@field provider {}
local pickers_manager = {
  _inject = {
    config = "laravel.services.config",
  },
}

function pickers_manager:new(config)
  local providerName = config("features.pickers.provider")
  local instance = {
    _enable = config("features.pickers.enable"),
    name = providerName,
    provider = app("pickers." .. providerName),
  }

  if instance._enable and not instance.provider.check() then
    error("Picker provider not found: " .. providerName .. ". Check your configuration")
  end

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@async
---@param name string
function pickers_manager:run(name, opts)
  if not self:enable() then
    return
  end

  local picker = app(("laravel.pickers.%s"):format(name))

  local picker_name = self:get_pickers()[name]
  if not picker_name then
    notify.error("Picker not found: " .. name)
    return
  end

  picker:run(app(picker_name), opts)
end

---@param name string
function pickers_manager:exists(name)
  return self:enable() and vim.tbl_contains(vim.tbl_keys(self:get_pickers()), name)
end

function pickers_manager:get_pickers()
  return self.provider.pickers or {}
end

function pickers_manager:enable()
  return self._enable
end

return pickers_manager
