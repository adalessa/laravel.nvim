local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("laravel.pickers.telescope.actions")

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

  pickers
    .new(opts, {
      prompt_title = "Laravel Command History",
      finder = finders.new_table({
        results = self.history_provider:get(),
        entry_maker = function(history_entry)
          return {
            value = history_entry,
            display = string.format("%s %s", history_entry.name, table.concat(history_entry.args, " ")),
            ordinal = string.format("%s %s", history_entry.name, table.concat(history_entry.args, " ")),
          }
        end,
      }),
      previewer = false,
      sorter = conf.prefilter_sorter({
        sorter = conf.generic_sorter(opts or {}),
      }),
      attach_mappings = function(_, map)
        map("i", "<cr>", actions.re_run_command)

        return true
      end,
    })
    :find()
end

return history_picker
