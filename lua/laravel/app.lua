---@class LaravelApp
---@field container LaravelContainer
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
  }
  setmetatable(instance, self)
  self.__index = self
  self.__call = function(cls, abstract, args)
    return cls:make(abstract, args)
  end

  opts = vim.tbl_deep_extend("force", require("laravel.options.default"), opts or {})
  instance:instance("options", require("laravel.services.options"):new(opts))

  return instance
end

function app:make(abstract, arguments)
  if not self.container:has(abstract) then
    error("Could not find " .. abstract)
  end

  return self.container:get(abstract)(arguments)
end

function app:makeByTag(tag)
  return vim.tbl_map(function(element)
    return self:make(element)
  end, self.container:byTag(tag))
end

---@param abstract string
---@param factory string|function
---@param opts table|nil
function app:bind(abstract, factory, opts)
  assert(type(factory) == "string" or type(factory) == "function", "Factory should be a string or a function")

  if type(factory) == "string" then
    factory = self:_createFactory(factory)
  end

  self.container:set(abstract, factory, opts)

  return self
end

---@param abstract string
---@param factory string|function
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
---@param factory string|function
---@param opts table|nil
function app:singelton(abstract, factory, opts)
  assert(type(factory) == "string" or type(factory) == "function", "Factory should be a string or a function")

  if type(factory) == "string" then
    factory = self:_createFactory(factory)
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
---@param factory string|function
---@param opts table|nil
function app:singeltonIf(abstract, factory, opts)
  if not self.container:has(abstract) then
    self:singelton(abstract, factory, opts)
  end

  return self
end

function app:boot()
  local providers = self:make("options"):get().providers
  local user_providers = self:make("options"):get().user_providers

  for _, provider in pairs(providers) do
    if provider.register then
      provider:register(self)
    end
  end

  for _, provider in pairs(user_providers) do
    if provider.register then
      provider:register(self)
    end
  end

  for _, provider in pairs(providers) do
    if provider.boot then
      provider:boot(self)
    end
  end

  for _, provider in pairs(user_providers) do
    if provider.boot then
      provider:boot(self)
    end
  end

  return self
end

function app:start()
  return self:boot()
end

function app:down()
  local providers = self.container:get("options"):get().providers
  local user_providers = self.container:get("options"):get().user_providers

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

--- PRIVATE FUNCTIONS

--- private usage not recomended
function app:_createFactory(moduleName)
  return function(arguments)
    local ok, module = pcall(require, moduleName)
    if not ok then
      error("Could not load module " .. moduleName)
    end

    local constructor = module.new

    if not constructor then
      return module
    end

    local args = vim.tbl_extend("force", get_args(constructor), arguments or {})

    if #args > 1 then
      table.remove(args, 1)
      local module_args = {}
      for k, v in pairs(args) do
        module_args[k] = self:make(v)
      end

      return module:new(unpack(module_args))
    end

    return module:new()
  end
end

return app
