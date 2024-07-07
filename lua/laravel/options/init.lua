---@class LaravelOptionsProvider
local options = {}

function options:new()
  local instance = setmetatable({}, { __index = options })
  instance.opts = require("laravel.options.default")
  return instance
end

---@param opt LaravelOptions
function options:set(opt)
  self.opts = vim.tbl_deep_extend("force", {}, self.opts, opt or {})
end

---@return LaravelOptions
function options:get()
  return self.opts
end

return options
