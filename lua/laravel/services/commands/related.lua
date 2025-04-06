local related = {}

function related:new(pickers)
  local instance = {
    pickers = pickers,
    command = "related",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related:handle()
  self.pickers:run("related")
end

return related
