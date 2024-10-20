local panel_provider = {}

---@param app LaravelApp
function panel_provider:register(app)
  app:bindIf("panel_command", "laravel_panel.command", { tags = { "command" } })

  app:bindIf("laravel_panel.modules.info", "laravel_panel.modules.info", { tags = { "panel" } })
  app:bindIf("laravel_panel.modules.logs", "laravel_panel.modules.logs", { tags = { "panel" } })
  app:bindIf("laravel_panel.modules.tinker", "laravel_panel.modules.tinker", { tags = { "panel" } })
  app:bindIf("laravel_panel.modules.dev", "laravel_panel.modules.dev", { tags = { "panel" } })
  -- app:bindIf("laravel_panel.modules.sail", "laravel_panel.modules.sail", { tags = { "panel" } })

  app:singeltonIf("panel", function()
    local Panel = require("laravel_panel")

    return Panel:new(app:makeByTag("panel"))
  end)
end

return panel_provider
