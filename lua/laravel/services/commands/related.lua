local related = {}

function related:new(pickers)
  local instance = {
    pickers = pickers,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function related:commands()
  return { "related" }
end

function related:handle()
  if self.pickers:exists("related") then
    self.pickers:run("related")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

return related
