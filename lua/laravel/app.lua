---@class laravel.app
---@field container laravel.container
---@field associations table
---@field facades table
local app = {}

local function get_args(func)
  local args = {}
  for i = 1, debug.getinfo(func).nparams, 1 do
    table.insert(args, debug.getlocal(func, i))
  end
  return args
end

function app:new(opts)
  local instance = {
    container = require("laravel.container"):new(),
    associations = {},
    facades = {},
  }
  setmetatable(instance, self)
  self.__index = self
  -- self.__index = function(t, k)
  --   return rawget(self, k) or instance:make(k)
  -- end
  self.__call = function(cls, abstract, args)
    return cls:make(abstract, args)
  end

  opts = vim.tbl_deep_extend("force", require("laravel.options.default"), opts or {})
  local opts_instance = require("laravel.services.options"):new(opts)
  instance:instance("options", opts_instance)
  instance:instance("laravel.services.options", opts_instance)

  return instance
end

function app:isActive()
  return self:make("env"):isActive()
end

function app:whenActive(callback)
  return function(...)
    if self:isActive() then
      callback(...)
    end
  end
end

function app:has(abstract)
  abstract = self.facades[abstract] or abstract
  return self.container:has(abstract)
end

function app:make(abstract, arguments)
  abstract = self.facades[abstract] or abstract
  if not self.container:has(abstract) then
    local ok, _ = pcall(require, abstract)
    if ok then
      self:bind(abstract, abstract)
    else
      error("Could not find " .. abstract)
    end
  end

  return self.container:get(abstract)(arguments)
end

function app:makeByTag(tag)
  return vim.tbl_map(function(element)
    return self:make(element)
  end, self.container:byTag(tag))
end

function app:associate(abstract, associations)
  self.associations[abstract] = vim.tbl_extend("force", self.associations[abstract] or {}, associations)
end

---@param alias string
---@param real string
function app:facade(alias, real)
  self.facades[alias] = real
end

---@param abstract string
---@param factory string|function
---@param opts table|nil
function app:bind(abstract, factory, opts)
  assert(type(factory) == "string" or type(factory) == "function", "Factory should be a string or a function")

  if type(factory) == "string" then
    factory = self:_createFactory(abstract, factory)
  end

  self.container:set(abstract, factory, opts)

  return self
end

---@param abstract string
---@param factory string|fun(app: laravel.app): any
---@param opts table|nil
function app:bindIf(abstract, factory, opts)
  if not self.container:has(abstract) then
    self:bind(abstract, factory, opts)
  end

  return self
end

---@param abstract string
---@param instance table
---@param opts table|nil
function app:instance(abstract, instance, opts)
  self.container:set(abstract, function()
    return instance
  end, opts)

  return self
end

---@param abstract string
---@param factory string|function|nil
---@param opts table|nil
function app:singelton(abstract, factory, opts)
  factory = factory or abstract
  assert(type(factory) == "string" or type(factory) == "function", "Factory should be a string or a function")

  if type(factory) == "string" then
    factory = self:_createFactory(abstract, factory)
  end

  self.container:set(abstract, function(arguments)
    local instance = factory(arguments)
    self.container:set(abstract, function()
      return instance
    end)

    return instance
  end, opts)
end

---@param abstract string
---@param factory string|function|nil
---@param opts table|nil
function app:singeltonIf(abstract, factory, opts)
  if not self.container:has(abstract) then
    self:singelton(abstract, factory, opts)
  end

  return self
end

function app:boot()
  local options = self:make("options"):get()
  local providers = options.providers
  local user_providers = options.user_providers

  local register = function(provider)
    if provider.register then
      provider:register(self)
    end
  end

  local boot = function(provider)
    if provider.boot then
      provider:boot(self)
    end
  end

  vim.tbl_map(register, providers)
  vim.tbl_map(register, user_providers)

  for extension, extension_options in pairs(options.extensions) do
    if extension_options.enable then
      local extension_provider = require("laravel.extensions." .. extension)
      if extension_provider.register then
        extension_provider:register(self, extension_options)
      end
    end
  end

  vim.tbl_map(boot, providers)
  vim.tbl_map(boot, user_providers)

  for extension, extension_options in pairs(options.extensions) do
    if extension_options.enable then
      local extension_provider = require("laravel.extensions." .. extension)
      if extension_provider.boot then
        extension_provider:boot(self, extension_options)
      end
    end
  end

  return self
end

function app:start()
  self:validate_instalation()
  return self:boot()
end

function app:validate_instalation()
  local plenary_ok, _ = pcall(require, "plenary")
  local async_ok, _ = pcall(require, "promise")
  local nui_ok, _ = pcall(require, "nui.popup")

  if not plenary_ok or not async_ok or not nui_ok then
    local errors = {}
    if not plenary_ok then
      table.insert(errors, "Plenary is required for Laravel, please install it")
    end
    if not async_ok then
      table.insert(errors, "Promise-async is required for Laravel, please install it")
    end
    if not nui_ok then
      table.insert(errors, "Nui is required for Laravel, please install it")
    end

    error(table.concat(errors, "\n"))
  end
end

function app:down()
  local providers = self:make("options"):get().providers
  local user_providers = self:make("options"):get().user_providers

  for _, provider in pairs(providers) do
    if provider.down then
      provider:down(self)
    end
  end

  for _, provider in pairs(user_providers) do
    if provider.down then
      provider:down(self)
    end
  end

  return self
end

function app:command(name, callback)
  self:bindIf(name .. "_command", function()
    local command = {
      command = name,
    }
    function command:handle(...)
      callback(...)
    end

    return command
  end, { tags = { "command" } })
end

--- PRIVATE FUNCTIONS

--- private usage not recomended
function app:_createFactory(abstract, moduleName)
  return function(arguments)
    local ok, module = pcall(require, moduleName)
    if not ok then
      error("Could not load module " .. moduleName)
    end

    local constructor = module.new

    if not constructor then
      return module
    end

    local injects = module._inject or {}

    local args = get_args(constructor)

    local params = vim.tbl_extend(
      "force",
      self.associations[abstract] or {},
      arguments or {}
    )

    if #args > 1 then
      table.remove(args, 1)
      local module_args = {}
      for k, v in pairs(args) do
        if params[v] then
          module_args[k] = params[v]
        elseif injects[v] then
          module_args[k] = self:make(injects[v])
        else
          if not self:has(v) then
            error(string.format("could not find %s for %s", v, abstract))
          end
          module_args[k] = self:make(v)
        end
      end

      return module:new(unpack(module_args))
    end

    return module:new()
  end
end

return app
