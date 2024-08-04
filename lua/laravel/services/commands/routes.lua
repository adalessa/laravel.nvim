local routes = {}

function routes:new(routes_picker)
  local instance = {
    picker = routes_picker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes:commands()
  return { "routes" }
end

function routes:handle()
  self.picker()
end

function routes:complete()
  return {}
end

return routes
