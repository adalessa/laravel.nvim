local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.loaders.configs_loader
---@field tinker laravel.services.tinker
local ConfigsLoader = Class({
  tinker = "laravel.services.tinker",
})

---@return string[], laravel.error
function ConfigsLoader:load()
  local response, err = self.tinker:json("echo json_encode(array_keys(Arr::dot(Config::all())));")
  if err then
    return {}, Error:new("Failed to load configs"):wrap(err)
  end

  return vim
    .iter(response)
    :filter(function(c)
      return type(c) == "string"
    end)
    :totable()
end

---@return table, laravel.error
function ConfigsLoader:get(name)
  if not name or name == "" then
    return {}, Error:new("Config name cannot be empty")
  end
  local response, err = self.tinker:json(string.format("echo json_encode(config('%s'));", name))

  if err then
    return {}, Error:new(("Failed to get config '%s'"):format(name)):wrap(err)
  end

  return response, nil
end

return ConfigsLoader
