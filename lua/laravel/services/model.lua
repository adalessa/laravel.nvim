local Class = require("laravel.utils.class")

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
function model:getByBuffer(bufnr)
  local class, err = self.class:get(bufnr)
  if err then
    return {}, "Error getting the class: " .. err
  end

  local res, err = self.tinker:json(string.format(
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
  if err then
    return {}, "Error on reflection of class: " .. err
  end

  if not res.is_model then
    return {}, "Class is not a model"
  end

  local info, err = self:info(class.fqn)
  if err then
    return {}, "Error getting model info: " .. err
  end

  info.start = res.class_start
  info.class_info = class

  return info
end

---@async
---@param fqn string
---@return laravel.dto.model, string?
function model:info(fqn)
  local res, err = self.api:run("artisan", { "model:show", "--json", string.format("\\%s", fqn) })
  if err then
    return {}, "Error running artisan model:show: " .. err
  end

  local info = res:json()
  if vim.tbl_isempty(info) then
    return {}, "No model info found for " .. fqn
  end

  return info
end

return model
