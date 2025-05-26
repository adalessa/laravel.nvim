local history_provider = {}

---@param app laravel.app
function history_provider:register(app)
  app:singletonIf("history", "laravel.extensions.history.service")
  app:bindIf("history_command", "laravel.extensions.history.command", { tags = { "command" } })
end

---@param app laravel.app
function history_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel", {})
  vim.api.nvim_create_autocmd({ "User" }, {
    group = group,
    pattern = "LaravelCommandRun",
    callback = function(ev)
      app("history"):add(ev.data.job_id, ev.data.cmd, ev.data.args, ev.data.options)
    end,
  })
end

return history_provider
