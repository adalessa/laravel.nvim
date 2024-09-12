---@class LaravelServeCommand
---@field api LaravelApi
---@field job vim.SystemObj|nil
local serve = {}

function serve:new(api)
  local instance = {
    api = api,
    job = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function serve:commands()
  return { "serve" }
end

function serve:handle()
  if self.job then
    vim.notify("Server already running", vim.log.levels.INFO, {})
    return
  end

  local cmd = self.api:generate_command("artisan", { "serve" })

  local command = vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function()
      self.job:kill(15)
    end,
  })

  self.job = vim.system(cmd, {}, function(out)
    local level = vim.log.levels.ERROR
    if out.signal == 15 then
      level = vim.log.levels.INFO
    end
    vim.notify("Server stopped", level, {})
    vim.api.nvim_del_autocmd(command)
    self.job = nil
  end)

  vim.notify("Server started PID: " .. self.job.pid, vim.log.levels.INFO, {})
end

function serve:complete()
  return {}
end

return serve
