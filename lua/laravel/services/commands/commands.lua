local commands = {}

function commands:new(pickers)
  local instance = {
    pickers = pickers,
    command = "commands",
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function commands:handle()
  self.pickers:run("commands")
end

return commands
