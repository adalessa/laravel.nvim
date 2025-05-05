---@class LaravelRouteInfoProvider : laravel.providers.provider
local route_info = {}

function route_info:register(app, opts)
  app:singeltonIf("route_info", "laravel.extensions.route_info.service")
  app:bindIf("route_info_view", function()
    return require("laravel.extensions.route_info.view_factory"):new(opts, {
      top = require("laravel.extensions.route_info.view_top"),
      right = require("laravel.extensions.route_info.view_right"),
    })
  end)
  app:bindIf("route_info_command", "laravel.extensions.route_info.command", { tags = { "command" } })
end

function route_info:boot(app, opts)
  local group = vim.api.nvim_create_augroup("laravel.route_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = app:whenActive(function(ev)
      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      app("route_info"):handle(ev.buf)
    end),
  })
end

return route_info
