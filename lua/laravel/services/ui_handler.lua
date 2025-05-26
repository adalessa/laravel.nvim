local Popup = require("nui.popup")
local Split = require("nui.split")

---@class LaravelUIHandler
---@field builders table<string, function>
---@field config laravel.services.config
local ui_handler = {
  _inject = {
    config = "laravel.services.config",
  }
}

function ui_handler:new(config)
  local instance = {
    builders = {
      split = Split,
      popup = Popup,
    },
    config = config,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param opts table
function ui_handler:handle(opts)
  local type = opts.ui or self.config("ui.default")

  local instance = self.builders[type](opts.nui_opts or self.config("ui.nui_opts")[type])

  return instance
end

return ui_handler
