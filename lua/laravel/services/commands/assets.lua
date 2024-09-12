---@class LaravelAssetsCommand
---@field api LaravelApi
---@field job vim.SystemObj|nil
local assets = {}

function assets:new(api)
  local instance = {
    api = api,
    job = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function assets:commands()
  return { "assets" }
end

function assets:handle()
  --TODO: support stop
  if self.job then
    vim.notify("Assets dev already running", vim.log.levels.INFO, {})
    return
  end

  local cmd = self.api:generate_command("npm", { "run", "dev" })

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
    vim.notify("Assets dev stopped", level, {})
    vim.api.nvim_del_autocmd(command)
    self.job = nil
  end)

  vim.notify("Assets dev started PID: " .. self.job.pid, vim.log.levels.INFO, {})
end

function assets:complete()
  return {}
end

return assets
