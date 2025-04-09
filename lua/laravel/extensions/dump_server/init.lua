---@class LaravelDumpServerProvider : LaravelProvider
local dump_server_provider = {}

function dump_server_provider:register(app)
  app:singeltonIf("dump_server", "laravel.extensions.dump_server.service")
  app:singeltonIf("dump_server_ui", "laravel.extensions.dump_server.ui")
  app:bind("dump_server_command", "laravel.extensions.dump_server.command", { tags = { "command" } })
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
