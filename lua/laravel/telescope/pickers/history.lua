local conf = require("telescope.config").values
local actions = require("laravel.telescope.actions")
local finders = require("telescope.finders")
local historyService = require("laravel.services.history_service")
local pickers = require("telescope.pickers")

return function(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Laravel Command History",
      finder = finders.new_table({
        results = historyService:all(),
        ---@param history_entry HistoryRecord
        entry_maker = function(history_entry)
          return {
            value = history_entry,
            display = string.format("%s %s", history_entry.name, vim.fn.join(history_entry.args, " ")),
            ordinal = string.format("%s %s", history_entry.name, vim.fn.join(history_entry.args, " ")),
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
