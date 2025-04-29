---@class LaravelModelInfoProvider : LaravelProvider
local model_info_provider = {}

function model_info_provider:register(app)
  app:bindIf("model_info", "laravel.extensions.model_info.service")
  app:bindIf("model_info_view", "laravel.extensions.model_info.view")
end

function model_info_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.model_info", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = "*.php",
    group = group,
    callback = function(ev)
      if not app("env"):is_active() then
        return
      end
      -- check that is not from the vendor folder
      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      app("model_info"):handle(ev.buf)
    end,
  })
end

return model_info_provider
