local make = {}

function make:new(make_picker)
  local instance = {
    picker = make_picker,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function make:commands()
  return { "make" }
end

function make:handle()
  self.picker:run()
end

return make
