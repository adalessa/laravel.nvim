local override_provider = {}

---@param app LaravelApp
function override_provider:register(app)
  app:bindIf("override", "laravel.services.override")
end

---@param app LaravelApp
function override_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.override", {})
  vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
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

      app("override"):handle(ev.buf)
    end,
  })
end

return override_provider
