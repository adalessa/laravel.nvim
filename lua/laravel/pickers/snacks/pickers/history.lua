local snacks = require("snacks").picker
local format_entry = require("laravel.pickers.snacks.format_entry")

local history_picker = {}

function history_picker:new(history, runner)
  local instance = {
    history_provider = history,
    runner = runner,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function history_picker:run(opts)
  snacks.pick(vim.tbl_extend("force", {
    title = "Laravel Commands History",
    items = vim
      .iter(self.history_provider:get())
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
end

return history_picker
