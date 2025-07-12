local format_entry = require("laravel.pickers.providers.snacks.format_entry")
local common_actions = require("laravel.pickers.common.actions")

local related_picker = {}

function related_picker.run(opts, relations)
  Snacks.picker.pick(vim.tbl_extend("force", {
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
end

return related_picker
