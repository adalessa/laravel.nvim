local command = {}

function command:new(tinker_service)
  local instance = {
    service = tinker_service,
    command = "tinker",
    subCommands = {
      "open",
      "select",
      "create",
    },
    default = "open",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function command:open()
  self.service:open()
end

function command:select()
  self.service:select()
end

function command:create()
  self.service:create()
end

return command
