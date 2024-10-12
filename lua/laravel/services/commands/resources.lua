local resources = {}

function resources:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function resources:commands()
  return { "resources" }
end

function resources:handle()
  if self.pickers:exists("resources") then
    self.pickers:run("resources")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return resources
