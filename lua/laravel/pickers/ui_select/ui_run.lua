local Layout = require("nui.layout")
local Popup = require("nui.popup")
local app = require("laravel").app
local common = require("laravel.pickers.common.ui_run")

return function(command)
  common.ui_run(command, { entry_popup = common.entry_popup() })
end
