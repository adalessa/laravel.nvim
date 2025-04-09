local make = {}

function make:new(pickers)
  local instance = {
    pickers = pickers,
    command = "make",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make:handle()
  self.pickers:run("make")
end

return make
