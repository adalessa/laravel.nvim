local views_provider = {}

---@param app LaravelApp
function views_provider:register(app)
  app:bindIf("views", "laravel.services.views")
  -- TODO: add new service for cache one.
end

function views_provider:boot(app)
  -- TODO: add listeners to renew the cache.
  -- autocmd for .blade.php files
end

return views_provider
