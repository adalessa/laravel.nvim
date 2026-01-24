local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.services.livewire
---@field code laravel.services.code
local livewire = Class({
  code = "laravel.services.code",
}, {})

---@param className string
---@return {name: string}, laravel.error
function livewire:getName(className)
  local res, err = self.code:run(string.format(
    [[
    $c = "%s";
    if (class_exists("\Livewire\Mechanisms\ComponentRegistry") && app()->has("\Livewire\Mechanisms\ComponentRegistry")) {
      echo json_encode(["name" => app("\Livewire\Mechanisms\ComponentRegistry")->getName($c)]);
    } else if (app()->has('livewire.finder')) {
      echo json_encode(["name" => app('livewire.finder')->normalizeName($c)]);
    } else {
      echo json_encode(["name" => ""]);
    }
  ]],
    className
  ))

  if res.name == "" or res.name == className then
    return {}, Error:new(("Livewire component name not found for class: %s"):format(className))
  end

  return res, nil
end

return livewire
