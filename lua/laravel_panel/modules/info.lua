local Popup = require("nui.popup")
local Layout = require("nui.layout")
local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local promise = require("promise")

local app = require("laravel").app

local info_panel = {}

function info_panel:new()
  local instance = {
    id = "info",
    text = "Info",
  }
  setmetatable(instance, self)
  self.__index = self

  instance._panel = instance:_create_panel()
  instance._layout = instance:_create_layout()

  return instance
end

-- private methods

function info_panel:_create_panel()
  return Popup({
    border = {
      style = "single",
      text = {
        top = self.text,
      },
    },
    buf_options = {
      modifiable = false,
    },
  })
end

function info_panel:_create_layout()
  return Layout.Box(self._panel, { size = "100%" })
end

--- interface
function info_panel:active()
  return true
end

function info_panel:getTargetWinId()
  return self._panel.winid
end

function info_panel:setup(opts)
  self._panel:map("n", "q", opts.quit)
  self._panel:map("n", "<tab>", opts.menu_focus)
  self._panel:map("n", "r", function ()
    self:activate()
  end)
end

function info_panel:layout()
  return self._layout
end

function info_panel:activate()
  promise
      .all({
        app("api"):send("artisan", { "about", "--json" }),
        app("cache_routes_repository"):all(),
      })
      :thenCall(function(results)
        local response, routes = unpack(results)
        local data = response:json()

        local lines = {}

        table.insert(lines, NuiLine({ NuiText("Environment:", "String") }))
        table.insert(lines, NuiLine({ NuiText("    Application Name:    "), NuiText(data.environment.application_name) }))
        table.insert(lines, NuiLine({ NuiText("    Environment:         "), NuiText(data.environment.environment) }))
        table.insert(
          lines,
          NuiLine({ NuiText("    Debug Mode:          "), NuiText(data.environment.debug_mode and "Yes" or "No") })
        )
        table.insert(lines, NuiLine({ NuiText("    Url:                 "), NuiText(data.environment.url) }))
        table.insert(lines, NuiLine({ NuiText("    Amount Routes:       "), NuiText(string.format("%d", #routes)) }))
        table.insert(lines, NuiLine({ NuiText("    Laravel Version:     "), NuiText(data.environment.laravel_version) }))
        table.insert(lines, NuiLine({ NuiText("    PHP Version:         "), NuiText(data.environment.php_version) }))
        table.insert(
          lines,
          NuiLine({ NuiText("    Maintenance:         "), NuiText(data.environment.maintenance_mode and "Yes" or "No") })
        )
        table.insert(lines, NuiLine({ NuiText("    Timezone:            "), NuiText(data.environment.timezone) }))
        table.insert(lines, NuiLine({ NuiText("    Locale:              "), NuiText(data.environment.locale) }))

        table.insert(lines, NuiLine())

        table.insert(lines, NuiLine({ NuiText("Cache:", "String") }))
        table.insert(lines, NuiLine({ NuiText("    Config:         "), NuiText(data.cache.config and "Yes" or "No") }))
        table.insert(lines, NuiLine({ NuiText("    Events:         "), NuiText(data.cache.events and "Yes" or "No") }))
        table.insert(lines, NuiLine({ NuiText("    Routes:         "), NuiText(data.cache.routes and "Yes" or "No") }))
        table.insert(lines, NuiLine({ NuiText("    Views:          "), NuiText(data.cache.views and "Yes" or "No") }))

        table.insert(lines, NuiLine())

        table.insert(lines, NuiLine({ NuiText("Drivers:", "String") }))
        table.insert(lines, NuiLine({ NuiText("    Database:       "), NuiText(data.drivers.database) }))
        table.insert(lines, NuiLine({ NuiText("    Mail:           "), NuiText(data.drivers.mail) }))
        table.insert(lines, NuiLine({ NuiText("    Queue:          "), NuiText(data.drivers.queue) }))
        table.insert(lines, NuiLine({ NuiText("    Session:        "), NuiText(data.drivers.session) }))
        table.insert(lines, NuiLine({ NuiText("    Cache:          "), NuiText(data.drivers.cache) }))
        table.insert(lines, NuiLine({ NuiText("    Broadcasting:   "), NuiText(data.drivers.broadcasting) }))

        vim.api.nvim_set_option_value("modifiable", true, { buf = self._panel.bufnr })
        local line = 0
        for i, l in ipairs(lines) do
          l:render(self._panel.bufnr, -1, line + i)
        end
        vim.api.nvim_set_option_value("modifiable", false, { buf = self._panel.bufnr })
      end)
end

return info_panel
