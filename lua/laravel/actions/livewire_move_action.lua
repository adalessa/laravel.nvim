local nio = require("nio")
local Class = require("laravel.utils.class")

---@class laravel.actions.livewire_move_action
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

  if err then
    return false
  end

  self.component = res.name

  return true
end

function action:format()
  return "Move Component"
end

function action:run(bufnr)
  nio.run(function()
    local name = nio.ui.input({ prompt = "New Component Name" })
    self.runner:run("artisan", { "livewire:move", self.component, name })
  end)
end

return action
