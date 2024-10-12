local app = require("laravel").app

local history_picker = {}

function history_picker:new(history)
  local instance = {
    history_provider = history,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function history_picker:run(opts)
  opts = opts or {}

  vim.ui.select(self.history_provider:get(), {
    prompt = "History",
    format_item = function(history_entry)
      return string.format("%s %s", history_entry.name, table.concat(history_entry.args, " "))
    end,
    kind = "history",
  }, function(command)
    if command ~= nil then
      app("runner"):run(command.name, command.args, command.opts)
    end
  end)
end

return history_picker
