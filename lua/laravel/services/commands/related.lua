local related = {}

function related:new(related_picker)
  local instance = {
    picker = related_picker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related:commands()
  return { "related" }
end

function related:handle()
  self.picker()
end

return related
