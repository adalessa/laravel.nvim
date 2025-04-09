local resources = {}

function resources:new(pickers)
  local instance = {
    pickers = pickers,
    command = "resources",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function resources:handle()
  self.pickers:run("resources")
end

return resources
