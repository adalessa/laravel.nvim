local history = {}

function history:new(history_picker)
  local instance = {
    picker = history_picker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function history:commands()
  return { "history" }
end

function history:handle()
  self.picker:run()
end

return history
