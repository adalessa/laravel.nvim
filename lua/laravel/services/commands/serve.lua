---@class LaravelServeCommand
---@field api LaravelApi
---@field job vim.SystemObj|nil
---@field commandId integer|nil
local serve = {}

function serve:new(api)
  local instance = {
    api = api,
    job = nil,
    commandId = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function serve:commands()
  return { "serve" }
end

function serve:start()
  if self.job then
    vim.notify("Server already running", vim.log.levels.INFO, {})
    return
  end

  local cmd = self.api:generate_command("artisan", { "serve" })

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
      vim.notify("Server stopped", level, {})
      vim.api.nvim_del_autocmd(self.commandId)
      self.job = nil
      self.commandId = nil
    end)
  )

  vim.notify("Server started PID: " .. self.job.pid, vim.log.levels.INFO, {})
end

function serve:stop()
  self.job:kill(15)
end

function serve:handle(args)
  table.remove(args.fargs, 1)

  if args.fargs[1] == "start" or args.fargs[1] == "" or args.fargs[1] == nil then
    self:start()
  elseif args.fargs[1] == "stop" then
    self:stop()
  end
end

function serve:complete(argLead)
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

return serve
