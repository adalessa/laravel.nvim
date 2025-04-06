local Task = require("laravel.task")

local command = {}

function command:new(api, configs_repository)
  local instance = {
    api = api,
    configs_repository = configs_repository,
    task = Task:new(),
    command = "dev",
    host = "",
    subCommands = {
      "start",
      "stop",
    },
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function command:start()
  if self.task:running() then
    vim.notify("Server already running", vim.log.levels.INFO, {})
    return
  end

  local cmd = self.api:generate_command("composer", { "dev" })

  self.task:run(cmd)
  self.configs_repository:get("app.url"):thenCall(function(value)
    self.host = value
  end)

  vim.notify("Composer Dev Started", vim.log.levels.INFO, {})
end

function command:stop()
  self.task:stop()
end

function command:hostname()
  return self.host
end

function command:isRunning()
  return self.task:running()
end

function command:handle(args)
  table.remove(args.fargs, 1)

  if args.fargs[1] == "start" or args.fargs[1] == "" or args.fargs[1] == nil then
    self:start()
  elseif args.fargs[1] == "stop" then
    self:stop()
  end
end

return command
