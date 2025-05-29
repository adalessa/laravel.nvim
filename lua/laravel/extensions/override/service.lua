local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")
local nio = require("nio")

---@class laravel.extensions.override.service
---@field tinker laravel.services.tinker
---@field class laravel.services.class
---@field sign_name string
local override = Class({
  tinker = "laravel.services.tinker",
  class = "laravel.services.class",
}, function(instance)
  instance.sign_name = "LaravelOverride"

  if vim.tbl_isempty(vim.fn.sign_getdefined(instance.sign_name)) then
    vim.fn.sign_define(instance.sign_name, { text = " ", texthl = "String" })
  end
end)

function override:handle(bufnr)
  local group = "laravel_overwrite"
  vim.fn.sign_unplace(group, { buffer = bufnr })

  nio.run(function()
    local class, err = self.class:get(bufnr)
    if err then
      return
    end

    local methods, err = self.tinker:json(string.format(
      [[
          $r = new ReflectionClass('%s');
          echo collect($r->getMethods())
            ->filter(fn (ReflectionMethod $method) => $method->hasPrototype() && $method->getFileName() == $r->getFileName())
            ->map(fn (ReflectionMethod $method) => [
                'name' => $method->getName(),
                'line' => $method->getStartLine(),
                'from_interface' => $method->getPrototype()->getDeclaringClass()->isInterface()
            ])
            ->values()
            ->toJson();
        ]],
      class.fqn
    ))

    if err then
      return notify.error("Error getting methods: " .. err)
    end

    vim.schedule(function()
      vim.fn.sign_placelist(vim
        .iter(methods)
        :map(function(method)
          return {
            group = group,
            lnum = method.line,
            name = self.sign_name,
            buffer = bufnr,
          }
        end)
        :totable())
    end)
  end)
end

return override
