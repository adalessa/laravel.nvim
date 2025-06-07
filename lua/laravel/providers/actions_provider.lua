---@class laravel.providers.actions: laravel.providers.provider
local actions_provider = { name = "laravel.providers.actions" }

function actions_provider:register(app)
  vim.tbl_map(function(action)
    app:bindIf(action, action, { tags = { "action" } })
  end, require("laravel.actions"))

  app:bindIf("laravel.actions", function()
    return app:makeByTag("action")
  end)

  app:addCommand("laravel.code_actions", function()
    return {
      signature = "actions",
      description = "Run Laravel code actions",
      handle = function()
        app("laravel.managers.actions_manager"):run()
      end,
    }
  end)
end

return actions_provider
