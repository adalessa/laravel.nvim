local app = require("laravel").app

-- Resolve how multiples pickers will interact
-- app('pickers'):run('artisan', {})
-- let say we have native and telescope and fzf
-- these are multiples
-- should pickers be an option on features.
-- add option for 'provider'
-- telescope
-- ui.select
-- fzf
--
-- define in the container an element like telescope.pickers base on the name
-- check laravel/providers/telescope_providers.lua
-- for reference

---@class LaravelPickersManager
---@field _enable boolean
---@field provider string
local pickers_manager = {}

function pickers_manager:new(options)
  local instance = {
    _enable = options:get().features.pickers.enable,
    provider = options:get().features.pickers.provider,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param name string
function pickers_manager:run(name, ...)
  if not self:enable() then
    return
  end
  local picker_name = self:get_pickers()[name]

  app(picker_name):run(...)
end

---@param name string
function pickers_manager:exists(name)
  return self:enable() and vim.tbl_contains(vim.tbl_keys(self:get_pickers()), name)
end

function pickers_manager:get_pickers()
  return app(self.provider .. ".pickers") or {}
end

function pickers_manager:enable()
  return self._enable
end

return pickers_manager
