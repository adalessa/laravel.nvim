---@class LaravelActionsprovider: LaravelProvider
local actions_provider = {}

function actions_provider:register(app)
  app:bindIf("actions", function()
    return app:makeByTag("action")
  end)

  app:bindIf("actions_service", "laravel.services.actions", {})

  app:bindIf("model_to_mgiration_action", "laravel.actions.model_to_migration", { tags = { "action" } })

  app:bindIf("actions_command", function()
    local command = {
      command = "actions",
    }
    function command:handle()
      app("actions_service"):run()
    end

    return command
  end, { tags = { "command" } })
end

return actions_provider
