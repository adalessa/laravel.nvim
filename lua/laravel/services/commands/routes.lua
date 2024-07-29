local routes = {}

function routes:new()
  local instance = {}
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function routes:commands()
  return {"routes"}
end

function routes:handle()
  require("telescope").extensions.laravel.routes()
end

function routes:complete()
  return {}
end

return routes
