---@class ComposerProvider : laravel.providers.provider
local composer_provider = {}

function composer_provider:register(app)
  app:bindIf("composer_info", "laravel.extensions.composer_info.service")
end

function composer_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.composer_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "composer.json",
    group = group,
    callback = app:whenActive(function(ev)
      app("composer_info"):handle(ev.buf)
    end),
  })
end

return composer_provider
