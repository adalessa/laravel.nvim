local Class = require("laravel.utils.class")
local fs = require("laravel.utils.fs")

---@class laravel.dto.artisan_views
---@field name string
---@field path string

---@class laravel.loaders.views_loader
---@field resources_loader laravel.loaders.resources_loader
local ViewsLoader = Class({
  resources_loader = "laravel.loaders.resources_loader",
})

---@return laravel.dto.artisan_views[], string?
function ViewsLoader:load()
  local directory, err = self.resources_loader:get("views")
  if err then
    return {}, "Failed to load views: " .. err
  end

  local rule = string.format("^%s/(.*).blade.php$", directory:gsub("-", "%%-"))

  local files = fs.scanDir(directory, 4)

  return vim
    .iter(files)
    :filter(function(value)
      return value ~= nil
    end)
    :map(function(value)
      local match = value:match(rule)
      if not match then
        return nil
      end
      return {
        name = match:gsub("/", "."),
        path = value,
      }
    end)
    :filter(function(value)
      return value ~= nil
    end)
    :totable()
end

return ViewsLoader
