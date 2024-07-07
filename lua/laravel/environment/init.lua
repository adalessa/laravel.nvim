local get_env = require("laravel.utils").get_env
local Environment = require("laravel.environment.environment")

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
---@field options LaravelOptionsProvider
local environment = {}

---@return LaravelEnvironment
function environment:new(options)
  local instance = setmetatable({}, { __index = environment })
  instance.environment = nil
  instance.options = options
  return instance
end

function environment:boot()
  if vim.fn.filereadable("artisan") == 0 then
    self.environment = nil
    return
  end

  local opts = self.options:get().environments

  if opts.env_variable then
    local env_opts = find_env_by_name(get_env(opts.env_variable), opts.definitions)
    if env_opts then
      self.environment = Environment:new(env_opts)
      return
    end
  end

  if opts.auto_dicover then
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
function environment:get_executable(name)
  if not self.environment then
    return nil
  end

  if name == "artisan" then
    return vim.fn.extend(self.environment:executable("php"), { "artisan" })
  end

  return self.environment:executable(name)
end

function environment:is_active()
  return self.environment ~= nil
end

return environment
