local diagnostics_provider = {}

---@param app laravel.app
function diagnostics_provider:register(app)
  app:bindIf("view_diagnostics", "laravel.extensions.diagnostic.views", { tags = { "diagnostics" } })
end

---@param app laravel.app
function diagnostics_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.diagnostic", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*.php" },
    group = group,
    callback = app:whenActive(function(ev)
      for _, diagnostic in ipairs(app:makeByTag("diagnostics")) do
        diagnostic:handle(ev.buf)
      end
    end),
  })
end

return diagnostics_provider
