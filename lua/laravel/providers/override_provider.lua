local override_provider = {}

function override_provider:register(app)
  app():register("override", "laravel.services.override")
end

function override_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.override", {})
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = "*.php",
    group = group,
    callback = function(ev)
      if not app("env"):is_active() then
        return
      end

      app("override"):handle(ev.buf)
    end,
  })
end

return override_provider