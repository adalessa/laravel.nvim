local Popup = require("nui.popup")
local Split = require("nui.split")

---@class LaravelUIHandler
---@field builders table<string, function>
---@field options laravel.services.options
local ui_handler = {}

function ui_handler:new(options)
  local instance = {
    builders = {
      split = Split,
      popup = Popup,
    },
    options = options,
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@param opts table
function ui_handler:handle(opts)
  local type = opts.ui or self.options:get("ui.default")

  local instance = self.builders[type](opts.nui_opts or self.options:get().ui.nui_opts[type])

  return instance
end

return ui_handler
