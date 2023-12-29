local config = require "laravel.config"
local user_commands = require "laravel.user_commands"
local get_env = require("laravel.utils").get_env
local Environment = require "laravel.environment.environment"

local M = {}

M.environment = nil

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

---@return Environment|nil
local function resolve()
  local opts = config.options.environments

  if opts.env_variable then
    local env = find_env_by_name(get_env(opts.env_variable), opts.definitions)
    if env then
      return env
    end
  end

  if opts.auto_dicover then
    for _, opt in ipairs(opts.definitions) do
      local env = Environment:new(opt)
      if env:check() then
        return env
      end
    end
  end

  if opts.default then
    local env = find_env_by_name(opts.default, opts.definitions)
    if env then
      return env
    end
  end

  return nil
end

function M.setup()
  M.environment = nil
  if vim.fn.filereadable "artisan" == 0 then
    return
  end

  M.environment = resolve()

  if not M.environment then
    return
  end

  user_commands.setup()

  if config.options.features.route_info.enable then
    require("laravel.route_info").setup()
  end

  if config.options.features.null_ls.enable then
    require("laravel.null_ls").setup()
  end
end

---@param name string
---@return string[]|nil
function M.get_executable(name)
  if not M.environment then
    return nil
  end

  if name == "artisan" then
    return vim.fn.extend(M.environment:executable "php", { "artisan" })
  end

  return M.environment:executable(name)
end

return M
