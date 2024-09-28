---@class ComposerProvider : LaravelProvider
local composer_provider = {}

function composer_provider:register(app)
  app:bindIf("composer_info", "laravel.services.composer_info")
end

function composer_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.composer_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "composer.json",
    group = group,
    callback = function (ev)
      if not app("env"):is_active() then
        return
      end
      app("composer_info"):handle(ev.buf)
    end
  })
end

return composer_provider
