local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")
local nio = require("nio")

---@class laravel.services.inertia
---@field inertia_loader laravel.loaders.inertia_cache_loader
local inertia = Class({
  inertia_loader = "laravel.loaders.inertia_cache_loader",
})

---@param view string
function inertia:find(view)
  local config, err = self.inertia_loader:load()

  if err then
    return "", Error:new("Failed to get inertia config from loader"):wrap(err)
  end

  for _, page_path in ipairs(config.page_paths or {}) do
    for _, page_extension in ipairs(config.page_extensions or {}) do
      local possible_path = string.format("%s/%s.%s", page_path, view, page_extension)
      local _, file_stats = nio.uv.fs_stat(possible_path)
      if file_stats then
        return possible_path, nil
      end
    end
  end

  return "", Error:new("Inertia view not found: " .. view)
end

return inertia
