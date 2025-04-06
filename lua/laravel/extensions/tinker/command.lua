local command = {}

function command:new()
  local instance = {
    command = "tinker",
    subCommands = {
      "open",
      "select",
    },
    default = "open",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function command:open()
  vim.print("Tinker open")
end

function command:select()
  vim.print("Tinker select")
end

return command
