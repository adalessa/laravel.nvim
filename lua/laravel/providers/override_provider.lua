local override_provider = {}

function override_provider:register(app)
  app():register("override", "laravel.services.override")
end

function override_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.override", {})
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    group = group,
    callback = function(ev)
      app("override"):handle(ev.buf)
    end,
  })
end

return override_provider
