--- Usage
--- config("some config")
--- config.get('some.config')
--- config.set('some.config', value)
--- config.set(<table>)

local configs = {}

local function get_config(property, default)
  if not property then
    return configs
  end

  local value = configs
  for _, seg in ipairs(vim.split(property, "%.")) do
    if type(value) ~= "table" then
      return default
    end
    value = value[seg]
  end

  return value or default
end

---@class laravel.services.config
local config = setmetatable({}, {
  __call = function(_, property, default)
    return get_config(property, default)
  end,
})

function config.set(property, value)
  if type(property) == "table" then
    for k, v in pairs(property) do
      configs[k] = v
    end
  else
    local segments = vim.split(property, "%.")
    local current = configs

    for i = 1, #segments - 1 do
      if not current[segments[i]] then
        current[segments[i]] = {}
      end
      current = current[segments[i]]
    end

    current[segments[#segments]] = value
  end
end

function config.get(property, default)
  return get_config(property, default)
end

return config
