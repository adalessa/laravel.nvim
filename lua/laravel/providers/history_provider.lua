local provider = { name = "laravel.providers.history_provider" }

function provider:register(app)
  app:singletonIf("history", "laravel.services.history")

  app:addCommand("laravel.commands.history", function()
    return {
      signature = "pickers:history",
      description = "Show the command history",
      handle = function()
        app:make("pickers_manager"):run("history")
      end,
    }
  end)
end

function provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.history", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = { "LaravelCommandRun" },
    callback = function(ev)
      app("history"):add(ev.data.job_id, ev.data.cmd, ev.data.args, ev.data.options)
    end,
  })
end

return provider
