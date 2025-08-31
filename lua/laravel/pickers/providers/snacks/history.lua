local format_entry = require("laravel.pickers.providers.snacks.format_entry")

local history_picker = {}

function history_picker.run(opts, history_items)
  Snacks.picker.pick(vim.tbl_extend("force", {
    title = "Laravel Commands History",
    items = vim
      .iter(history_items)
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
        Laravel.run(item.value.name, item.value.args, item.value.opts)
      end
    end,
  }, opts or {}))
end

return history_picker
