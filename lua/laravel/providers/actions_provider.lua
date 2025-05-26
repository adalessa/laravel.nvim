---@class laravel.providers.actions: laravel.providers.provider
local actions_provider = {name = "laravel.providers.actions"}

function actions_provider:register(app)
  vim.tbl_map(function(action)
    app:bindIf(action, action, { tags = { "action" } })
  end, require("laravel.actions"))

  app:bindIf("laravel.actions", function()
    return app:makeByTag("action")
  end)

  app:command("actions", function()
    app("laravel.services.actions"):run()
  end)
end

return actions_provider
