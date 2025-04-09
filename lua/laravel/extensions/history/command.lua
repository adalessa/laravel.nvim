local history = {}

function history:new(pickers)
  local instance = {
    pickers = pickers,
    command = "history",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function history:handle()
  self.pickers:run("history")
end

return history
