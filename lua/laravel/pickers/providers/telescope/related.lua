local actions = require("laravel.pickers.providers.telescope.actions")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("laravel.pickers.providers.telescope.make_entry")
local pickers = require("telescope.pickers")

local related_picker = {}

function related_picker.run(opts, relations)
  pickers
    .new(opts or {}, {
      prompt_title = "Related Files",
      finder = finders.new_table({
        results = relations,
        entry_maker = make_entry.gen_from_model_relations(opts),
      }),
      sorter = conf.prefilter_sorter({
        sorter = conf.generic_sorter(opts or {}),
      }),
      attach_mappings = function(_, map)
        map("i", "<cr>", actions.open_relation)

        return true
      end,
    })
    :find()
end

return related_picker
