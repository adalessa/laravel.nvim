---@class LaravelConfigsProvider
---@field api LaravelApi
local configs = {}

function configs:new(api)
  local instance = setmetatable({}, { __index = configs })
  instance.api = api
  return instance
end

---@param callback fun(configs: string[])
---@return vim.SystemObj
function configs:keys(callback)
  return self.api:tinker("echo json_encode(array_keys(Arr::dot(Config::all())));", function(response)
    if response:failed() then
      callback({})
    end

    callback(vim
      .iter(response:json())
      :filter(function(c)
        return type(c) == "string"
      end)
      :totable())
  end)
end

---@param key string
---@param callback fun(value: string | table | nil)
---@return vim.SystemObj
function configs:get(key, callback)
  return self.api:tinker(string.format("echo json_encode(config('%s'));", key), function (response)
    if response:failed() then
      callback(nil)
    end
    callback(response:json())
  end)
end

return configs
