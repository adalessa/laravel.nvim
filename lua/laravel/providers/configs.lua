---@class LaravelConfigsProvider
---@field api LaravelApi
local configs = {}

function configs:new(api)
  local instance = setmetatable({}, { __index = configs })
  instance.api = api
  return instance
end

---@param callback fun(configs: Iter<string>)
---@return Job
function configs:get(callback)
  return self.api:tinker("json_encode(array_keys(Arr::dot(Config::all())));", function(response)
    if response:failed() then
      callback({})
    end

    callback(vim.iter(vim.json.decode(response:prettyContent())):filter(function(c)
      return type(c) == "string"
    end))
  end)
end

return configs
