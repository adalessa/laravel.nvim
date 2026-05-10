local Popup = require("nui.popup")
local Split = require("nui.split")
local Class = require("laravel.utils.class")

---@class LaravelUIHandler
---@field builders table<string, function>
---@field options laravel.core.options_manager
local ui_handler = Class({
  options = "laravel.core.options_manager",
}, {
  builders = {
    split = Split,
    popup = Popup,
  },
})

---@param opts table
function ui_handler:handle(opts)
  local type = opts.ui or self.options.get("ui.default")

  local instance = self.builders[type](opts.nui_opts or self.options.get("ui.nui_opts", {})[type])

  return instance
end

return ui_handler
