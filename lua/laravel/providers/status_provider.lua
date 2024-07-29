local status_provider = {}

function status_provider:register(app)
  app():register("status", function()
    return require("laravel.services.status"):new(app("artisan"), app("php"), 120)
  end)
end

function status_provider:boot(app)
  app('status'):start()
end

return status_provider
