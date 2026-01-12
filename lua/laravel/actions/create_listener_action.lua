local nio = require("nio")
local Class = require("laravel.utils.class")

local action = Class({
  class_service = "laravel.services.class",
  runner = "laravel.services.runner",
}, { class = nil })

---@async
function action:check(bufnr)
  local class, err = self.class_service:getByBuffer(bufnr)
  if err then
    return false
  end
  self.class = class
  -- check the the namesspace contains the text Events
  local namespace = self.class.namespace

  return namespace:find("Events") ~= nil
end

function action:format()
  return "Create new Listener"
end

function action:run()
  nio.run(function()
    local event = self.class.class
    local listener = nio.ui.input({ prompt = "Listener Name: " })
    self.runner:run("artisan", { "make:listener", "-e", event, listener })
  end)
end

return action
