local format_entry = require("laravel.pickers.snacks.format_entry")
local Class = require("laravel.utils.class")

local history_picker = Class({
  history_service = "laravel.services.history",
  runner = "laravel.services.runner",
})

function history_picker:run(opts)
  vim.schedule(function()
    Snacks.picker.pick(vim.tbl_extend("force", {
      title = "Laravel Commands History",
      items = vim
        .iter(self.history_service:get())
        :map(function(history_entry)
          return {
            value = history_entry,
            text = string.format("%s %s", history_entry.name, table.concat(history_entry.args, " ")),
          }
        end)
        :totable(),
      format = format_entry.history,
      preview = "none",
      layout = {
        preview = false,
      },
      confirm = function(picker, item)
        picker:close()
        if item then
          self.runner:run(item.value.name, item.value.args, item.value.opts)
        end
      end,
    }, opts or {}))
  end)
end

return history_picker
