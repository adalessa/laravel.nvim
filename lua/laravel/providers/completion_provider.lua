local completion_provider = {}

function completion_provider:register(app)
  app():register_many({
    completion = "laravel.services.completion",
  })
end

function completion_provider:boot(app)
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.register_source("laravel", app("completion"))
  end
end

return completion_provider
