local get_env = require("laravel.utils.init").get_env
local combine_tables = require("laravel.utils.init").combine_tables

---@class laravel.dto.environment
---@field name string
---@field condition table|nil
---@field commands table
local Environment = {}

local cache = {}

---@param env table
---@return laravel.dto.environment
function Environment:new(env)
  local instance = {
    name = env.name,
    condition = env.condition or nil,
    commands = env.commands or {},
  }

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return boolean
function Environment:check()
  if not self.condition then
    return true
  end

  for _, file in pairs(self.condition.file_exists or {}) do
    if vim.fn.filereadable(file) ~= 1 then
      return false
    end
  end

  for _, exec in pairs(self.condition.executable or {}) do
    if vim.fn.executable(exec) == 0 then
      return false
    end
  end

  return true
end

---@param name string
---@return table|nil
function Environment:executable(name)
  if cache[name] then
    return cache[name]
  end

  -- check commands directly by name
  if self.commands[name] then
    cache[name] = self.commands[name]
    return cache[name]
  end

  for _, value in pairs(self.commands) do
    if vim.tbl_contains(value.commands or {}, name) then
      -- is on the list have to process it
      if value.docker then
        -- is set to run from docker
        if not value.docker.container then
          error(
            "Configuration indicates docker but there is no container information, check the configuration",
            vim.log.levels.ERROR
          )
        end

        local container = value.docker.container.default
        if value.docker.container.env and get_env(value.docker.container.env) then
          container = get_env(value.docker.container.env)
        end

        if not container then
          error("Could not resolve container name check the configuration", vim.log.levels.ERROR)
        end

        if not value.docker.exec then
          error("Need to define a docker exec command", vim.log.levels.ERROR)
        end

        cache[name] = combine_tables(value.docker.exec, { container, name })

        return cache[name]
      end

      if value.prefix then
        cache[name] = combine_tables(value.prefix, { name })

        return cache[name]
      end
    end
  end

  -- if is not define look for the executable in the system
  if vim.fn.executable(name) == 1 then
    cache[name] = { name }

    return { name }
  end

  return nil
end

return Environment
