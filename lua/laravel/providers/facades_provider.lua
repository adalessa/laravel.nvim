---@type laravel.providers.provider
local provider = { name = "laravel.providers.facades_provider" }

function provider.register(app)
  app:alias("api", "laravel.services.api")
  app:alias("cache", "laravel.services.cache")
  app:alias("class", "laravel.services.class")
  app:alias("composer", "laravel.services.composer")
  app:alias("config", "laravel.services.config")
  app:alias("env", "laravel.core.env")
  app:alias("env_vars", "laravel.services.env")
  app:alias("gf", "laravel.services.gf")
  app:alias("log", "laravel.utils.log")
  app:alias("model", "laravel.services.model")
  app:alias("related", "laravel.services.related")
  app:alias("runner", "laravel.services.runner")
  app:alias("tinker", "laravel.services.tinker")
  app:alias("view_finder", "laravel.services.view_finder")
  app:alias("views", "laravel.services.views")
end

return provider
