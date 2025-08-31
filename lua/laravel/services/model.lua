local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

---@class laravel.dto.model
---@field class_info laravel.dto.class
---@field start number

---@class laravel.services.model
---@field class laravel.services.class
---@field tinker laravel.services.tinker
---@field api laravel.services.api
local model = Class({
  class = "laravel.services.class",
  tinker = "laravel.services.tinker",
  api = "laravel.services.api",
})

---@async
---@return laravel.dto.model, laravel.error
function model:getByBuffer(bufnr)
  local class, err = self.class:getByBuffer(bufnr)
  if err then
    return {}, Error:new("Error getting the class"):wrap(err)
  end

  local res, tinkerError = self.tinker:json(string.format(
    [[
      $r = new ReflectionClass("%s");
      $isModel = $r->isSubclassOf("Illuminate\Database\Eloquent\Model");
      echo json_encode([
        'is_model' => $isModel,
        'class_start' => $r->getStartLine(),
      ]);
    ]],
    class.fqn
  ))
  if tinkerError then
    return {}, Error:new("Failed to reflect class"):wrap(tinkerError)
  end

  if not res.is_model then
    return {}, Error:new("Class is not a model")
  end

  local info, infoError = self:info(class.fqn)
  if infoError then
    return {}, Error:new("Failed to get model info"):wrap(infoError)
  end

  info.start = res.class_start
  info.class_info = class

  return info
end

---@async
---@param fqn string
---@return laravel.dto.model, laravel.error
function model:info(fqn)
  local res, err = self.api:run("artisan", { "model:show", "--json", string.format("\\%s", fqn) })
  if err then
    return {}, Error:new("Failed to run artisan model:show"):wrap(err)
  end

  local info = res:json()
  if vim.tbl_isempty(info) then
    return {}, Error:new(("No model info found for %s"):format(fqn))
  end

  return info
end

return model
