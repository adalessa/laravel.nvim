local resources = {}

function resources:new(resources_picker)
  local instance = {
    picker = resources_picker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function resources:commands()
  return { "resources" }
end

function resources:handle()
  self.picker:run()
end

return resources
