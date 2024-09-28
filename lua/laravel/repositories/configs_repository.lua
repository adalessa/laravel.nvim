---@class ConfigsRespository
---@field tinker Tinker
local configs_repository = {}

function configs_repository:new(tinker)
  local instance = { tinker = tinker }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function configs_repository:all()
  return self.tinker:json("echo json_encode(array_keys(Arr::dot(Config::all())));"):thenCall(function(response)
    return vim
        .iter(response)
        :filter(function(c)
          return type(c) == "string"
        end)
        :totable()
  end)
end

---@param key string
---@return Promise
function configs_repository:get(key)
  return self.tinker:json(string.format("echo json_encode(config('%s'));", key)):thenCall(function(response)
    return response
  end)
end

return configs_repository
