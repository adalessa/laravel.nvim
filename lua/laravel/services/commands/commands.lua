local commands = {}

function commands:new(commands_picker)
  local instance = {
    picker = commands_picker,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function commands:commands()
  return {"commands"}
end

function commands:handle()
  self.picker:run()
end

function commands:complete()
  return {}
end

return commands
