local make = {}

function make:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make:commands()
  return { "make" }
end

function make:handle()
  if self.pickers:exists("make") then
    self.pickers:run("make")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return make
