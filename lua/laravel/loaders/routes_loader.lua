local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.loaders.routes_loader
---@field api laravel.services.api
---@field options laravel.core.options_manager
---@field mapper laravel.mappers.route_mapper
local RoutesLoader = Class({
  api = "laravel.services.api",
  options = "laravel.core.options_manager",
  mapper = "laravel.mappers.route_mapper",
})

---@return laravel.dto.artisan_routes[], laravel.error
function RoutesLoader:load()
  local result, err = self.api:run(self.options.get("loaders.route_info.command", "artisan route:list --json"))

  if err then
    return {}, Error:new("Failed to load routes"):wrap(err)
  end

  if result:failed() then
    return {}, Error:new("Failed to load routes " .. result:prettyErrors())
  end

  return vim.tbl_map(self.mapper.map, result:json() or {})
end

return RoutesLoader
