local nio = require("nio")
local Class = require("laravel.utils.class")

---@class laravel.actions.livewire_delete_action
---@field class laravel.services.class
---@field runner laravel.services.runner
---@field livewire laravel.services.livewire
local action = Class({
  class = "laravel.services.class",
  runner = "laravel.services.runner",
  livewire = "laravel.services.livewire",
}, { component = nil })

function action:check(bufnr)
  local cls, err = self.class:get(bufnr)
  if err then
    return false
  end

  local res, err = self.livewire:getName(cls.fqn)

  if err or res.version ~= 3 then
    return false
  end

  self.component = res.name

  return true
end

function action:format()
  return "Delete Component"
end

function action:run(bufnr)
  nio.run(function()
    self.runner:run("artisan", { "livewire:delete", self.component })
  end)
end

return action
