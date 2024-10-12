local commands = {}

function commands:new(pickers)
  local instance = {
    pickers = pickers,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function commands:commands()
  return { "commands" }
end

function commands:handle()
  if self.pickers:exists("commands") then
    self.pickers:run("commands")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

function commands:complete()
  return {}
end

return commands
