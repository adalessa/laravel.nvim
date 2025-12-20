local provider = { name = "laravel.providers.history_provider" }

function provider:register(app)
  app:singletonIf("history", "laravel.services.history")

  app:addCommand("laravel.commands.history", function()
    return {
      signature = "picker:history",
      description = "Show the command history",
      handle = function()
        app:make("pickers_manager"):run("history")
      end,
    }
  end)
end

return provider
