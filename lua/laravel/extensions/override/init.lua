---@class LaravelOverrideProvider : laravel.providers.provider
local override_provider = {}

---@param app laravel.app
function override_provider:register(app)
  app:bindIf("override", "laravel.extensions.override.service")
end

---@param app laravel.app
function override_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.override", {})
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    pattern = "*.php",
    group = group,
    callback = app:whenActive(function(ev)
      local cwd = vim.uv.cwd()
      if vim.startswith(ev.file, cwd .. "/vendor") then
        return
      end

      app("override"):handle(ev.buf)
    end),
  })
end

return override_provider
