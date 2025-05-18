return function(deps, callback)
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

      if callback then
        if type(callback) == "table" then
          for k, v in pairs(callback) do
            instance[k] = v
          end
        elseif type(callback) == "function" then
          callback(instance, ...)
        end
      end

      return instance
    end,
  }

  return m
end
