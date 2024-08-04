local route_info_provider = {}

---@param app LaravelApp
function route_info_provider:register(app)
  app:bindIf('route_info', 'laravel.services.route_info')
  app:bindIf('route_virtual_text', 'laravel.services.route_virtual_text')
end

---@param app LaravelApp
function route_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.route_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = function(ev)
      if not app("env"):is_active() then
        return
      end
      app("route_info"):handle(ev.buf)
    end,
  })
end

return route_info_provider
