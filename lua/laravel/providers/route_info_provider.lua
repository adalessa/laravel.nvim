local route_info_provider = {}

---@param app LaravelApp
function route_info_provider:register(app)
  app:singeltonIf("route_info", "laravel.services.route_info")
  app:bindIf("route_info_view", function()
    return require("laravel.services.route_info.view_factory"):new(app("options"), {
      top = require("laravel.services.route_info.view_top"),
      right = require("laravel.services.route_info.view_right"),
    })
  end)
  app:bindIf("route_info_command", "laravel.services.route_info.command", { tags = { "command" } })
end

---@param app LaravelApp
function route_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.route_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = function(ev)
      if not app("env"):is_active() or not app("options"):get().features.route_info.enable then
        return
      end
      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      app("route_info"):handle(ev.buf)
    end,
  })
end

return route_info_provider
