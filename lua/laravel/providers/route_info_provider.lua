local route_info_provider = {}

function route_info_provider:register(app)
  app():register_many({
    route_info = "laravel.services.route_info",
    route_virutal_text = "laravel.services.route_virtual_text",
  })
end

function route_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.route_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*Controller.php" },
    group = group,
    callback = function(ev)
      app("route_info"):handle(ev.buf)
    end,
  })
end

return route_info_provider
