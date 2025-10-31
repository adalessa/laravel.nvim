local nio = require("nio")
local Class = require("laravel.utils.class")

local action = Class({
  class = "laravel.services.class",
  runner = "laravel.services.runner",
  tinker = "laravel.services.tinker",
}, { component = nil })

function action:check(bufnr)
  local cls = self.class:get(bufnr)
  local res = self.tinker:text(string.format(
    [[
try {
    echo app(Livewire\Mechanisms\ComponentRegistry::class)
    ->getName("%s");
} catch (Throwable){
    echo "";
}]],
    cls.fqn
  ))

  if res ~= "" then
    self.component = vim.trim(res)
    return true
  end

  return false
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
