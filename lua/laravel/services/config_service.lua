local resolver = require("laravel.resolvers.cache")

---@class ConfigService
local ConfigService = {}

---@param key string
---@param onSuccess fun(config: any)
---@param onFailure fun(err: string)
function ConfigService:get(key, onSuccess, onFailure)
  resolver.configs.resolve(function(config)
    if vim.tbl_contains(vim.tbl_keys(config), key) then
      onSuccess(config[key])
    else
      onFailure("key not found in the config")
    end
  end, onFailure)
end

return ConfigService
