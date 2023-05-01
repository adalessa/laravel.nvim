local storage = {}

return {
  get = function(key, default)
    if storage[key] ~= nil then
      return storage[key]
    end

    if type(default) == "function" then
      return default()
    end
    return default
  end,
  set = function(key, value)
    storage[key] = value
    return value
  end,
  unset = function(key)
    storage[key] = nil
    return nil
  end,
  purge = function()
    storage = {}
  end
}
