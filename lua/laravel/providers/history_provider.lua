local history_provider = {}

---@param app LaravelApp
function history_provider:register(app)
  app:singeltonIf("history", "laravel.services.history")
  app:bindIf("history_command", "laravel.services.commands.history", { tags = { "command" } })
end

---@param app LaravelApp
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
