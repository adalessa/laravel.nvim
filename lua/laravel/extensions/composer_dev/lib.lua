local Class = require("laravel.utils.class")
local Task = require("laravel.task")

---@class laravel.extensions.composer_dev.lib
---@field command_generator laravel.services.command_generator
---@field configs_loader laravel.loaders.configs_loader
---@field task laravel.task
local lib = Class({
  command_generator = "laravel.services.command_generator",
  configs_loader = "laravel.loaders.configs_loader",
}, {
  task = Task:new(),
  host = "",
})

---@async
function lib:start()
  local cmd = self.command_generator:generate("composer dev")
  if not cmd then
    return "Composer not found"
  end

  self.task:run(cmd)
  local url, err = self.configs_loader:get("app.url")
  if err then
    return "Could not load app.url: " .. err:toString()
  end
  if not url or type(url) ~= "string" or url == "" then
    return "app.url is not set or invalid"
  end

  self.host = url

  return nil
end

function lib:stop()
  self.task:stop()
end

function lib:hostname()
  return self.host
end

function lib:isRunning()
  return self.task:running()
end

return lib
