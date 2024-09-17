---@class LarvelOverrideService
---@field api LaravelApi
---@field class LaravelClassService
local override = {}

function override:new(api, class)
  local instance = {
    api = api,
    class = class,
  }

  vim.fn.sign_define("LaravelOverwrite", { text = " ", texthl = "String" })

  setmetatable(instance, self)
  self.__index = self

  return instance
end

function override:handle(bufnr)
  local group = "laravel_overwrite"
  vim.fn.sign_unplace(group, { buffer = bufnr })

  self.class:get(bufnr, function(class)
    self.api:tinker(
      string.format(
        [[
          $r = new ReflectionClass('%s');
          echo collect($r->getMethods())
            ->filter(fn (ReflectionMethod $method) => $method->hasPrototype() && $method->class == $r->name)
            ->map(fn (ReflectionMethod $method) => [
                'name' => $method->getName(),
                'line' => $method->getStartLine(),
                'from_interface' => $method->getPrototype()->getDeclaringClass()->isInterface()
            ])
            ->values()
            ->toJson();
        ]],
        class.fqn
      ),
      vim.schedule_wrap(function(response)
        local methods = response:json()
        if not methods then
          return
        end

        vim.fn.sign_placelist(vim
          .iter(methods)
          :map(function(method)
            return {
              group = group,
              lnum = method.line,
              name = "LaravelOverwrite",
              buffer = bufnr,
            }
          end)
          :totable())
      end)
    )
  end)
end

return override
