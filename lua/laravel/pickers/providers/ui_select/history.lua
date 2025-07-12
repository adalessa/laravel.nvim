local Class = require("laravel.utils.class")
local notify = require("laravel.utils.notify")

local history_picker = Class({
  history_service = "laravel.services.history",
  runner = "laravel.services.runner",
})

function history_picker:run()
  local items = self.history_service:get()
  if #items == 0 then
    notify.warn("No history available")
    return
  end

  vim.ui.select(items, {
    prompt = "History",
    format_item = function(history_entry)
      return string.format("%s %s", history_entry.name, table.concat(history_entry.args, " "))
    end,
    kind = "history",
  }, function(command)
    if command ~= nil then
      self.runner:run(command.name, command.args, command.opts)
    end
  end)
end

return history_picker
