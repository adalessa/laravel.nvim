local snacks = require("snacks").picker
local format_entry = require("laravel.pickers.snacks.format_entry")
local common_actions = require("laravel.pickers.common.actions")
local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

---@class laravel.pickers.snacks.related
---@field related laravel.services.related
local related_picker = Class({
  related = "laravel.services.related",
})

function related_picker:run(opts)
  local relations, err = self.related:get(vim.api.nvim_get_current_buf())
  if err then
    return notify.error("Error loading related items: " .. err)
  end

  vim.schedule(function()
    snacks.pick(vim.tbl_extend("force", {
      title = "Related",
      items = vim
        .iter(relations)
        :map(function(item)
          return {
            value = item,
            text = string.format("%s %s %s", item.class, item.type, item.extra_information),
          }
        end)
        :totable(),

      format = format_entry.related,
      layout = {
        preview = false,
      },
      confirm = function(picker, item)
        picker:close()
        if item then
          common_actions.open_relation(item.value)
        end
      end,
    }, opts or {}))
  end)
end

return related_picker
