local Task = require("laravel.task")
local notify = require("laravel.utils.notify")
local Class = require("laravel.utils.class")
local nio = require("nio")

local command = Class({
  command_generator = "laravel.services.command_generator",
  configs_loader = "laravel.loaders.configs_cache_loader",
}, {
  task = Task:new(),
  command = "dev",
  host = "",
  subCommands = {
    "start",
    "stop",
  },
  default = "start",
})

function command:start()
  if self.task:running() then
    notify.info("Server already running")
    return
  end

  local cmd = self.command_generator:generate("composer dev")
  if not cmd then
    notify.error("Composer not found")
    return
  end

  self.task:run(cmd)
  nio.run(function()
    local url, err = self.configs_loader:get("app:url")
    if err then
      notify.error("Could not load app.url: " .. err)
      return
    end
    self.host = url
    notify.info("Composer Dev Started at " .. self.host)
  end)
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
