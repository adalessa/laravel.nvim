local model_info_provider = {}

---@param app LaravelApp
function model_info_provider:register(app)
  app:bindIf("model_info", "laravel.services.model_info")
end

---@param app LaravelApp
function model_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.model_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*.php",
    group = group,
    callback = function(ev)
      if not app("env"):is_active() then
        return
      end
      app("model_info"):handle(ev.buf)
    end,
  })
end

return model_info_provider
