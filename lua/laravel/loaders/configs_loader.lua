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

function ConfigsLoader:get(name)
  if not name or name == "" then
    return nil, "Config name cannot be empty"
  end
  local response, err = self.tinker:json(string.format("echo json_encode(config('%s'));", name))

  if err then
    return nil, "Failed to get config '" .. name .. "': " .. err
  end

  return response, nil
end

return ConfigsLoader
