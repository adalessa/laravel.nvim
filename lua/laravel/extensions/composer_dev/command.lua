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
    default = "start",
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

  local cmd = self.api:generateCommand("composer", { "dev" })

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

return command
