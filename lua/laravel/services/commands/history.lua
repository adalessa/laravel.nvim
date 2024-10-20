local history = {}

function history:new(pickers)
  local instance = {
    pickers = pickers,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function history:commands()
  return { "history" }
end

function history:handle()
  if self.pickers:exists("history") then
    self.pickers:run("history")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return history
