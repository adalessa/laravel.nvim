local routes = {}

function routes:new(pickers)
  local instance = {
    pickers = pickers,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes:commands()
  return { "routes" }
end

function routes:handle()
  if self.pickers:exists("routes") then
    self.pickers:run("routes")
    return
  end
  vim.notify("No picker defined", vim.log.levels.ERROR)
end

function routes:complete()
  return {}
end

return routes
