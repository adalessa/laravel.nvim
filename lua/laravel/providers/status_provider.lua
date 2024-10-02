local status_provider = {}

---@param app LaravelApp
function status_provider:register(app)
  app:singeltonIf("status", "laravel.services.status")

  app:associate("status", {
    frequency = 120,
  })
end

---@param app LaravelApp
function status_provider:boot(app)
  if not app("env"):is_active() then
    return
  end

  app("status"):start()

  local group = vim.api.nvim_create_augroup("laravel", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      if ev.data.cmd == "composer" then
        app("status"):update()
      end
    end,
  })
end

return status_provider
