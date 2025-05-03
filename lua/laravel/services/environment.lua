local get_env = require("laravel.utils").get_env
local combine_tables = require("laravel.utils").combine_tables
local Environment = require("laravel.dto.environment")

---@param name string|nil
---@param envs table
---@return table|nil
local function find_env_by_name(name, envs)
  if not name then
    return nil
  end
  for _, env in ipairs(envs) do
    if env.name == name then
      return env
    end
  end

  return nil
end

---@class LaravelEnvironment
---@field environment Environment|nil
---@field options LaravelOptionsService
local environment = {}

function environment:new(options)
  local instance = {
    options = options,
    environment = nil,
  }
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function environment:boot()
  if vim.fn.filereadable("artisan") == 0 then
    self.environment = nil
    return
  end

  local opts = self.options:get('environments')
  if not opts then
    self.environment = nil
    return
  end

  if opts.env_variable then
    local environment_name = get_env(opts.env_variable)
    if environment_name then
      local env_opts = find_env_by_name(environment_name, opts.definitions)
      if env_opts then
        self.environment = Environment:new(env_opts)
        return
      end
      vim.notify(
        string.format(
          "Laravel environment '%s' not found availables are %s",
          environment_name,
          vim
            .iter(opts.definitions)
            :map(function(item)
              return item.name
            end)
            :join(", ")
        ),
        vim.log.levels.WARN,
        { title = "Laravel" }
      )
      self.environment = nil
      return
    end
  end

  if opts.auto_discover then
    for _, opt in ipairs(opts.definitions) do
      local env = Environment:new(opt)
      if env:check() then
        self.environment = env
        return
      end
    end
  end

  if opts.default then
    local env_opts = find_env_by_name(opts.default, opts.definitions)
    if env_opts then
      local env = Environment:new(env_opts)
      if env:check() then
        self.environment = env
        return
      end
    end
  end

  self.environment = nil
end

---@param name string
---@return string[]|nil
function environment:getExecutable(name)
  if not self.environment then
    return nil
  end

  if name == "artisan" then
    local exec = self.environment:executable("php")
    if not exec then
      return nil
    end

    return combine_tables(exec, { "artisan" })
  end

  return self.environment:executable(name)
end

function environment:isActive()
  return self.environment ~= nil
end

return environment
