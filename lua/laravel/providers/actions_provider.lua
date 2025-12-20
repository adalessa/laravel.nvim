local utils = require("laravel.utils")

---@type laravel.providers.provider
local actions_provider = { name = "laravel.providers.actions" }

function actions_provider.register(app)
  vim
    .iter(utils.get_modules({
      "lua/laravel/actions/*_action.lua",
      "lua/laravel/extensions/**/*_action.lua",
    }))
    :each(function(action)
      app:bindIf(action, action, { tags = { "action" } })
    end)

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
