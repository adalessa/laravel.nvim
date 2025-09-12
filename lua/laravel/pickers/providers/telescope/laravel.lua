local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local laravel_picker = {}

function laravel_picker.run(opts, commands)
  pickers
    .new(opts or {}, {
      prompt_title = "Laravel commands",
      finder = finders.new_table({
        results = commands,
        entry_maker = function(command)
          return {
            value = command,
            display = command.signature,
            ordinal = command.signature,
          }
        end,
      }),
      sorter = conf.prefilter_sorter({
        sorter = conf.generic_sorter(opts or {}),
      }),
      attach_mappings = function(_, map)
        map("i", "<cr>", function(prompt_bufnr)
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          entry.value:handle()
        end)

        return true
      end,
    })
    :find()
end

return laravel_picker
