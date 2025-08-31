local actions = require("laravel.pickers.common.actions")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.ui_select.related
---@field related laravel.services.related
local related_picker = Class({
  related = "laravel.services.related",
})

function related_picker:run()
  local relations, err = self.related:get(vim.api.nvim_get_current_buf())
  if err then
    return notify.error("Error loading related items: " .. err)
  end

  vim.schedule(function()
    vim.ui.select(relations, {
      prompt = "Related Files",
      format_item = function(relation)
        return relation.class .. " " .. relation.extra_information
      end,
      kind = "make",
    }, function(resource)
      if resource ~= nil then
        actions.open_relation(resource)
      end
    end)
  end)
end

return related_picker
