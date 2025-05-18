local Task = require("laravel.task")

local command = {
  _inject = {
    command_generator = "laravel.services.command_generator",
  }
}

function command:new(command_generator, configs_repository)
  local instance = {
    command_generator = command_generator,
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

  local cmd = self.command_generator:generate("composer dev")
  if not cmd then
    vim.notify("Composer not found", vim.log.levels.ERROR, {})
    return
  end

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
