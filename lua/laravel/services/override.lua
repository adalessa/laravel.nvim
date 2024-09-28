---@class LarvelOverrideService
---@field tinker Tinker
---@field class LaravelClassService
local override = {}

function override:new(tinker, class)
  local instance = {
    tinker = tinker,
    class = class,
  }

  vim.fn.sign_define("LaravelOverwrite", { text = " ", texthl = "String" })

  setmetatable(instance, self)
  self.__index = self

  return instance
end

---@return Promise
function override:handle(bufnr)
  local group = "laravel_overwrite"
  vim.fn.sign_unplace(group, { buffer = bufnr })

  return self.class
      :get(bufnr)
      :thenCall(function(class)
        return self.tinker:json(string.format(
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
      end)
      :thenCall(function(methods)
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
      :catch(function() end)
end

return override
