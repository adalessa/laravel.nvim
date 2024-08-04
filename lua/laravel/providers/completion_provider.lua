local completion_provider = {}

---@param app LaravelApp
function completion_provider:register(app)
  app:bindIf('completion', 'laravel.services.completion')
end

---@param app LaravelApp
function completion_provider:boot(app)
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.register_source("laravel", app("completion"))
  end
end

return completion_provider
