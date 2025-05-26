local Class = require("laravel.utils.class")

---@class laravel.loaders.configs_loader
---@field tinker laravel.services.tinker
local ConfigsLoader = Class({
  tinker = "laravel.services.tinker",
})

---@return string[], string?
function ConfigsLoader:load()
  local response, err = self.tinker:json("echo json_encode(array_keys(Arr::dot(Config::all())));")
  if err then
    return {}, "Failed to load configs: " .. err
  end

  return vim
    .iter(response)
    :filter(function(c)
      return type(c) == "string"
    end)
    :totable()
end

return ConfigsLoader
