local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

-- {"page_extensions":["js","jsx","svelte","ts","tsx","vue"],"page_paths":["resources\/js\/Pages","resources\/js\/pages"]}

---@class laravel.loaders.inertia_loader
---@field code laravel.services.code
local InertiaLoader = Class({
  code = "laravel.services.code",
})

---@class laravel.dto.inertia
---@field page_extensions string[]
---@field page_paths string[]

---@return laravel.dto.inertia, laravel.error
function InertiaLoader:load()
  local inertia, err = self.code:run("inertia")
  if err then
    return {}, Error:new("Failed to load inertia"):wrap(err)
  end

  return inertia or {}, nil
end

return InertiaLoader
