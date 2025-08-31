---@class laravel.core.app
---@field container laravel.core.container
local app = setmetatable({
  container = require("laravel.core.container"):new(),
}, {
  __call = function(cls, abstract, args)
    return cls:make(abstract, args)
  end,
})

function app:start(opts)
  self:validateInstalation()
  self:bootstrap(opts)

  return self
end

function app:bootstrap(opts)
  require("laravel.core.bootstrap"):bootstrap(self, opts)
end

function app:validateInstalation()
  require("laravel.core.validation"):validate()
end

-- status
function app:isActive()
  return self:make("laravel.core.env"):isActive()
end

function app:whenActive(callback)
  return function(...)
    if self:isActive() then
      return callback(...)
    end
  end
end

-- helper
function app:addCommand(module, concrete)
  self:bind(module, concrete or module, { tags = { "laravel.command" } })
end

-- Binding
function app:bind(abstract, concrete, opts)
  self.container:set(abstract, require("laravel.core.factory"):createConcrete(self, concrete), opts)
end

function app:singleton(abstract, concrete, opts)
  self.container:set(abstract, function(...)
    local instance = require("laravel.core.factory"):createConcrete(self, concrete or abstract)(...)
    self.container:set(abstract, function()
      return instance
    end, opts)

    return instance
  end, opts)
end

-- Conditionals
function app:bindIf(abstract, ...)
  if not self.container:has(abstract) then
    self:bind(abstract, ...)
  end
end

function app:singletonIf(abstract, ...)
  if not self.container:has(abstract) then
    self:singleton(abstract, ...)
  end
end

function app:alias(alias, abstract)
  local aliases = self.container:get("aliases") or {}
  aliases[alias] = abstract
  self.container:set("aliases", aliases)
end

-- Creation
function app:make(abstract, argument)
  local aliases = self.container:get("aliases") or {}
  abstract = aliases[abstract] or abstract

  local instance = self.container:get(abstract)
  if instance ~= nil then
    return instance(argument)
  end

  return require("laravel.core.factory"):create(self, abstract)(argument)
end

function app:makeByTag(tag)
  return vim.tbl_map(function(element)
    return self:make(element)
  end, self.container:byTag(tag))
end

return app
