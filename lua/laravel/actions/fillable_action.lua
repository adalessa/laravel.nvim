local Class = require("laravel.utils.class")
local nio = require("nio")

---@class laravel.actions.fillable_action
---@field model laravel.services.model
---@field info laravel.dto.model_response|nil
local action = Class({
  model = "laravel.services.model",
}, { info = nil })

---@async
function action:check(bufnr)
  local info, err = self.model:get(bufnr)
  if err then
    return false
  end
  self.info = info

  return true
end

function action:format()
  return "Fillable Fields"
end

---@async
function action:run(bufnr)
  -- does the class have a fillable property
  -- Get all the fields expect the created_at and updated_at and id
  local fields = vim
    .iter(self.info.model.attributes)
    :map(function(a)
      return a.name
    end)
    :filter(function(name)
      return not vim.tbl_contains({ "id", "created_at", "updated_at", "deleted_at" }, name)
    end)
    :map(function(a)
      return ([[        '%s',]]):format(a)
    end)
    :totable()
  table.insert(fields, 1, "    protected $fillable = [")
  table.insert(fields, "    ];")

  local property = vim.iter(self.info.class.properties):find(function(p)
    return p.name == "fillable"
  end)

  local insertRowStart = 0
  local insertRowEnd = 0
  if property then
    insertRowStart = property.position.start.row
    insertRowEnd = property.position.end_.row + 1
  else
    insertRowStart = self.info.class.position.start.row + 2
    insertRowEnd = insertRowStart
    table.insert(fields, "")
  end

  nio.api.nvim_buf_set_lines(bufnr, insertRowStart, insertRowEnd, false, fields)
end

return action
