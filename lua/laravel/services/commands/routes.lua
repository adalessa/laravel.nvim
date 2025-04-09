local routes = {}

function routes:new(pickers)
  local instance = {
    pickers = pickers,
    command = "routes",
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes:handle()
  self.pickers:run("routes")
end

function routes:complete()
  return {}
end

return routes
