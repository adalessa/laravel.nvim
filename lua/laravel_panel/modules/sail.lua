local app = require("laravel").app

local sail_panel = {}

function sail_panel:active()
  return app("env").environment.name == "sail"
end

function sail_panel:getTargetWinId() end

function sail_panel:setup(opts) end

function sail_panel:layout()
end

function sail_panel:activate()
end

return sail_panel
