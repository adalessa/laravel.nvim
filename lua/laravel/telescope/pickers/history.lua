local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local finders = require "telescope.finders"
local history = require "laravel.history"
local pickers = require "telescope.pickers"
local run = require "laravel.run"

return function(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Laravel Command History",
      finder = finders.new_table {
        results = history.all(),
        entry_maker = function(history_entry)
          return {
            value = history_entry,
            display = string.format("%s %s", history_entry.name, vim.fn.join(history_entry.args, " ")),
            ordinal = string.format("%s %s", history_entry.name, vim.fn.join(history_entry.args, " ")),
          }
        end,
      },
      previewer = false,
      sorter = conf.prefilter_sorter {
        sorter = conf.generic_sorter(opts or {}),
      },
      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          run(entry.value.name, entry.value.args, entry.value.opts)
        end)

        return true
      end,
    })
    :find()
end
