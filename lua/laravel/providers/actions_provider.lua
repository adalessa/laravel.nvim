---@class LaravelActionsprovider: LaravelProvider
local actions_provider = {}

function actions_provider:register(app)
  app:bindIf("actions", function()
    return app:makeByTag("action")
  end)

  app:bindIf("actions_service", "laravel.services.actions", {})

  vim.tbl_map(function(action)
    app:bindIf(action, action, { tags = { "action" } })
  end, require("laravel.actions"))

  app:command("actions", function()
    app("actions_service"):run()
  end)
end

return actions_provider
