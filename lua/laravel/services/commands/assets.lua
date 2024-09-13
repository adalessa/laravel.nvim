---@class LaravelAssetsCommand
---@field api LaravelApi
---@field job vim.SystemObj|nil
---@field commandId integer|nil
local assets = {}

function assets:new(api)
  local instance = {
    api = api,
    job = nil,
    commandId = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function assets:stop()
  self.job:kill(15)
end

function assets:start()
  if self.job then
    vim.notify("Assets dev already running", vim.log.levels.INFO, {})
    return
  end

  local cmd = self.api:generate_command("npm", { "run", "dev" })

  self.commandId = vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
    callback = function()
      self.job:kill(15)
    end,
  })

  self.job = vim.system(
    cmd,
    {},
    vim.schedule_wrap(function(out)
      local level = vim.log.levels.ERROR
      if out.signal == 15 then
        level = vim.log.levels.INFO
      end
      vim.notify("Assets dev stopped", level, {})
      vim.api.nvim_del_autocmd(self.commandId)
      self.job = nil
      self.commandId = nil
    end)
  )

  vim.notify("Assets dev started PID: " .. self.job.pid, vim.log.levels.INFO, {})
end

function assets:commands()
  return { "assets" }
end

function assets:handle(args)
  table.remove(args.fargs, 1)

  if args.fargs[1] == "start" or args.fargs[1] == "" or args.fargs[1] == nil then
    self:start()
  elseif args.fargs[1] == "stop" then
    self:stop()
  end
end

function assets:complete(argLead)
  return vim
      .iter({
        "start",
        "stop",
      })
      :filter(function(name)
        return vim.startswith(name, argLead)
      end)
      :totable()
end

return assets
