---@param deps table<string, string>|nil
---@param default table|function|nil
return function(deps, default)
  deps = deps or {}
  local m = {
    _inject = deps,
    new = function(self, ...)
      local instance = {}
      local params = { ... }

      for k, v in ipairs(vim.tbl_keys(deps)) do
        instance[v] = params[k]
      end

      setmetatable(instance, self)
      self.__index = self

      if default then
        if type(default) == "table" then
          for k, v in pairs(default) do
            if not instance[k] then
              instance[k] = v
            end
          end
        elseif type(default) == "function" then
          default(instance, ...)
        end
      end

      return instance
    end,
  }

  return m
end
