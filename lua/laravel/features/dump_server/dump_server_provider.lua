---@class LaravelDumpServerProvider : LaravelProvider
local dump_server_provider = {}

function dump_server_provider:register(app)
  app:singeltonIf("dump_server", "laravel.features.dump_server.dump_server_service")
  app:singeltonIf("dump_server_ui", "laravel.features.dump_server.dump_server_ui")
  app:bind("dump_server_command", "laravel.features.dump_server.dump_server_command", { tags = { "command" } })
end

function dump_server_provider:boot(app)
  -- app:make("dump_server")
  local group = vim.api.nvim_create_augroup("laravel.dump_server", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "DumpServerRecord",
    callback = function()
      app("dump_server_ui"):update()
    end,
  })
end

return dump_server_provider
