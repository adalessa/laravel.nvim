local container = require "laravel.container":new()

---@alias LaravelApp fun(string):any

---@param abstract ?string
---@return any
return function(abstract)
  if not abstract then
    return container
  end

  return container:get(abstract)
end
